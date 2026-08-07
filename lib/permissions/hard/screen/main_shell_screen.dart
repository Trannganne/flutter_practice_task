import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/image/image_bloc.dart';
import 'package:flutterpractisetasks/permissions/hard/bloc/report/report_bloc.dart';
import 'package:flutterpractisetasks/permissions/hard/screen/map_screen.dart';
import 'package:flutterpractisetasks/permissions/hard/screen/reportlist_screen.dart';
import 'field_report_screen.dart';
//import 'report_list_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => MainShellScreenState();
}

class MainShellScreenState extends State<MainShellScreen> {
  int _currentBottomNavIndex = 0;
  // // Navigator key riêng cho nhánh Field Report — không phải Navigator gốc của app
  // final GlobalKey<NavigatorState> _shellNavigatorKey =
  //     GlobalKey<NavigatorState>();

  void changeTab(int index) {
    setState(() => _currentBottomNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Nếu sau này có repository thì sẽ truyền qua chỗ này
        BlocProvider<ReportBloc>(create: (context) => ReportBloc()),
        BlocProvider<ImageBloc>(create: (context) => ImageBloc()),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentBottomNavIndex,
          children: const [
            FieldReportScreen(),
            ReportlistScreen(),
            MapScreen(),
            SettingsScreen(), //nếu làm tiếp 2 tab còn lại
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF0F172A),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: Colors.grey,
          currentIndex: _currentBottomNavIndex,
          onTap: (index) {
            setState(() => _currentBottomNavIndex = index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Reports',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
