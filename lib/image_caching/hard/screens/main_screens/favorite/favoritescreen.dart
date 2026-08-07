import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_bloc.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_state.dart';
import 'package:flutterpractisetasks/image_caching/models/photo_model.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_event.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    // Khi màn hình được khởi tạo, tải danh sách ảnh yêu thích từ cơ sở dữ liệu
    super.initState();
    context.read<PhotoBloc>().add(LoadFavoritesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // Nút Làm mới danh sách Yêu thích nếu cần
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Gọi event tải lại danh sách yêu thích
              context.read<PhotoBloc>().add(LoadFavoritesEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<PhotoBloc, PhotoState>(
        builder: (context, state) {
          // 1. Trạng thái Đang tải (Loading)
          if (state.status == PhotoStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Giả định biến chứa danh sách ảnh yêu thích trong state là favoritePhotos
          // Nếu bạn chưa tách riêng, có thể dùng: state.photos.where((p) => p.isFavorited).toList();
          final favorites = state.favoritePhotos;

          // 2. Trạng thái Trống (Empty State)
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Favorites Yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore and heart your favorite photos\nto see them saved here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // 3. Trạng thái Có dữ liệu (Grid View hiển thị ảnh)
          return RefreshIndicator(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 cột
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75, // Tỷ lệ khung hình dọc
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final photo = favorites[index];
                return _FavoritePhotoCard(photo: photo);
              },
            ),
            onRefresh: () async {
              context.read<PhotoBloc>().add(LoadFavoritesEvent());
            },
          );
        },
      ),
    );
  }
}

// Widget Item thẻ ảnh trong Grid
class _FavoritePhotoCard extends StatelessWidget {
  final PhotoEnity photo;

  const _FavoritePhotoCard({required this.photo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Chuyển sang màn hình Chi tiết Ảnh
        // context.push('${AppRoutes.explore}/photo-detail', extra: photo);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Hiển thị Ảnh có Hero Animation
            Hero(
              tag: photo.id,
              child: Image.network(
                photo.url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),

            // 2. Lớp phủ Gradient đen mờ ở phía dưới để rõ chữ hơn
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

            // 3. Nút Bỏ Yêu thích (Unfavorite) ở góc trên bên phải
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black38,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    // Bắn Event bỏ Yêu thích trong PhotoBloc
                    context.read<PhotoBloc>().add(ToggleFavoritesEvent(photo));
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.favorite, color: Colors.red, size: 20),
                  ),
                ),
              ),
            ),

            // 4. Thông tin Tác giả ở đáy ảnh
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    photo.photoGrapher,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: photo.source == PhotoType.pexel
                              ? Colors.teal
                              : Colors.deepOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          photo.source == PhotoType.pexel ? 'Pexels' : 'Picsum',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
