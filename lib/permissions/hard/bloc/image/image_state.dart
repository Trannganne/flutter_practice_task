import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

sealed class ImageState extends Equatable {
  const ImageState();

  @override
  List<Object?> get props => [];
}

class ImageInitial extends ImageState {}

class ImageLoading extends ImageState {}

class ImageRequestPermission extends ImageState {}

class ImagePickedSuccess extends ImageState {
  final List<XFile> mediaFileList;
  final String? actionMessage;

  ImagePickedSuccess(this.mediaFileList, this.actionMessage);

  @override
  List<Object?> get props => [mediaFileList, actionMessage];
}

class ImagePickedFailure extends ImageState {
  final String message;

  const ImagePickedFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
