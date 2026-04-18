import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:yapa/features/auth/ui/screens/login_screen.dart';
import 'package:yapa/features/deunabusiness/ui/screens/business_mockup_screen.dart';
import '../../features/deunamockup/ui/screens/mockup_home_screen.dart';
import '../../features/deunamockup/ui/screens/mockup_qr_scanner_screen.dart';
import '../../features/loyalty/ui/screens/loyalty_dashboard_screen.dart';
import '../../features/loyalty/ui/screens/business_detail_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/', // Inicia en el Login según tus últimos cambios
    routes: [
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
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
      // ✅ Pantalla de detalle conservada de la rama HEAD
      GoRoute(
        path: '/business-detail',
        name: 'business_detail',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          
          final mockTransactions = [
            {'date': '18 Abr 2026, 10:30', 'amount': 15.50, 'points': 15},
            {'date': '15 Abr 2026, 14:15', 'amount': 8.00, 'points': 8},
            {'date': '10 Abr 2026, 09:00', 'amount': 22.40, 'points': 22},
          ];
          
          return BusinessDetailScreen(
            businessName: data['name'],
            businessIcon: data['icon'],
            tierName: data['tier'],
            cashbackPercentage: data['cashback'],
            currentTrustPoints: data['currentPoints'] ?? 0,
            targetTrustPoints: data['targetPoints'] ?? 100,
            transactions: data['transactions'] ?? mockTransactions, 
          );
        },
      ),
    ],
  );
}