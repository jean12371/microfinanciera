// lib/config/firebase_config.dart

import 'package:firebase_core/firebase_core.dart';
// Importa la clase de opciones de Firebase generada automáticamente.
// Asegúrate de que FlutterFire CLI haya generado este archivo (generalmente en lib/).
// import '../firebase_options.dart'; 

class FirebaseConfig {
  
  /// Inicializa la aplicación Firebase. 
  /// Este método es llamado en main.dart antes de ejecutar runApp.
  static Future<void> initialize() async {
    try {
      // Se recomienda llamar ensureInitialized() en main.dart, pero se incluye aquí por si acaso.
      // WidgetsFlutterBinding.ensureInitialized(); 
      
      await Firebase.initializeApp(
        // Descomenta la siguiente línea si has ejecutado 'flutterfire configure'
        // y tienes el archivo firebase_options.dart.
        // options: DefaultFirebaseOptions.currentPlatform,
      );
      
      print("✅ Firebase inicializado con éxito.");
      
    } catch (e) {
      // Manejar cualquier error durante la inicialización
      print("❌ Error al inicializar Firebase: $e");
      // Puedes optar por relanzar el error o manejarlo de forma más robusta.
      rethrow; 
    }
  }

  // Puedes añadir otros métodos o propiedades estáticas aquí si necesitas 
  // obtener instancias de servicios específicos de Firebase (Auth, Firestore, etc.)
  // de forma centralizada.
}