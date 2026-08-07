import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/core/appcolor.dart';

class CommonBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int index) onTap;

  const CommonBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<NavItem> navItems = [
    NavItem(icon: Icons.home, label: "Home", isHome: true),
    NavItem(icon: Icons.search, label: "Explore"),
    NavItem(icon: Icons.save, label: "Saved"),
    NavItem(icon: Icons.notifications, label: "Notification"),
    NavItem(icon: Icons.person, label: "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    const double navHeight = 56;
    const double barHeight = 64;
    const double labelFontSize = 10;

    return SizedBox(
      height: navHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          /// Background
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(height: barHeight, color: Appcolor.primary),
          ),

          /// ITEMS
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final selected = currentIndex == index;

                return GestureDetector(
                  onTap: () {
                    onTap(index);
                  },
                  child: SizedBox(
                    width: 60,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            item.icon,
                            color: selected
                                ? Appcolor.textSecondary
                                : Appcolor.textPrimary,
                          ),
                        ),
                        //const SizedBox(height: 2),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: labelFontSize,
                            color: selected
                                ? Appcolor.textSecondary
                                : Appcolor.textPrimary,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final bool isHome;

  const NavItem({required this.icon, required this.label, this.isHome = false});
}
