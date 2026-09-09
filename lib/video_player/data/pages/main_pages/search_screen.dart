import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/permissions/hard/core/widgets/common/commontext.dart';
import 'package:flutterpractisetasks/video_player/bloc/connectivity/connectivity_cubit.dart';
import 'package:flutterpractisetasks/video_player/bloc/search_bloc/search_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/search_bloc/search_event.dart';
import 'package:flutterpractisetasks/video_player/bloc/search_bloc/search_state.dart';
import 'package:flutterpractisetasks/video_player/data/pages/main_pages/video_player_screen.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/error_retry_banner.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/offline_banner.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/video_grid_card.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';

/// Tab Search (Pixabay). SearchBloc đã tự debounce 500ms nội bộ — UI chỉ
/// cần bắn SearchQueryChanged mỗi lần onChanged, KHÔNG debounce lại ở đây.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ConnectivityCubit cấp ở ĐÂY (cha của _SearchView) — không phải bên
    // trong build() của chính _SearchView như HomePage — nên _SearchView
    // (và các State method của nó) truy cập bình thường qua context.read,
    // vì provider nằm PHÍA TRÊN nó trong tree, không phải cùng widget.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SearchBloc()),
        BlocProvider(create: (_) => ConnectivityCubit()),
      ],
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    // Cùng lý do như home_page._onFeedScroll — chặn load-more khi đã
    // BIẾT CHẮC offline, tránh chờ HTTP timeout mới catch được lỗi.
    final connectivity = context.read<ConnectivityCubit>().state;
    if (connectivity.isKnown && !connectivity.isOnline) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<SearchBloc>().add(const SearchLoadMoreRequested());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F141C),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Tìm video trên Pixabay...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: (query) =>
              context.read<SearchBloc>().add(SearchQueryChanged(query)),
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            // Tôi cần biết hết mọi thứ
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                switch (state.status) {
                  case SearchStatus.emptyQuery:
                    return const Center(
                      child: CommonText(
                        text: 'Gõ từ khoá để tìm video',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  case SearchStatus.loading:
                    return const Center(child: CircularProgressIndicator());
                  case SearchStatus.noResults:
                    return const Center(
                      child: Text(
                        'Không tìm thấy video nào',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  case SearchStatus.error:
                    return Center(
                      child: ErrorRetryBanner(
                        message: state.errorMessage ?? 'Đã có lỗi xảy ra',
                        onRetry: () => context.read<SearchBloc>().add(
                          const SearchRetryRequested(),
                        ),
                      ),
                    );
                  case SearchStatus.loaded:
                  case SearchStatus.loadingMore:
                    return GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      // maxCrossAxisExtent (thay vì fixedCrossAxisCount) để khớp với
                      // VideoGridCard đang hardcode width 140 — tránh tràn/lệch ô.
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 160,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                      itemCount:
                          state.videos.length +
                          (state.status == SearchStatus.loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.videos.length) {
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        final video = state.videos[index];
                        return VideoGridCard(
                          title: video.title,
                          duration: video.duration.inSeconds,
                          imageUrl: video.thumbnailUrl,
                          onTap: () => _openPlayer(context, video),
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// FIX cùng bug với home_page.dart: chặn double-tap push 2
  /// VideoPlayerScreen chồng nhau, gây 2 PlaybackCubit độc lập chạy
  /// fallback song song (log xen kẽ trông như 1 chuỗi lỗi/lặp lạ).
  /// SearchScreen là StatelessWidget nên không giữ được biến bool cờ như
  /// _HomePageVideoPlayerState — dùng ModalRoute.isCurrent để kiểm tra
  /// "màn hình này có còn đang là route trên cùng không" thay thế.
  Future<void> _openPlayer(BuildContext context, VideoEntity video) {
    if (ModalRoute.of(context)?.isCurrent != true) {
      return Future.value();
    }
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)));
  }
}
