import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/push_notification/easy/bloc/detail_bloc/detail_bloc.dart';
import 'package:flutterpractisetasks/push_notification/easy/bloc/detail_bloc/detail_event.dart';
import 'package:flutterpractisetasks/push_notification/easy/bloc/detail_bloc/detail_state.dart';
import 'package:flutterpractisetasks/push_notification/easy/screen/components/commonText.dart';
import 'package:flutterpractisetasks/push_notification/easy/screen/components/footerlikecomment.dart';

class Postdetailscreen extends StatefulWidget {
  final int postId;
  const Postdetailscreen({super.key, required this.postId});

  @override
  State<Postdetailscreen> createState() => _PostdetailscreenState();
}

class _PostdetailscreenState extends State<Postdetailscreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PostDetailBloc()..add(FetchDetailPostEvent(postId: widget.postId)),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor:
              Colors.grey.shade50, // Nền xám nhẹ giúp nội dung nổi bật
          appBar: AppBar(
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: BlocBuilder<PostDetailBloc, PostDetailState>(
              builder: (context, state) {
                final id = state is PostDetailLoadSuccess ? widget.postId : 0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Commontext(
                      title: 'Chi tiết bài viết',
                      fontSize: "16",
                      colorText: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 2),
                    Commontext(
                      title: '#$id',
                      colorText: Colors.grey.shade500,
                      fontSize: '12',
                    ),
                  ],
                );
              },
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(color: Colors.grey.shade200, height: 1),
            ),
          ),
          body: BlocBuilder<PostDetailBloc, PostDetailState>(
            builder: (context, state) {
              return switch (state) {
                PostDetailInitial() => const SizedBox.shrink(),
                // Đã bọc Center để vòng xoay loading nằm giữa màn hình
                PostDetailLoading() => const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
                PostDetailLoadFailure(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Commontext(
                          title: message,
                          colorText: Colors.grey.shade600,
                          fontSize: '14',
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => context.read<PostDetailBloc>().add(
                            FetchDetailPostEvent(postId: widget.postId),
                          ),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Commontext(
                            title: 'Thử lại',
                            colorText: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PostDetailLoadSuccess() => _buildPostDetail(
                  context,
                  state as PostDetailLoadSuccess,
                ),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPostDetail(BuildContext context, PostDetailLoadSuccess state) {
    return SingleChildScrollView(
      // Chống tràn viền khi bài viết dài
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Hàng thông tin ID và Tác giả ---
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                  child: const Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Commontext(
                      title: 'User ${state.post.userId}',
                      fontWeight: FontWeight.bold,
                      fontSize: '14',
                      colorText: Colors.black87,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Commontext(
                          title: '${state.post.id}h ago',
                          colorText: Colors.grey.shade500,
                          fontSize: '12',
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 3,
                          width: 3,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Thẻ hashtag ID nhỏ nhắn, tinh tế hơn
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Commontext(
                            title: '#ID ${state.post.id}',
                            colorText: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: '11',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 20),

            // --- Tiêu đề bài viết ---
            Commontext(
              maxLines: 3,
              title: state.post.title,
              fontSize: '22', // Tăng kích thước tiêu đề chính
              fontWeight: FontWeight.bold,
              colorText: Colors.black,
            ),

            const SizedBox(height: 14),

            // --- Nội dung bài viết ---
            Commontext(
              title: state.post.body,
              fontSize: '15',
              colorText: Colors
                  .grey
                  .shade800, // Đậm màu hơn một chút để người dùng dễ đọc content lâu
              fontWeight: FontWeight.normal,
            ),

            const SizedBox(height: 28),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),

            // --- Khu vực tương tác dưới cùng ---
            Footerlikecomment(
              icon_like:
                  Icons.favorite_border_rounded, // Đổi icon bo góc mềm mại hơn
              iconComment: Icons.chat_bubble_outline_rounded,
              countLike: state.post.id * 3,
              countComment: state.post.id,
            ),
          ],
        ),
      ),
    );
  }
}
