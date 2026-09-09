import 'package:flutterpractisetasks/push_notification/hard/models/feed_item_model.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/new_hub_screen.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/notification_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutterpractisetasks/push_notification/hard/screens/Feed_Item_Detail_Screen.dart';

class AppRoutes {
  static const String newHub = '/';
  static const String notifications = '/notifications';

  // Router hiện đang active — cập nhật mỗi khi ModuleHost mở module này
  static GoRouter? _activeRouter;
  static GoRouter get router {
    if (_activeRouter == null) {
      throw StateError('Router chưa được khởi tạo. Gọi createRouter() trước.');
    }
    return _activeRouter!;
  }

  static GoRouter createRouter() {
    _activeRouter = GoRouter(
      initialLocation: newHub,
      routes: [
        GoRoute(
          path: newHub,
          name: 'newshub',
          builder: (context, state) => const NewsHubScreen(),
        ),
        GoRoute(
          path: notifications,
          name: 'notifications',
          builder: (context, state) {
            return NotificationCenterScreen();
          },
        ),
        GoRoute(
          path: '/feeditem',
          name: 'feedItemDetail',
          builder: (context, state) {
            final feedItem = state.extra as FeedItem?;
            //if (feedItem == null) return const NewsHomescreen();
            if (feedItem == null) {
              return const NewsHubScreen();
            }
            return FeedDetailScreen(item: feedItem);
          },
        ),
      ],
    );
    return _activeRouter!;
  }
}
