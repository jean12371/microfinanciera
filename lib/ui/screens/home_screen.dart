// lib/ui/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../config/app_routes.dart';
import '../../../models/loan_model.dart';
import '../widgets/loan_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    void logout() async {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MicroFin App - Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: Text('Error: Usuario no autenticado.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Mis Préstamos',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),

                  // StreamBuilder de préstamos
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('loans')
                          .where('userId', isEqualTo: userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text('Aún no tienes préstamos.'));
                        }

                        final loans = snapshot.data!.docs
                            .map((doc) => LoanModel.fromMap(
                                doc.data() as Map<String, dynamic>, doc.id))
                            .toList();

                        return ListView.builder(
                          itemCount: loans.length,
                          itemBuilder: (context, index) {
                            final loan = loans[index];
                            return LoanCard(
                              key: ValueKey(loan.id), // <- Agregado para identificar cada tarjeta
                              loan: loan,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.quotasList,
                                  arguments: loan.id,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.loanRequest);
        },
        label: const Text('Solicitar Préstamo'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
