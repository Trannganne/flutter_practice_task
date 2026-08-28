import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Control bar TỰ VẼ — thay cho control bar mặc định của Chewie
/// (showControls: false ở player_body.dart). Lý do bắt buộc phải tự vẽ:
/// Chewie KHÔNG expose API nào để biết lúc nào control bar của nó đang
/// ẩn/hiện, nên không thể đồng bộ 1 nút bên ngoài theo đúng nhịp của nó.
/// Bằng cách tự vẽ, progress bar + nút fullscreen dùng CHUNG đúng 1 biến
/// [_controlsVisible] -> luôn ẩn/hiện cùng lúc, tuyệt đối.
class PlayerControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const PlayerControlsOverlay({
    super.key,
    required this.controller,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  State<PlayerControlsOverlay> createState() => _PlayerControlsOverlayState();
}

class _PlayerControlsOverlayState extends State<PlayerControlsOverlay> {
  bool _controlsVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _resetHideTimer();
    widget.controller.addListener(_onControllerTick);
  }

  @override
  void didUpdateWidget(covariant PlayerControlsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nguồn fallback đổi -> controller đổi -> phải rebind listener, nếu
    // không sẽ nghe nhầm controller cũ đã dispose.
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller.removeListener(_onControllerTick);
      widget.controller.addListener(_onControllerTick);
    }
  }

  void _onControllerTick() {
    // Chỉ để trigger rebuild progress bar theo vị trí phát hiện tại —
    // không đọc gì thêm ở đây, tránh setState thừa khi giá trị không đổi.
    if (mounted) setState(() {});
  }

  /// Bấm vào bất kỳ đâu trên video: nếu đang ẩn -> hiện lại; nếu đang
  /// hiện -> ẩn ngay (không đợi hết 3s) — đúng hành vi Chewie/YouTube.
  void _handleTap() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _resetHideTimer();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.controller.removeListener(_onControllerTick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleTap,
      child: Stack(
        children: [
          // Nút play/pause lớn giữa màn hình — cũng ẩn/hiện cùng lúc.
          if (_controlsVisible)
            Center(
              child: IconButton(
                iconSize: 56,
                icon: Icon(
                  value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: Colors.white,
                ),
                onPressed: () {
                  value.isPlaying
                      ? widget.controller.pause()
                      : widget.controller.play();
                  _resetHideTimer();
                },
              ),
            ),

          // Thanh dưới cùng: progress bar + thời gian + nút fullscreen —
          // TẤT CẢ chung 1 AnimatedOpacity, đây là phần trả lời đúng yêu
          // cầu "ẩn/hiện cùng lúc" của bạn.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: _controlsVisible ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_controlsVisible,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VideoProgressIndicator(
                        widget.controller,
                        allowScrubbing: true,
                        padding: EdgeInsets.zero,
                        colors: VideoProgressColors(
                          playedColor: Theme.of(context).colorScheme.primary,
                          bufferedColor: Colors.white38,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            _formatDuration(value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            ' / ',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(value.duration),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              widget.isExpanded
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              widget.onToggleExpand();
                              _resetHideTimer();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
