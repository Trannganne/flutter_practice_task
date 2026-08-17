import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/file_picker/models/upload_task.dart';
import 'package:image_picker/image_picker.dart';

enum FileStatus { loading, success, failure }

class FileState extends Equatable {
  final List<UploadModel> files;
  final FileStatus status;
  final List<XFile> mediaFileList;
  final List<String> taskPaths;
  final List<UploadModel> completedFiles;
  final String? rejectMessage;
  final bool hasMoreCompleted;
  final bool isLoadingMore;
  final String? actionMessage;

  const FileState({
    this.files = const [],
    this.status = FileStatus.loading,
    this.mediaFileList = const [],
    this.taskPaths = const [],
    this.completedFiles = const [],
    this.rejectMessage,
    this.hasMoreCompleted = true,
    this.isLoadingMore = false,
    this.actionMessage,
  });

  FileState copyWith({
    List<UploadModel>? files,
    FileStatus? status,
    List<XFile>? mediaFileList,
    List<String>? taskPaths,
    List<UploadModel>? completedFiles,
    String? rejectMessage,
    bool? hasMoreCompleted,
    bool? isLoadingMore,
    String? actionMessage,
  }) {
    return FileState(
      files: files ?? this.files,
      status: status ?? this.status,
      mediaFileList: mediaFileList ?? this.mediaFileList,
      taskPaths: taskPaths ?? this.taskPaths,
      completedFiles: completedFiles ?? this.completedFiles,
      rejectMessage: rejectMessage ?? this.rejectMessage,
      hasMoreCompleted: hasMoreCompleted ?? this.hasMoreCompleted,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    files,
    status,
    taskPaths,
    completedFiles,
    rejectMessage,
    hasMoreCompleted,
    isLoadingMore,
    actionMessage,
  ];
}
