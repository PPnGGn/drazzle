import 'package:drazzle/ui/auth/pages/email_verivy_page.dart';
import 'package:drazzle/ui/auth/pages/login_page.dart';
import 'package:drazzle/ui/auth/pages/register_page.dart';
import 'package:drazzle/ui/gallery/gallery_page.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      builder: (context, state) => const LoginPage(),
      path: '/login',
      name: 'login',
    ),
    GoRoute(
      builder: (context, state) => const RegisterPage(),
      path: '/register',
      name: 'register',
    ),
    GoRoute(
      builder: (context, state) => const GalleryPage(),
      path: '/gallery',
      name: 'gallery',
    ),
    GoRoute(
      builder: (context, state) => const EmailVerifyPage(),
      path: '/email-verify',
      name: 'email-verify',
    ),
  ],
);
