import 'package:equatable/equatable.dart';
import 'package:flutterpractisetasks/file_picker/models/upload_task.dart';
import 'package:image_picker/image_picker.dart';

abstract class FileEvent extends Equatable {
  const FileEvent();

  @override
  List<Object?> get props => [];
}

class ToggleAddMoreEvent extends FileEvent {
  final ImageSource source;

  ToggleAddMoreEvent(this.source);

  @override
  List<Object?> get props => [source];
}

class ClearQueueEvent extends FileEvent {}

class ChangeStatus extends FileEvent {}

class PauseUploadEvent extends FileEvent {
  final String taskId;
  PauseUploadEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ResumeUploadEvent extends FileEvent {
  final String taskId;
  ResumeUploadEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class RemoveFileEvent extends FileEvent {
  final String url;

  RemoveFileEvent(this.url);
  @override
  List<Object?> get props => [url];
}

class UploadQueueStarted extends FileEvent {}

class UploadTaskStarted extends FileEvent {
  final UploadModel task;

  UploadTaskStarted(this.task);
  @override
  List<Object?> get props => [];
}

class LoadCompletedTasks extends FileEvent {}

class LoadMoreCompletedTasks extends FileEvent {}

class ConnectivityRestored extends FileEvent {}

class CancelUploadEvent extends FileEvent {
  final String taskId;
  CancelUploadEvent(this.taskId);
  @override
  List<Object?> get props => [taskId];
}
