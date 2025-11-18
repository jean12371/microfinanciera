// lib/state/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/auth_service.dart';

// 1. Provee la instancia del AuthService para que pueda ser utilizada.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/**
 * 2. AuthStateProvider: Provee el estado actual del usuario (User?) en tiempo real.
 * - Escucha los cambios de authStateChanges del AuthService.
 * - Es la fuente de verdad sobre si el usuario está logueado o no.
 */
final authStateProvider = StreamProvider<User?>((ref) {
  // Observa el stream de cambios de estado de Firebase Auth a través del AuthService.
  return ref.watch(authServiceProvider).authStateChanges;
});

/**
 * 3. AuthController: Clase que gestiona la lógica de negocio (login, logout)
 * y notifica si hay errores o cambios de estado.
 */
class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  
  // StateNotifier requiere un estado inicial. Usamos AsyncValue para manejar carga/error.
  AuthController(this._authService) : super(const AsyncData(null));

  // Iniciar Sesión (utilizado por LoginScreen)
  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await _authService.loginWithEmailPassword(email: email, password: password);
      state = const AsyncData(null); // Éxito
    } catch (e) {
      state = AsyncError(e, StackTrace.current); // Error
    }
  }

  // Cerrar Sesión (utilizado por HomeScreen)
  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await _authService.signOut();
      state = const AsyncData(null); // Éxito
    } catch (e) {
      state = AsyncError(e, StackTrace.current); // Error
    }
  }
  
  // Registrar Usuario (utilizado por RegisterScreen)
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();
    try {
      await _authService.registerWithEmailPassword(email: email, password: password, name: name);
      state = const AsyncData(null); // Éxito
    } catch (e) {
      state = AsyncError(e, StackTrace.current); // Error
    }
  }
}

// 4. Provee el controlador de autenticación (la lógica de negocio)
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});