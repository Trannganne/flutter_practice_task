import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/image_caching/core/customappbar.dart';
import 'package:flutterpractisetasks/video_player/bloc/player_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/player_state.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/error_banner.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/history_tile.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/video_card.dart';
import 'package:flutterpractisetasks/video_player/data/pages/widgets/video_grid_card.dart';
import 'package:flutterpractisetasks/widgets/common_tabbar/custom_tabbar.dart';
import 'package:flutterpractisetasks/widgets/components/apptoast.dart';

class HomePageVideoPlayer extends StatefulWidget {
  const HomePageVideoPlayer({super.key});

  @override
  State<HomePageVideoPlayer> createState() => _HomePageVideoPlayerState();
}

class _HomePageVideoPlayerState extends State<HomePageVideoPlayer>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlayerBloc, Playerstate>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F141C),
          appBar: CustomAppbar(
            backgroundColor: const Color(0xFF0F141C),
            // elevation: 0,
            // leading: const Icon(Icons.menu, color: Colors.white),
            title: 'Video Explorer',
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    'https://cdn.pixabay.com/video/2025/09/06/302062_small.jpg',
                  ),
                ),
              ),
            ],
            // bottom: TabBar(
            //   controller: _tabController,
            //   isScrollable: true,
            //   indicatorColor: Colors.blue,
            //   labelColor: Colors.blue,
            //   unselectedLabelColor: Colors.grey,
            //   tabs: const [
            //     Tab(text: 'Discover'),
            //     Tab(text: 'Trending'),
            //     Tab(text: 'Categories'),
            //     Tab(text: 'Channels'),
            //   ],
            // ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTabBar(
                  tabController: _tabController,
                  labels: ['Discover', 'Trending', 'Categories', 'Channels'],
                  labelColor: Colors.blue,
                ),
                const SizedBox(height: 16),
                // Featured Video Card
                const VideoCard(
                  title: 'Surfing Paradise\nIndonesia',
                  duration: '03:12',
                  imageUrl:
                      'https://cdn.pixabay.com/video/2025/09/06/302062_small.jpg',
                ),
                const SizedBox(height: 8),
                // Indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: index == 0 ? 8 : 6,
                      height: index == 0 ? 8 : 6,
                      decoration: BoxDecoration(
                        color: index == 0 ? Colors.blue : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Saved Videos Section
                _buildSectionHeader('Saved Videos'),
                SizedBox(
                  height: 150,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: const [
                      VideoGridCard(
                        title: 'Norway Fjords\nAerial View',
                        duration: '02:45',
                        imageUrl:
                            'https://cdn.pixabay.com/video/2025/09/06/302062_small.jpg',
                      ),
                      SizedBox(width: 12),
                      VideoGridCard(
                        title: 'Desert Roads\nAdventure',
                        duration: '03:07',
                        imageUrl:
                            'https://cdn.pixabay.com/video/2025/09/06/302062_small.jpg',
                      ),
                      SizedBox(width: 12),
                      VideoGridCard(
                        title: 'Neon City\nTimelapse',
                        duration: '01:58',
                        imageUrl:
                            'https://cdn.pixabay.com/video/2025/09/06/302062_small.jpg',
                      ),
                    ],
                  ),
                ),

                // Watch History Section
                _buildSectionHeader('Watch History'),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.videos.length,
                    itemBuilder: (context, index) {
                      final video = state.videos[index];
                      return HistoryTile(
                        title: '$video.name',
                        durationText: '02:10 / 04:30',
                        progress: 0.5,
                        imageUrl: '$video.thumbnail',
                      );
                    },
                  ),
                ),

                // Error Banner
                ErrorBanner(
                  title: 'Failed to load more videos',
                  subtitle: 'Please check your connection.',
                  onRetry: () {},
                ),

                // Mini Player Bar
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2630),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          'https://cdn.pixabay.com/video/2025/09/06/302062_small.jpg',
                          width: 50,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Mountains in Clouds',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '01:12 / 03:45',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.pause, color: Colors.white),
                      const SizedBox(width: 12),
                      const Icon(Icons.close, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      listener: (context, state) {
        if (state.actionMessage != null && state.actionMessage!.isNotEmpty) {
          Apptoast.show(state.actionMessage!);
        }
      },
    );
  }

  Widget _buildSectionHeader(String title) {
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
            onPressed: () {},
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
