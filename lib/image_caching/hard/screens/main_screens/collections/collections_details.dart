import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/hub/app_routes/app_routes.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_bloc.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_event.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_state.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/grid/photogridview.dart';
import 'package:flutterpractisetasks/push_notification/easy/screen/components/commonText.dart';
import 'package:go_router/go_router.dart';
import 'package:flutterpractisetasks/image_caching/models/photo_model.dart';
import 'package:flutterpractisetasks/push_notification/easy/screen/components/apptoast.dart';

class CollectionPhotosScreen extends StatefulWidget {
  final String collectionId;
  final String collectionTitle;

  const CollectionPhotosScreen({
    super.key,
    required this.collectionId,
    required this.collectionTitle,
  });

  @override
  State<CollectionPhotosScreen> createState() => _CollectionPhotosScreenState();
}

class _CollectionPhotosScreenState extends State<CollectionPhotosScreen> {
  final ScrollController _scrollController = ScrollController();

  final Set<String> _precachedUrls = {};

  @override
  void initState() {
    super.initState();
    // 1. Tải danh sách ảnh thuộc Collection ngay khi mở màn hình
    _loadPhotos();

    // 2. Lắng nghe sự kiện cuộn trang để kích hoạt Load More
    _scrollController.addListener(_onScroll);
  }

  void _loadPhotos() {
    context.read<PhotoBloc>().add(
      LoadPhotosByCollectionIdEvent(widget.collectionId),
    );
  }

