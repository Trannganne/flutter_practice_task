import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/widgets/card/photo_card.dart';
import 'package:flutterpractisetasks/image_caching/models/pexel_collection.dart';

class CollectionGridView extends StatelessWidget {
  final List<PexelCollections> collections;
  final Function(PexelCollections collection)? onCollectionTap;
  final ScrollController? scrollController;

  const CollectionGridView({
    Key? key,
    required this.collections,
    this.onCollectionTap,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 cột vuông cân đối
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.0, // Tỉ lệ 1:1 cho ô vuông đẹp mắt
      ),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return PhotoCard(
          collections: collection,
          onTap: () => onCollectionTap?.call(collection),
        );
      },
    );
  }
}
