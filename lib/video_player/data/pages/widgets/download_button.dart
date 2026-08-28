import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/download/download_cubit.dart';
import 'package:flutterpractisetasks/video_player/bloc/download/download_state.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';
import 'package:flutterpractisetasks/widgets/components/apptoast.dart';

/// Nút tải video về máy — tự tạo BlocProvider<DownloadCubit> CỦA RIÊNG
/// NÓ, không phụ thuộc bloc nào cấp từ bên ngoài. Dùng trong
/// VideoPlayerScreen. Báo kết quả qua Apptoast — KHÔNG dùng SnackBar.
class DownloadButton extends StatelessWidget {
  final VideoEntity video;
  const DownloadButton({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DownloadCubit.forVideo(video),
      child: BlocConsumer<DownloadCubit, DownloadState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == DownloadStatus.error &&
              state.errorMessage != null) {
            Apptoast.show(state.errorMessage!);
          }
          if (state.status == DownloadStatus.completed) {
            Apptoast.show('Đã lưu video vào máy.');
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case DownloadStatus.completed:
              return const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.download_done, color: Colors.greenAccent),
              );

            case DownloadStatus.downloading:
              // Bấm lúc đang tải = huỷ, không phải tải lại.
              return SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: state.progress == 0 ? null : state.progress,
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                      onPressed: () => context.read<DownloadCubit>().cancel(),
                    ),
                  ],
                ),
              );

            case DownloadStatus.error:
            case DownloadStatus.idle:
              return IconButton(
                icon: const Icon(Icons.download_outlined, color: Colors.white),
                onPressed: () => context.read<DownloadCubit>().download(video),
              );
          }
        },
      ),
    );
  }
}
