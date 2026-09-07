import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/player_bloc/playback_cubit.dart';
import 'package:flutterpractisetasks/video_player/bloc/player_bloc/playback_state.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/error_retry_banner.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/player_controls_overlay.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class PlayerBody extends StatefulWidget {
  // Cần 2 tham số này để PlayerControlsOverlay vẽ đúng icon fullscreen +
  // gọi được đúng hàm toggle từ VideoPlayerScreen (chủ sở hữu thật của
  // trạng thái dọc/ngang) — PlayerBody không tự giữ state đó.
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const PlayerBody({
    super.key,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  State<PlayerBody> createState() => _PlayerBodyState();
}

class _PlayerBodyState extends State<PlayerBody> {
  ChewieController? _chewieController;
  // Theo dõi identity của VideoPlayerController hiện tại đang gắn với
  // ChewieController — biết khi nào PlaybackCubit đổi sang controller mới
  // (fallback source) mà KHÔNG so sánh theo state (state đổi liên tục
  // theo mỗi frame, không dùng để quyết định tái tạo Chewie).
  Object? _boundControllerKey;

  @override
  void dispose() {
    _chewieController?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void _syncChewieController(PlaybackCubit cubit) {
    final controller = cubit.controller;
    if (controller == null) return;
    if (identical(controller, _boundControllerKey)) return; // không đổi, bỏ qua

    _chewieController?.dispose();
    _chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: false,
      allowFullScreen: false,
      allowedScreenSleep: false,
      // TẮT control bar mặc định của Chewie — thay bằng
      // PlayerControlsOverlay tự vẽ ở dưới, để progress bar + nút
      // fullscreen dùng chung 1 trạng thái ẩn/hiện (Chewie không cho
      // đồng bộ với widget bên ngoài nó).
      showControls: false,
    );
    _boundControllerKey = controller;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlaybackCubit, PlaybackState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        // Bật/tắt wakelock thủ công theo status thay vì chỉ dựa vào
        // allowedScreenSleep của Chewie — tắt cả lúc buffering/error.
        if (state.status == PlaybackStatus.playing) {
          WakelockPlus.enable();
        } else {
          WakelockPlus.disable();
        }
      },
      builder: (context, state) {
        final cubit = context.read<PlaybackCubit>();

        if (state.status == PlaybackStatus.error) {
          return Center(
            child: ErrorRetryBanner(
              message: state.errorMessage ?? 'Đã có lỗi xảy ra.',
              onRetry: cubit.retry,
            ),
          );
        }

        if (state.status == PlaybackStatus.loading ||
            cubit.controller == null) {
          return const Center(child: CircularProgressIndicator());
        }

        _syncChewieController(cubit);

        return Stack(
          alignment: Alignment.center,
          children: [
            Chewie(controller: _chewieController!),
            if (state.status == PlaybackStatus.buffering)
              const CircularProgressIndicator(),
            // Nằm TRÊN Chewie trong Stack — GestureDetector của overlay
            // này nhận tap trước, Chewie (đã tắt showControls) không còn
            // gesture riêng nào để tranh chấp nữa.
            PlayerControlsOverlay(
              controller: cubit.controller!,
              isExpanded: widget.isExpanded,
              onToggleExpand: widget.onToggleExpand,
            ),
          ],
        );
      },
    );
  }
}
