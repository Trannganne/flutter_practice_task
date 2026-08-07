enum UploadStatus { failed, success, pending, uploading, cancelled }

enum ProviderType { imgBB, freeimage }

class UploadTask {
  final String id;
  final String filePath;
  final String fileHash;
  final ProviderType provider;
  final UploadStatus status;
  final String remoteUrl;
  final int retryCount;
  final int createdAt;
  final int updatedAt;

  const UploadTask({
    required this.id,
    required this.filePath,
    required this.fileHash,
    this.provider = ProviderType.imgBB,
    this.status = UploadStatus.uploading,
    this.remoteUrl = '',
    required this.retryCount,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'fileHash': fileHash,
      'provider': provider,
      'status': status,
      'remoteUrl': remoteUrl,
      'retryCount': retryCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UploadTask.fromJson(Map<String, dynamic> json) {
    final srcMap = json['data'] as Map<String, dynamic>?;
    return UploadTask(
      id: srcMap?['id'],
      filePath: srcMap?['filePath'],
      fileHash: srcMap?['fileHash'] as String? ?? '',
      provider: ProviderType.values.byName(srcMap?['provider']),
      status: UploadStatus.values.byName(srcMap?['status']),
      retryCount: srcMap?['retryCount'],
      createdAt: srcMap?['createdAt'],
      updatedAt: srcMap?['updatedAt'],
    );
  }

  UploadTask copyWith(
    ProviderType? provider,
    UploadStatus? status,

    String? filePath,
    String? remoteUrl,
    int? retryCount,
    int? updatedAt,
  ) {
    return UploadTask(
      id: id,
      filePath: filePath ?? this.filePath,
      fileHash: fileHash,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
