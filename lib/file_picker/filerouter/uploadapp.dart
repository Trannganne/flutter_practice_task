import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/file_picker/filerouter/uploadrouter.dart';
import 'package:go_router/go_router.dart';

class UploadAppRouter {
  static GoRouter createRouter() {
    final navigatorKey = GlobalKey<NavigatorState>();
    return GoRouter(
      debugLogDiagnostics: true,
      navigatorKey: navigatorKey,
      initialLocation: '/upload/home',
      routes: [Uploadrouter.route(navigatorKey)],
    );
  }
}
