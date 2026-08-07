import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/image_caching/models/photo_model.dart';

class PhotoDetailScreen extends StatefulWidget {
  final PhotoEnity photo;

  const PhotoDetailScreen({super.key, required this.photo});

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late bool _isFavorited;
  late bool _isCachedLocally;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.photo.isFavorited;
    _isCachedLocally = widget.photo.isCachedLocally;
  }

  // Tải ảnh / Cache ảnh về máy
  void _toggleCacheLocal() {
    setState(() {
      _isCachedLocally = !_isCachedLocally;
      widget.photo.isCachedLocally = _isCachedLocally;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isCachedLocally
              ? 'Saved image to local storage'
              : 'Removed image from local storage',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Toggle trạng thái Yêu thích
  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
      widget.photo.isFavorited = _isFavorited;
    });

    // TODO: Bắn event lên PhotoBloc hoặc lưu vào database nếu có
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CircleAvatar(
          backgroundColor: Colors.black45,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          // Nút Tải về / Save Offline
          CircleAvatar(
            backgroundColor: Colors.black45,
            child: IconButton(
              icon: Icon(
                _isCachedLocally ? Icons.download_done : Icons.download,
                color: _isCachedLocally ? Colors.greenAccent : Colors.white,
              ),
              onPressed: _toggleCacheLocal,
            ),
          ),
          const SizedBox(width: 8),
          // Nút Share
          CircleAvatar(
            backgroundColor: Colors.black45,
            child: IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.white),
              onPressed: () {
                // TODO: Gọi package share_plus để chia sẻ widget.photo.url
              },
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Khu vực hiển thị Ảnh có Zoom và Hero
          Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Hero(
                tag: widget.photo.id,
                child: Image.network(
                  widget.photo.url,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 64,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 2. Panel Thông tin chi tiết ở phía dưới
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.95),
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hàng Tác giả & Favorite
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.photo.photoGrapher,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Photographer',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Nút Yêu thích (Favorite Button)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: _toggleFavorite,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.15),
                            ),
                            child: Icon(
                              _isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _isFavorited ? Colors.red : Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Description (Mô tả ảnh - nếu có)
                  if (widget.photo.description != null &&
                      widget.photo.description!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      widget.photo.description!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Thông tin chi tiết kỹ thuật (Source, Resolution, Cached Badge)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Badge Nguồn ảnh (Pexel hoặc Piscum)
                      _buildChip(
                        label: widget.photo.source == PhotoType.pexel
                            ? 'Pexels'
                            : 'Picsum',
                        icon: Icons.camera_alt_outlined,
                        color: widget.photo.source == PhotoType.pexel
                            ? Colors.teal
                            : Colors.deepOrange,
                      ),

                      // Badge Kích thước ảnh (Width x Height)
                      _buildChip(
                        label: '${widget.photo.width} x ${widget.photo.height}',
                        icon: Icons.aspect_ratio,
                        color: Colors.white24,
                      ),

                      // Badge Trạng thái đã tải offline
                      if (_isCachedLocally)
                        _buildChip(
                          label: 'Saved Offline',
                          icon: Icons.offline_pin,
                          color: Colors.blueAccent.withOpacity(0.8),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Nút Đặt làm hình nền (Set Wallpaper Button)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Setting image as wallpaper...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.wallpaper),
                      label: const Text(
                        'Set as Wallpaper',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị Chip thông số
  Widget _buildChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
