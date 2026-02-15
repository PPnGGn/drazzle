import 'dart:typed_data';

import 'package:drazzle/features/auth/ui/pages/login_page.dart';
import 'package:drazzle/features/auth/ui/pages/registration_page.dart';
import 'package:drazzle/core/di/auth_providers.dart';
import 'package:drazzle/core/di/talker_provider.dart';
import 'package:drazzle/features/drawing/ui/pages/drawing_page.dart';
import 'package:drazzle/features/gallery/ui/pages/fullscreen_image_page.dart';
import 'package:drazzle/features/gallery/ui/pages/gallery_page.dart';
import 'package:drazzle/features/splash/splash_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final talker = ref.watch(talkerProvider);
  final router = GoRouter(
    observers: [TalkerRouteObserver(talker)],
    initialLocation: '/splash',

    redirect: (context, state) {
      final authAsync = ref.watch(authUserProvider);
      return authAsync.when(
        data: (user) {
          final isLoggedIn = user != null;
          final isOnAuthPage =
              state.matchedLocation == '/login' ||
              state.matchedLocation == '/registration';
          final isOnSplashPage = state.matchedLocation == '/splash';

          if (isOnSplashPage) {
            return isLoggedIn ? '/gallery' : '/login';
          }

          if (isLoggedIn && isOnAuthPage) {
            return '/gallery';
          }

          if (!isLoggedIn && !isOnAuthPage) {
            return '/login';
          }

          return null;
        },
        loading: () {
          return null;
        },
        error: (error, stack) {
          return '/login';
        },
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/registration',
        name: 'registration',
        builder: (context, state) => const RegistrationPage(),
      ),
      GoRoute(
        path: '/gallery',
        name: 'gallery',
        builder: (context, state) => const GalleryPage(),
      ),
      GoRoute(
        path: '/drawing',
        name: 'drawing',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            final backgroundImage = extra['backgroundImage'];
            final closeOnSave = extra['closeOnSave'];
            final drawingId = extra['drawingId'];
            final title = extra['title'];
            final createdAt = extra['createdAt'];
            return DrawningPage(
              backgroundImage: backgroundImage is Uint8List
                  ? backgroundImage
                  : null,
              closeOnSave: closeOnSave is bool ? closeOnSave : false,
              drawingId: drawingId is String ? drawingId : null,
              initialTitle: title is String ? title : null,
              createdAt: createdAt is DateTime ? createdAt : null,
            );
          }

          return const DrawningPage();
        },
      ),
      GoRoute(
        path: '/image-viewer',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return FullscreenImagePage(
            imageUrl: extra['imageUrl'] as String,
            heroTag: extra['heroTag'] as String,
            drawingId: extra['drawingId'] as String?,
            title: extra['title'] as String?,
            createdAt: extra['createdAt'] as DateTime?,
          );
        },
      ),
    ],
  );

  return router;
});
