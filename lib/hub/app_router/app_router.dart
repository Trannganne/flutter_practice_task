import 'package:flutter/widgets.dart';
import 'package:flutterpractisetasks/file_picker/filerouter/uploadrouter.dart';
import 'package:flutterpractisetasks/image_caching/router/photos_router.dart';
import 'package:flutterpractisetasks/permissions/router/country_router.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter createRouter() {
    final navigatorKey = GlobalKey<NavigatorState>();
    return GoRouter(
      debugLogDiagnostics: true,
      navigatorKey: navigatorKey,
      initialLocation: '/photos/explore',
      routes: [
        PhotosRouter.route(navigatorKey),
        CountryRouter.route,
        Uploadrouter.route(navigatorKey),
      ],
    );
  }
}
