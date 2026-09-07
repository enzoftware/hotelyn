import 'package:go_router/go_router.dart';
import 'package:hotelyn/features/home/view/home_page.dart';
import 'package:hotelyn/features/hotel_detail/hotel_detail.dart';
import 'package:hotelyn/features/intro/intro.dart';
import 'package:hotelyn/features/login/view/login_page.dart';
import 'package:hotelyn/features/notifications/notifications.dart';
import 'package:hotelyn/features/payment/view/payment_page.dart';
import 'package:hotelyn/features/splash/view/splash_screen.dart';
import 'package:hotelyn_domain/hotelyn_domain.dart' as domain;

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/intro',
        builder: (context, state) => const IntroPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/hotel-detail',
        builder: (context, state) {
          final hotel = state.extra is domain.Hotel
              ? state.extra! as domain.Hotel
              : const domain.Hotel(
                  id: 'default',
                  name: 'Grand Royal Hotel',
                  city: 'Purwokerto',
                  country: 'Indonesia',
                );
          return HotelDetailPage(hotel: hotel);
        },
      ),
      GoRoute(
        path: '/payment',
        builder: (context, state) => const PaymentPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
    ],
  );
}
