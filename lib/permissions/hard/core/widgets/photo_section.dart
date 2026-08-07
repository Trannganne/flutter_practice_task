import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../widgets/components/dashed_container.dart';

class PhotoSection extends StatelessWidget {
  final List<String> photoUrls;
  final int photoCount;
  final VoidCallback onTakePhotoPressed;
  final ValueChanged<String> onRemovePhotoPressed;

  const PhotoSection({
    super.key,
    required this.photoUrls,
    required this.photoCount,
    required this.onTakePhotoPressed,
    required this.onRemovePhotoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Photo Evidence',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${photoUrls.length} photo captured',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final path in photoUrls) ...[
                _PhotoThumnails(
                  path: path,
                  onRemovePressed: () => onRemovePhotoPressed(path),
                ),
                const SizedBox(width: 10),
              ],
              SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: InkWell(
                  onTap: onTakePhotoPressed,
                  borderRadius: BorderRadius.circular(12),
                  child: DashedContainer(
                    color: Colors.white,
                    radius: 12,
                    child: Container(
                      height: 100,
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.white),
                          SizedBox(height: 4),
                          Text(
                            'Take Photo',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Row(
        //   children: [

        //    // Preview Image từ API
        //     Expanded(
        //       flex: 6,
        //       child: ClipRRect(
        //         borderRadius: BorderRadius.circular(12),
        //         child: photoUrls
        //             ? Image.file(
        //                 File(photoUrls!),
        //                 height: 100,
        //                 fit: BoxFit.cover,
        //                 errorBuilder: (context, error, stackTrace) => Container(
        //                   height: 100,
        //                   color: const Color(0xFF111827),
        //                   child: const Icon(
        //                     Icons.broken_image,
        //                     color: Colors.white24,
        //                   ),
        //                 ),
        //               )
        //             : Container(
        //                 height: 100,
        //                 color: const Color(0xFF111827),
        //                 child: const Icon(Icons.image, color: Colors.white24),
        //               ),
        //       ),
        //     ),
        //     const SizedBox(width: 12),
        //     // Nút Take Photo dạng nét đứt
        //     Expanded(
        //       flex: 4,
        //       child: InkWell(
        //         onTap: onTakePhotoPressed,
        //         borderRadius: BorderRadius.circular(12),
        //         child: DashedContainer(
        //           color: Colors.white,
        //           radius: 12,
        //           child: Container(
        //             height: 100,
        //             alignment: Alignment.center,
        //             child: const Column(
        //               mainAxisAlignment: MainAxisAlignment.center,
        //               children: [
        //                 Icon(Icons.camera_alt, color: Colors.white),
        //                 SizedBox(height: 4),
        //                 Text(
        //                   'Take Photo',
        //                   style: TextStyle(color: Colors.white, fontSize: 12),
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

class _PhotoThumnails extends StatelessWidget {
  final String path;
  final VoidCallback onRemovePressed;
  const _PhotoThumnails({required this.path, required this.onRemovePressed});
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(path),
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 100,
              color: const Color(0xFF111827),
              child: const Icon(Icons.broken_image, color: Colors.white24),
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemovePressed,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(Icons.close, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}
