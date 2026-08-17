import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterpractisetasks/file_picker/models/upload_task.dart';
import 'package:flutterpractisetasks/file_picker/models/uploadresult.dart';

abstract class UploadProvider {
  ProviderType get name;
  Future<UploadResult> upload(
    File file, {
    void Function(double percent)? onProgress,
    CancelToken? cancelToken,
  });
}

class ImgBBProvider implements UploadProvider {
  @override
  ProviderType get name => ProviderType.imgBB;

  @override
  Future<UploadResult> upload(
    File file, {
    void Function(double percent)? onProgress,
    CancelToken? cancelToken, // Trường hợp hủy upload
  }) async {
    final apiKey = dotenv.env['IMGBB_API_KEY'];
    final dio = Dio();
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(file.path),
    });
    final response = await dio.post(
      'https://api.imgbb.com/1/upload?key=$apiKey',
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
      cancelToken: cancelToken,
    );
    final imageData = response.data['data'];

    return UploadResult(
      success: true,
      providerUsed: name,
      url: imageData['url'],
      height: imageData['height'],
      width: imageData['width'],
      sizedByte: imageData['size'],
    );
  }
}

class FreeImageProvider implements UploadProvider {
  final apiKey = dotenv.env['FREEIMAGE_API_KEY'];
  @override
  ProviderType get name => ProviderType.freeimage;

  @override
  Future<UploadResult> upload(
    File file, {
    void Function(double percent)? onProgress,

    // Trong trường hợp hủy upload
    CancelToken? cancelToken,
  }) async {
    final dio = Dio();

    final formData = FormData.fromMap({
      'source': await MultipartFile.fromFile(file.path),
    });

    final response = await dio.post(
      'https://freeimage.host/api/1/upload?key=$apiKey&format=json',
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
      cancelToken: cancelToken,
    );
    final imageData = response.data['image'];
    return UploadResult(
      success: true,
      providerUsed: name,
      url: imageData['url'],
      height: imageData['height'],
      width: imageData['width'],
      sizedByte: imageData[''],
    );
  }
}
