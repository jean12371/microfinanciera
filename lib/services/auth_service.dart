// lib/services/auth_service.dart (ACTUALIZADO)

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; 

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Método de registro (el provisto anteriormente)
  Future<User?> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    // ... (El código de registro previo aquí)
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel newUser = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(newUser.uid).set(newUser.toMap());

      return credential.user;
    } on FirebaseAuthException catch (e) {
      print('Error de registro: ${e.message}');
      return null;
    }
  }

  // 1. Método de inicio de sesión (¡NUEVO!)
  Future<User?> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      // Manejo de errores de autenticación
      print('Error de inicio de sesión: ${e.message}');
      return null;
    }
  }

  // Stream para detectar cambios de estado de autenticación (útil para main.dart)
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}