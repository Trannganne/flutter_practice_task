import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/connectivity_check/connectivity_service.dart';
import 'package:flutterpractisetasks/connectivity_check/cubit/connectivity_cubit.dart';
import 'package:flutterpractisetasks/file_picker/bloc/file_bloc.dart';
import 'package:flutterpractisetasks/file_picker/data/datasources/upload_provider.dart';
import 'package:flutterpractisetasks/file_picker/data/repository/upload_repository_impl.dart';
import 'package:flutterpractisetasks/file_picker/services/localstorage/localdb.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_bloc.dart';
import 'package:flutterpractisetasks/permissions/medium/screens/home_screen.dart';
import 'package:flutterpractisetasks/video_player/bloc/history_bloc/history_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/popular_bloc/popular_bloc.dart';
import 'package:flutterpractisetasks/video_player/bloc/search_bloc/search_bloc.dart';
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

import 'package:flutterpractisetasks/permissions/hard/router/permission_app.dart'
    as per_hard_router;

// Image caching/ picker
import 'package:flutterpractisetasks/hub/app_router/app_router.dart'
    as hard_image_caching;

import 'package:flutterpractisetasks/file_picker/file_router/upload_app.dart'
    as hard_file_picker;

import 'package:flutterpractisetasks/video_player/video_router/player_app.dart'
    as hard_video_player;

/// Màn hình gốc của app: gom toàn bộ các bài tập vào 1 Dashboard hiện đại,
/// thoáng đãng, dễ thao tác và chuẩn UI/UX mobile.
class DevHubScreen extends StatefulWidget {
  const DevHubScreen({super.key});

  @override
  State<DevHubScreen> createState() => _DevHubScreenState();
}

class _DevHubScreenState extends State<DevHubScreen> {
  // Đánh dấu module nào đang trong lúc khởi tạo (xin quyền + lấy FCM token...)
  // để hiển thị loading trên card và tránh người dùng bấm nhiều lần.
  String? _loadingKey;
  String? _activeModuleKey;

  @override
  void initState() {
    super.initState();
    _handleFCMIntegration();
  }

