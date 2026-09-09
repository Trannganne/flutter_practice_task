enum UploadStatus { failed, done, pending, uploading, cancelled, paused }

enum ProviderType { imgBB, freeimage, bothFailed }

class UploadModel {
  final String id;
  final String filePath;
  final String fileHash;
  final ProviderType provider;
  final UploadStatus status;
  final String remoteUrl;
  final int retryCount;
  final int createdAt;
  final int updatedAt;
  final double progress;
  final int? width;
  final int? height;
  final int? sizeByte;

  const UploadModel({
    required this.id,
    required this.filePath,
    required this.fileHash,
    this.provider = ProviderType.imgBB,
    this.status = UploadStatus.uploading,
    this.remoteUrl = '',
    required this.retryCount,
    required this.createdAt,
    required this.updatedAt,
    this.progress = 0,
    this.width,
    this.height,
    this.sizeByte,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'fileHash': fileHash,
      'provider': provider.name,
      'status': status.name,
      'remoteUrl': remoteUrl,
      'retryCount': retryCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'progress': progress,
      'width': width,
      'height': height,
      'sizeByte': sizeByte,
    };
  }

  factory UploadModel.fromJson(Map<String, dynamic> json) {
    return UploadModel(
      id: json['id'],
      filePath: json['filePath'] as String? ?? '',
      fileHash: json['fileHash'],
      provider: ProviderType.values.byName(json['provider']),
      status: UploadStatus.values.byName(json['status']),
      retryCount: json['retryCount'] as int,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      width: json['width'] as int?,
      height: json['height'] as int?,
      sizeByte: json['sizeByte'] as int?,
      remoteUrl: json['remoteUrl'] as String? ?? '',
    );
  }

  UploadModel copyWith({
    ProviderType? provider,
    UploadStatus? status,
    double? progress,
    String? filePath,
    String? remoteUrl,
    int? retryCount,
    int? updatedAt,
    int? width,
    int? height,
    int? sizeBytes,
  }) {
    return UploadModel(
      id: id,
      filePath: filePath ?? this.filePath,
      fileHash: fileHash,
      progress: progress ?? this.progress,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      provider: provider ?? this.provider,
      status: status ?? this.status,
      width: width ?? this.width,
      height: height ?? this.height,
      sizeByte: sizeBytes ?? this.sizeByte,
    );
  }
}
