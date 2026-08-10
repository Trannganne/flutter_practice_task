import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/file_picker/bloc/file_event.dart';
import 'package:flutterpractisetasks/file_picker/bloc/file_state.dart';
import 'package:flutterpractisetasks/file_picker/models/upload_task.dart';
import 'package:flutterpractisetasks/permissions/hard/service/image_picker.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  FileBloc() : super(const FileState()) {
    on<ToggleAddMoreEvent>(_onToggleAddMore);
    on<RemoveFileEvent>(_onRemoveFile);
  }

  Future<void> _onRemoveFile(
    RemoveFileEvent event,
    Emitter<FileState> emit,
  ) async {
    final newPaths = state.taskPaths.where((p) => p != event.url).toList();

    emit(state.copyWith(taskPaths: newPaths));
  }

  Future<void> _onToggleAddMore(
    ToggleAddMoreEvent event,
    Emitter<FileState> emit,
  ) async {
    try {
      final ImagePickerService pickerService = ImagePickerService();

      final files = await pickerService.imageButtonPressed(event.source);

      if (files!.isEmpty) {
        return;
      }
      final newPaths = files.map((file) => file.path).toList();

      // Thêm ảnh mới vào ảnh cũ
      final allPaths = [...state.taskPaths, ...newPaths];

      final allFiles = [...state.mediaFileList, ...files];
      // Nếu chọn/ chụp ảnh thành công thì emit ảnh

      emit(state.copyWith(mediaFileList: allFiles, taskPaths: allPaths));
    } catch (e) {
      debugPrint('Chọn ảnh thất bại!');
    }
  }
}
