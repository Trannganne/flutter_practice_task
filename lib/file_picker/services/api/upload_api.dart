import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterpractisetasks/file_picker/models/upload_task.dart';

class Uploadapi {
  static final apiKey = dotenv.env['FREEIMAGE_API_KEY'];
  static final Dio _dio = Dio();

  Future<void> uploadFile(UploadModel task, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          task.filePath,
          filename: fileName,
        ),
      });
      final response = await _dio.post(
        'https://api.imgbb.com/1/upload',
        data: formData,
        onSendProgress: (int sent, int total) {
          final percent = (sent / total * 100).toStringAsFixed(0);
          print(percent);
        },
      );

      // Lấy response
      final data = response.data['data'] as Map<String, dynamic>;
      final remoteUrl = data['url'] as String;

      final updatedTask = task.copyWith(
        status: UploadStatus.done,
        remoteUrl: remoteUrl,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
    } on DioException catch (e) {
      print("URI: ${e.requestOptions.uri}");
      print("Status: ${e.response?.statusCode}");
      print("Body: ${e.response?.data}");
      rethrow;
    }
  }
}
