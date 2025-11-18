// lib/models/quota_model.dart

class QuotaModel {
  final String? id; // ID de Firestore (ID del documento de la cuota)
  final String loanId;
  final int quotaNumber;
  final DateTime dueDate;
  final double amountDue;
  final double amountPaid;
  final bool isPaid;

  QuotaModel({
    this.id,
    required this.loanId,
    required this.quotaNumber,
    required this.dueDate,
    required this.amountDue,
    this.amountPaid = 0.0,
    this.isPaid = false,
  });

  // Convertir objeto a un Map para subir a Firestore
  Map<String, dynamic> toMap() {
    return {
      'loanId': loanId,
      'quotaNumber': quotaNumber,
      'dueDate': dueDate.toIso8601String(),
      'amountDue': amountDue,
      'amountPaid': amountPaid,
      'isPaid': isPaid,
    };
  }

  // Crear objeto desde un DocumentSnapshot de Firestore
  factory QuotaModel.fromMap(Map<String, dynamic> map, String id) {
    return QuotaModel(
      id: id,
      loanId: map['loanId'] ?? '',
      quotaNumber: map['quotaNumber'] as int,
      dueDate: DateTime.parse(map['dueDate']),
      amountDue: (map['amountDue'] as num).toDouble(),
      amountPaid: (map['amountPaid'] as num).toDouble(),
      isPaid: map['isPaid'] ?? false,
    );
  }
}