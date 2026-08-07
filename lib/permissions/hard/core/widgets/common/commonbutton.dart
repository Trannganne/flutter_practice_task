import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/push_notification/easy/screen/components/commonText.dart';

class Commonbutton extends StatelessWidget {
  final String content;
  final IconData? icon;
  final Color colorButton;
  final VoidCallback? onPressed;
  final double width;

  Commonbutton({
    super.key,
    required this.content,
    this.icon,
    this.colorButton = Colors.blueAccent,
    this.onPressed,
    this.width = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      child: icon == null
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorButton,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Commontext(
                title: content,
                colorText: onPressed == null ? Colors.grey : Colors.white,
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorButton,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                icon,
                color: onPressed == null ? Colors.grey : Colors.white,
              ),
              label: Commontext(
                title: content,
                colorText: onPressed == null ? Colors.grey : Colors.white,
              ),
            ),
    );
  }
}

// Outline Button
class CommonOutlineButton extends StatelessWidget {
  final String content;
  final Color colorButton;
  final VoidCallback? onPressed;
  final double width;

  CommonOutlineButton({
    super.key,
    required this.content,
    this.colorButton = Colors.blueAccent,
    this.onPressed,
    this.width = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      child: OutlinedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorButton,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFF1E293B)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Commontext(
          title: content,
          colorText: onPressed == null ? Colors.grey : Colors.white,
        ),
      ),
    );
  }
}
