// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'config/app_routes.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/auth/login_screen.dart';

// Importa el archivo generado por FlutterFire. 
// Asume que el archivo .yaml fue usado para generar esta clase.
// import 'firebase_options.dart'; 

void main() async {
  // Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicialización de Firebase con las opciones de la plataforma
  try {
    await Firebase.initializeApp(
      // Descomentar si usaste `flutterfire configure`
      // options: DefaultFirebaseOptions.currentPlatform, 
    ); 
  } catch (e) {
    // Manejo de errores en caso de fallo en la inicialización (ej. falta de options)
    print("Error al inicializar Firebase: $e");
  }
  
  runApp(const MicroFinApp());
}

class MicroFinApp extends StatelessWidget {
  const MicroFinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MicroFin App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
          secondary: Colors.amber,
        ),
        useMaterial3: true,
      ),
      
      // Enlace de las rutas centralizadas
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,

      // El AuthWrapper decide la pantalla inicial
      home: const AuthWrapper(),
    );
  }
}

/**
 * Widget que envuelve la aplicación para determinar si el usuario
 * está autenticado o no (Login vs. Home).
 */
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios de estado de autenticación de Firebase
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        // Estado de conexión: cargando la información inicial
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
          );
        }
        
        // Si hay datos (un usuario está logueado), mostrar la pantalla Home
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }
        
        // Si no hay datos (no hay usuario logueado), mostrar la pantalla Login
        return const LoginScreen();
      },
    );
  }
}