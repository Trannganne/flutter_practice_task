import 'package:flutterpractisetasks/push_notification/easy/screen/PostDetailScreen.dart';
import 'package:flutterpractisetasks/push_notification/easy/screen/homeScreen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const Homescreen(),
      ),
      GoRoute(
        path: '/post/:id',
        name: 'postDetail',
        builder: (context, state) {
          final postId = int.parse(state.pathParameters['id']!);
          return Postdetailscreen(postId: postId);
        },
      ),
    ],
  );
}
