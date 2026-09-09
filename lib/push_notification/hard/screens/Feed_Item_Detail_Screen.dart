import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/widgets/components/commonText.dart';
import 'package:flutterpractisetasks/push_notification/hard/models/feed_item_model.dart';
import 'package:flutterpractisetasks/push_notification/medium/services/urlservice.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/core/appcolor.dart';
import 'package:go_router/go_router.dart';

class FeedDetailScreen extends StatelessWidget {
  final FeedItem item;
  const FeedDetailScreen({super.key, required this.item});

  // Tính thời gian đăng dạng "3h ago"
  String _timeAgo(DateTime? date) {
    if (date == null) return 'Vừa xong';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // Ước tính thời gian đọc dựa trên trường body
  String _readTime(String? content) {
    if (content == null || content.isEmpty) return '1 phút đọc';
    final wordCount = content.split(' ').length;
    final minutes = (wordCount / 200).ceil(); // Giả định tốc độ 200 từ/phút
    return '$minutes phút đọc';
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem item có ảnh hợp lệ hay không
    final bool hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor:
          Appcolor.primary, // Đổi màu nền chính sang màu xám xanh đậm
      appBar: AppBar(
        backgroundColor: Appcolor.primary,
        foregroundColor: Appcolor.textTertiary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          }, // Sử dụng GoRouter pop thống nhất logic
        ),
        title: Commontext(
          title: item.type == 'article'
              ? 'Chi tiết bài báo'
              : 'Chi tiết bài đăng',
          fontSize: '16',
          fontWeight: FontWeight.w500,
          colorText: Appcolor.textTertiary,
        ),
        actions: [
          // Chỉ hiện nút Share trên AppBar nếu là bài viết có đường dẫn liên kết URL
          if (item.url != null && item.url!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => Urlservice.openArticle(item.url!),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chỉ hiển thị khối ảnh nếu bài viết có ảnh thực tế (thường là Article)
            if (hasImage) _buildThumbnail() else const SizedBox(height: 12),

            _buildContent(context),
            _buildFooterActions(),

            // Chỉ hiển thị khối "Đọc bài gốc" nếu có liên kết URL thực tế
            if (item.url != null && item.url!.isNotEmpty)
              _buildOpenOriginalCard(context),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Phần ảnh thumbnail với Gradient phủ mờ
  Widget _buildThumbnail() {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: item.imageUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Appcolor.bgCard,
              child: const Center(
                child: CircularProgressIndicator(color: Appcolor.textSecondary),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Appcolor.bgCard,
              child: const Icon(
                Icons.broken_image,
                size: 50,
                color: Appcolor.textPrimary,
              ),
            ),
          ),
          // Gradient phủ nhẹ dưới chân ảnh để đọc chữ dễ hơn nếu cần lồng chữ
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black38, Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Khối nội dung chính nằm trong Card màu bgCard độc quyền
  Widget _buildContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Appcolor.bgCard, // Sử dụng màu bgCard làm nổi bật vùng nội dung
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Nguồn/Thể loại, thời gian + biểu tượng Bookmark
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Appcolor.bgColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (item.category ?? item.type).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Appcolor.textTertiary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.sourceName != null && item.sourceName!.isNotEmpty
                    ? item.sourceName!
                    : (item.type == 'post' ? 'Cộng đồng' : 'Tin tức'),
                style: const TextStyle(
                  fontSize: 12,
                  color: Appcolor.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                _timeAgo(item.publishedAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: Appcolor.textTertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tiêu đề chính của FeedItem
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Appcolor.textTertiary, // Chữ trắng nổi bật trên nền bgCard
              height: 1.35,
            ),
          ),

          const SizedBox(height: 10),

          // Tác giả & Thời gian ước tính đọc bài
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 14,
                color: Appcolor.textTertiary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.author != null && item.author!.isNotEmpty
                      ? item.author!
                      : 'Ẩn danh',
                  style: TextStyle(
                    fontSize: 11,
                    color: Appcolor.textTertiary.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.access_time,
                size: 14,
                color: Appcolor.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                _readTime(item.body),
                style: TextStyle(
                  fontSize: 11,
                  color: Appcolor.textTertiary.withOpacity(0.7),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white10, height: 1),
          ),

          // Hiển thị phần Description (Mô tả ngắn) nếu có dữ liệu
          if (item.description != null && item.description!.isNotEmpty) ...[
            Text(
              item.description!,
              style: TextStyle(
                fontSize: 14,
                color: Appcolor.textTertiary.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Thân bài viết (Trường body chính) hiển thị chi tiết, không giới hạn dòng
          Text(
            item.body,
            style: TextStyle(
              fontSize: 14.5,
              color: Appcolor.textTertiary.withOpacity(0.85),
              height: 1.65,
            ),
          ),

          // Lời nhắc thông báo nếu nội dung là preview thu gọn từ trang báo gốc
          if (item.type == 'article') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Appcolor.bgColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: Appcolor.textSecondary, width: 3),
                ),
              ),
              child: Text(
                'Nội dung đầy đủ có trên trang gốc. Nhấn "Đọc bài gốc" bên dưới để xem chi tiết.',
                style: TextStyle(
                  fontSize: 12,
                  color: Appcolor.textTertiary.withOpacity(0.9),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Khu vực tương tác nhanh (Like, Comment, Share) đồng bộ màu sắc thương hiệu
  Widget _buildFooterActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          _buildActionButton(Icons.favorite_border_rounded, '128'),
          const SizedBox(width: 10),
          _buildActionButton(Icons.chat_bubble_outline_rounded, '34'),
          const SizedBox(width: 10),
          _buildActionButton(Icons.ios_share_rounded, 'Chia sẻ'),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Appcolor.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Appcolor.bgColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Appcolor.textTertiary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Appcolor.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Khối xem bài viết gốc dành riêng cho loại dữ liệu tin tức dạng 'article'
  Widget _buildOpenOriginalCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Appcolor.bgCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Appcolor.bgColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nguồn liên kết bài viết',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Appcolor.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.url ?? '',
            style: TextStyle(
              fontSize: 11,
              color: Appcolor.textTertiary.withOpacity(0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Urlservice.openArticle(item.url!),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Đọc bài gốc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Appcolor
                    .textSecondary, // Đổi sang màu đỏ rực rỡ để tạo điểm nhấn Call to Action (CTA)
                foregroundColor: Appcolor.textTertiary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
