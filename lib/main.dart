import 'package:carnetizacion/config/provider/auth_provider.dart';
import 'package:carnetizacion/config/provider/employee_provider.dart';
import 'package:carnetizacion/config/provider/register_provider.dart';
import 'package:carnetizacion/config/provider/unidades_provider.dart';
import 'package:carnetizacion/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Importaciones de configuración y rutas
import 'config/router/app_router.dart';
import 'config/theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider permite inyectar múltiples estados en la cima del árbol de widgets
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Provider para el Dashboard (Tabla de empleados)
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),

        // Provider para el Formulario de Registro (Nuevo empleado)
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        ChangeNotifierProvider(create: (_) => UnidadesProvider()),
      ],
      child: MaterialApp.router(
        title: 'Control Central TED',
        debugShowCheckedModeBanner: false,

        // Configuración de rutas (GoRouter)
        routerConfig: appRouter,

        // Tema Global
        theme: ThemeData(
          // Usamos Google Fonts para que se vea moderno como en tu diseño
          textTheme: GoogleFonts.poppinsTextTheme(),
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryYellow),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,

          // Estilo global de inputs para ahorrar código en pantallas
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }
}
