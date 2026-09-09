import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/file_picker/bloc/file_event.dart';
import 'package:flutterpractisetasks/file_picker/bloc/file_state.dart';
import 'package:flutterpractisetasks/file_picker/data/repository/upload_repository.dart';
import 'package:flutterpractisetasks/file_picker/models/queue_result.dart';
import 'package:flutterpractisetasks/file_picker/models/upload_task.dart';
import 'package:flutterpractisetasks/permissions/hard/service/image_picker.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  static const int _pageSize = 10; // Có thể chỉnh tùy ý

  final UploadRepository uploadRepository;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  FileBloc(this.uploadRepository) : super(const FileState()) {
    on<UploadQueueStarted>(_onUploadQueueStarted);
    on<ToggleAddMoreEvent>(_onToggleAddMore);
    on<RemoveFileEvent>(_onRemoveFile);
    on<UploadTaskStarted>(_onUploadTaskStarted);
    on<LoadCompletedTasks>(_onLoadCompletedTasks);
    on<ConnectivityRestored>(_onConnectivityRestored);
    on<LoadMoreCompletedTasks>(_onLoadMoreCompletedTasks);
    on<CancelUploadEvent>(_onCancelUpload);
    // Xử lý sự kiện pause/ resume upload
    on<PauseUploadEvent>(_onPauseUpload);
    on<ResumeUploadEvent>(_onResumeUpload);

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        add(ConnectivityRestored());
      }
    });
  }
  Future<void> _onResumeUpload(
    ResumeUploadEvent event,
    Emitter<FileState> emit,
  ) async {
    UploadModel? currentTask;

    for (final task in state.files) {
      if (task.id == event.taskId) {
        currentTask = task;
        break;
      }
    }

    if (currentTask == null) {
      emit(state.copyWith(actionMessage: 'Không tìm thấy task upload'));

      return;
    }

    if (currentTask.status != UploadStatus.paused) {
      return;
    }

    final resumedTask = currentTask.copyWith(
      status: UploadStatus.pending,

      // Vì upload lại từ đầu nên progress phải trở về 0.
      progress: 0,
    );

    final updatedFiles = state.files.map((task) {
      return task.id == event.taskId ? resumedTask : task;
    }).toList();

    // Cập nhật ngay để nút Resume biến mất,
    // tránh người dùng nhấn nhiều lần.
    emit(state.copyWith(files: updatedFiles, status: FileStatus.success));

    add(UploadTaskStarted(resumedTask));
  }

  Future<void> _onPauseUpload(
    PauseUploadEvent event,
    Emitter<FileState> emit,
  ) async {
    try {
      debugPrint('Có tới đây không nhỉ!');
      final wasPaused = await uploadRepository.pauseUpload(event.taskId);
      if (!wasPaused) {
        emit(
          state.copyWith(
            actionMessage: 'Task này không còn trong quá trình upload!',
          ),
        );
        return;
      }

      final updatedFiles = state.files.map((task) {
        if (task.id != event.taskId) {
          return task;
        }
        return task.copyWith(
          status: UploadStatus.paused,
          progress: task.progress,
        );
      }).toList();

      emit(
        state.copyWith(
          files: updatedFiles,
          actionMessage: 'Tạm ngừng upload!',
          status: FileStatus.success,
        ),
      );
    } catch (e) {
      // Bắt lỗi khi pause upload thất bại
      debugPrint('Lỗi khi pause upload: $e');
      emit(
        state.copyWith(
          actionMessage: 'Không thể pause upload. Vui lòng thử lại.',
        ),
      );
    }
  }

  Future<void> _onCancelUpload(
    CancelUploadEvent event,
    Emitter<FileState> emit,
  ) async {
    await uploadRepository.cancelUpload(event.taskId);
    // Không cần emit ở đây — uploadTask() đang chạy sẽ tự bắt DioExceptionType.cancel,
    // cập nhật DB, và _onUploadTaskStarted (đang "await" nó) sẽ tự đọc lại + emit state mới
  }

  Future<void> _onLoadMoreCompletedTasks(
    LoadMoreCompletedTasks event,
    Emitter<FileState> emit,
  ) async {
    if (!state.hasMoreCompleted || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final moreTasks = await uploadRepository.getCompletedTasks(
        limit: _pageSize,
        offset: state.completedFiles.length,
      );
      emit(
        state.copyWith(
          completedFiles: [...state.completedFiles, ...moreTasks!],
          hasMoreCompleted: moreTasks.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          actionMessage: 'Load thêm dữ liệu thất bại!',
          isLoadingMore: false,
        ),
      );
    }
  }

  // Cho trường hợp có mạng trở lại
  // Tự động gọi db local (filter pending) thành uploading
  Future<void> _onConnectivityRestored(
    ConnectivityRestored event,
    Emitter<FileState> emit,
  ) async {
    final pendingTasks = state.files
        .where((t) => t.status == UploadStatus.pending)
        .toList();
    for (final task in pendingTasks) {
      add(UploadTaskStarted(task));
    }
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }

  Future<void> _onLoadCompletedTasks(
    LoadCompletedTasks event,
    Emitter<FileState> emit,
  ) async {
    try {
      final tasks = await uploadRepository.getCompletedTasks(
        limit: _pageSize,
        offset: 0,
      );
      emit(
        state.copyWith(
          completedFiles: tasks,
          hasMoreCompleted: tasks?.length == _pageSize,
        ),
      );
    } catch (e) {
      debugPrint("Load dữ liệu file đã upload thất bại: $e");
    }
  }

  Future<void> _onUploadTaskStarted(
    UploadTaskStarted event,
    Emitter<FileState> emit,
  ) async {
    try {
      final result = await uploadRepository.uploadTask(
        event.task,
        onProgress: (percent) {
          final updated = state.files.map((t) {
            return t.id == event.task.id
                ? t.copyWith(progress: percent, status: UploadStatus.uploading)
                : t;
          }).toList();
          emit(state.copyWith(files: updated, status: FileStatus.success));
        },
      );
    } catch (e) {
      debugPrint('Upload file thất bại: $e');
      //debugPrint("$stack");
    }
    // Đọc lại đúng bản ghi vừa upload (đã có status/url/width/height/size mới nhất)
    // Chạy trong mọi trường hợp - uploadTask() thành công hay ném exception
    // đây là bước đảm bảo UI luôn phản ánh đúng trạng thái mới nhất từ DB
    final updatedTask = await uploadRepository.getTaskById(event.task.id);
    if (updatedTask == null) {
      final newFiles = state.files.where((t) => t.id != event.task.id).toList();
      emit(state.copyWith(files: newFiles));
      return;
    }
    ;

    // Cập nhật lại đúng item trong Queue (KHÔNG xoá khỏi list)
    final newFiles = state.files.map((t) {
      return t.id == updatedTask.id ? updatedTask : t;
    }).toList();

    // Nếu thành công, thêm bản sao vào Completed (danh sách riêng, không ảnh hưởng Queue)
    final newCompleted = updatedTask.status == UploadStatus.done
        ? [...state.completedFiles, updatedTask]
        : state.completedFiles;

    emit(state.copyWith(files: newFiles, completedFiles: newCompleted));
  }

  Future<void> _onUploadQueueStarted(
    UploadQueueStarted event,
    Emitter<FileState> emit,
  ) async {
    final tasks = await uploadRepository.resumePendingQueue();
    emit(state.copyWith(files: tasks));
  }

  Future<void> _onRemoveFile(
    RemoveFileEvent event,
    Emitter<FileState> emit,
  ) async {
    final newPaths = state.files.where((p) => p.filePath != event.url).toList();

    emit(state.copyWith(files: newPaths));
  }

  String _messageFor(QueueRejectReason reason) {
    switch (reason) {
      case QueueRejectReason.duplicate:
        return 'File đã được upload trước đó';
      case QueueRejectReason.invalidMimeType:
        return 'Định dạng file không hợp lệ, chỉ chấp nhận ảnh';
      case QueueRejectReason.tooLarge:
        return 'File vượt quá dung lượng cho phép (32MB)';
    }
  }

  Future<void> _onToggleAddMore(
    ToggleAddMoreEvent event,
    Emitter<FileState> emit,
  ) async {
    try {
      final ImagePickerService pickerService = ImagePickerService();
      // 1. Chọn ảnh
      final files = await pickerService.imageButtonPressed(event.source);

      if (files == null || files.isEmpty) return;
      debugPrint("Số lượng ảnh vừa lấy: ${files.length}");

      // for (final file in files) {
      //   final result = await uploadRepository.addFileToQueue(File(file.path));
      //   if (result.isSuccess) {
      //     newTasks.add(result.task!);
      //   } else {
      //     rejectedMessages.add(_messageFor(result.rejectReason!));
      //   }
      // }

      // if (rejectedMessages.isNotEmpty) {
      //   emit(state.copyWith(rejectMessage: rejectedMessages.join('\n')));
      //   // TODO: UI lắng nghe field này để show dialog (không SnackBar, theo convention công ty)
      // }

      // if (newTasks.isEmpty) return;
      // emit(state.copyWith(files: [...state.files, ...newTasks]));
      // for (final task in newTasks) {
      //   add(UploadTaskStarted(task));
      // }

      // 2. Đưa ảnh vào queue
      final newTasks = <UploadModel>[];
      final rejectedMessages = <String>[];

      for (final file in files) {
        final result = await uploadRepository.addFileToQueue(File(file.path));

        if (result.isSuccess) {
          newTasks.add(result.task!);
        } else {
          rejectedMessages.add(_messageFor(result.rejectReason!));
        }
      }

      if (rejectedMessages.isNotEmpty) {
        emit(state.copyWith(rejectMessage: rejectedMessages.join('\n')));
        // TODO: UI lắng nghe field này để show apptoast
      }

      if (files.isEmpty) {
        return;
      }

      // 3. Emit state để UI thấy ảnh xuất hiện trong Queue ngay
      emit(state.copyWith(files: [...state.files, ...newTasks]));

      // 4. Trigger upload cho từng task mới (KHÔNG gọi uploadRepository.uploadTask trực tiếp ở đây)
      for (final task in newTasks) {
        add(UploadTaskStarted(task));
      }
    } catch (e) {
      debugPrint('Chọn ảnh thất bại: $e');
    }
  }
}
