// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutterpractisetasks/image_caching/core/customappbar.dart';
// import 'package:flutterpractisetasks/video_player/bloc/connectivity/connectivity_cubit.dart';
// import 'package:flutterpractisetasks/video_player/bloc/history_bloc/history_bloc.dart';
// import 'package:flutterpractisetasks/video_player/bloc/history_bloc/history_event.dart';
// import 'package:flutterpractisetasks/video_player/bloc/history_bloc/history_state.dart';
// import 'package:flutterpractisetasks/video_player/bloc/popular_bloc/popular_bloc.dart';
// import 'package:flutterpractisetasks/video_player/bloc/popular_bloc/popular_event.dart';
// import 'package:flutterpractisetasks/video_player/bloc/popular_bloc/popular_state.dart';
// import 'package:flutterpractisetasks/video_player/data/pages/widgets/error_retry_banner.dart';
// import 'package:flutterpractisetasks/video_player/data/pages/widgets/history_tile.dart';
// import 'package:flutterpractisetasks/video_player/data/pages/widgets/offline_banner.dart';
// import 'package:flutterpractisetasks/video_player/data/pages/widgets/video_card.dart';
// import 'package:flutterpractisetasks/video_player/data/pages/main_pages/video_player_screen.dart';
// import 'package:flutterpractisetasks/video_player/data/pages/widgets/video_grid_card.dart';
// import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';
// import 'package:flutterpractisetasks/widgets/components/apptoast.dart';

// /// LƯU Ý: KHÔNG tạo BlocProvider mới ở đây — PopularBloc/HistoryBloc/
// /// SearchBloc đã được cung cấp từ bên ngoài lúc mở module (providers: [...]
// /// trong _openModule). Chỉ đọc lại qua context.read/BlocBuilder.
// class HomePageVideoPlayer extends StatefulWidget {
//   const HomePageVideoPlayer({super.key});

//   @override
//   State<HomePageVideoPlayer> createState() => _HomePageVideoPlayerState();
// }

// class _HomePageVideoPlayerState extends State<HomePageVideoPlayer> {
//   late final ScrollController _scrollController;
//   late final ScrollController _feedScrollController;
//   late final PageController _bannerPageController;
//   late final ValueNotifier<int> _currentBannerPage;

//   // Instance RIÊNG cho màn hình này (không qua _openModule) — theo đúng
//   // cách đã làm với DownloadsBloc/DownloadCubit: connectivity là 1
//   // concern độc lập, không cần chia sẻ state với Bloc nào khác.
//   late final ConnectivityCubit _connectivityCubit;

//   // Số video đầu dùng làm banner carousel — phần feed ngang bên dưới sẽ
//   // bỏ qua đúng số này, không lặp lại video đã có trong banner.
//   static const _bannerCount = 5;

//   @override
//   void initState() {
//     super.initState();

//     _connectivityCubit = ConnectivityCubit();

//     // Bloc được tạo từ bên ngoài (chưa tự load), nên phải tự bắn event
//     // load ban đầu ở đây — khác với cách viết cũ (Bloc tự load lúc khởi tạo).
//     context.read<PopularBloc>().add(const PopularLoadRequested());
//     context.read<HistoryBloc>().add(const HistoryLoadRequested());

//     _scrollController = ScrollController();
//     // Trigger infinite scroll theo dải NGANG chứa feed Popular — KHÔNG
//     // dùng _scrollController (trang dọc) nữa, vì cuộn hết trang dọc
//     // (qua cả Watch History, error banner...) không còn đồng nghĩa với
//     // "đã xem hết feed Popular" như lúc feed còn là lưới dọc.
//     _feedScrollController = ScrollController()..addListener(_onFeedScroll);
//     _bannerPageController = PageController();
//     _currentBannerPage = ValueNotifier(0);
//   }

//   void _onFeedScroll() {
//     // CHỦ ĐỘNG chặn load-more khi ĐÃ BIẾT CHẮC đang offline — tránh bắn
//     // API để rồi phải đợi timeout HTTP mới catch được lỗi (trải nghiệm
//     // tệ + tốn pin). Chỉ chặn khi _connectivityCubit đã check xong lần
//     // đầu (isKnown) và kết quả là offline; nếu chưa biết (isKnown=false)
//     // vẫn cho thử — best-effort, tránh chặn nhầm lúc mới mở app.
//     final connectivity = _connectivityCubit.state;
//     if (connectivity.isKnown && !connectivity.isOnline) return;

