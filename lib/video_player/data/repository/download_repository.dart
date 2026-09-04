import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';
import 'cache_metadata_repository.dart';

/// Tải file video THẬT về máy khi user bấm nút Download.
///
/// Đây là nơi DUY NHẤT trong module Video Explorer ghi file nhị phân
/// xuống disk. VideoMetadataCacheRepository.saveAll() chỉ lưu link
/// stream + info hiển thị (metadata-only) — video chỉ có file thật khi
/// user bấm Download tường minh.
class DownloadRepository {
  final Dio _dio;
  final VideoMetadataCacheRepository _metadataRepo;

  DownloadRepository({Dio? dio, VideoMetadataCacheRepository? metadataRepo})
    : _dio = dio ?? Dio(),
      _metadataRepo = metadataRepo ?? VideoMetadataCacheRepository();

  /// Tải source ĐẦU TIÊN trong videoSources (chất lượng cao nhất, đã sắp
  /// giảm dần từ mapper) về thư mục Documents của app, rồi ghi
  /// localFilePath vào cache metadata để VideoEntity.isDownloaded = true.
  Future<String> download({
    required VideoEntity video,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (video.videoSources.isEmpty) {
      throw Exception('Video không có nguồn phát để tải.');
    }

    final dir = await getApplicationDocumentsDirectory();
    final videosDir = Directory('${dir.path}/downloaded_videos');
    debugPrint("Đường dẫn:  ${dir.path}");
    await videosDir.create(recursive: true);

    final ext = _extractExtension(video.videoSources.first);
    // Tên file theo source+id — không đụng độ giữa Pexels/Pixabay dù 2 API
    // có thể trùng số id.
    final savePath = '${videosDir.path}/${video.source.name}_${video.id}$ext';
    debugPrint("Đường dẫn:  $savePath");
    await _dio.download(
      video.videoSources.first,
      savePath,
      onReceiveProgress: onProgress,
      cancelToken: cancelToken,
    );

    await _metadataRepo.markDownloaded(video.id, video.source, savePath);
    return savePath;
  }

  /// Xoá file thật khỏi disk + gỡ cờ "đã tải" trong cache metadata.
  /// Idempotent — không throw nếu file đã bị xoá thủ công từ trước.
  Future<void> deleteDownload(VideoEntity video) async {
    final path = video.localFilePath;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _metadataRepo.clearDownload(video.id, video.source);
  }

  String _extractExtension(String url) {
    final path = Uri.tryParse(url)?.path ?? url;
    final dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) return '.mp4';
    return path.substring(dot).split('?').first;
  }
}
