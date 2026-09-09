import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/file_picker/bloc/file_bloc.dart';
import 'package:flutterpractisetasks/file_picker/bloc/file_state.dart';
import 'package:flutterpractisetasks/hub/app_routes/app_routes.dart';
import 'package:flutterpractisetasks/widgets/components/commonText.dart';
import 'package:flutterpractisetasks/widgets/components/media_task_tile.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileBloc, FileState>(
      builder: (context, state) {
        return Scaffold(
          // appBar: AppBar(
          //   title: const Text(
          //     'Dashboard',
          //     style: TextStyle(fontWeight: FontWeight.bold),
          //   ),
          //   actions: [
          //     IconButton(
          //       icon: const Icon(Icons.notifications_none),
          //       onPressed: () {},
          //     ),
          //   ],
          // ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Commontext(
                  title: 'Dashboard',
                  fontWeight: FontWeight.bold,
                  fontSize: '18',
                  colorText: Colors.white,
                ),
                pinned: false,
                floating: true,
                backgroundColor: Colors.black,
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Storage Overview Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade700, Colors.blue.shade500],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cloud Storage',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '14.2 GB / 50 GB',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              value: 0.28,
                              backgroundColor: Colors.white24,
                              color: Colors.white,
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Quick Actions
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.cloud_upload,
                          label: 'Upload File',
                          color: Colors.blue,
                          ontap: () {
                            context.go(AppRoutes.upload);
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.photo_library,
                          label: 'Gallery',
                          color: Colors.purple,
                          ontap: () {},
                        ),
                        _buildActionButton(
                          icon: Icons.history,
                          label: 'History',
                          color: Colors.orange,
                          ontap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Recent Uploads using Reusable Component
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // MediaTaskTile(
                    //   fileName: 'mountains.jpg',
                    //   subtitleText: '2m ago',
                    //   url: 'https://i.ibb.co/abc123/mountains.jpg',
                    //   statusText: 'Done',
                    //   statusColor: Colors.green,
                    //   type: TileType.completed,
                    // ),
                    // MediaTaskTile(
                    //   fileName: 'city_street.png',
                    //   subtitleText: '10m ago',
                    //   url: 'https://i.ibb.co/def456/city-street.png',
                    //   statusText: 'Done',
                    //   statusColor: Colors.green,
                    //   type: TileType.completed,
                    // ),
                  ],
                ),
              ),

              // Thay thế ListView.builder bằng SliverList
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final task = state.completedFiles[index];

                  return MediaTaskTile(
                    fileName: task.filePath.split('/').last,
                    statusText: task.status.name,
                    url: task.remoteUrl,
                    type: TileType.completed,
                    imageUrl: task.filePath,
                  );
                }, childCount: state.completedFiles.length),
              ),
            ],
          ),
          // SingleChildScrollView(
          //   child:
          // ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback ontap,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: () {
            ontap.call();
          },
          icon: Icon(icon, color: color),
          color: color.withOpacity(0.1),
        ),

        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
