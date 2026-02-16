import 'package:carnetizacion/presentation/screens/computo_screen.dart';
import 'package:carnetizacion/presentation/screens/login_screen.dart';
import 'package:carnetizacion/presentation/screens/unidades_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/dashboard_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/success_screen.dart';
import '../../presentation/screens/print_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    GoRoute(
      path: '/registro',
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/success',
      builder: (context, state) {
        final id = state.extra as String?;
        return SuccessScreen(registerId: id);
      },
    ),
    
    GoRoute(
      path: '/impresion',
      builder: (context, state) => const PrintScreen(),
    ),

    GoRoute(
      path: '/unidades',
      builder: (context, state) => const UnidadesScreen(),
    ),
    GoRoute(
      path: '/computo',
      builder: (context, state) => const ComputoScreen(),
    ),
    GoRoute(
  path: '/login',
  builder: (context, state) => const LoginScreen(),
),
  ],
);
