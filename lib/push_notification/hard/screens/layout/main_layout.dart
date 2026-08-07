import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/push_notification/hard/router/app_routes.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/core/appcolor.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/layout/bottom_nav.dart';

import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget body;

  final PreferredSizeWidget? appBar;
  final bool showBottomNav;

  const MainLayout({
    super.key,
    required this.body,
    this.appBar,
    this.showBottomNav = true,
  });

  int _getCurrentIndex(String location) {
    switch (location) {
      case AppRoutes.newHub:
        return 0;

      case AppRoutes.notifications:
        return 3;

      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _getCurrentIndex(location);
    return Scaffold(
      backgroundColor: Appcolor.primary,
      appBar: appBar,
      body: body,

      bottomNavigationBar: showBottomNav
          ? CommonBottomNav(
              currentIndex: currentIndex,
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.push(AppRoutes.newHub);
                    break;

                  case 3:
                    context.push(AppRoutes.notifications);
                    break;
                }
              },
            )
          : null,
    );
  }
}
