import 'package:flutter/material.dart';

class Commontext extends StatelessWidget {
  final Color colorText;
  final String title;
  final FontWeight fontWeight;
  final String fontSize;
  final int maxLines;
  final FontStyle? fontStyle;

  const Commontext({
    super.key,
    required this.title,
    this.colorText = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.fontSize = '14',
    this.maxLines = 1,
    this.fontStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: colorText,
        fontWeight: fontWeight,
        fontSize: double.parse(fontSize),
        fontStyle: fontStyle,
      ),
    );
  }
}
