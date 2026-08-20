import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/video_player/video_router/playerrouter.dart';
import 'package:go_router/go_router.dart';

class PlayerAppRouter {
  static GoRouter createRouter() {
    final navigatorKey = GlobalKey<NavigatorState>();
    return GoRouter(
      debugLogDiagnostics: true,
      navigatorKey: navigatorKey,
      initialLocation: '/player',
      routes: [PlayerRouter.route(navigatorKey)],
    );
  }
}
