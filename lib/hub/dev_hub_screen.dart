import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/connectivity_check/connectivity_service.dart';
import 'package:flutterpractisetasks/connectivity_check/cubit/connectivity_cubit.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_bloc.dart';
import 'package:flutterpractisetasks/permissions/medium/screens/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutterpractisetasks/hub/widgets/feature_card.dart';
import 'package:flutterpractisetasks/hub/widgets/module_host.dart';

// ===================== PUSH NOTIFICATION (FCM) =====================
import 'package:flutterpractisetasks/push_notification/easy/router/app_router.dart'
    as easy_push_router;
import 'package:flutterpractisetasks/push_notification/medium/router/approute.dart'
    as medium_push_router;
import 'package:flutterpractisetasks/push_notification/hard/router/app_routes.dart'
    as hard_push_router;
import 'package:flutterpractisetasks/push_notification/easy/services/notification_service.dart'
    as easy_push_noti;
import 'package:flutterpractisetasks/push_notification/medium/services/notificationService.dart'
    as medium_push_noti;
import 'package:flutterpractisetasks/push_notification/hard/services/notification_service.dart'
    as hard_push_noti;

import 'package:flutterpractisetasks/hub/app_router/app_router.dart'
    as hard_image_caching;

// ===================== LOCAL NOTIFICATION =====================
import 'package:flutterpractisetasks/local_notification/router/approutes.dart'
    as local_router;
import 'package:flutterpractisetasks/local_notification/easy/services/notification_service.dart'
    as easy_local_noti;
import 'package:flutterpractisetasks/local_notification/medium/service/notificationservice.dart'
    as medium_local_noti;
import 'package:flutterpractisetasks/local_notification/hard/services/notificationservice.dart'
    as hard_local_noti;

// ===================== PERMISSION =====================
import 'package:flutterpractisetasks/permissions/router/app_router.dart'
    as per_router;

/// Màn hình gốc của app: gom toàn bộ 6 bài tập (Easy/Medium/Hard x
/// Push Notification(FCM)/Local Notification) vào 1 nơi duy nhất, thay vì
/// trước đây chỉ có bài "Push - Hard" được gắn làm route gốc trong main.dart
/// nên 5 bài còn lại không thể mở được từ app đang chạy.
class DevHubScreen extends StatefulWidget {
  const DevHubScreen({super.key});

  @override
  State<DevHubScreen> createState() => _DevHubScreenState();
}

