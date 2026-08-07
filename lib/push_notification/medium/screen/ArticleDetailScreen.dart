import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/push_notification/medium/router/approute.dart';
import 'package:flutterpractisetasks/push_notification/easy/screen/components/commonText.dart';
import 'package:flutterpractisetasks/push_notification/medium/models/articlesmodel.dart';
import 'package:flutterpractisetasks/push_notification/medium/services/urlservice.dart';
import 'package:go_router/go_router.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  // Tính thời gian đăng dạng "3h ago"
  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  // Ước tính thời gian đọc
  String _readTime(String? content) {
    if (content == null || content.isEmpty) return '1 phút đọc';
    final wordCount = content.split(' ').length;
    final minutes = (wordCount / 200).ceil(); // 200 từ/phút
    return '$minutes phút đọc';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              Navigator.pop(context);
            } else {
              AppRouter.router.go('/');
            }
          },
        ),
        title: Commontext(
          title: 'Chi tiết bài báo',
          fontSize: '16',
          fontWeight: FontWeight.w500,
          colorText: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => Urlservice.openArticle(article.url),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(),
            _buildContent(context),
            _buildFooterActions(),
            _buildOpenOriginalCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Phần ảnh thumbnail
  Widget _buildThumbnail() {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ảnh — dùng CachedNetworkImage
          article.urlToImage != null
              ? CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => _buildImageFallback(),
                )
              : _buildImageFallback(),

          // Gradient overlay phía dưới
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ),

          // Badge category
          // Positioned(
          //   bottom: 12,
          //   left: 12,
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          //     decoration: BoxDecoration(
          //       color: Colors.white.withOpacity(0.2),
          //       borderRadius: BorderRadius.circular(20),
          //       border: Border.all(color: Colors.white38),
          //     ),
          //     child: const Text(
          //       'Technology',
          //       style: TextStyle(
          //         fontSize: 11,
          //         color: Colors.white,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // Fallback khi không có ảnh
  Widget _buildImageFallback() {
    return Container(
      color: Colors.blueGrey.shade100,
      child: const Center(
        child: Icon(Icons.newspaper, size: 60, color: Colors.blueGrey),
      ),
    );
  }

  // Phần nội dung chính
  Widget _buildContent(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: nguồn + bookmark
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.newspaper,
                  size: 16,
                  color: Colors.blue.shade300,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.sourceName!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _timeAgo(article.publishedAt),
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.bookmark_outline, color: Colors.grey.shade400),
            ],
          ),

          const SizedBox(height: 12),

          // Tiêu đề
          Text(
            article.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 8),

          // Tác giả + thời gian đọc
          Row(
            children: [
              Icon(Icons.person_outline, size: 13, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  article.author ?? 'Unknown',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.access_time, size: 13, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                _readTime(article.content),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),

          const Divider(height: 24),

          // Description
          Text(
            article.description ?? 'Không có mô tả.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.7,
            ),
          ),

          const SizedBox(height: 12),

          // Content preview (bị cắt)
          if (article.content != null) ...[
            Text(
              article.content!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.7,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
          ],

          // Ghi chú nội dung bị cắt
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(color: Colors.blue.shade700, width: 3),
              ),
            ),
            child: Text(
              'Nội dung đầy đủ có trên trang gốc. Nhấn "Đọc bài gốc" để xem toàn bộ.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue.shade800,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Footer like / comment / share
  Widget _buildFooterActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _buildActionButton(Icons.favorite_outline, '128'),
          const SizedBox(width: 8),
          _buildActionButton(Icons.comment_outlined, '34'),
          const SizedBox(width: 8),
          _buildActionButton(Icons.share_outlined, 'Chia sẻ'),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade500),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  // Card đọc bài gốc
  Widget _buildOpenOriginalCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nguồn bài báo',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            article.url,
            style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Nút đọc bài gốc
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Urlservice.openArticle(article.url),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Đọc bài gốc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