//     final position = _feedScrollController.position;
//     if (position.pixels >= position.maxScrollExtent - 200) {
//       context.read<PopularBloc>().add(const PopularLoadMoreRequested());
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _feedScrollController.dispose();
//     _bannerPageController.dispose();
//     _currentBannerPage.dispose();
//     _connectivityCubit.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // BlocProvider.value (không phải BlocProvider(create:...)) vì Cubit
//     // đã được tạo sẵn ở initState — để _onFeedScroll (method của State,
//     // không nằm trong subtree do build() trả về) vẫn truy cập được đúng
//     // instance qua field _connectivityCubit thay vì context.read.
//     return BlocProvider.value(
//       value: _connectivityCubit,
//       // Lắng nghe lỗi để hiện toast — KHÔNG dùng SnackBar theo convention team.
//       child: MultiBlocListener(
//         listeners: [
//           BlocListener<PopularBloc, PopularState>(
//             listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
//             listener: (context, state) {
//               if (state.errorMessage != null) {
//                 Apptoast.show(state.errorMessage!);
//               }
//             },
//           ),
//         ],
//         child: Scaffold(
//           backgroundColor: const Color(0xFF0F141C),
//           appBar: CustomAppbar(
//             backgroundColor: const Color(0xFF0F141C),
//             title: 'Video Explorer',
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.search, color: Colors.white),
//                 onPressed: () {}, // TODO: điều hướng sang SearchScreen
//               ),
//             ],
//           ),
//           body: SingleChildScrollView(
//             controller: _scrollController,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const OfflineBanner(),
//                 const SizedBox(height: 16),
//                 _buildFeaturedBanner(),
//                 const SizedBox(height: 5),
//                 _buildMainGrid(),
//                 const SizedBox(height: 5),
//                 _buildWatchHistorySection(),
//                 _buildLoadMoreErrorBanner(),
//                 const SizedBox(height: 12),
//                 // Saved Videos: tạm ẩn — DownloadsBloc chưa viết (Bước 8,
//                 // làm sau khi rubric chính xong). Đây LÀ tính năng chưa
//                 // làm tới, không phải bug — chưa có nút "Lưu"/Download
//                 // vì phần này cố tình để cuối cùng.
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   /// Banner lớn trên cùng — chỉ rebuild khi videos/status đổi, không
//   /// rebuild theo mọi thay đổi khác của PopularState.
//   Widget _buildFeaturedBanner() {
//     return BlocBuilder<PopularBloc, PopularState>(
//       buildWhen: (prev, curr) =>
//           prev.videos != curr.videos || prev.status != curr.status,
//       builder: (context, state) {
//         if (state.status == PopularStatus.loading) {
//           return const SizedBox(
//             height: 220,
//             child: Center(child: CircularProgressIndicator()),
//           );
//         }

//         // Lỗi NGAY LẦN ĐẦU (chưa có video nào) — khác với lỗi lúc load more
//         // (xử lý riêng ở _buildLoadMoreErrorBanner bên dưới).
//         if (state.status == PopularStatus.error && state.videos.isEmpty) {
//           return ErrorRetryBanner(
//             message: state.errorMessage ?? 'Tải thất bại. Vui lòng thử lại!',
//             onRetry: () =>
//                 context.read<PopularBloc>().add(const PopularRetryRequested()),
//           );
//         }

//         if (state.videos.isEmpty) return const SizedBox.shrink();

//         // Lấy tối đa _bannerCount video đầu cho carousel — không lấy hết
//         // toàn bộ feed vào banner, phần còn lại hiện ở _buildMainGrid.
//         final bannerVideos = state.videos.take(_bannerCount).toList();

