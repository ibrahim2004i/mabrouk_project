import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Screens
import 'package:mabrouk_app/features/auth/presentation/login_screen.dart';
import 'package:mabrouk_app/features/auth/presentation/register_type_screen.dart';
import 'package:mabrouk_app/features/auth/presentation/register_customer_screen.dart';
import 'package:mabrouk_app/features/auth/presentation/register_provider_screen.dart';
import 'package:mabrouk_app/features/auth/presentation/pending_approval_screen.dart';
import 'package:mabrouk_app/features/services/presentation/home_screen.dart';
import 'package:mabrouk_app/features/bookings/presentation/my_bookings_screen.dart';
import 'package:mabrouk_app/features/services/presentation/service_details_screen.dart';
import 'package:mabrouk_app/features/dashboard/presentation/provider_dashboard_screen.dart';
import 'package:mabrouk_app/features/bookings/presentation/provider_bookings_screen.dart';
import 'package:mabrouk_app/features/admin/presentation/admin_moderation_screen.dart';
import 'package:mabrouk_app/features/services/presentation/add_service_screen.dart';
import 'package:mabrouk_app/features/services/presentation/provider_services_screen.dart';
import 'package:mabrouk_app/features/bookings/presentation/service_bookings_screen.dart';
import 'package:mabrouk_app/features/bookings/presentation/booking_details_screen.dart';
import 'package:mabrouk_app/features/profile/presentation/profile_screen.dart';
import 'package:mabrouk_app/features/settings/presentation/settings_screen.dart';
import 'package:mabrouk_app/features/notifications/presentation/notifications_screen.dart';
import 'package:mabrouk_app/features/services/presentation/favorites_screen.dart';

import 'package:mabrouk_app/features/reels/presentation/reels_screen.dart';

import 'package:mabrouk_app/features/bookings/domain/booking_model.dart';
import 'package:mabrouk_app/features/auth/presentation/auth_state.dart';

import '../../features/info/presentation/about_screen.dart';
import '../../features/services/domain/service_models.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = RouterNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: authNotifier,
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      GoRoute(
  path: '/reels',
  builder: (context, state) => const ReelsScreen(),
),



      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // GLOBAL ROUTES (Shared between roles)
      GoRoute(
        path: '/bookings/:id',
        builder: (context, state) {
          final booking = state.extra as Booking;
          return BookingDetailsScreen(booking: booking);
        },
      ),

      GoRoute(
        path: '/customer/services/:type/:id',
        builder: (context, state) {
          final type = state.pathParameters['type']!;
          final id = state.pathParameters['id']!;
          final showPanel =
              state.uri.queryParameters['showBookingPanel'] != 'false';

          return ServiceDetailsScreen(
            serviceType: type,
            serviceId: id,
            showBookingPanel: showPanel,
          );
        },
      ),

      // CUSTOMER FLOW
      ShellRoute(
        builder: (context, state, child) => Scaffold(body: child),
        routes: [
          GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
          GoRoute(
            path: '/register-type',
            builder: (context, state) => RegisterTypeScreen(),
          ),
          GoRoute(
            path: '/register/customer',
            builder: (context, state) => RegisterCustomerScreen(),
          ),
          GoRoute(
            path: '/register/provider',
            builder: (context, state) => RegisterProviderScreen(),
          ),
          GoRoute(
            path: '/register/pending-approval',
            builder: (context, state) => PendingApprovalScreen(),
          ),
          GoRoute(
            path: '/customer/home',
            builder: (context, state) => HomeScreen(),
          ),
          GoRoute(
            path: '/customer/bookings',
            builder: (context, state) => MyBookingsScreen(),
          ),
          GoRoute(
            path: '/customer/favorites',
            builder: (context, state) => FavoritesScreen(),
          ),
          GoRoute(
            path: '/customer/profile',
            builder: (context, state) => ProfileScreen(),
          ),
          GoRoute(
            path: '/customer/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/customer/about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),

      // PROVIDER FLOW
      ShellRoute(
        builder: (context, state, child) => Scaffold(body: child),
        routes: [
          GoRoute(
            path: '/provider/dashboard',
            builder: (context, state) => const ProviderDashboardScreen(),
          ),
          GoRoute(
            path: '/provider/bookings',
            builder: (context, state) => const ProviderBookingsScreen(),
          ),
          GoRoute(
            path: '/provider/my-services',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return ProviderServicesScreen(
                targetProviderId: extra?['id'],
                targetProviderName: extra?['name'],
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/provider/services/:type/:id/bookings',
        builder: (context, state) {
          final type = state.pathParameters['type']!;
          final id = int.parse(state.pathParameters['id']!);
          final name = state.extra as String;
          return ServiceBookingsScreen(type: type, id: id, serviceTitle: name);
        },
      ),
      GoRoute(
        path: '/provider/add-service',
        builder: (context, state) {
          final service = state.extra as ServiceBase?;
          return AddServiceScreen(existingService: service);
        },
      ),

      // ADMIN FLOW
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminModerationScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final loggingIn = state.matchedLocation == '/login';
      final location = state.matchedLocation;

      // Publicly accessible routes (Discover Mode)
      final publicRoutes = [
        '/login',
        '/register-type',
        '/register/customer',
        '/register/provider',
        '/register/pending-approval',
        '/customer/home',
        '/customer/settings',
        '/customer/about',
      ];

      final bool isPublicRoute =
          publicRoutes.contains(location) ||
          (location.startsWith('/customer/services/') &&
              !location.endsWith('/bookings'));

      if (authState is! AuthSuccess) {
        // If user is NOT logged in and trying to access a private route, send to login
        if (!isPublicRoute) return '/login';
        return null;
      }

      // User IS logged in
      final role = authState.user.role;
      
      // If user is on login/register pages but is already authenticated, redirect to their home
      if (loggingIn || location == '/register-type' || location.startsWith('/register/')) {
        if (role == 'admin') return '/admin';
        if (role == 'provider') return '/provider/dashboard';
        return '/customer/home';
      }

      // Protect routes based on role
      if (location.startsWith('/admin') && role != 'admin') return '/customer/home';
      if (location.startsWith('/provider') && role != 'provider' && role != 'admin') return '/customer/home';

      return null;
    },
  );
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (previous, next) {
      notifyListeners();
    });
  }
}
