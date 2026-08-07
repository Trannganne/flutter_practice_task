import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/image/image_event.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/image/image_state.dart';
import 'package:flutterpractisetasks/permissions/hard/service/image_picker.dart';

class ImageBloc extends Bloc<ImagePickerEvent, ImageState> {
  ImageBloc() : super(ImageInitial()) {
    on<PickImageRequested>(_onImagePicker);
  }

  Future<void> _onImagePicker(
    PickImageRequested event,
    Emitter<ImageState> emit,
  ) async {
    emit(ImageRequestPermission());

    emit(ImageLoading());
    try {
      final ImagePickerService pickerService = ImagePickerService();

      final files = await pickerService.imageButtonPressed(event.source);

      // Nếu chọn/ chụp ảnh thành công thì emit ảnh
      if (files != null && files.isNotEmpty) {
        emit(ImagePickedSuccess(files, 'Tải ảnh thành công!'));
      } else {
        // Nếu không thì quay về trạng thái ban đầu
        //emit(ImageInitial());
        emit(ImagePickedFailure(message: 'Không tải được ảnh: '));
      }
    } catch (e) {
      emit(ImagePickedFailure(message: 'Không tải được ảnh: $e'));
    }
  }
}
