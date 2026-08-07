import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomMainWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<BottomNavigationBarItem> items;
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;

  const CustomMainWrapper({
    super.key,
    required this.navigationShell,
    required this.items,
    this.backgroundColor = const Color(0xFF0F172A),
    this.selectedColor = const Color(0xFF2563EB),
    this.unselectedColor = Colors.grey,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: backgroundColor,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        items: items,
      ),
    );
  }
}
