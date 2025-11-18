import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/quota_model.dart';
import '../../../services/firestore_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final String loanId; // ← El historial trabaja con ID de préstamo

  const PaymentHistoryScreen({super.key, required this.loanId});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pagos'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<QuotaModel>>(
        stream: _firestoreService.getQuotasByLoanId(widget.loanId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final quotas = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quotas.length,
            itemBuilder: (context, index) {
              final quota = quotas[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    'Cuota #${quota.quotaNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Monto total: ${currencyFormatter.format(quota.amountDue)}"),
                      Text("Pagado: ${currencyFormatter.format(quota.amountPaid)}"),
                      Text("Estado: ${quota.isPaid ? "Pagada" : "Pendiente"}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
