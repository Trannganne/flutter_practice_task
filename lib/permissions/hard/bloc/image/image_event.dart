import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class ImagePickerEvent extends Equatable {
  const ImagePickerEvent();

  @override
  List<Object?> get props => [];
}

class PickImageRequested extends ImagePickerEvent {
  final ImageSource source;

  PickImageRequested(this.source);
}
