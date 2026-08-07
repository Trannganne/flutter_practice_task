import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/hub/app_routes/app_routes.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_bloc.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_event.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_state.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/grid/photogridview.dart';
import 'package:flutterpractisetasks/widgets/components/commonText.dart';
import 'package:go_router/go_router.dart';

class PhotosSection extends StatefulWidget {
  const PhotosSection({super.key});

  @override
  State<PhotosSection> createState() => _PhotosSectionState();
}

class _PhotosSectionState extends State<PhotosSection> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhotoBloc, PhotoState>(
      builder: (context, state) {
        return Column(
          children: [
            // 1. Header bao gồm Tiêu đề & Nút bấm đổi Layout
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Photos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      // Nút Grid 3 cột
                      IconButton(
                        icon: Icon(
                          Icons.grid_on,
                          color: state.columnCount == 3
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        onPressed: () {
                          context.read<PhotoBloc>().add(ColumnCountChange(3));
                        },
                      ),
                      // Nút Grid 2 cột (hoặc List 1 cột)
                      IconButton(
                        icon: Icon(
                          Icons.grid_view,
                          color: state.columnCount == 2
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        onPressed: () {
                          context.read<PhotoBloc>().add(ColumnCountChange(2));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Tái sử dụng PhotoGridView
            PhotoGridView(
              photos: state.pagePhotos, // Chỉ hiển thị ảnh của trang hiện tại
              crossAxisCount:
                  state.columnCount, // Tự động thay đổi số cột mượt mà!
              onPhotoTap: (photo) {
                // Gọi hàm xử lý sự kiện xem chi tiết ảnh
                context.pushNamed(
                  AppRoutes.photoDetails,
                  extra: {
                    'photoBloc': context.read<PhotoBloc>(),
                    'photo': photo,
                  },
                );
                print("Đã xem ảnh: ${photo.id}");
              },
              onFavoriteToggle: (photo) {
                // Gọi hàm xử lý sự kiện lưu favorite/

                context.read<PhotoBloc>().add(ToggleFavoritesEvent(photo));
                print("Đã thả tim ảnh: ${photo.id}");
              },
            ),

            // 3. Thanh phân trang
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nút lùi trang
                IconButton(
                  onPressed: state.currentPage > 1
                      ? () => context.read<PhotoBloc>().add(
                          PageChange(
                            state.currentPage - 1,
                            state.currentPage,
                            state.columnCount,
                          ),
                        )
                      : null,
                  icon: const Icon(Icons.chevron_left, color: Colors.black87),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    shape: const CircleBorder(),
                  ),
                ),
                // Hiển thị Page x of total page
                const SizedBox(width: 16),

                Commontext(
                  title: 'Page ${state.currentPage} of ${state.totalPages}',
                  fontWeight: FontWeight.bold,
                  fontSize: '12',
                ),

                const SizedBox(width: 16),
                // Nút tiến trang(>)
                IconButton(
                  onPressed: state.currentPage < state.totalPages
                      ? () => context.read<PhotoBloc>().add(
                          PageChange(
                            state.currentPage + 1,
                            state.currentPage,
                            state.columnCount,
                          ),
                        )
                      : null,
                  icon: const Icon(Icons.chevron_right, color: Colors.black87),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
