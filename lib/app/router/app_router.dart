import 'package:go_router/go_router.dart';
import 'package:hotelyn/features/home/view/home_page.dart';
import 'package:hotelyn/features/login/view/login_page.dart';
import 'package:hotelyn/features/on_boarding/view/on_boarding_page.dart';
import 'package:hotelyn/features/splash/view/splash_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnBoardingPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
}
