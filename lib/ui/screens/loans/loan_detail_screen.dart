// lib/ui/screens/loans/loan_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Necesitas la librería intl en pubspec.yaml para formato de fecha/moneda
import '../../../../models/loan_model.dart';
import '../../../../config/app_routes.dart';

class LoanDetailScreen extends StatelessWidget {
  final LoanModel loan;
  
  // Se espera que el LoanModel se pase como argumento al navegar
  const LoanDetailScreen({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    // Helper para formato de moneda (asegúrate de que el locale sea correcto)
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Préstamo'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Encabezado ---
            Text(
              'Monto Solicitado: ${currencyFormatter.format(loan.amount)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 10),
            Text('Estado: ${loan.status}', 
              style: TextStyle(
                fontSize: 18, 
                color: loan.status == 'Paid' ? Colors.green : (loan.status == 'Pending' ? Colors.orange : Colors.red),
              ),
            ),
            const Divider(height: 30),

            // --- Detalles del Préstamo ---
            _buildDetailRow(
              context,
              icon: Icons.calendar_today,
              label: 'Fecha de Solicitud',
              value: DateFormat('dd/MM/yyyy').format(loan.requestDate),
            ),
            _buildDetailRow(
              context,
              icon: Icons.timer,
              label: 'Plazo (Meses)',
              value: '${loan.termMonths}',
            ),
            _buildDetailRow(
              context,
              icon: Icons.pie_chart,
              label: 'Tasa de Interés',
              value: '${(loan.interestRate * 100).toStringAsFixed(1)}% Anual',
            ),
            
            const SizedBox(height: 40),

            // --- Botón de Gestión de Cuotas (Punto 4) ---
            ElevatedButton.icon(
              onPressed: () {
                // Navegar a la pantalla de lista de cuotas, pasando el ID del préstamo
                if (loan.id != null) {
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.quotasList, 
                    arguments: loan.id
                  );
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('El préstamo aún no tiene un ID válido.')),
                    );
                }
              },
              icon: const Icon(Icons.list_alt),
              label: const Text('Ver y Gestionar Cuotas'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para mostrar filas de detalle consistentes
  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.blueGrey, size: 24),
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}