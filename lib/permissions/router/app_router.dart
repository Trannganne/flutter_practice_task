import 'package:flutter/material.dart';

// Các màn hình phụ đại diện cho các Tab còn lại
class RegionsScreen extends StatelessWidget {
  const RegionsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Regions')));
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Favorites')));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Settings')));
}

// class AppRouter {
//   static final _rootNavigatorKey = GlobalKey<NavigatorState>();
//   static final GoRouter router = GoRouter(
//     initialLocation: '/',
//     //navigatorKey: _rootNavigatorKey,
//     routes: [
//       StatefulShellRoute.indexedStack(
//         builder: (context, state, navigationShell) {
//           // Trả về MainWrapper chứa BottomNavigationBar chung
//           return MainWrapper(navigationShell: navigationShell);
//         },
//         branches: [
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: '/',
//                 builder: (context, state) => const CountryScreen(),
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: '/regions',
//                 builder: (context, state) => const RegionsScreen(),
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: '/favorites',
//                 builder: (context, state) => const FavoritesScreen(),
//               ),
//             ],
//           ),
//           StatefulShellBranch(
//             routes: [
//               GoRoute(
//                 path: '/settings',
//                 builder: (context, state) => const SettingsScreen(),
//               ),
//             ],
//           ),
//         ],
//       ),
//     ],
//   );
// }
