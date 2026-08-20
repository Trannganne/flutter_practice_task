import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/file_picker/screens/mainscreens/uploadpage.dart';
import 'package:flutterpractisetasks/hub/app_routes/app_routes.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/placeholder/placeholder.dart';
import 'package:flutterpractisetasks/video_player/data/pages/mainpages/homepage.dart';
import 'package:flutterpractisetasks/widgets/mainwrapper/customainwrapper.dart';
import 'package:go_router/go_router.dart';

class PlayerRouter {
  static StatefulShellRoute route(GlobalKey<NavigatorState> rootNavigatorKey) {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => CustomMainWrapper(
        navigationShell: navigationShell,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
        ],
      ),
      branches: [
        // Tab Home( trống)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.homeVideo,
              builder: (context, state) {
                debugPrint('Home upload Route');
                return const HomePageVideoPlayer();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.exploreVideo,
              builder: (context, state) {
                debugPrint('Explore Route');
                return const Uploadpage();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.savedVideo,
              builder: (context, state) {
                debugPrint("Bookmark route");
                return PlaceholderTab(label: 'Bookmark page nè');
              },
            ),
          ],
        ),
      ],
    );
  }
}
