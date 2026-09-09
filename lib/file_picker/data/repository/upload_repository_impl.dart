import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterpractisetasks/file_picker/core/utils/file_hash_util.dart';
import 'package:flutterpractisetasks/file_picker/data/datasources/upload_provider.dart';
import 'package:flutterpractisetasks/file_picker/data/repository/upload_repository.dart';
import 'package:flutterpractisetasks/file_picker/models/queue_result.dart';
import 'package:flutterpractisetasks/file_picker/models/upload_task.dart';
import 'package:flutterpractisetasks/file_picker/models/upload_result.dart';
import 'package:flutterpractisetasks/file_picker/services/localstorage/localdb.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class UploadRepositoryImpl implements UploadRepository {
  final UploadLocaldb localDb;
  final UploadProvider primary;
  final UploadProvider fallback;

  UploadRepositoryImpl({
    required this.localDb,
    required this.primary,
    required this.fallback,
  });

  // Dùng cho sự kiện pause/ resume
  final Set<String> _pauseRequestedTasks = {};
  final Map<String, CancelToken> _cancelTokens = {};
  // InvalidMime
  static const int _maxSizeBytes = 32 * 1024 * 1024;

  QueueRejectReason? _validateFile(File file) {
    final mimeType = lookupMimeType(file.path);
    if (mimeType == null || !mimeType.startsWith('image/')) {
      return QueueRejectReason.invalidMimeType;
    }

    final sizeBytes = file.lengthSync();
    if (sizeBytes > _maxSizeBytes) {
      return QueueRejectReason.tooLarge;
    }

    return null;
  }

  @override
  Future<bool> pauseUpload(String taskId) async {
    final cancelToken = _cancelTokens[taskId];

    debugPrint('[Repository] Pause task=$taskId');
    debugPrint('[Repository] Token tồn tại=${cancelToken != null}');

    if (cancelToken == null) {
      return false;
    }

    debugPrint('[Repository] Trước cancel: ${cancelToken.isCancelled}');

    if (cancelToken.isCancelled) {
      return false;
    }

    _pauseRequestedTasks.add(taskId);
    cancelToken.cancel('Upload paused');

    debugPrint('[Repository] Sau cancel: ${cancelToken.isCancelled}');

    return true;
  }

  @override
  Future<bool> resumeUpload(String taskId) async {
    return true;
  }

  @override
  Future<void> cancelUpload(String taskId) async {
    final cancelToken = _cancelTokens[taskId];
    if (cancelToken == null || cancelToken.isCancelled) {
      return;
    }
    _pauseRequestedTasks.remove(taskId);
    _cancelTokens[taskId]?.cancel('Người dùng hủy upload.');
  }

  Future<String> _persistFile(File sourceFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/upload_media');
    if (!await mediaDir.exists()) await mediaDir.create(recursive: true);

    final ext = p.extension(sourceFile.path);
    final newPath = '${mediaDir.path}/${const Uuid().v4()}$ext';
    await sourceFile.copy(newPath);
    return newPath;
  }

  // Lấy file(task) theo id
  @override
  Future<UploadModel?> getTaskById(String id) async {
    final task = await localDb.getTaskById(id);
    return task;
  }
  // Lấy danh sách tasks( file ) đã hoàn tất upload

  @override
  Future<List<UploadModel>?> getCompletedTasks({
    required int limit,
    required int offset,
  }) async {
    final tasks = await localDb.getCompletedTasks(limit: limit, offset: offset);

    return tasks;
  }

  @override
  Future<QueueResult> addFileToQueue(File file) async {
    // validate trước
    final rejectReason = _validateFile(file);
    if (rejectReason != null) {
      return QueueResult.rejected(rejectReason);
    }

    // Hash file
    final hash = await FileHashUtil.hashFile(file.path);
    final existing = await localDb.findByHash(hash);

    if (existing != null && existing.status == UploadStatus.done) {
      return QueueResult.rejected(
        QueueRejectReason.duplicate,
      ); // đã upload rồi -> không thêm nữa
    }

    final persistentPath = await _persistFile(file);

    final task = UploadModel(
      id: const Uuid().v4(),
      filePath: persistentPath,
      fileHash: hash,
      status: UploadStatus.pending,
      progress: 0.0,
      retryCount: 1,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await localDb.addUploadTask(item: task);
    return QueueResult.success(task);
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
  @override
  Future<UploadResult> uploadTask(
    UploadModel task, {
    void Function(double percent)? onProgress,
  }) async {
    final cancelToken = CancelToken();

    // Đăng ký token cho task đang upload.
    _cancelTokens[task.id] = cancelToken;

    try {
      await localDb.updateStatus(id: task.id, status: UploadStatus.uploading);

      final file = File(task.filePath);

      try {
        // ================= PRIMARY =================

        final result = await primary.upload(
          file,
          onProgress: onProgress,
          cancelToken: cancelToken,
        );

        await _handleSuccess(task, result);

        return result;
      } on DioException catch (primaryError) {
        // Pause hoặc Cancel trong lúc primary upload.
        if (CancelToken.isCancel(primaryError)) {
          return await _handleUploadInterrupted(
            task,
            providerUsed: primary.name,
          );
        }

        final primaryStatusCode = primaryError.response?.statusCode;

        if (primaryStatusCode != null && primaryStatusCode >= 400) {
          try {
            // ================= FALLBACK =================

            final result = await fallback.upload(
              file,
              onProgress: onProgress,
              cancelToken: cancelToken,
            );

            await _handleSuccess(task, result);

            return result;
          } on DioException catch (fallbackError) {
            // Pause hoặc Cancel trong lúc fallback upload.
            if (CancelToken.isCancel(fallbackError)) {
              return await _handleUploadInterrupted(
                task,
                providerUsed: fallback.name,
              );
            }

            final fallbackStatusCode = fallbackError.response?.statusCode;

            if (fallbackStatusCode == null) {
              // Không có status code:
              // mất mạng, DNS, timeout...
              await localDb.updateStatus(
                id: task.id,
                status: UploadStatus.pending,
              );

              rethrow;
            }

            // Primary và fallback đều trả về lỗi HTTP.
            await localDb.updateStatus(
              id: task.id,
              status: UploadStatus.failed,
            );

            return UploadResult(
              success: false,
              providerUsed: ProviderType.bothFailed,
            );
          }
        }

        // Primary lỗi nhưng không có HTTP status:
        // mất mạng, DNS, timeout...
        await localDb.updateStatus(id: task.id, status: UploadStatus.pending);

        rethrow;
      }
    } finally {
      // Chỉ cần dọn tại một nơi duy nhất.
      _cancelTokens.remove(task.id);
      _pauseRequestedTasks.remove(task.id);
    }
  }

  // Xử lý khi upload bị pause hoặc cancel
  Future<UploadResult> _handleUploadInterrupted(
    UploadModel task, {
    required ProviderType providerUsed,
  }) async {
    final isPaused = _pauseRequestedTasks.remove(task.id);

    if (isPaused) {
      // Pause thì giữ task trong database.
      await localDb.updateStatus(id: task.id, status: UploadStatus.paused);
    } else {
      // Cancel thì xóa task theo logic hiện tại của bạn.
      await _deleteTaskCompletely(task);

      // Nếu muốn giữ task cancelled trong DB thì dùng:
      //
      // await localDb.updateStatus(
      //   id: task.id,
      //   status: UploadStatus.cancelled,
      // );
    }

    return UploadResult(success: false, providerUsed: providerUsed);
  }

  Future<void> _deleteTaskCompletely(UploadModel task) async {
    await localDb.deleteUploadTask(id: task.id);
    final file = File(task.filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _handleSuccess(UploadModel task, UploadResult result) async {
    final updated = task.copyWith(
      status: UploadStatus.done,
      remoteUrl: result.url,
      width: result.width,
      height: result.height,
      sizeBytes: result.sizedByte,
      progress: 1.0,
    );
    await localDb.updateTask(id: task.id, item: updated);
    await localDb.addHistory(item: updated);
  }

  // Lưu history
  Future<bool> saveHistory(UploadModel item) async {
    try {
      await localDb.addHistory(item: item);
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
