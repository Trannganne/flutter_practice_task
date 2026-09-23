import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/local_notification/easy/screens/homeScreen.dart';
import 'package:flutterpractisetasks/local_notification/hard/bloc/planner_bloc.dart';
import 'package:flutterpractisetasks/local_notification/hard/bloc/planner_event.dart';
import 'package:flutterpractisetasks/local_notification/hard/screens/history_screen.dart';
import 'package:flutterpractisetasks/local_notification/hard/screens/homescreen.dart';
import 'package:flutterpractisetasks/local_notification/hard/screens/reminder_screen.dart';
import 'package:flutterpractisetasks/local_notification/hard/screens/settings_screen.dart';
import 'package:flutterpractisetasks/local_notification/hard/screens/widgets/scaffoldwithnavbar.dart';
import 'package:flutterpractisetasks/local_notification/medium/screens/weatherscreen.dart';
import 'package:flutterpractisetasks/local_notification/menu.dart';
import 'package:go_router/go_router.dart';

class AppRoutes {
  static const String start = '/';

  static const String activity = '/activity';
  static const String umbrella = '/umbrella';

  static const String hardDashboard = '/hard-dashboard';
  static const String hardReminders = '/hard-reminders';
  static const String hardHistory = '/hard-history';
  static const String hardSettings = '/hard-settings';

  static GoRouter createRouter({
    String initialLocation = start,
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: start,
          name: 'start',
          builder: (context, state) => const AppNavigationMenu(),
        ),

        // ================= EASY =================
        GoRoute(
          path: activity,
          name: 'activity',
          builder: (context, state) => const ActivityScreen(),
        ),

        // ================= MEDIUM =================
        GoRoute(
          path: umbrella,
          name: 'umbrellaReminder',
          builder: (context, state) => const WeatherScreen(),
        ),

        // ================= HARD =================
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return BlocProvider(
              create: (_) => PlannerBloc()..add(FetchPlannerEvent()),
              child: ScaffoldWithNavBar(
                navigationShell: navigationShell,
              ),
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: hardDashboard,
                  name: 'hardDashboard',
                  builder: (context, state) =>
                      const HardDashboardScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: hardReminders,
                  name: 'hardReminders',
                  builder: (context, state) =>
                      const HardRemindersScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: hardHistory,
                  name: 'hardHistory',
                  builder: (context, state) =>
                      const HardHistoryScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: hardSettings,
                  name: 'hardSettings',
                  builder: (context, state) =>
                      const HardSettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}