import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/success_screen.dart';
import '../../presentation/screens/print_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    GoRoute(path: '/registro', builder: (context, state) => const RegisterScreen()),
    
    GoRoute(
      path: '/success',
      builder: (context, state) {
        final id = state.extra as String?; 
        return SuccessScreen(registerId: id);
      },
    ),

    GoRoute(path: '/impresion', builder: (context, state) => const PrintScreen()),

    GoRoute(
      path: '/computo',
      builder: (context, state) => const Scaffold(
        body: Center(child: Text("Módulo de Cómputo (Próximamente)")),
      ),
    ),
  ],
);