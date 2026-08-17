import 'package:flutterpractisetasks/file_picker/models/upload_task.dart';

enum QueueRejectReason { duplicate, invalidMimeType, tooLarge }

class QueueResult {
  final UploadModel? task;
  final QueueRejectReason? rejectReason;

  QueueResult.success(this.task) : rejectReason = null;
  QueueResult.rejected(this.rejectReason) : task = null;

  bool get isSuccess => task != null;
}
