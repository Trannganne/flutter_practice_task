import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/search_bloc/search_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/search_bloc/search_event.dart';
import 'package:flutterpractisetasks/video_player/bloc/search_bloc/search_state.dart';
import 'package:flutterpractisetasks/video_player/data/pages/main_pages/video_player_screen.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/error_retry_banner.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/video_grid_card.dart';
import 'package:flutterpractisetasks/video_player/models/video_entity_model.dart';

/// Tab Search (Pixabay). SearchBloc đã tự debounce 500ms nội bộ — UI chỉ
/// cần bắn SearchQueryChanged mỗi lần onChanged, KHÔNG debounce lại ở đây.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc(),
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
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          switch (state.status) {
            case SearchStatus.emptyQuery:
              return const Center(
                child: Text(
                  'Gõ từ khoá để tìm video',
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
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
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
                    duration: '${video.duration.inSeconds}s',
                    imageUrl: video.thumbnailUrl,
                    onTap: () => _openPlayer(context, video),
                  );
                },
              );
          }
        },
      ),
    );
  }

  Future<void> _openPlayer(BuildContext context, VideoEntity video) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)));
  }
}
