// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loan_model.dart';
import '../models/quota_model.dart';
import '../models/payment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// (2) Solicitar un nuevo préstamo
  Future<void> requestNewLoan(LoanModel loan) async {
    try {
      // Crear el préstamo
      DocumentReference docRef =
          await _db.collection('loans').add(loan.toMap());

      // ID asignado automáticamente
      String loanId = docRef.id;

      // Generar cuotas simples (puedes mejorar la lógica más adelante)
      for (int i = 1; i <= loan.termMonths; i++) {
        QuotaModel quota = QuotaModel(
          loanId: loanId,
          quotaNumber: i,
          dueDate: DateTime.now().add(Duration(days: 30 * i)),
          amountDue: loan.amount / loan.termMonths,
          amountPaid: 0.0,
          isPaid: false,
        );

        await _db.collection('quotas').add(quota.toMap());
      }
    } catch (e) {
      print('Error al solicitar préstamo: $e');
      rethrow;
    }
  }

  /// ⭐ (Nuevo) Obtener los préstamos del usuario
  Stream<List<LoanModel>> getLoansByUserId(String userId) {
    return _db
        .collection('loans')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((query) {
      return query.docs
          .map((doc) => LoanModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// (4) Obtener cuotas de un préstamo
  Stream<List<QuotaModel>> getQuotasByLoanId(String loanId) {
    return _db
        .collection('quotas')
        .where('loanId', isEqualTo: loanId)
        .orderBy('quotaNumber')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => QuotaModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// (3) Registrar pago de una cuota
  Future<void> registerPayment({
    required QuotaModel quota,
    required double paymentAmount,
    required String paymentMethod,
  }) async {
    // 1. Guardar el pago en la colección "payments"
    PaymentModel newPayment = PaymentModel(
      quotaId: quota.id!,
      amount: paymentAmount,
      paymentDate: DateTime.now(),
      method: paymentMethod,
    );

    await _db.collection('payments').add(newPayment.toMap());

    // 2. Actualizar cuota
    double newAmountPaid = quota.amountPaid + paymentAmount;
    bool newIsPaid = newAmountPaid >= quota.amountDue;

    await _db.collection('quotas').doc(quota.id).update({
      'amountPaid': newAmountPaid,
      'isPaid': newIsPaid,
    });
  }
}
