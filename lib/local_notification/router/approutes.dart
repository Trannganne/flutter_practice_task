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

  // Định nghĩa các đường dẫn (Path) cho 4 Tab thuộc cấp độ HARD
  static const String hardDashboard = '/hard-dashboard';
  static const String hardReminders = '/hard-reminders';
  static const String hardHistory = '/hard-history';
  static const String hardSettings = '/hard-settings';

  static final GoRouter router = GoRouter(
    initialLocation: start,
    routes: [
      GoRoute(
        path: '/',
        name: 'start',
        builder: (context, state) =>
            const AppNavigationMenu(), // MenuScreen của bạn
      ),
      GoRoute(
        path: '/activity',
        name: 'activity',
        builder: (context, state) => const ActivityScreen(),
      ),

      GoRoute(
        path: '/umbrella',
        name: 'umbrellaReminder',
        builder: (context, state) => const WeatherScreen(),
      ),
      // ==========================================
      // 3. CẤU TRÚC SHELL CHO CẤP ĐỘ HARD (4 TABS THEO ẢNH)
      // ==========================================
      StatefulShellRoute.indexedStack(
        // QUAN TRỌNG: bọc 1 BlocProvider DUY NHẤT bên ngoài toàn bộ shell.
        // Trước đây mỗi branch tự tạo PlannerBloc() riêng -> 4 instance độc lập,
        // khiến bật/tắt reminder ở tab Reminders không đồng bộ với Dashboard.
        // Giờ cả 4 tab dùng chung 1 PlannerBloc nên state luôn đồng nhất.
        builder: (context, state, navigationShell) {
          return BlocProvider(
            create: (_) => PlannerBloc()..add(FetchPlannerEvent()),
            child: ScaffoldWithNavBar(navigationShell: navigationShell),
          );
        },
        branches: [
          // Tab 1: Dashboard (Màn hình chính Reminder Center )
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: hardDashboard,
                name: 'hardDashboard',
                builder: (context, state) => const HardDashboardScreen(),
              ),
            ],
          ),

          // Tab 2: Reminders (Màn hình quản lý danh sách nhắc nhở)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: hardReminders,
                name: 'hardReminders',
                builder: (context, state) => const HardRemindersScreen(),
              ),
            ],
          ),

          // Tab 3: History (Màn hình xem chi tiết lịch sử đầy đủ)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: hardHistory,
                name: 'hardHistory',
                builder: (context, state) => const HardHistoryScreen(),
              ),
            ],
          ),

          // Tab 4: Settings (Màn hình cài đặt chuyên sâu)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: hardSettings,
                name: 'hardSettings',
                builder: (context, state) => const HardSettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
