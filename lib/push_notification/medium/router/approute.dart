import 'package:flutterpractisetasks/push_notification/medium/models/articlesmodel.dart';
import 'package:flutterpractisetasks/push_notification/medium/screen/ArticleDetailScreen.dart';
import 'package:flutterpractisetasks/push_notification/medium/screen/homescreen.dart';
import 'package:flutterpractisetasks/push_notification/medium/screen/settings_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'news',
        builder: (context, state) => const NewsHomescreen(),
      ),
      GoRoute(
        path: '/article',
        name: 'articleDetail',
        builder: (context, state) {
          final article = state.extra as Article?;
          if (article == null) return const NewsHomescreen();
          return ArticleDetailScreen(article: article);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
