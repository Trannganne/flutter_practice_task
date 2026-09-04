import 'package:flutterpractisetasks/hub/app_routes/app_routes.dart';
import 'package:flutterpractisetasks/permissions/hard/screen/field_report_screen.dart';
import 'package:flutterpractisetasks/permissions/hard/screen/main_shell_screen.dart';
import 'package:go_router/go_router.dart';

class PermissionRouter {
  static final StatefulShellRoute route = StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) => MainShellScreen(),
    //navigatorKey: _rootNavigatorKey,
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.permission,
            builder: (context, state) => const FieldReportScreen(),
          ),
        ],
      ),
    ],
  );
}
