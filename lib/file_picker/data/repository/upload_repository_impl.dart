import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterpractisetasks/file_picker/core/utils/file_hash_util.dart';
import 'package:flutterpractisetasks/file_picker/data/datasources/upload_provider.dart';
import 'package:flutterpractisetasks/file_picker/data/repository/upload_repository.dart';
import 'package:flutterpractisetasks/file_picker/models/upload_task.dart';
import 'package:flutterpractisetasks/file_picker/models/uploadresult.dart';
import 'package:flutterpractisetasks/file_picker/services/localstorage/localdb.dart';
import 'package:uuid/uuid.dart';

class UploadRepositoryImpl implements UploadRepository {
  final UploadLocaldb localDb;
  final UploadProvider primary;
  final UploadProvider fallback;

  UploadRepositoryImpl({
    required this.localDb,
    required this.primary,
    required this.fallback,
  });
  // Lấy danh sách tasks( file ) đã hoàn tất upload

  @override
  Future<List<UploadModel>?> getCompletedTasks() async {
    final tasks = await localDb.getCompletedTasks();

    return tasks;
  }

  @override
  Future<UploadModel?> addFileToQueue(File file) async {
    final hash = await FileHashUtil.hashFile(file.path);
    final existing = await localDb.findByHash(hash);

    if (existing != null && existing.status == UploadStatus.success) {
      return null; // đã upload rồi -> không thêm nữa
    }

    final task = UploadModel(
      id: const Uuid().v4(),
      filePath: file.path,
      fileHash: hash,
      status: UploadStatus.pending,
      progress: 0.0,
      retryCount: 1,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await localDb.addUploadTask(item: task);
    return task;
  }

  @override
  Future<List<UploadModel>> resumePendingQueue() async {
    final tasks = await localDb.getUploadingOrPending();
    final updated = <UploadModel>[];

    // Task nào đang 'uploading' mà thấy được lúc khởi động app
    // nghĩa là app đã bị kill giữa chừng -> reset về pending
    for (final task in tasks) {
      if (task.status == UploadStatus.uploading) {
        await localDb.updateStatus(id: task.id, status: UploadStatus.pending);
        updated.add(task.copyWith(status: UploadStatus.pending));
      } else {
        updated.add(task);
      }
    }
    return updated;
  }

  // upload task
  @override
  Future<UploadResult> uploadTask(
    UploadModel task, {
    void Function(double percent)? onProgress,
  }) async {
    await localDb.updateStatus(id: task.id, status: UploadStatus.uploading);
    final file = File(task.filePath);
    try {
      final result = await primary.upload(file, onProgress: onProgress);
      await _handleSuccess(task, result);
      return result;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      if (statusCode != null && statusCode >= 400) {
        try {
          final result = await fallback.upload(file, onProgress: onProgress);
          await _handleSuccess(task, result);
          return result;
        } on DioException {
          await localDb.updateStatus(id: task.id, status: UploadStatus.failed);
          return UploadResult(
            success: false,
            providerUsed: ProviderType.bothFailed,
          );
        }
      }
      // Mất mạng thật sự -> quay về pending, không fallback
      await localDb.updateStatus(id: task.id, status: UploadStatus.pending);
      rethrow;
    }
  }

  Future<void> _handleSuccess(UploadModel task, UploadResult result) async {
    final updated = task.copyWith(
      status: UploadStatus.success,
      remoteUrl: result.url,
      width: result.width,
      height: result.height,
      sizeBytes: result.sizedByte,
    );
    await localDb.updateStatus(id: task.id, status: task.status);
    await localDb.addHistory(item: updated);
  }

  // Lưu history
  Future<bool> saveHistory(UploadModel item) async {
    try {
      await UploadLocaldb().addHistory(item: item);
      return true;
    } catch (e) {
      debugPrint('Lỗi khi thêm lịch sử: $e ');
      return false;
    }
  }

  @override
  Future<List<UploadModel>> getHistory() async {
    final tasks = await localDb.getHistory();

    return tasks;
  }
}
