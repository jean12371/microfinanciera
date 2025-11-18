// lib/ui/screens/quotas/quota_list_screen.dart

import 'package:flutter/material.dart';
import '../../../models/quota_model.dart';
import '../../../services/firestore_service.dart';
import '../../widgets/quota_item.dart';
import '../../../config/app_routes.dart';

class QuotaListScreen extends StatelessWidget {
  final String loanId;
  
  const QuotaListScreen({super.key, required this.loanId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuotas del Préstamo'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Ver Historial de Pagos',
            onPressed: () {
              Navigator.pushNamed(
                context, 
                AppRoutes.paymentHistory, 
                arguments: loanId,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<QuotaModel>>(
        stream: firestoreService.getQuotasByLoanId(loanId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar las cuotas: ${snapshot.error}'));
          }

          final quotas = snapshot.data;

          if (quotas == null || quotas.isEmpty) {
            return const Center(
              child: Text(
                'No hay cuotas programadas para este préstamo.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            itemCount: quotas.length,
            itemBuilder: (context, index) {
              final quota = quotas[index];
              
              return QuotaItem(
                quota: quota,
                onPayTap: () {
                  if (quota.isPaid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Esta cuota ya está marcada como PAGADA.')),
                    );
                    return;
                  }
                  
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.payment, 
                    arguments: quota,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
