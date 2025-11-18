// lib/models/loan_model.dart

class LoanModel {
  final String? id; // ID de Firestore (puede ser nulo al crear)
  final String userId;
  final double amount;
  final int termMonths;
  final double interestRate;
  final String status; // Ej: 'Pending', 'Approved', 'Paid'
  final DateTime requestDate;

  LoanModel({
    this.id,
    required this.userId,
    required this.amount,
    required this.termMonths,
    required this.interestRate,
    this.status = 'Pending',
    required this.requestDate,
  });

  // Convertir objeto a un Map para subir a Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'termMonths': termMonths,
      'interestRate': interestRate,
      'status': status,
      'requestDate': requestDate.toIso8601String(),
    };
  }

  // Crear objeto desde un DocumentSnapshot de Firestore
  factory LoanModel.fromMap(Map<String, dynamic> map, String id) {
    return LoanModel(
      id: id,
      userId: map['userId'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      termMonths: map['termMonths'] as int,
      interestRate: (map['interestRate'] as num).toDouble(),
      status: map['status'] ?? 'Unknown',
      requestDate: DateTime.parse(map['requestDate']),
    );
  }
}