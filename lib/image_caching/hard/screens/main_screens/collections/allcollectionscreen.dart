import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/hub/app_routes/app_routes.dart';
import 'package:flutterpractisetasks/image_caching/core/app_colors.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_bloc.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_event.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_state.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/grid/collection_gridview.dart';
import 'package:flutterpractisetasks/image_caching/models/pexel_collection.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutterpractisetasks/push_notification/easy/screen/components/apptoast.dart';

class AllCollectionsScreen extends StatefulWidget {
  const AllCollectionsScreen({Key? key}) : super(key: key);

  @override
  State<AllCollectionsScreen> createState() => _AllCollectionsScreenState();
}

class _AllCollectionsScreenState extends State<AllCollectionsScreen> {
  @override
  void initState() {
    super.initState();
    // Tự động trigger tải lại danh sách nếu chưa có dữ liệu
    final bloc = context.read<PhotoBloc>();
    if (bloc.state.collections.isEmpty) {
      bloc.add(LoadCollectionsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'All Collections',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<PhotoBloc, PhotoState>(
        listener: (context, state) {
          if (state.actionMessage != null && state.actionMessage!.isNotEmpty) {
            Apptoast.show(state.actionMessage!);
          }
        },
        builder: (context, state) {
          // 1. TRẠNG THÁI LOADING (Lần đầu vào màn hình)
          if (state.status == PhotoStatus.loading &&
              state.collections.isEmpty) {
            final loading = state.status == PhotoStatus.loading;

            return Skeletonizer(
              enabled: loading,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            );
          }

          // 2. TRẠNG THÁI LỖI (Và không có data cache)
          if (state.collections.isEmpty &&
              state.status == PhotoStatus.failure) {
            return _buildErrorState(
              context,
              message: 'Không thể tải danh sách bộ sưu tập',
              onRetry: () =>
                  context.read<PhotoBloc>().add(LoadCollectionsEvent()),
            );
          }

          // 3. TRẠNG THÁI THÀNH CÔNG (Hiển thị Grid + Pull to Refresh)
          return RefreshIndicator(
            onRefresh: () async {
              context.read<PhotoBloc>().add(LoadCollectionsEvent());
            },
            child: CollectionGridView(
              collections: state.collections,
              onCollectionTap: (collection) {
                // TODO: Chuyển hướng sang màn hình Chi tiết ảnh trong Collection
                _navigateToCollectionDetail(context, collection);
              },
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET TRẠNG THÁI LOADING (SKELETON) ---
  Widget _buildLoadingShimmer(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.0,
      ),
      itemCount: 8, // Hiển thị 8 khung giả lập
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET TRẠNG THÁI LỖI (RETRY) ---
  Widget _buildErrorState(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tải lại'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCollectionDetail(
    BuildContext context,
    PexelCollections collection,
  ) {
    // Chuyển sang màn hình xem ảnh của Collection
    context.pushNamed(
      AppRoutes.collectionDetails,
      pathParameters: {'collectionId': collection.id},
      extra: {
        'photoBloc': context.read<PhotoBloc>(),
        'collectionTitle': collection.title,
      },
    );
  }
}
