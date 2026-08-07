import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/hub/app_routes/app_routes.dart';
import 'package:flutterpractisetasks/image_caching/core/customappbar.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_bloc.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_event.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_state.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/main_screens/photosection.dart/photosection.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/widgets/collections_section/collections_section.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Explorepage extends StatefulWidget {
  const Explorepage({super.key});

  @override
  State<Explorepage> createState() => _ExplorepageState();
}

class _ExplorepageState extends State<Explorepage> {
  bool _enabled = true;
  // late final Future<List<PexelCollections>> _mockData;
  // int _selectedCollectionIndex = 0;

  @override
  void initState() {
    super.initState();
    // Dispatch qua instance đã có sẵn từ ancestor, không tự tạo Bloc mới
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PhotoBloc>().add(LoadExploreDataEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Photo Explorer',
        iconData: Icons.menu,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search, size: 30)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert, size: 30)),
        ],
      ),
      body: BlocBuilder<PhotoBloc, PhotoState>(
        builder: (context, state) {
          final loading = state.status == PhotoStatus.loading;
          if (state.status == PhotoStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == PhotoStatus.failure) {
            return Center(
              child: Text('Đã xảy ra lỗi khi tải dữ liệu. Vui lòng thử lại!'),
            );
          }
          if (state.collections.isEmpty) {
            return Center(child: Text('Không có dữ liệu Collections'));
          }

          // final allPhotos = collections.expand((c) => c.photos).toList();// Dùng để lấy tất cả ảnh từ 1 list

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Skeletonizer(
                  enabled: loading,
                  child: CollectionSection(
                    collections: state.collections,
                    onSeeAllPressed: () => context.go(AppRoutes.allCollections),
                    // Kiểm tra lại phần void callback sẽ gọi gì

                    // onCollectionTap: (index) {
                    //   setState(() {
                    //     _selectedCollectionIndex = index;
                    //   });
                    // },
                  ),
                ),
                // Truyền đúng danh sách photos vào PhotosSection
                Skeletonizer(child: PhotosSection(), enabled: loading),
              ],
            ),
          );
        },
      ),
    );
  }
}
