import 'package:flutter/material.dart';

class CommonText extends StatelessWidget {
  final TextStyle? style;
  final String text;
  final String? fontFamily;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign? textAlign;
  final int? maxLines;

  const CommonText({
    super.key,
    this.style,
    required this.text,
    this.fontFamily = 'Regular',
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.color = Colors.black,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.bodyMedium;
    return Text(
      text,
      style: defaultStyle
          ?.copyWith(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            fontFamily: fontFamily,
          )
          .merge(style),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );
  }
}

class CommonRichText extends StatelessWidget {
  final List<TextSpan> spans;
  final TextAlign? textAlign;
  final Color color;
  final String? fontFamily;
  final String? fontSize;
  final FontWeight? fontWeight;

  const CommonRichText({
    super.key,
    required this.spans,
    this.textAlign,
    this.color = Colors.black,
    this.fontFamily = 'Medium',
    this.fontSize = '14',
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: color,
          fontFamily: fontFamily,
          fontSize: double.parse(fontSize!),
          fontWeight: fontWeight,
        ),
        children: spans,
      ),
      textAlign: textAlign ?? TextAlign.start,
    );
  }
}
