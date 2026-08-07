import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/push_notification/easy/models/post.dart';
import 'package:flutterpractisetasks/push_notification/easy/screen/components/commonText.dart';
import 'package:go_router/go_router.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2, // Tạo độ nổi nhẹ giúp card tách biệt khỏi nền
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bo góc hiện đại hơn
      ),
      margin: const EdgeInsets.only(
        bottom: 16,
      ), // Tăng khoảng cách giữa các bài post
      child: InkWell(
        borderRadius: BorderRadius.circular(16), // Trùng với độ bo góc của Card
        onTap: () {
          // Giữ nguyên logic điều hướng
          context.push('/post/${post.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(
            16,
          ), // Tăng padding để nội dung "thở" tốt hơn
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Căn lề trái cho toàn bộ nội dung
            children: [
              // --- Header: Thông tin User & Thời gian ---
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(
                      Icons.person,
                      size: 18,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Commontext(
                    title: 'User ${post.userId}',
                    fontWeight: FontWeight.w600,
                    colorText: Colors.black87,
                  ),
                  const Spacer(),
                  Commontext(
                    title: '${post.id}h ago',
                    colorText: Colors.grey.shade500,
                    fontSize: '13',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- Body: Tiêu đề bài viết ---
              Commontext(
                title: post.title,
                fontSize: '16', // Tăng nhẹ size tiêu đề
                fontWeight: FontWeight.bold,
                colorText: Colors.black,
              ),
              const SizedBox(height: 6),

              // --- Body: Nội dung tóm tắt ---
              Commontext(
                title: post.body,
                colorText:
                    Colors.grey.shade700, // Đổi màu xám đậm vừa phải để dễ đọc
                fontWeight: FontWeight.normal,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // --- Footer: Tương tác (Like, Comment, Bookmark) ---
              Row(
                children: [
                  // Nút Like
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Commontext(
                    title: '${post.id * 3}',
                    colorText: Colors.grey.shade600,
                    fontSize: '14',
                  ),
                  const SizedBox(width: 20),

                  // Nút Comment
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 19,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Commontext(
                    title: '${post.id}',
                    fontSize: '14',
                    colorText: Colors.grey.shade600,
                  ),
                  const Spacer(),

                  // Nút Bookmark
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 21,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
