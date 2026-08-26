import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/player_bloc/playback_cubit.dart';
import 'package:flutterpractisetasks/video_player/bloc/player_bloc/playback_state.dart';
import 'package:flutterpractisetasks/video_player/data/pages/services/player_propress_tracker.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/player_body.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.video});
  final VideoEntity video;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final PlaybackCubit _cubit;
  PlayerProgressTracker? _tracker;

  @override
  void initState() {
    super.initState();

    // Khoá màn hình ngang khi vào player fullscreen — trả lại dọc khi thoát.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _cubit = PlaybackCubit()..loadVideo(widget.video.videoSources);
    _initTracker();
  }

  /// PlayerProgressTracker cần VideoPlayerController THẬT (có sau khi
  /// initialize() xong bên trong PlaybackCubit), nên phải đợi tới khi
  /// status đạt "playing" lần đầu tiên rồi mới start() được.
  Future<void> _initTracker() async {
    await _cubit.stream.firstWhere(
      (state) => state.status == PlaybackStatus.playing,
    );

    if (!mounted || _cubit.controller == null) return;

    final tracker = PlayerProgressTracker(
      controller: _cubit.controller!,
      videoId: widget.video.id,
      source: widget.video.source,
    );
    await tracker
        .start(); // tự resume nếu có progress cũ, rồi bắt đầu throttle-save
    _tracker = tracker;
  }

  @override
  void dispose() {
    // BẮT BUỘC trả lại orientation mặc định, nếu không toàn app sẽ bị
    // kẹt màn hình ngang sau khi thoát player.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Lưu vị trí xem cuối cùng TRƯỚC khi đóng cubit — nếu đảo thứ tự,
    // controller đã dispose thì tracker không đọc được position nữa.
    _tracker?.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: PopScope(
        canPop: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                const Positioned.fill(child: PlayerBody()),
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
