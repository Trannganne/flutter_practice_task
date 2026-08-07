import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/push_notification/hard/bloc/feed_bloc/feed_bloc.dart';
import 'package:flutterpractisetasks/push_notification/hard/bloc/feed_bloc/feed_event.dart';
import 'package:flutterpractisetasks/push_notification/hard/bloc/feed_bloc/feed_state.dart';
import 'package:flutterpractisetasks/push_notification/hard/models/feeditemmodel.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/components/feedcard.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/core/appcolor.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/layout/main_layout.dart';
import 'package:flutterpractisetasks/push_notification/medium/models/articlesmodel.dart';
import 'package:flutterpractisetasks/push_notification/medium/router/approute.dart';
import 'package:go_router/go_router.dart';

class NewsHubScreen extends StatelessWidget {
  const NewsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        debugPrint("Create FeedBloc");
        return FeedBloc()..add(FetchFeedEvent());
      },
      child: MainLayout(
        appBar: AppBar(
          leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
          backgroundColor: Appcolor.primary,
          foregroundColor: Colors.white,
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'News',
                  style: TextStyle(
                    color: Appcolor.textTertiary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                TextSpan(
                  text: 'Hub',
                  style: TextStyle(
                    color: Appcolor.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          ],
        ),
        body: BlocBuilder<FeedBloc, FeedState>(
          builder: (context, state) {
            debugPrint(state.runtimeType.toString());
            return switch (state) {
              FeedInitial() => const SizedBox.shrink(),

              FeedLoading() => const Center(child: CircularProgressIndicator()),

              FeedError(:final message, :final cachedItems) =>
                cachedItems.isNotEmpty
                    ? _buildList(
                        context,
                        cachedItems,
                        hasMore: false,
                        isOffline: true,
                      )
                    : Center(child: Text(message)),

              FeedLoaded() || FeedLoadingMore() => _buildList(
                context,
                (state as FeedLoaded).items,
                hasMore: state.hasMore,
                isOffline: state.isOffline,
                isLoadingMore: state is FeedLoadingMore,
              ),
            };
          },
        ),
      ),
    );
  }

  // Widget _buildList(
  //   BuildContext context,
  //   List<FeedItem> items, {
  //   required bool hasMore,
  //   required bool isOffline,
  //   bool isLoadingMore = false,
  // }) {
  //   print("Build List: ${items.length}");
  //   return RefreshIndicator(
  //     onRefresh: () async => context.read<FeedBloc>().add(RefreshFeedEvent()),
  //     // NotificationListener bắt sự kiện cuộn để tự động load more
  //     child: NotificationListener<ScrollNotification>(
  //       onNotification: (scroll) {
  //         if (hasMore &&
  //             !isLoadingMore &&
  //             scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
  //           context.read<FeedBloc>().add(LoadMoreFeedEvent());
  //         }
  //         return false;
  //       },
  //       child: ListView.builder(
  //         padding: const EdgeInsets.all(12),
  //         itemCount:
  //             items.length + (isLoadingMore ? 1 : 0) + (isOffline ? 1 : 0),
  //         itemBuilder: (context, index) {
  //           // Banner offline ở đầu list
  //           if (isOffline && index == 0) {
  //             return _buildOfflineBanner();
  //           }
  //           final realIndex = isOffline ? index - 1 : index;

  //           // Loading indicator ở cuối list khi load more
  //           if (realIndex >= items.length) {
  //             return const Center(
  //               child: Padding(
  //                 padding: EdgeInsets.all(16),
  //                 child: CircularProgressIndicator(strokeWidth: 2),
  //               ),
  //             );
  //           }

  //           return Feedcard(
  //             item: items[realIndex],
  //             onTap: () => _onTapItem(context, items[realIndex]),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildList(
    BuildContext context,
    List<FeedItem> items, {
    required bool hasMore,
    required bool isOffline,
    bool isLoadingMore = false,
  }) {
    print("Build List: ${items.length}");

    // 1. Tính toán xem có cần hiển thị thêm một ô (Row) ở cuối danh sách cho việc Load More hay không
    // Nếu đang loading hặc còn dữ liệu để load (hasMore) thì +1 ô ở cuối
    final bool showBottomRow = hasMore || isLoadingMore;

    return RefreshIndicator(
      onRefresh: () async => context.read<FeedBloc>().add(RefreshFeedEvent()),
      // ĐÃ XÓA NotificationListener ở đây để chặn việc tự động gọi sự kiện khi cuộn
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length + (showBottomRow ? 1 : 0) + (isOffline ? 1 : 0),
        itemBuilder: (context, index) {
          // Banner offline ở đầu list
          if (isOffline && index == 0) {
            return _buildOfflineBanner();
          }
          final realIndex = isOffline ? index - 1 : index;

          // 2. Xử lý phần hiển thị ở đáy danh sách (Nút bấm hoặc Vòng quay Loading)
          if (realIndex >= items.length) {
            if (isLoadingMore) {
              // Trạng thái đang tải dữ liệu: Hiện vòng xoay
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            } else {
              // Trạng thái bình thường và còn dữ liệu: Hiện nút bấm thủ công
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Kích hoạt sự kiện lấy thêm dữ liệu khi người dùng bấm nút
                    context.read<FeedBloc>().add(LoadMoreFeedEvent());
                  },
                  icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                  label: const Text(
                    'Xem thêm bài viết',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }
          }

          // Hiển thị phần tử danh sách bình thường
          return Feedcard(
            item: items[realIndex],
            onTap: () => _onTapItem(context, items[realIndex]),
          );
        },
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, size: 14, color: Colors.orange.shade700),
          const SizedBox(width: 6),
          Text(
            'Offline — đang hiện dữ liệu đã lưu',
            style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
          ),
        ],
      ),
    );
  }

  void _onTapItem(BuildContext context, FeedItem item) {
    context.pushNamed('feedItemDetail', extra: item);
  }
}
