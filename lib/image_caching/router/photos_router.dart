import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterpractisetasks/hub/app_router/navigator_key.dart';
import 'package:flutterpractisetasks/image_caching/hard/bloc/photo_bloc.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/main_screens/collections/allcollectionscreen.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/main_screens/collections/collections_details.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/main_screens/explorepage.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/navbottom/photomainwrapper.dart';
import 'package:flutterpractisetasks/hub/app_routes/app_routes.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/placeholder/placeholder.dart';
import 'package:go_router/go_router.dart';
import 'package:flutterpractisetasks/image_caching/hard/screens/main_screens/details/photodetailscreen.dart';
import 'package:flutterpractisetasks/image_caching/models/photo_model.dart'
    as photo_model;
import 'package:flutterpractisetasks/image_caching/hard/screens/main_screens/favorite/favoritescreen.dart';

class PhotosRouter {
  static StatefulShellRoute route(GlobalKey<NavigatorState> rootNavigatorKey) {
    return StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          PhotoMainWrapper(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.explore,
              builder: (context, state) {
                debugPrint('Explore route');
                return const Explorepage();
              },
              routes: [
                GoRoute(
                  path: 'allCollections',
                  name: AppRoutes.allCollections,
                  builder: (context, state) => const AllCollectionsScreen(),
                  routes: [
                    GoRoute(
                      path: 'details/:collectionId',
                      name: AppRoutes.collectionDetails,
                      builder: (context, state) {
                        final collectionId =
                            state.pathParameters['collectionId'] as String;
                        final collectionTitle =
                            (state.extra
                                    as Map<
                                      String,
                                      dynamic
                                    >?)?['collectionTitle']
                                as String? ??
                            '';

                        debugPrint('Collection Details route');
                        return CollectionPhotosScreen(
                          collectionId: collectionId,
                          collectionTitle: collectionTitle,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'details',
                  name: AppRoutes.photoDetails,
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final extraMap = state.extra as Map<String, dynamic>;
                    final photoBloc = extraMap['photoBloc'] as PhotoBloc;
                    final photo = extraMap['photo'] as photo_model.PhotoEnity;

                    debugPrint('Photo Details route');
                    return BlocProvider.value(
                      value: photoBloc,
                      child: PhotoDetailScreen(photo: photo),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // Ví dụ cho các tab trống
        // Search tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.search,
              builder: (context, state) =>
                  const PlaceholderTab(label: 'Search Tab'),
            ),
          ],
        ),

        // Favorites tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.favorite,
              builder: (context, state) {
                debugPrint('Favorite route');
                return const FavoritesScreen();
              },
            ),
          ],
        ),
        // Profile tab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) =>
                  const PlaceholderTab(label: 'Profile Tab'),
            ),
          ],
        ),
      ],
    );
  }
}
