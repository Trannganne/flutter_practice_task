import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/file_picker/screens/mainscreens/homepage.dart';
import 'package:flutterpractisetasks/file_picker/screens/mainscreens/uploadpage.dart';
import 'package:flutterpractisetasks/hub/app_routes/app_routes.dart';
import 'package:flutterpractisetasks/widgets/mainwrapper/customainwrapper.dart';
import 'package:go_router/go_router.dart';

class Uploadrouter {
  static StatefulShellRoute route(GlobalKey<NavigatorState> rootNavigatorKey) {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => CustomMainWrapper(
        navigationShell: navigationShell,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_upload),
            label: 'Upload',
          ),
        ],
      ),
      branches: [
        // Tab Home( trống)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.homeUpload,
              builder: (context, state) {
                debugPrint('Home upload Route');
                return const HomePage();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.upload,
              builder: (context, state) {
                debugPrint('Upload Route');
                return const Uploadpage();
              },
            ),
          ],
        ),
      ],
    );
  }
}
