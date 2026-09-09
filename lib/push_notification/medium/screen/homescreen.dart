import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/widgets/components/commonText.dart';
import 'package:flutterpractisetasks/push_notification/medium/bloc/articlebloc/article_bloc.dart';
import 'package:flutterpractisetasks/push_notification/medium/bloc/articlebloc/article_event.dart';
import 'package:flutterpractisetasks/push_notification/medium/bloc/articlebloc/article_state.dart';
import 'package:flutterpractisetasks/push_notification/medium/widget/components/categorybar.dart';
import 'package:flutterpractisetasks/push_notification/medium/widget/components/custombottomsheet.dart';
import 'package:flutterpractisetasks/push_notification/medium/widget/components/newscard.dart';
import 'package:go_router/go_router.dart';

class NewsHomescreen extends StatefulWidget {
  const NewsHomescreen({super.key});

  @override
  State<NewsHomescreen> createState() => _NewsHomescreenState();
}

class _NewsHomescreenState extends State<NewsHomescreen> {
  final List<String> _categories = [
    'general',
    'technology',
    'business',
    'sports',
    'health',
    'science',
    'entertainment',
  ];

  String _selectedCategory = 'general'; // mặc định

  @override
  Widget build(BuildContext context) {
    //  BlocProvider bao ngoài cùng
    return BlocProvider(
      create: (_) =>
          ArticleBloc()..add(FetchArticleEvent(category: _selectedCategory)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
          title: Commontext(
            title: 'Top Headlines',
            colorText: Colors.white,
            fontSize: '18',
            fontWeight: FontWeight.bold,
          ),
          actions: [
            IconButton(
              onPressed: () {
                context.pushNamed('settings');
              },
              icon: const Icon(Icons.notifications, color: Colors.white),
            ),
          ],
        ),
        //  Builder để context thấy được ArticleBloc
        body: Builder(
          builder: (context) => Column(
            children: [
              _buildCategoryRow(context), //  truyền context vào
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 8),
                child: Row(
                  children: [
                    Commontext(
                      title: 'Top Stories',
                      colorText: Colors.black,
                      fontSize: '16',
                      fontWeight: FontWeight.bold,
                    ),
                    Spacer(),
                    Commontext(
                      title: 'Updated just now',
                      colorText: Colors.grey.shade500,
                      fontSize: '10',
                      fontWeight: FontWeight.normal,
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<ArticleBloc>().add(
                          FetchArticleEvent(category: _selectedCategory),
                        );
                      },
                      icon: const Icon(Icons.sync, size: 20),
                    ),
                  ],
                ),
              ),
              Expanded(
                // ← bắt buộc có Expanded
                child: _buildArticleList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //  Nhận context từ ngoài vào
  Widget _buildCategoryRow(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (_, index) {
          final category = _categories[index];
          return CategoryTab(
            category: category,
            isSelected: _selectedCategory == category,
            onTap: () {
              if (_selectedCategory == category) return;
              setState(() => _selectedCategory = category);

              //  context này đã thấy ArticleBloc
              context.read<ArticleBloc>().add(
                FetchArticleEvent(category: category),
              );
              //TopicService.subscribe(category);
            },
          );
        },
      ),
    );
  }

  Widget _buildArticleList(BuildContext context) {
    return BlocConsumer<ArticleBloc, ArticleState>(
      // CHỈ kích hoạt listener hiển thị BottomSheet khi gói thông báo thực sự thay đổi hoặc có tin mới
      listenWhen: (previous, current) {
        if (current is ArticleLoadingSuccess) {
          final currNoti = current.foregroundNotification;
          if (previous is ArticleLoadingSuccess) {
            return currNoti != previous.foregroundNotification &&
                currNoti != null;
          }
          return currNoti != null;
        }
        return false;
      },
      listener: (context, state) {
        if (state is ArticleLoadingSuccess && state.actionMessage != null) {
          final noti = state.foregroundNotification!;

          // Mở BottomSheet an toàn ở tầng UI
          showModalBottomSheet(
            context: context,
            builder: (ctx) => CustomBottomSheet(
              title: noti.title,
              body: noti.body,
              sourceName: noti.sourceName,
              urlToImage: noti.urlToImage,
              url: noti.url,
            ),
          );
        }
      },
      builder: (context, state) {
        return switch (state) {
          ArticleInitial() => const SizedBox.shrink(),

          ArticleLoading() => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Đang tải...'),
              ],
            ),
          ),

          ArticleLoadingFailure(:final message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Commontext(
                  title: message,
                  fontSize: '14',
                  colorText: Colors.grey,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => context.read<ArticleBloc>().add(
                    FetchArticleEvent(category: _selectedCategory),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          ),

          ArticleLoadingSuccess(:final articles) => RefreshIndicator(
            onRefresh: () async => context.read<ArticleBloc>().add(
              FetchArticleEvent(category: _selectedCategory),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 12, right: 12),
              itemCount: articles.length,
              itemBuilder: (_, index) => Newscard(article: articles[index]),
            ),
          ),
        };
      },
    );
  }
}