  void _handleFCMIntegration() async {
    // Terminated
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _processFCMMessage(initialMessage);
    }
    // Background tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _processFCMMessage(message);
    });
  }

  void _processFCMMessage(RemoteMessage message) {
    final type = message.data['type'];
    if (type == 'fcm_hard') {
      if (_activeModuleKey == 'push_hard') {
        // Module is already active, NotificationService inside the module will handle it.
        return;
      }
      
      // Navigate to module
      _openModule(
        key: 'push_hard',
        beforeOpen: () async {
          await hard_push_noti.NotificationService.initialize();
          // Store pending payload for the router to consume once ready
          hard_push_noti.NotificationService.pendingNavigationPayload = message.data;
          hard_push_noti.NotificationService.pendingNavigationPayload!['title'] = message.notification?.title;
        },
        title: 'Notification Center (Hard)',
        routerConfig: hard_push_router.AppRoutes.createRouter(),
      );
    }
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
    _activeModuleKey = key;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ModuleHost(
          title: title,
          routerConfig: routerConfig,
          providers: providers,
        ),
      ),
    );
    _activeModuleKey = null;
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3B82F6); // Modern professional blue

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50 background
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.code_rounded, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Flutter Practice Hub',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                letterSpacing: -0.3,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Production Ready',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Workspace Tổng Hợp Bài Tập',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Khám phá các module từ Easy đến Hard bao gồm Push/Local Notification, Permission, Caching và Media Player.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ===================== SECTION 1: PUSH NOTIFICATION (FCM) =====================
            _sectionHeader(
              title: 'Push Notification (FCM)',
              icon: Icons.notifications_active_rounded,
              color: Colors.blue.shade600,
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
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

            const SizedBox(height: 28),

            // ===================== SECTION 2: LOCAL NOTIFICATION =====================
            _sectionHeader(
              title: 'Local Notification',
              icon: Icons.alarm_rounded,
              color: Colors.teal.shade600,
            ),
            const SizedBox(height: 12),
            FeatureCard(
              title: 'Daily Activity Reminder',
              subtitle:
                  'Lên lịch local notification hằng ngày, gọi API lấy nội dung nhắc việc và cho phép test notification.',
              badgeText: 'Easy · 2h',
              badgeColor: Colors.green.shade600,
              icon: Icons.alarm_rounded,
              isLoading: _loadingKey == 'local_easy',
              onTap: () => _openModule(
                key: 'local_easy',
                beforeOpen: () async {
                  await easy_local_noti.NotificationService.initialize();
                },
                title: 'Daily Activity Reminder (Easy)',
                routerConfig: local_router.AppRoutes.createRouter(
                  initialLocation: local_router.AppRoutes.activity,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FeatureCard(
              title: 'Rain Umbrella Reminder',
              subtitle:
                  'Dùng dữ liệu thời tiết để quyết định có cần nhắc mang ô; xử lý loading, error, offline và quyền notification.',
              badgeText: 'Medium · 4h',
              badgeColor: Colors.orange.shade700,
              icon: Icons.umbrella_rounded,
              isLoading: _loadingKey == 'local_medium',
              onTap: () => _openModule(
                key: 'local_medium',
                beforeOpen: () async {
                  await medium_local_noti.NotificationService.initialize();
                },
                title: 'Rain Umbrella Reminder (Medium)',
                routerConfig: local_router.AppRoutes.createRouter(
                  initialLocation: local_router.AppRoutes.umbrella,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FeatureCard(
              title: 'Smart Daily Planner',
              subtitle:
                  'Kết hợp nhắc việc, thời tiết, offline cache, retry, timezone và quản lý lịch nhắc với giao diện nhiều tab.',
              badgeText: 'Hard · 6-8h',
              badgeColor: Colors.red.shade600,
              icon: Icons.event_note_rounded,
              isLoading: _loadingKey == 'local_hard',
              onTap: () => _openModule(
                key: 'local_hard',
                beforeOpen: () async {
                  await hard_local_noti.NotificationService.initialize();
                },
                title: 'Smart Daily Planner (Hard)',
                routerConfig: local_router.AppRoutes.createRouter(
                  initialLocation: local_router.AppRoutes.hardDashboard,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ===================== SECTION 3: PERMISSION =====================
            _sectionHeader(
              title: 'Permission & Integration',
              icon: Icons.security_rounded,
              color: Colors.amber.shade700,
            ),
            const SizedBox(height: 12),
            FeatureCard(
              title: 'Country CSV Exporter',
              subtitle:
                  'Xin quyền lưu file, gọi API quốc gia, chuyển dữ liệu JSON sang CSV và chia sẻ/mở file.',
              badgeText: 'Medium · 4h',
              badgeColor: Colors.orange.shade700,
              icon: Icons.file_download_rounded,
              isLoading: _loadingKey == 'permission_medium',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CountryScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            FeatureCard(
              title: 'Field Report with Weather & CSV',
              subtitle:
                  'Phối hợp camera, location, storage: chụp ảnh hiện trường, lấy thời tiết vị trí thật, lưu báo cáo CSV offline.',
              badgeText: 'Hard · 6-8h',
              badgeColor: Colors.red.shade600,
              icon: Icons.assignment_turned_in_rounded,
              isLoading: _loadingKey == 'permission_hard',
              onTap: () => _openModule(
                key: 'push_hard',
                beforeOpen: () async {
                  await hard_push_noti.NotificationService.initialize();
                },
                title: 'Notification Center (Hard)',
                routerConfig: per_hard_router.PermissionAppRouter.createRouter(),
              ),
            ),

            const SizedBox(height: 28),

            // ===================== SECTION 4: IMAGE CACHING & MEDIA =====================
            _sectionHeader(
              title: 'Image Caching & Media Hub',
              icon: Icons.perm_media_rounded,
              color: Colors.purple.shade600,
            ),
            const SizedBox(height: 12),
            FeatureCard(
              title: 'Offline Discovery Gallery',
              subtitle:
                  'Làm gallery gần production: 2 nguồn ảnh, cache offline, pagination, favorite, graceful degradation khi mất mạng.',
              badgeText: 'Hard · 6-8h',
              badgeColor: Colors.red.shade600,
              icon: Icons.photo_library_rounded,
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
            const SizedBox(height: 12),
            FeatureCard(
              title: 'Reliable Media Uploader',
              subtitle:
                  'Làm uploader gần production: 2 API upload, queue offline, retry, progress, fallback provider và UX mượt.',
              badgeText: 'Hard · 6-8h',
              badgeColor: Colors.red.shade600,
              icon: Icons.cloud_upload_rounded,
              isLoading: _loadingKey == 'file_hard',
              onTap: () => _openModule(
                key: 'file_hard',
                beforeOpen: () async {},
                title: 'File/ Image Picker (Hard)',
                routerConfig: hard_file_picker.UploadAppRouter.createRouter(),
                providers: [
                  BlocProvider<FileBloc>(
                    create: (_) => FileBloc(
                      UploadRepositoryImpl(
                        localDb: UploadLocaldb(),
                        primary: ImgBBProvider(),
                        fallback: FreeImageProvider(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FeatureCard(
              title: 'Production Video Explorer',
              subtitle:
                  'Làm video app gần production: 2 API, pagination, cache metadata, player UX, fallback video source, error handling.',
              badgeText: 'Hard · 6-8h',
              badgeColor: Colors.red.shade600,
              icon: Icons.play_circle_filled_rounded,
              isLoading: _loadingKey == 'player_hard',
              onTap: () => _openModule(
                key: 'player_hard',
                beforeOpen: () async {},
                title: 'Video player(Hard)',
                routerConfig: hard_video_player.PlayerAppRouter.createRouter(),
                providers: [
                  BlocProvider<HistoryBloc>(create: (_) => HistoryBloc()),
                  BlocProvider<SearchBloc>(create: (_) => SearchBloc()),
                  BlocProvider<PopularBloc>(create: (_) => PopularBloc()),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Tiêu đề phân đoạn bài tập cực kỳ sang trọng và rõ ràng
  Widget _sectionHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}