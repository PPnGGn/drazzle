import 'package:drazzle/ui/auth/login/login_page.dart';
import 'package:drazzle/ui/auth/register/register_page.dart';
import 'package:drazzle/ui/gallery/gallery_page.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(builder: (context, state) => const LoginPage(), path: '/login', name: 'login'),
    GoRoute(builder: (context, state) => const RegisterPage(), path: '/register', name: 'register'),
    GoRoute(builder: (context, state) => const GalleryPage(), path: '/gallery', name: 'gallery'),
  ],
);
