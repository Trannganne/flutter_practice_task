import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//import 'report_list_screen.dart';

class PhotoMainWrapper extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const PhotoMainWrapper({super.key, required this.navigationShell});

  // Điều hướng khi tab vào navbottom
  void onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  State<PhotoMainWrapper> createState() => NavBottomState();
}

class NavBottomState extends State<PhotoMainWrapper> {
  int _currentBottomNavIndex = 0;

  void changeTab(int index) {
    setState(() => _currentBottomNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0F172A),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
          widget.onTap(index); // Điều hướng sang tab tương ứng
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
