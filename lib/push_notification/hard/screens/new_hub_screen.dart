import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/push_notification/hard/bloc/feed_bloc/feed_bloc.dart';
import 'package:flutterpractisetasks/push_notification/hard/bloc/feed_bloc/feed_event.dart';
import 'package:flutterpractisetasks/push_notification/hard/bloc/feed_bloc/feed_state.dart';
import 'package:flutterpractisetasks/push_notification/hard/models/feeditemmodel.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/components/feed_card.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/core/appcolor.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/layout/main_layout.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/error_retry_banner.dart';
import 'package:go_router/go_router.dart';
import 'package:flutterpractisetasks/widgets/components/commonText.dart';
import 'package:flutterpractisetasks/push_notification/hard/models/notificationmodel.dart';

class NewsHubScreen extends StatefulWidget {
  const NewsHubScreen({super.key});

  @override
  State<NewsHubScreen> createState() => _NewsHubScreenState();
}

class _NewsHubScreenState extends State<NewsHubScreen> {
  static const _bannerCount = 6;
  late final PageController _bannerPageController;
  late final ValueNotifier<int> _currentBannerPage = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _bannerPageController.dispose();
    _currentBannerPage.dispose();
    super.dispose();
  }

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
    final bannerItems = items
        .where((item) => item.type == "article")
        .take(_bannerCount)
        .toList();

    // Không hiển thị lại 6 bài đã nằm trong banner
    final remainingItems = items.skip(bannerItems.length).toList();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FeedBloc>().add(RefreshFeedEvent());
      },
      child: CustomScrollView(
        slivers: [
          if (isOffline)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: _buildOfflineBanner(),
              ),
            ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Text(
                'Top Headlines',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: _buildFeaturedBanner(bannerItems)),

          if (remainingItems.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 10),
                child: Text(
                  'Latest News',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = remainingItems[index];

                return Feedcard(
                  item: item,
                  onTap: () => _onTapItem(context, item),
                );
              }, childCount: remainingItems.length),
            ),
          ),

          if (hasMore || isLoadingMore)
            SliverToBoxAdapter(
              child: _buildLoadMoreSection(
                context,
                isLoadingMore: isLoadingMore,
              ),
            ),

          // Chừa chỗ cho Notification Center cố định phía dưới
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
    );
  }

  Widget _buildLoadMoreSection(
    BuildContext context, {
    required bool isLoadingMore,
  }) {
    if (isLoadingMore) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      child: OutlinedButton.icon(
        onPressed: () {
          context.read<FeedBloc>().add(LoadMoreFeedEvent());
        },
        icon: const Icon(Icons.arrow_downward_rounded),
        label: const Text('Xem thêm bài viết'),
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
  //   final bannerItems = items.take(_bannerCount).toList();

  //   // Không hiển thị lại 6 bài đã nằm trong banner
  //   final remainingItems = items.skip(bannerItems.length).toList();

  //   print("Build List: ${items.length}");

  //   // 1. Tính toán xem có cần hiển thị thêm một ô (Row) ở cuối danh sách cho việc Load More hay không
  //   // Nếu đang loading hặc còn dữ liệu để load (hasMore) thì +1 ô ở cuối
  //   final bool showBottomRow = hasMore || isLoadingMore;

  //   return RefreshIndicator(
  //     onRefresh: () async => context.read<FeedBloc>().add(RefreshFeedEvent()),
  //     // ĐÃ XÓA NotificationListener ở đây để chặn việc tự động gọi sự kiện khi cuộn
  //     child: ListView.builder(
  //       padding: const EdgeInsets.all(12),
  //       itemCount: items.length + (showBottomRow ? 1 : 0) + (isOffline ? 1 : 0),
  //       itemBuilder: (context, index) {
  //         final int headlineIndex = isOffline ? 1 : 0;
  //         if (index == headlineIndex) {
  //           return Padding(
  //             padding: const EdgeInsets.all(8),
  //             child: Row(
  //               children: [
  //                 Commontext(
  //                   title: 'Top Headlines',
  //                   colorText: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: '24',
  //                 ),
  //               ],
  //             ),
  //           );
  //         }
  //         // Tiêu đề

  //         // Banner offline ở đầu list
  //         if (isOffline && index == 0) {
  //           return _buildOfflineBanner();
  //         }
  //         final realIndex = isOffline ? index - 1 : index;

  //         // 2. Xử lý phần hiển thị ở đáy danh sách (Nút bấm hoặc Vòng quay Loading)
  //         if (realIndex >= items.length) {
  //           if (isLoadingMore) {
  //             // Trạng thái đang tải dữ liệu: Hiện vòng xoay
  //             return const Center(
  //               child: Padding(
  //                 padding: EdgeInsets.all(16),
  //                 child: CircularProgressIndicator(strokeWidth: 2),
  //               ),
  //             );
  //           } else {
  //             // Trạng thái bình thường và còn dữ liệu: Hiện nút bấm thủ công
  //             return Padding(
  //               padding: const EdgeInsets.symmetric(
  //                 vertical: 16,
  //                 horizontal: 32,
  //               ),
  //               child: OutlinedButton.icon(
  //                 style: OutlinedButton.styleFrom(
  //                   padding: const EdgeInsets.symmetric(vertical: 12),
  //                   side: BorderSide(color: Colors.grey.shade800),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //                 onPressed: () {
  //                   // Kích hoạt sự kiện lấy thêm dữ liệu khi người dùng bấm nút
  //                   context.read<FeedBloc>().add(LoadMoreFeedEvent());
  //                 },
  //                 icon: const Icon(Icons.arrow_downward_rounded, size: 18),
  //                 label: const Text(
  //                   'Xem thêm bài viết',
  //                   style: TextStyle(fontWeight: FontWeight.w600),
  //                 ),
  //               ),
  //             );
  //           }
  //         }

  //         // Hiển thị phần tử danh sách bình thường
  //         return Feedcard(
  //           item: items[realIndex],
  //           onTap: () => _onTapItem(context, items[realIndex]),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildFeaturedBanner(List<FeedItem> items) {
    final bannerItems = items.take(_bannerCount).toList();

    if (bannerItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _bannerPageController,
            itemCount: bannerItems.length,
            onPageChanged: (index) {
              _currentBannerPage.value = index;
            },
            itemBuilder: (context, index) {
              final item = bannerItems[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Feedcard(
                  item: item,
                  onTap: () => _onTapItem(context, item),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // Lắng nghe sự thay đổi của _currentBannerPage để cập nhật chỉ số trang hiện tại
        ValueListenableBuilder<int>(
          valueListenable: _currentBannerPage,
          builder: (context, currentPage, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(bannerItems.length, (index) {
                final isSelected = index == currentPage;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isSelected ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Appcolor.textSecondary
                        : Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  // Nếu nhiều widget dùng thì sẽ thiết kế lại truyền tham số vào
  Widget _showHeaderBottomSheet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Commontext(title: 'Notification Center'),
          Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 153, 151, 151),
            ),
            onPressed: () {},
            child: Commontext(
              title: 'Clear all',
              colorText: Colors.white,
              fontSize: '14',
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _showRowTap(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Commontext(title: 'Today'),
          Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 153, 151, 151),
            ),
            onPressed: () {},
            child: Commontext(
              title: '$count',
              colorText: Colors.white,
              fontSize: '14',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationBottomSheet(
    BuildContext context,
    FeedItem item,
    List<NotificationItem> notifications,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _showHeaderBottomSheet(context),
              const SizedBox(height: 16),
              _showRowTap(context, notifications.length),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(item.description!),
              const SizedBox(height: 16),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.pop(context);
              //     _onTapItem(context, item);
              //   },
              //   child: const Text('Xem chi tiết'),
              // ),
            ],
          ),
        );
      },
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
