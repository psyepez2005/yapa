import 'package:go_router/go_router.dart';
import 'package:yapa/core/models/loyalty_profile.dart';
import 'package:yapa/features/auth/ui/screens/login_screen.dart';
import 'package:yapa/features/auth/ui/screens/user_login_screen.dart';
import 'package:yapa/features/auth/ui/screens/merchant_login_screen.dart';
import 'package:yapa/features/deunabusiness/ui/screens/business_mockup_screen.dart';
import 'package:yapa/features/loyalty/ui/screens/my_yapas_screen.dart';
import '../../features/deunamockup/ui/screens/mockup_home_screen.dart';
import '../../features/deunamockup/ui/screens/mockup_qr_scanner_screen.dart';
import '../../features/loyalty/ui/screens/loyalty_dashboard_screen.dart';
import '../../features/loyalty/ui/screens/business_detail_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/login/user',
        name: 'user_login',
        builder: (context, state) => const UserLoginScreen(),
      ),
      GoRoute(
        path: '/login/merchant',
        name: 'merchant_login',
        builder: (context, state) => const MerchantLoginScreen(),
      ),
      GoRoute(
        path: '/business',
        name: 'business_mockup',
        builder: (context, state) => const BusinessMockupScreen(),
      ),
      GoRoute(
        path: '/mockup',
        name: 'mockup_home',
        builder: (context, state) => const MockupHomeScreen(),
      ),
      GoRoute(
        path: '/loyalty',
        name: 'loyalty_dashboard',
        builder: (context, state) => const LoyaltyDashboardScreen(),
      ),
      GoRoute(
        path: '/qr-scanner',
        name: 'qr_scanner',
        builder: (context, state) => const MockupQrScannerScreen(),
      ),
      GoRoute(
        path: '/my-yapas',
        name: 'my_yapas',
        builder: (context, state) {
          final entries = (state.extra as List?)
                  ?.cast<LoyaltyProfileEntry>() ??
              const [];
          return MyYapasScreen(entries: entries);
        },
      ),
      GoRoute(
        path: '/business-detail',
        name: 'business_detail',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;

          final activeYapas =
              (data['activeYapas'] as List?)?.cast<ActiveYapa>() ?? [];

          // Historial mock mientras no existe endpoint de transacciones
          final mockTransactions = [
            {'date': '18 Abr 2026, 10:30', 'amount': 15.50, 'points': 15},
            {'date': '15 Abr 2026, 14:15', 'amount': 8.00, 'points': 8},
            {'date': '10 Abr 2026, 09:00', 'amount': 22.40, 'points': 22},
          ];

          return BusinessDetailScreen(
            businessName: data['name'] as String,
            businessIcon: data['icon'],
            tierName: data['tier'] as String,
            cashbackPercentage: data['cashback'] as String,
            currentTrustPoints: (data['currentPoints'] as num?)?.toInt() ?? 0,
            targetTrustPoints: (data['targetPoints'] as num?)?.toInt() ?? 100,
            activeYapas: activeYapas,
            transactions: data['transactions'] as List<Map<String, dynamic>>? ??
                mockTransactions,
          );
        },
      ),
    ],
  );
}
