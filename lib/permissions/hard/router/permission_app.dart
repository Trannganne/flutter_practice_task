import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/permissions/hard/router/permission_router.dart';
import 'package:go_router/go_router.dart';

class PermissionAppRouter {
  static GoRouter createRouter() {
    final navigatorKey = GlobalKey<NavigatorState>();
    return GoRouter(
      debugLogDiagnostics: true,
      navigatorKey: navigatorKey,
      initialLocation: '/permission',
      routes: [PermissionRouter.route],
    );
  }
}
