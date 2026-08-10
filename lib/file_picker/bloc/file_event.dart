import 'package:equatable/equatable.dart';
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

class PauseEvent extends FileEvent {}

class RemoveFileEvent extends FileEvent {
  final String url;

  RemoveFileEvent(this.url);
  @override
  List<Object?> get props => [url];
}
