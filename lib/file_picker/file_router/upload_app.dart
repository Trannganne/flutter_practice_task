import 'package:flutter/material.dart';
import 'package:flutterpractisetasks/file_picker/file_router/upload_router.dart';
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
