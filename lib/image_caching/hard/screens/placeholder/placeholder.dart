// Thêm 1 widget placeholder đơn giản, không chứa logic/GlobalKey gì
import 'package:flutter/cupertino.dart';

class PlaceholderTab extends StatelessWidget {
  final String label;
  const PlaceholderTab({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$label - Coming soon'));
  }
}
