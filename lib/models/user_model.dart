// lib/models/user_model.dart

class UserModel {
  final String uid; // ID de Firebase Auth
  final String name;
  final String email;
  final String? phone;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    required this.createdAt,
  });

  // Convertir el objeto a un Map para subir a Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Crear un objeto desde un DocumentSnapshot de Firestore
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      // El ID del documento en Firestore es el UID del usuario
      uid: id, 
      name: map['name'] ?? 'N/A',
      email: map['email'] ?? 'N/A',
      phone: map['phone'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Método para crear desde la estructura de Firestore directamente si el UID está en el mapa
  // Esto es útil si los documentos de 'users' tienen el UID como campo interno además de ser el Doc ID.
  factory UserModel.fromFirestore(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? 'N/A',
      name: map['name'] ?? 'N/A',
      email: map['email'] ?? 'N/A',
      phone: map['phone'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}