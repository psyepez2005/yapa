import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Importaremos las pantallas cuando las creemos. 
// Por ahora usamos placeholders para que no marque error.
import '../../features/deunamockup/ui/screens/mockup_home_screen.dart';
import '../../features/loyalty/ui/screens/loyalty_dashboard_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
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