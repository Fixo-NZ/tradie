import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../core/constants/api_constants.dart';


class ProfileService {
  final Dio _dio;

  ProfileService([Dio? dio]) : _dio = dio ?? Dio();

  /// Uploads [image] as multipart under form key `avatar`.
  /// If [token] is provided, it will be sent in the Authorization header.
  Future<Response> uploadAvatar(File image, {String? token}) async {
    final filename = image.path.split(Platform.pathSeparator).last;
    final isJpg = filename.toLowerCase().endsWith('.jpg') || filename.toLowerCase().endsWith('.jpeg');
    final isPng = filename.toLowerCase().endsWith('.png');
    final contentType = isPng ? 'image/png' : (isJpg ? 'image/jpeg' : 'image/jpeg');

    final form = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        image.path,
        filename: filename,
        contentType: MediaType.parse(contentType),
      ),
    });

    final options = Options(
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      contentType: 'multipart/form-data',
    );

    final url = '${ApiConstants.baseUrl}${ApiConstants.uploadAvatarEndpoint}';
    print('Uploading to URL: $url');
    
    return _dio.post(url, data: form, options: options);
  }
}
