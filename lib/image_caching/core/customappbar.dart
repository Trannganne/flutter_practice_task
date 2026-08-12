import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? iconData;
  final VoidCallback? onLeadingPressed;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color backgroundColor;
  final Color textColor;

  const CustomAppbar({
    Key? key,
    required this.title,
    this.iconData,
    this.onLeadingPressed,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy màu sắc động từ Theme hệ thống thay vì cố định Colors.black
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          // Màu chữ tự động đổi theo Light/Dark Mode
          // color: theme.colorScheme.onSurface,
          color: textColor,
        ),
      ),
      centerTitle: centerTitle,

      // Xử lý nút Leading (Back/Menu) linh hoạt
      leading: iconData != null
          ? IconButton(
              icon: Icon(iconData, size: 30),
              color: theme.colorScheme.onSurface, // Màu Icon tự động theo Theme
              onPressed: onLeadingPressed ?? () => Navigator.maybePop(context),
            )
          : (ModalRoute.of(context)?.canPop ?? false)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: theme.colorScheme.onSurface,

              onPressed: () => Navigator.maybePop(context),
            )
          : null,

      actions: actions,
      foregroundColor: textColor,
      //backgroundColor: theme.colorScheme.surface, // Màu nền AppBar theo Theme
      backgroundColor: backgroundColor,
      elevation: 0, // Làm phẳng AppBar theo xu hướng thiết kế hiện đại
    );
  }

  // Bắt buộc phải có khi implements PreferredSizeWidget
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