class _DevHubScreenState extends State<DevHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Đánh dấu module nào đang trong lúc khởi tạo (xin quyền + lấy FCM token...)
  // để hiển thị loading trên card và tránh người dùng bấm nhiều lần.
  String? _loadingKey;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openModule({
    required String key,
    required Future<void> Function() beforeOpen,
    required String title,
    required GoRouter routerConfig,

    List<BlocProvider> providers = const [],
  }) async {
    if (_loadingKey != null) return;
    setState(() => _loadingKey = key);
    try {
      await beforeOpen();
    } catch (e) {
      // Không chặn điều hướng nếu xin quyền/khởi tạo lỗi (VD: chưa cấu hình
      // Firebase trên thiết bị) — vẫn cho vào để xem UI, lỗi sẽ hiện trong app.
      debugPrint('Khởi tạo module "$title" gặp lỗi: $e');
    } finally {
      if (mounted) setState(() => _loadingKey = null);
    }

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ModuleHost(
          title: title,
          routerConfig: routerConfig,
          providers: providers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Flutter Practice Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        foregroundColor: Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor: Colors.blueAccent,
          tabs: const [
            Tab(icon: Icon(Icons.notifications_active), text: 'Push (FCM)'),
            Tab(icon: Icon(Icons.alarm), text: 'Local Notification'),
            Tab(icon: Icon(Icons.connect_without_contact), text: 'Permission'),
            Tab(icon: Icon(Icons.image), text: 'Image caching'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPushTab(),
          _buildLocalTab(),
          _buildPermissionTab(),
          _builImageCachingTab(),
        ],
      ),
    );
  }

  // ===================== TAB 1: PUSH NOTIFICATION (FCM) =====================
  Widget _buildPushTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Chọn cấp độ bài tập Push Notification (FCM):'),
          const SizedBox(height: 16),
          FeatureCard(
            title: 'Post Alert - Thông báo bài đăng mới',
            subtitle:
                'Xin quyền, lấy FCM token, nhận foreground/background message, điều hướng khi tap notification.',
            badgeText: 'Easy · 2h',
            badgeColor: Colors.green.shade600,
            icon: Icons.forum_rounded,
            isLoading: _loadingKey == 'push_easy',
            onTap: () => _openModule(
              key: 'push_easy',
              beforeOpen: easy_push_noti.NotificationService.initialize,
              title: 'Post Alert (Easy)',
              routerConfig: easy_push_router.AppRouter.router,
            ),
          ),
          const SizedBox(height: 16),
          FeatureCard(
            title: 'News Flash - Push tin nóng',
            subtitle:
                'Subscribe/unsubscribe FCM topic theo category, list headline có loading/empty/error, mở article detail.',
            badgeText: 'Medium · 4h',
            badgeColor: Colors.orange.shade700,
            icon: Icons.newspaper_rounded,
            isLoading: _loadingKey == 'push_medium',
            onTap: () => _openModule(
              key: 'push_medium',
              beforeOpen: medium_push_noti.NotificationService.initialize,
              title: 'News Flash (Medium)',
              routerConfig: medium_push_router.AppRouter.router,
            ),
          ),
          const SizedBox(height: 16),
          FeatureCard(
            title: 'Production Notification Center',
            subtitle:
                '2 API, backend mock, dedupe, offline inbox, pagination, retry, analytics tap notification.',
            badgeText: 'Hard · 6-8h',
            badgeColor: Colors.red.shade600,
            icon: Icons.dashboard_customize_rounded,
            isLoading: _loadingKey == 'push_hard',
            onTap: () => _openModule(
              key: 'push_hard',
              beforeOpen: () async {
                await hard_push_noti.NotificationService.initialize();
              },
              title: 'Notification Center (Hard)',
              routerConfig: hard_push_router.AppRoutes.createRouter(),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== TAB 2: LOCAL NOTIFICATION =====================
  Widget _buildLocalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Bộ bài tập Local Notification:'),
          const SizedBox(height: 16),
          // Module Local Notification đã có sẵn 1 menu nội bộ với đầy đủ
          // 3 cấp độ (Easy/Medium/Hard) + router riêng cho cả 4 tab của bản
          // Hard (Dashboard/Reminders/History/Settings). Ta chỉ cần mở nó ra.
          FeatureCard(
            title: 'Mở bộ Local Notification',
            subtitle:
                'Daily Activity Reminder (Easy) · Rain Umbrella Reminder (Medium) · Smart Daily Planner (Hard)',
            badgeText: 'Easy · Medium · Hard',
            badgeColor: Colors.teal.shade600,
            icon: Icons.checklist_rtl_rounded,
            isLoading: _loadingKey == 'local_all',
            onTap: () => _openModule(
              key: 'local_all',
              beforeOpen: () async {
                // Trước đây KHÔNG có nơi nào trong project gọi initialize()
                // cho cả 3 cấp độ Local Notification, nên FlutterLocalNotificationsPlugin
                // chưa từng được khởi tạo/xin quyền -> bấm Test/Schedule sẽ lỗi
                // hoặc không hiển thị notification. Gọi cả 3 ở đây (mỗi cái đã
                // có cờ _isInitialized nên gọi lại nhiều lần vẫn an toàn).
                await easy_local_noti.NotificationService.initialize();
                await medium_local_noti.NotificationService.initialize();
                await hard_local_noti.NotificationService.initialize();
              },
              title: 'Local Notification',
              routerConfig: local_router.AppRoutes.router,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== TAB 3: PERMISSION =====================
  Widget _buildPermissionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Chọn cấp độ bài tập Permission:'),
          const SizedBox(height: 16),

          FeatureCard(
            title: 'Country CSV Exporter',
            subtitle:
                'Xin quyền lưu file, gọi API quốc gia, chuyển dữ liệu JSON sang CSV và chia sẻ/mở file.',
            badgeText: 'Medium · 4h',
            badgeColor: Colors.orange.shade700,
            icon: Icons.newspaper_rounded,
            isLoading: _loadingKey == 'permission_medium',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CountryScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          FeatureCard(
            title: 'Field Report with Weather & CSV',
            subtitle:
                'Phối hợp camera, location, storage: chụp ảnh hiện trường, lấy thời tiết vị trí thật, lưu báo cáo CSV offline.',
            badgeText: 'Hard · 6-8h',
            badgeColor: Colors.red.shade600,
            icon: Icons.dashboard_customize_rounded,
            isLoading: _loadingKey == 'permission_hard',
            onTap: () => _openModule(
              key: 'push_hard',
              beforeOpen: () async {
                await hard_push_noti.NotificationService.initialize();
              },
              title: 'Notification Center (Hard)',
              routerConfig: hard_push_router.AppRoutes.createRouter(),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== TAB 4: Image Caching =====================
  Widget _builImageCachingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Chọn cấp độ bài tập Image Caching:'),
          const SizedBox(height: 16),

          FeatureCard(
            title: 'Offline Discovery Gallery',
            subtitle:
                'Làm gallery gần production: 2 nguồn ảnh, cache offline, pagination, favorite, graceful degradation khi mất mạng.',
            badgeText: 'Hard · 6-8h',
            badgeColor: Colors.red.shade600,
            icon: Icons.dashboard_customize_rounded,
            isLoading: _loadingKey == 'image_hard',
            onTap: () => _openModule(
              key: 'image_hard',
              beforeOpen: () async {},
              title: 'Image Caching (Hard)',
              routerConfig: hard_image_caching.AppRouter.createRouter(),
              providers: [
                BlocProvider<PhotoBloc>(create: (_) => PhotoBloc()),
                BlocProvider<ConnectivityCubit>(
                  create: (_) => ConnectivityCubit(ConnectivityService()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black54,
    ),
  );
}
