import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/player_bloc/playback_cubit.dart';
import 'package:flutterpractisetasks/video_player/bloc/player_bloc/playback_state.dart';
import 'package:flutterpractisetasks/video_player/data/pages/services/player_propress_tracker.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/download_button.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/player_body.dart';
import 'package:flutterpractisetasks/video_player/data/repository/cache_metadata_repository.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key, required this.video});
  final VideoEntity video; //

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final PlaybackCubit _cubit;
  final _metadataRepo = VideoMetadataCacheRepository();
  PlayerProgressTracker? _tracker;

  // Mặc định phát DỌC — chỉ chuyển ngang khi user chủ động bấm nút mở
  // rộng. false = đang dọc (portrait), true = đang mở rộng (landscape).
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    // Vào màn hình LUÔN ở chế độ dọc trước — không tự khoá ngang nữa như
    // trước đây. User bấm nút mở rộng (_toggleExpand) mới chuyển ngang.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _cubit = PlaybackCubit();
    _loadAndPlay();
    _initTracker();
  }

  /// Fix: LUÔN đọc lại bản MỚI NHẤT từ VideoMetadataCacheRepository —
  /// đây là nguồn sự thật duy nhất mà markDownloaded() ghi vào — thay vì
  /// tin vào widget.video. Nếu vì lý do gì đó không tìm thấy trong cache
  /// (hiếm, video bị evict do vượt _maxCached), fallback về widget.video
  /// như cũ để không crash.
  Future<void> _loadAndPlay() async {
    final latest = await _metadataRepo.getById(
      widget.video.id,
      widget.video.source,
    );
    final effectiveVideo = latest ?? widget.video;

    // DEBUG: xem đúng dữ liệu app đang dùng để quyết định phát local hay
    // network — nếu isDownloaded=false ở đây dù bạn CHẮC CHẮN đã tải,
    // nghĩa là markDownloaded() lúc trước bị bỏ qua (xem log
    // [CacheMetadata] ở cache_metadata_repository.dart).
    debugPrint(
      '[VideoPlayerScreen] id=${effectiveVideo.id} '
      'isDownloaded=${effectiveVideo.isDownloaded} '
      'localFilePath=${effectiveVideo.localFilePath} '
      '(latest từ cache: ${latest != null})',
    );

    final sources = effectiveVideo.isDownloaded
        ? [effectiveVideo.localFilePath!, ...effectiveVideo.videoSources]
        : effectiveVideo.videoSources;

    if (mounted) _cubit.loadVideo(sources);
  }

  /// Bấm nút mở rộng: dọc -> ngang fullscreen (ẩn luôn status bar/nav bar
  /// cho đúng cảm giác "mở rộng" thật sự), hoặc ngược lại nếu đang ngang.
  void _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);

    if (_isExpanded) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  /// PlayerProgressTracker cần VideoPlayerController THẬT (có sau khi
  /// initialize() xong bên trong PlaybackCubit), nên phải đợi tới khi
  /// status đạt "playing" lần đầu tiên rồi mới start() được.
  Future<void> _initTracker() async {
    try {
      // Guard: nếu status ĐÃ là playing rồi thì khỏi phải đợi thêm — tránh
      // race condition (video load quá nhanh, playing được emit TRƯỚC khi
      // .firstWhere() kịp subscribe, khiến nó chờ mãi mãi cho 1 sự kiện
      // "playing" sẽ không bao giờ lặp lại).
      if (_cubit.state.status != PlaybackStatus.playing) {
        await _cubit.stream.firstWhere(
          (state) => state.status == PlaybackStatus.playing,
        );
      }
    } catch (_) {
      // FIX crash "Bad state: No element": xảy ra khi dispose() gọi
      // _cubit.close() TRONG LÚC firstWhere() ở trên vẫn đang chờ (ví dụ
      // offline, mọi fallback source đều fail nên KHÔNG BAO GIỜ đạt
      // "playing" — user sốt ruột bấm Back trước khi video kịp phát).
      // Stream đóng mà chưa khớp điều kiện nào -> firstWhere throw lỗi
      // này. Đây là race hợp lệ (không phải bug logic), màn hình đang bị
      // đóng nên không còn gì để track nữa -> bỏ qua an toàn.
      return;
    }

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
    // BẮT BUỘC trả lại dọc dù đang ở trạng thái nào (_isExpanded true/
    // false) — nếu không, thoát player lúc đang mở rộng sẽ làm kẹt toàn
    // app ở màn hình ngang.
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
        // Đang mở rộng (ngang) mà bấm back của hệ thống -> thu về dọc
        // trước, KHÔNG thoát màn hình luôn — giống hành vi YouTube/các
        // app video khác, tránh thoát nhầm khi chỉ định thu nhỏ lại.
        canPop: !_isExpanded,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _isExpanded) _toggleExpand();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            // Không cần safe-area 2 bên lúc đang mở rộng ngang (tránh
            // video bị "ăn" viền đen 2 bên do notch/status bar).
            top: !_isExpanded,
            bottom: !_isExpanded,
            child: Stack(
              children: [
                Positioned.fill(
                  child: PlayerBody(
                    isExpanded: _isExpanded,
                    onToggleExpand: _toggleExpand,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      if (_isExpanded) {
                        _toggleExpand();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
                // Nút fullscreen ĐÃ chuyển vào PlayerControlsOverlay (cạnh
                // progress bar, dưới cùng) — không đặt cố định ở đây nữa,
                // để nó ẩn/hiện cùng lúc với progress bar theo đúng yêu cầu.
                Positioned(
                  top: 8,
                  right: 8,
                  child: DownloadButton(video: widget.video),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
