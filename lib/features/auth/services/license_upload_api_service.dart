import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

class LicenseUploadApiService {
  // Use shared baseUrl from ApiConstants
  String get _baseUrl => ApiConstants.baseUrl;
  
  // DO NOT REMOVE: Get token from secure storage (set during login)
  Future<String> _getToken() async {
    return await DioClient.instance.getToken() ?? '';
  }

  /// Upload a single license or ID file
  Future<Map<String, dynamic>> uploadLicenseFile({
    required File file,
    required String fileType, // 'license' or 'id'
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiConstants.licenseUploadEndpoint}');
      final request = http.MultipartRequest('POST', uri);

      // DO NOT REMOVE: Get token from secure storage
      final token = await _getToken();
      
      // Log request details
      final tokenMasked = token.length > 10 ? '${token.substring(0, 10)}...' : token;
      final fileSize = await file.length();
      print('License Upload:');
      print('URL: $uri');
      print('File: ${file.path} ($fileSize bytes)');
      print('Type: $fileType');
      print('Token: $tokenMasked');

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['file_type'] = fileType;

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
      ));

      print('⏳ Sending request...');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60), // 60 second timeout for large files
        onTimeout: () {
          print('Upload timeout - server took too long to respond');
          throw TimeoutException('Upload timeout after 60 seconds');
        },
      );

      print('Reading response...');
      final responseBody = await streamedResponse.stream.bytesToString();

      print('Response Status: ${streamedResponse.statusCode}');
      print('Response Body: $responseBody');

      final isSuccess = streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201;
      
      // Parse JSON response
      dynamic parsedBody;
      try {
        parsedBody = jsonDecode(responseBody);
      } catch (_) {
        parsedBody = responseBody;
      }

      // Check if backend explicitly returned success flag
      final backendSuccess = (parsedBody is Map && parsedBody['success'] == true) || isSuccess;

      return {
        'success': backendSuccess,
        'statusCode': streamedResponse.statusCode,
        'body': parsedBody,
      };
    } catch (e) {
      print('License Upload Error: $e');
      return {
        'success': false,
        'statusCode': 0,
        'error': e.toString(),
      };
    }
  }

  /// Submit all license and ID documents
  Future<Map<String, dynamic>> submitLicenseDocuments({
    required List<File> licenseFiles,
    required List<File> idFiles,
  }) async {
    try {
      // Upload all license files
      for (final file in licenseFiles) {
        final result = await uploadLicenseFile(file: file, fileType: 'license');
        if (!result['success']) {
          return result;
        }
      }

      // Upload all ID files
      for (final file in idFiles) {
        final result = await uploadLicenseFile(file: file, fileType: 'id');
        if (!result['success']) {
          return result;
        }
      }

      return {
        'success': true,
        'message': 'All documents uploaded successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
