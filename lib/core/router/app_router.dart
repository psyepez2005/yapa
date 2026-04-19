import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:yapa/features/auth/ui/screens/login_screen.dart';
import 'package:yapa/features/deunabusiness/ui/screens/business_mockup_screen.dart';
import '../../features/deunamockup/ui/screens/mockup_home_screen.dart';
import '../../features/deunamockup/ui/screens/mockup_qr_scanner_screen.dart';
import '../../features/deunamockup/ui/screens/mockup_payment_amount_screen.dart';
import '../../features/deunamockup/ui/screens/mockup_payment_confirmation_screen.dart';
import '../../features/deunamockup/ui/screens/mockup_payment_receipt_screen.dart';
import '../../features/loyalty/ui/screens/loyalty_dashboard_screen.dart';
import '../../features/loyalty/ui/screens/business_detail_screen.dart';
import '../../features/loyalty/ui/screens/my_yapas_screen.dart'; 
// ✅ NUEVA IMPORTACIÓN
import '../../features/loyalty/ui/screens/business_yapas_screen.dart'; 

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
        builder: (context, state) => const MyYapasScreen(),
      ),

      // ✅ NUEVA RUTA PARA LOS CUPONES DEL NEGOCIO
      GoRoute(
        path: '/business-yapas',
        name: 'business_yapas',
        builder: (context, state) {
          final data = (state.extra as Map<String, dynamic>?) ?? {};
          return BusinessYapasScreen(
            businessName: data['name'] ?? 'Negocio',
            availableYapas: data['yapas'] ?? 0,
          );
        },
      ),

      GoRoute(
        path: '/payment-amount',
        name: 'payment_amount',
        builder: (context, state) => const MockupPaymentAmountScreen(),
      ),
      GoRoute(
        path: '/payment-confirmation/:amount',
        name: 'payment_confirmation',
        builder: (context, state) {
          final amount = state.pathParameters['amount'] ?? '0.00';
          return MockupPaymentConfirmationScreen(amount: amount);
        },
      ),
      GoRoute(
        path: '/payment-receipt/:amount/:yapa',
        name: 'payment_receipt',
        builder: (context, state) {
          final amount = state.pathParameters['amount'] ?? '0.00';
          final yapa = state.pathParameters['yapa'] ?? 'NINGUNA';
          return MockupPaymentReceiptScreen(amount: amount, usedYapa: yapa);
        },
      ),
      GoRoute(
        path: '/business-detail',
        name: 'business_detail',
        builder: (context, state) {
          final data = (state.extra as Map<String, dynamic>?) ?? {};
          
          final List<Map<String, dynamic>> mockTransactions = [
            {'date': '18 Abr 2026, 10:30', 'amount': 15.50, 'points': 15},
            {'date': '15 Abr 2026, 14:15', 'amount': 8.00, 'points': 8},
            {'date': '10 Abr 2026, 09:00', 'amount': 22.40, 'points': 22},
          ];
          
          return BusinessDetailScreen(
            businessName: data['name'] ?? 'Negocio',
            businessIcon: data['icon'] ?? Icons.store,
            tierName: data['tier'] ?? 'Bronce',
            currentTrustPoints: 75, 
            targetTrustPoints: 100,
            // ✅ EXTRAEMOS LAS YAPAS QUE VIENEN DESDE LA TARJETA DEL DASHBOARD
            availableYapas: data['currentPoints'] ?? 0, 
            transactions: data['transactions'] ?? mockTransactions, 
          );
        },
      ),
    ],
  );
}