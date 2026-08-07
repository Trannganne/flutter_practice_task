import 'package:flutterpractisetasks/hub/app_routes/app_routes.dart';
import 'package:flutterpractisetasks/permissions/medium/screens/home_screen.dart';
import 'package:flutterpractisetasks/permissions/medium/screens/main_wrapper.dart';
import 'package:flutterpractisetasks/permissions/router/app_router.dart';
import 'package:go_router/go_router.dart';

class CountryRouter {
  static final StatefulShellRoute route = StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        MainWrapper(navigationShell: navigationShell),
    //navigatorKey: _rootNavigatorKey,
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.country,
            builder: (context, state) => const CountryScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.regions,
            builder: (context, state) => const RegionsScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.countryFavorite,
            builder: (context, state) => const FavoritesScreen(),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.countrySetting,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
