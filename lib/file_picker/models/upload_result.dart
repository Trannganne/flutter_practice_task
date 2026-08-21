import 'package:flutterpractisetasks/file_picker/models/upload_task.dart';

class UploadResult {
  final bool success;
  final String? url;
  final ProviderType providerUsed;
  final int? width;
  final int? height;
  final int? sizedByte;

  UploadResult({
    required this.success,
    this.url,
    required this.providerUsed,
    this.width,
    this.height,
    this.sizedByte,
  });
}
