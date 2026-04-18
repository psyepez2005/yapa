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
      // 1. El "Cascarón" de la app principal
      GoRoute(
        path: '/',
        name: 'mockup_home',
        builder: (context, state) => const MockupHomeScreen(),
      ),
      
      // 2. Tu módulo principal del Hackathon
      GoRoute(
        path: '/loyalty',
        name: 'loyalty_dashboard',
        builder: (context, state) => const LoyaltyDashboardScreen(),
      ),
    ],
    // Manejo de errores de navegación
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Ruta no encontrada: ${state.uri.toString()}')),
    ),
  );
}