import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/push_notification/easy/screen/components/commonText.dart';

class Footerlikecomment extends StatelessWidget {
  final IconData icon_like;
  final IconData iconComment;
  final int countLike;
  final int countComment;

  const Footerlikecomment({
    super.key,
    required this.icon_like,
    required this.iconComment,
    required this.countLike,
    required this.countComment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon_like, color: Colors.grey),
        const SizedBox(width: 4),
        Commontext(title: '$countLike', colorText: Colors.grey),
        const SizedBox(width: 16),
        Icon(iconComment, color: Colors.grey),
        const SizedBox(width: 4),
        Commontext(title: '$countComment', colorText: Colors.grey),
        Spacer(),
        const Icon(Icons.bookmark_border, color: Colors.grey),
      ],
    );
  }
}