//         return Column(
//           children: [
//             SizedBox(
//               height: 220,
//               child: PageView.builder(
//                 controller: _bannerPageController,
//                 itemCount: bannerVideos.length,
//                 onPageChanged: (index) => _currentBannerPage.value = index,
//                 itemBuilder: (context, index) {
//                   final video = bannerVideos[index];
//                   return VideoCard(
//                     title: video.title,
//                     // TODO: kiểm tra lại chữ ký thật của VideoCard bạn đang có —
//                     // VideoGridCard dùng String cho duration, còn bản gốc bạn
//                     // gửi lại truyền int (1) cho VideoCard, 2 nơi đang không
//                     // nhất quán kiểu dữ liệu. Tạm dùng inSeconds, cần đối chiếu.
//                     duration: video.duration.inSeconds,
//                     imageUrl: video.thumbnailUrl,
//                     onTap: () => _openPlayer(video),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 8),
//             // Chỉ Row dot này rebuild khi đổi trang — không rebuild lại
//             // cả PageView/banner phía trên, nhờ tách riêng ValueNotifier.
//             ValueListenableBuilder<int>(
//               valueListenable: _currentBannerPage,
//               builder: (context, currentPage, _) {
//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(
//                     bannerVideos.length,
//                     (index) => Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 3),
//                       width: index == currentPage ? 8 : 6,
//                       height: index == currentPage ? 8 : 6,
//                       decoration: BoxDecoration(
//                         color: index == currentPage ? Colors.blue : Colors.grey,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   /// Feed Popular dạng dải cuộn NGANG — đồng bộ thẩm mỹ với Saved Videos/
//   /// Watch History trong mockup. Vẫn là infinite scroll thật (trigger qua
//   /// _feedScrollController khi cuộn gần hết dải NGANG này), chỉ khác
//   /// hướng cuộn so với bản GridView dọc trước đó — không ảnh hưởng đến
//   /// việc có đạt yêu cầu pagination/infinite scroll của rubric hay không.
//   Widget _buildMainGrid() {
//     return BlocBuilder<PopularBloc, PopularState>(
//       buildWhen: (prev, curr) =>
//           prev.videos != curr.videos || prev.status != curr.status,
//       builder: (context, state) {
//         if (state.videos.length <= _bannerCount) return const SizedBox.shrink();

//         final feedVideos = state.videos.skip(_bannerCount).toList();
//         final isLoadingMore = state.status == PopularStatus.loadingMore;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSectionHeader(
//               'Popular',
//               onSeeAll: () {
//                 // Không cần "See all" điều hướng đi đâu khác — đây đã là
//                 // tab Popular rồi, có thể ẩn nút này nếu muốn (để trống
//                 // onSeeAll cho đơn giản trước mắt).
//               },
//             ),
//             SizedBox(
//               height: 135,
//               child: ListView.separated(
//                 controller: _feedScrollController,
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 itemCount: feedVideos.length + (isLoadingMore ? 1 : 0),
//                 separatorBuilder: (_, __) => const SizedBox(width: 12),
//                 itemBuilder: (context, index) {
//                   // Phần tử cuối cùng là loading indicator khi đang tải
//                   // thêm trang — không phải video thật.
//                   if (index >= feedVideos.length) {
//                     return const SizedBox(
//                       width: 40,
//                       child: Center(
//                         child: SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         ),
//                       ),
//                     );
//                   }

