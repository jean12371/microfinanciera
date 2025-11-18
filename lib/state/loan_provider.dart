// lib/state/loan_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/loan_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

/// 1. Provider para FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// 2. Provider para obtener el UID del usuario autenticado.
/// Se basa en el authStateProvider.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).maybeWhen(
        data: (user) => user?.uid,
        orElse: () => null,
      );
});

/// 3. Provider que obtiene todos los préstamos del usuario actual.
/// Si no hay usuario logueado, emite un stream vacío.
final loansListProvider = StreamProvider<List<LoanModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  if (userId == null) {
    // Regresamos un stream vacío si no hay usuario logueado
    return Stream.value(const []);
  }

  // Se llama al FirestoreService para obtener los préstamos
  return firestoreService.getLoansByUserId(userId);
});
