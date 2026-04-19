import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(const DeUnaLoyaltyApp());
}

class DeUnaLoyaltyApp extends StatelessWidget {
  const DeUnaLoyaltyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DeUna Fidelización - Hackathon',
      debugShowCheckedModeBanner: false, // Escondemos la etiqueta de debug para la demo
      theme: AppTheme.lightTheme,
      
      // Configuración de GoRouter
      routerConfig: AppRouter.router,
    );
  }
}