//                   final video = feedVideos[index];
//                   return VideoGridCard(
//                     title: video.title,
//                     duration: video.duration.inSeconds,
//                     imageUrl: video.thumbnailUrl,
//                     onTap: () => _openPlayer(video),
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildWatchHistorySection() {
//     return BlocBuilder<HistoryBloc, HistoryState>(
//       builder: (context, state) {
//         if (state.items.isEmpty) return const SizedBox.shrink();

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSectionHeader(
//               'Watch History',
//               onSeeAll: () {
//                 // TODO: navigationShell.goBranch(index của tab History)
//               },
//             ),
//             SizedBox(
//               height: 160,
//               child: ListView.builder(
//                 scrollDirection: Axis.vertical,
//                 itemCount: state.items.length,
//                 itemBuilder: (context, index) {
//                   final item = state.items[index];
//                   return HistoryTile(
//                     title: item.video.title,
//                     durationText: item.progress.durationSeconds,
//                     progress: item.progress.progressRatio,
//                     imageUrl: item.video.thumbnailUrl,
//                     onTap: () => _openPlayer(item.video),
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   /// Banner lỗi RIÊNG cho trường hợp lỗi lúc load more (đã có video cũ
//   /// trong feed) — khác với lỗi lần đầu đã xử lý trong _buildFeaturedBanner.
//   Widget _buildLoadMoreErrorBanner() {
//     return BlocBuilder<PopularBloc, PopularState>(
//       buildWhen: (prev, curr) => prev.status != curr.status,
//       builder: (context, state) {
//         if (state.status == PopularStatus.error && state.videos.isNotEmpty) {
//           return ErrorRetryBanner(
//             message: state.errorMessage ?? 'Failed to load more videos',
//             onRetry: () =>
//                 context.read<PopularBloc>().add(const PopularRetryRequested()),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   /// Push sang VideoPlayerScreen. Navigator.push trực tiếp (không qua
//   /// GoRouter) vì Player là fullscreen tạm thời, không cần giữ trong
//   /// URL/lịch sử điều hướng như các tab chính.
//   ///
//   /// QUAN TRỌNG: HomePageVideoPlayer chỉ initState() 1 LẦN, không tự
//   /// chạy lại khi quay về từ Navigator.push — nên HistoryBloc không tự
//   /// biết có video mới vừa xem xong. Phải tự bắn lại HistoryLoadRequested
//   /// SAU KHI push() trả về (await), đúng lúc user đã pop khỏi Player.
//   Future<void> _openPlayer(VideoEntity video) async {
//     await Navigator.of(
//       context,
//     ).push(MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)));

//     if (!mounted) return;
//     context.read<HistoryBloc>().add(const HistoryLoadRequested());
//   }

//   Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           TextButton(
//             onPressed: onSeeAll,
//             child: const Text(
//               'See all',
//               style: TextStyle(color: Colors.blue, fontSize: 12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/image_caching/core/customappbar.dart';
import 'package:flutterpractisetasks/video_player/bloc/connectivity/connectivity_cubit.dart';
import 'package:flutterpractisetasks/video_player/bloc/connectivity/connectivity_state.dart';
import 'package:flutterpractisetasks/video_player/bloc/downloads/downloads_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/downloads/downloads_event.dart';
import 'package:flutterpractisetasks/video_player/bloc/downloads/downloads_state.dart';
import 'package:flutterpractisetasks/video_player/bloc/history_bloc/history_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/history_bloc/history_event.dart';
import 'package:flutterpractisetasks/video_player/bloc/history_bloc/history_state.dart';
import 'package:flutterpractisetasks/video_player/bloc/popular_bloc/popular_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/popular_bloc/popular_event.dart';
import 'package:flutterpractisetasks/video_player/bloc/popular_bloc/popular_state.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/error_retry_banner.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/history_tile.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/offline_banner.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/video_card.dart';
import 'package:flutterpractisetasks/video_player/data/pages/main_pages/video_player_screen.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/video_grid_card.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';
import 'package:flutterpractisetasks/widgets/components/apptoast.dart';

/// LƯU Ý: KHÔNG tạo BlocProvider mới ở đây — PopularBloc/HistoryBloc/
/// SearchBloc đã được cung cấp từ bên ngoài lúc mở module (providers: [...]
/// trong _openModule). Chỉ đọc lại qua context.read/BlocBuilder.
class HomePageVideoPlayer extends StatefulWidget {
  const HomePageVideoPlayer({super.key});

  @override
  State<HomePageVideoPlayer> createState() => _HomePageVideoPlayerState();
}

class _HomePageVideoPlayerState extends State<HomePageVideoPlayer> {
  late final ScrollController _scrollController;
  late final ScrollController _feedScrollController;
  late final PageController _bannerPageController;
  late final ValueNotifier<int> _currentBannerPage;

  // Instance RIÊNG cho màn hình này (không qua _openModule) — connectivity
  // và downloads đều là concern độc lập, không cần chia sẻ state với
  // Bloc nào khác.
  late final ConnectivityCubit _connectivityCubit;
  late final DownloadsBloc _downloadsBloc;

  // Số video đầu dùng làm banner carousel — phần feed ngang bên dưới sẽ
  // bỏ qua đúng số này, không lặp lại video đã có trong banner.
  static const _bannerCount = 5;

  @override
  void initState() {
    super.initState();

    _connectivityCubit = ConnectivityCubit();
    _downloadsBloc = DownloadsBloc();

    // Bloc được tạo từ bên ngoài (chưa tự load), nên phải tự bắn event
    // load ban đầu ở đây — khác với cách viết cũ (Bloc tự load lúc khởi tạo).
    context.read<PopularBloc>().add(const PopularLoadRequested());
    context.read<HistoryBloc>().add(const HistoryLoadRequested());
    // Load luôn từ đầu (không đợi biết offline) — để nếu app mở lên đã
    // offline sẵn, danh sách đã tải sẵn sàng ngay, không phải chờ
    // ConnectivityCubit check xong rồi mới bắn load lần đầu.
    _downloadsBloc.add(const DownloadsLoadRequested());

    _scrollController = ScrollController();
    // Trigger infinite scroll theo dải NGANG chứa feed Popular — KHÔNG
    // dùng _scrollController (trang dọc) nữa, vì cuộn hết trang dọc
    // (qua cả Watch History, error banner...) không còn đồng nghĩa với
    // "đã xem hết feed Popular" như lúc feed còn là lưới dọc.
    _feedScrollController = ScrollController()..addListener(_onFeedScroll);
    _bannerPageController = PageController();
    _currentBannerPage = ValueNotifier(0);
  }

  void _onFeedScroll() {
    // CHỦ ĐỘNG chặn load-more khi ĐÃ BIẾT CHẮC đang offline — tránh bắn
    // API để rồi phải đợi timeout HTTP mới catch được lỗi (trải nghiệm
    // tệ + tốn pin). Chỉ chặn khi _connectivityCubit đã check xong lần
    // đầu (isKnown) và kết quả là offline; nếu chưa biết (isKnown=false)
    // vẫn cho thử — best-effort, tránh chặn nhầm lúc mới mở app.
    final connectivity = _connectivityCubit.state;
    if (connectivity.isKnown && !connectivity.isOnline) return;

    final position = _feedScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<PopularBloc>().add(const PopularLoadMoreRequested());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _feedScrollController.dispose();
    _bannerPageController.dispose();
    _currentBannerPage.dispose();
    _connectivityCubit.close();
    _downloadsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // BlocProvider.value (không phải BlocProvider(create:...)) vì cả 2 đã
    // được tạo sẵn ở initState — để _onFeedScroll (method của State,
    // không nằm trong subtree do build() trả về) vẫn truy cập được đúng
    // instance qua field thay vì context.read.
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _connectivityCubit),
        BlocProvider.value(value: _downloadsBloc),
      ],
      // Lắng nghe lỗi để hiện toast — KHÔNG dùng SnackBar theo convention team.
      child: MultiBlocListener(
        listeners: [
          BlocListener<PopularBloc, PopularState>(
            listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
            listener: (context, state) {
              if (state.errorMessage != null) {
                Apptoast.show(state.errorMessage!);
              }
            },
          ),
          // Vừa CHUYỂN sang offline (hoặc mới biết là offline lúc mở app)
          // -> refresh lại danh sách đã tải, phòng trường hợp có video
          // mới được tải ở phiên trước mà _downloadsBloc lúc initState
          // chưa kịp phản ánh (đọc SharedPreferences rẻ, refresh vô tư).
          BlocListener<ConnectivityCubit, ConnectivityState>(
            listenWhen: (prev, curr) =>
                curr.isKnown &&
                !curr.isOnline &&
                (prev.isOnline || !prev.isKnown),
            listener: (context, state) {
              _downloadsBloc.add(const DownloadsLoadRequested());
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xFF0F141C),
          appBar: CustomAppbar(
            backgroundColor: const Color(0xFF0F141C),
            title: 'Video Explorer',
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {}, // TODO: điều hướng sang SearchScreen
              ),
            ],
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OfflineBanner(),
                const SizedBox(height: 16),
                _buildFeaturedBanner(),
                const SizedBox(height: 5),
                _buildMainGrid(),
                const SizedBox(height: 5),
                _buildHistoryOrDownloadsSection(),
                _buildLoadMoreErrorBanner(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Banner lớn trên cùng — chỉ rebuild khi videos/status đổi, không
  // rebuild theo mọi thay đổi khác của PopularState.
  Widget _buildFeaturedBanner() {
    return BlocBuilder<PopularBloc, PopularState>(
      buildWhen: (prev, curr) =>
          prev.videos != curr.videos || prev.status != curr.status,
      builder: (context, state) {
        if (state.status == PopularStatus.loading) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Lỗi NGAY LẦN ĐẦU (chưa có video nào) — khác với lỗi lúc load more
        // (xử lý riêng ở _buildLoadMoreErrorBanner bên dưới).
        if (state.status == PopularStatus.error && state.videos.isEmpty) {
          return ErrorRetryBanner(
            message: state.errorMessage ?? 'Tải thất bại. Vui lòng thử lại!',
            onRetry: () =>
                context.read<PopularBloc>().add(const PopularRetryRequested()),
          );
        }

        if (state.videos.isEmpty) return const SizedBox.shrink();

        // Lấy tối đa _bannerCount video đầu cho carousel — không lấy hết
        // toàn bộ feed vào banner, phần còn lại hiện ở _buildMainGrid.
        final bannerVideos = state.videos.take(_bannerCount).toList();

        return Column(
          children: [
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _bannerPageController,
                itemCount: bannerVideos.length,
                onPageChanged: (index) => _currentBannerPage.value = index,
                itemBuilder: (context, index) {
                  final video = bannerVideos[index];
                  return VideoCard(
                    title: video.title,
                    // TODO: kiểm tra lại chữ ký thật của VideoCard bạn đang có —
                    // VideoGridCard dùng String cho duration, còn bản gốc bạn
                    // gửi lại truyền int (1) cho VideoCard, 2 nơi đang không
                    // nhất quán kiểu dữ liệu. Tạm dùng inSeconds, cần đối chiếu.
                    duration: video.duration.inSeconds,
                    imageUrl: video.thumbnailUrl,
                    onTap: () => _openPlayer(video),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Chỉ Row dot này rebuild khi đổi trang — không rebuild lại
            // cả PageView/banner phía trên, nhờ tách riêng ValueNotifier.
            ValueListenableBuilder<int>(
              valueListenable: _currentBannerPage,
              builder: (context, currentPage, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    bannerVideos.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: index == currentPage ? 8 : 6,
                      height: index == currentPage ? 8 : 6,
                      decoration: BoxDecoration(
                        color: index == currentPage ? Colors.blue : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// Feed Popular dạng dải cuộn NGANG — đồng bộ thẩm mỹ với Saved Videos/
  /// Watch History trong mockup. Vẫn là infinite scroll thật (trigger qua
  /// _feedScrollController khi cuộn gần hết dải NGANG này), chỉ khác
  /// hướng cuộn so với bản GridView dọc trước đó — không ảnh hưởng đến
  /// việc có đạt yêu cầu pagination/infinite scroll của rubric hay không.
  Widget _buildMainGrid() {
    return BlocBuilder<PopularBloc, PopularState>(
      buildWhen: (prev, curr) =>
          prev.videos != curr.videos || prev.status != curr.status,
      builder: (context, state) {
        if (state.videos.length <= _bannerCount) return const SizedBox.shrink();

        final feedVideos = state.videos.skip(_bannerCount).toList();
        final isLoadingMore = state.status == PopularStatus.loadingMore;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Popular',
              onSeeAll: () {
                // Không cần "See all" điều hướng đi đâu khác — đây đã là
                // tab Popular rồi, có thể ẩn nút này nếu muốn (để trống
                // onSeeAll cho đơn giản trước mắt).
              },
            ),
            SizedBox(
              height: 135,
              child: ListView.separated(
                controller: _feedScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: feedVideos.length + (isLoadingMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  // Phần tử cuối cùng là loading indicator khi đang tải
                  // thêm trang — không phải video thật.
                  if (index >= feedVideos.length) {
                    return const SizedBox(
                      width: 40,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  final video = feedVideos[index];
                  return VideoGridCard(
                    title: video.title,
                    duration: video.duration.inSeconds,
                    imageUrl: video.thumbnailUrl,
                    onTap: () => _openPlayer(video),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Đúng yêu cầu: OFFLINE thì hiện "Downloaded Videos" THAY CHO Watch
  /// History (không hiện cả 2 cùng lúc) — vì Watch History chỉ ghi lại
  /// tiến độ xem (metadata), không có gì để PHÁT LẠI thật khi mất mạng
  /// nếu video đó chưa được tải file thật. Downloaded Videos mới là thứ
  /// user thực sự dùng được lúc offline.
  Widget _buildHistoryOrDownloadsSection() {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      buildWhen: (prev, curr) => prev.isOnline != curr.isOnline,
      builder: (context, connectivity) {
        // Chưa biết chắc (isKnown=false, lúc mới mở app) -> tạm coi như
        // online, tránh nhấp nháy đổi qua đổi lại section ngay khi vừa
        // vào màn hình.
        final isOffline = connectivity.isKnown && !connectivity.isOnline;
        return isOffline
            ? _buildDownloadedVideosSection()
            : _buildWatchHistorySection();
      },
    );
  }

  Widget _buildDownloadedVideosSection() {
    return BlocBuilder<DownloadsBloc, DownloadsState>(
      builder: (context, state) {
        if (state.videos.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Downloaded Videos', onSeeAll: () {}),
                const Text(
                  'Chưa có video nào được tải về máy.\nBấm biểu tượng tải khi đang xem video để lưu lại xem offline.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Downloaded Videos', onSeeAll: () {}),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: state.videos.length,
                itemBuilder: (context, index) {
                  final video = state.videos[index];
                  return HistoryTile(
                    title: video.title,
                    durationText: video.duration.inSeconds,
                    // 1.0 (đầy thanh) vì đây là "đã tải trọn vẹn", khác ý
                    // nghĩa progress của Watch History ("đang xem dở").
                    progress: 1.0,
                    imageUrl: video.thumbnailUrl,
                    onTap: () => _openPlayer(video),
                    onDelete: () => _downloadsBloc.add(
                      DownloadRemoveRequested(
                        videoId: video.id,
                        source: video.source,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWatchHistorySection() {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state.items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Watch History',
              onSeeAll: () {
                // TODO: navigationShell.goBranch(index của tab History)
              },
            ),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return HistoryTile(
                    title: item.video.title,
                    durationText: item.progress.durationSeconds,
                    progress: item.progress.progressRatio,
                    imageUrl: item.video.thumbnailUrl,
                    onTap: () => _openPlayer(item.video),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// Banner lỗi RIÊNG cho trường hợp lỗi lúc load more (đã có video cũ
  /// trong feed) — khác với lỗi lần đầu đã xử lý trong _buildFeaturedBanner.
  Widget _buildLoadMoreErrorBanner() {
    return BlocBuilder<PopularBloc, PopularState>(
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (context, state) {
        if (state.status == PopularStatus.error && state.videos.isNotEmpty) {
          return ErrorRetryBanner(
            message: state.errorMessage ?? 'Failed to load more videos',
            onRetry: () =>
                context.read<PopularBloc>().add(const PopularRetryRequested()),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  bool _isOpeningPlayer = false;

  /// Push sang VideoPlayerScreen. Navigator.push trực tiếp (không qua
  /// GoRouter) vì Player là fullscreen tạm thời, không cần giữ trong
  /// URL/lịch sử điều hướng như các tab chính.
  ///
  /// QUAN TRỌNG: HomePageVideoPlayer chỉ initState() 1 LẦN, không tự
  /// chạy lại khi quay về từ Navigator.push — nên HistoryBloc không tự
  /// biết có video mới vừa xem xong. Phải tự bắn lại HistoryLoadRequested
  /// SAU KHI push() trả về (await), đúng lúc user đã pop khỏi Player.
  Future<void> _openPlayer(VideoEntity video) async {
    // FIX: chặn double-tap. Trong lúc MaterialPageRoute đang chạy
    // animation chuyển màn hình (~300ms), VideoCard cũ vẫn hiển thị và
    // vẫn bắt tap được -> bấm 2 lần liên tiếp sẽ push 2 VideoPlayerScreen
    // chồng nhau, mỗi cái 1 PlaybackCubit riêng, tự fallback độc lập ->
    // log 2 chuỗi xen kẽ nhau trông như 1 chuỗi bị lỗi lặp/độ dài đổi.
    if (_isOpeningPlayer) return;
    _isOpeningPlayer = true;

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)));

    _isOpeningPlayer = false;
    if (!mounted) return;
    context.read<HistoryBloc>().add(const HistoryLoadRequested());
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'See all',
              style: TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
