import 'package:flutter/material.dart';

class ValidatedSectionWrapper extends StatelessWidget {
  final Widget child;
  final String? errorText;
  final Key sectionKey;

  const ValidatedSectionWrapper({
    required this.sectionKey,
    required this.child,
    this.errorText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Container(
      key: sectionKey,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: hasError
            ? Border.all(
                color: const Color.fromARGB(255, 225, 160, 160),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: Color.fromARGB(255, 225, 160, 160),
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
