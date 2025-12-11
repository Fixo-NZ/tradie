import 'dart:io';
import 'package:http/http.dart' as http;

class LicenseUploadApiService {
  static const String baseUrl = "http://192.168.4.134:8000/api/tradie";

  static const String token =
      "7|XULoPEKfwdg3MrihDS7AcKfx55OEOXezA5KSyXNNc7d32ead";

  /// Upload a single license or ID file
  Future<Map<String, dynamic>> uploadLicenseFile({
    required File file,
    required String fileType, // 'license' or 'id'
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/profile-setup/licenses');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['file_type'] = fileType;

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
      ));

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      print("🔹 License Upload Response: $responseBody");

      return {
        'success': streamedResponse.statusCode == 200,
        'body': responseBody,
      };
    } catch (e) {
      return {
        'success': false,
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
