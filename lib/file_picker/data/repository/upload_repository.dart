import 'dart:io';

import 'package:flutterpractisetasks/file_picker/models/queue_result.dart';
import 'package:flutterpractisetasks/file_picker/models/upload_task.dart';
import 'package:flutterpractisetasks/file_picker/models/upload_result.dart';

abstract class UploadRepository {
  // Đọc queue lúc app khởi động, reset uploading đang kẹt sang pending
  Future<List<UploadModel>> resumePendingQueue();

  // Upload 1 task: gọi provider chính, fallback provider khác nếu lỗi 4xx/ 5xx
  // tự cập nhật status => lưu history khi có kết quả
  Future<UploadResult> uploadTask(
    UploadModel task, {
    void Function(double percent)? onProgress,
  });
  Future<List<UploadModel>> getHistory();

  // Thêm file vào hàng đợi
  Future<QueueResult> addFileToQueue(File file); // null nếu trùng

  // Lấy danh sách task( file) đã hoàn tất upload
  Future<List<UploadModel>?> getCompletedTasks({
    required int limit,
    required int offset,
  });
  Future<UploadModel?> getTaskById(String id);

  // Xử lý sự kiện pause/ resume/ cancel upload
  Future<bool> pauseUpload(String taskId);
  Future<bool> resumeUpload(String taskId);
  Future<void> cancelUpload(String taskId);
}
