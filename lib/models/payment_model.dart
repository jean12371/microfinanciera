// lib/models/payment_model.dart

class PaymentModel {
  final String? id; // ID de Firestore (puede ser nulo al crear)
  final String quotaId; // ID de la cuota pagada (vincula con QuotaModel)
  final double amount;
  final DateTime paymentDate;
  final String method; // Ej: 'Transferencia Bancaria', 'Efectivo'

  PaymentModel({
    this.id,
    required this.quotaId,
    required this.amount,
    required this.paymentDate,
    required this.method,
  });

  // Convertir objeto a un Map para subir a Firestore
  Map<String, dynamic> toMap() {
    return {
      'quotaId': quotaId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'method': method,
    };
  }

  // Crear objeto desde un DocumentSnapshot de Firestore
  factory PaymentModel.fromMap(Map<String, dynamic> map, String id) {
    return PaymentModel(
      id: id,
      quotaId: map['quotaId'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(map['paymentDate']),
      method: map['method'] ?? 'Desconocido',
    );
  }
}