  void _onScroll() {
    if (_isBottom) {
      // Bắn event tải thêm ảnh khi cuộn gần đến đáy
      context.read<PhotoBloc>().add(
        LoadMoreCollectionPhotosEvent(widget.collectionId),
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Kích hoạt khi còn cách đáy 200px
    return currentScroll >= (maxScroll - 200);
  }

  void _precacheNextPhotos(BuildContext context, List<PhotoEnity> photos) {
    for (final photo in photos) {
      if (_precachedUrls.contains(photo.url)) continue;
      _precachedUrls.add(photo.url);
      precacheImage(CachedNetworkImageProvider(photo.url), context);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.collectionTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<PhotoBloc, PhotoState>(
        listener: (context, state) {
          // Hiển thị thông báo nếu xảy ra lỗi
          if (state.actionMessage != null && state.actionMessage!.isNotEmpty) {
            Apptoast.show(state.actionMessage!);
          }

          _precacheNextPhotos(context, state.collectionPhotos);
        },
        builder: (context, state) {
          // 1. Trạng thái Đang tải lần đầu (Loading)
          if (state.status == PhotoStatus.loading &&
              state.collectionPhotos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Trạng thái Thất bại hoặc Danh sách rỗng
          if (state.status == PhotoStatus.failure &&
              state.collectionPhotos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  const Text('Không thể tải danh sách ảnh!'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadPhotos,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state.collectionPhotos.isEmpty) {
            return const Center(
              child: Text(
                'Collection này chưa có ảnh nào.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // 3. Trạng thái Thành công -> Hiển thị danh sách ảnh + Pull to Refresh
          return RefreshIndicator(
            onRefresh: () async {
              context.read<PhotoBloc>().add(
                LoadPhotosByCollectionIdEvent(widget.collectionId),
              );
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  PhotoGridView(
                    photos: state.collectionPhotos,
                    onPhotoTap: (photo) {
                      context.pushNamed(
                        AppRoutes.photoDetails,
                        extra: {
                          'photoBloc': context.read<PhotoBloc>(),
                          'photo': photo,
                        },
                      );
                      debugPrint("Đã xem ảnh: ${photo.id}");
                    },
                    onFavoriteToggle: (photo) {
                      debugPrint("Đã thả tim ảnh: ${photo.id}");
                      context.read<PhotoBloc>().add(
                        ToggleFavoritesEvent(photo),
                      );
                    },
                  ),
                  if (state.isLoadingMoreCollectionPhotos)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.loadMoreFailed)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Không tải thêm được'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                context.read<PhotoBloc>().add(
                                  LoadMoreCollectionPhotosEvent(
                                    widget.collectionId,
                                  ),
                                );
                              },
                              child: Commontext(title: 'Retry', fontSize: '14'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            //GridView.builder(
            //   controller: _scrollController,
            //   padding: const EdgeInsets.all(12),
            //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //     crossAxisCount: state.columnCount > 0 ? state.columnCount : 2,
            //     crossAxisSpacing: 10,
            //     mainAxisSpacing: 10,
            //     childAspectRatio: 0.75,
            //   ),
            //   itemCount: state.isLoadingMoreCollectionPhotos
            //       ? state.collectionPhotos.length +
            //             1 // Thêm 1 item loading ở đáy
            //       : state.collectionPhotos.length,
            //   itemBuilder: (context, index) {
            //     // Hiển thị Loader spinner ở dòng cuối cùng khi đang load more
            //     // if (index >= state.collectionPhotos.length) {
            //     //   return const Center(
            //     //     child: Padding(
            //     //       padding: EdgeInsets.all(16.0),
            //     //       child: CircularProgressIndicator(),
            //     //     ),
            //     //   );
            //     // }

            //     if (index >= state.collectionPhotos.length) {
            //       if (state.loadMoreFailed) {
            //         return Padding(
            //           padding: const EdgeInsets.all(16),
            //           child: Center(
            //             child: Column(
            //               mainAxisSize: MainAxisSize.min,
            //               children: [
            //                 const Text("Không tải thêm được"),
            //                 const SizedBox(height: 8),
            //                 ElevatedButton(
            //                   onPressed: () {
            //                     context.read<PhotoBloc>().add(
            //                       LoadMoreCollectionPhotosEvent(
            //                         widget.collectionId,
            //                       ),
            //                     );
            //                   },
            //                   child: const Text("Retry"),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         );
            //       }

            //       return const Center(child: CircularProgressIndicator());
            //     }

            //     final photo = state.collectionPhotos[index];
            //     return PhotoGridView(
            //       photos: state.collectionPhotos,
            //       onPhotoTap: (photo) {
            //         context.pushNamed(
            //           AppRoutes.photoDetails,
            //           extra: {
            //             'photoBloc': context.read<PhotoBloc>(),
            //             'photo': photo,
            //           },
            //         );
            //         print("Đã xem ảnh: ${photo.id}");
            //       },
            //       onFavoriteToggle: (photo) {
            //         print("Đã thả tim ảnh: ${photo.id}");
            //         context.read<PhotoBloc>().add(ToggleFavoritesEvent(photo));
            //       },
            //     );
            //     //_ReusablePhotoTile(
            //     //   photo: photo,
            //     //   onTap: () {
            //     //     // Mở màn hình xem chi tiết ảnh
            //     //     context.pushNamed(
            //     //       AppRoutes.photoDetails,
            //     //       extra: {
            //     //         'photo': photo,
            //     //         'photoBloc': context.read<PhotoBloc>(),
            //     //       },
            //     //     );
            //     //   },
            //     //   onFavoriteToggle: () {
            //     //     context.read<PhotoBloc>().add(ToggleFavoritesEvent(photo));
            //     //   },
            //     // );
            //   },
            // ),
          );
        },
      ),
    );
  }
}

/// Widget Item ảnh có thể tái sử dụng (Reusable Photo Tile)
class _ReusablePhotoTile extends StatelessWidget {
  final PhotoEnity photo;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const _ReusablePhotoTile({
    required this.photo,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Hiển thị ảnh mạng
            Hero(
              tag: photo.id,
              child: CachedNetworkImage(
                imageUrl: photo.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),

            // 2. Lớp phủ Gradient mờ chân ảnh
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                  stops: [0.6, 1.0],
                ),
              ),
            ),

            // 3. Nút Thả tim (Favorite)
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black38,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onFavoriteToggle,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      photo.isFavorited
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: photo.isFavorited ? Colors.red : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            // 4. Tên Nhiếp ảnh gia
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                photo.photoGrapher,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
