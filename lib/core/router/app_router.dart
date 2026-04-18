import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Importaremos las pantallas
import '../../features/deunamockup/ui/screens/mockup_home_screen.dart';
import '../../features/loyalty/ui/screens/loyalty_dashboard_screen.dart';
import '../../features/auth/ui/screens/login_screen.dart';
import '../../features/deunabusiness/ui/screens/business_mockup_screen.dart';

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
      // Configuración de tu pantalla de Loyalty
      GoRoute(
        path: '/loyalty',
        name: 'loyalty_dashboard', // Este nombre es el que usaremos para navegar
        builder: (context, state) => const LoyaltyDashboardScreen(),
      ),
    ],
  );
}