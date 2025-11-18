// lib/ui/widgets/quota_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/quota_model.dart';

class QuotaItem extends StatelessWidget {
  final QuotaModel quota;
  final VoidCallback onPayTap;

  const QuotaItem({
    super.key,
    required this.quota,
    required this.onPayTap,
  });

  // Determina el color del estado de la cuota
  Color _getStatusColor() {
    if (quota.isPaid) {
      return Colors.green.shade600;
    }
    // Si la cuota está vencida (fecha de vencimiento anterior a hoy)
    if (quota.dueDate.isBefore(DateTime.now()) && quota.amountPaid < quota.amountDue) {
      return Colors.red.shade600;
    }
    // Pendiente y no vencida
    return Colors.orange.shade600;
  }

  // Genera el texto del estado
  String _getStatusText() {
    if (quota.isPaid) {
      return 'PAGADA';
    }
    if (quota.dueDate.isBefore(DateTime.now())) {
      return 'VENCIDA';
    }
    return 'PENDIENTE';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    final amountDueText = currencyFormatter.format(quota.amountDue);
    final amountPaidText = currencyFormatter.format(quota.amountPaid);
    final amountRemaining = currencyFormatter.format(quota.amountDue - quota.amountPaid);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Encabezado: Número y Estado ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cuota #${quota.quotaNumber}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 15),

            // --- Fechas y Montos ---
            _buildDetailRow(
              'Vencimiento',
              DateFormat('dd/MM/yyyy').format(quota.dueDate),
              Icons.date_range,
            ),
            _buildDetailRow(
              'Monto Total',
              amountDueText,
              Icons.monetization_on,
            ),
            _buildDetailRow(
              'Monto Pagado',
              amountPaidText,
              Icons.paid,
              color: Colors.green.shade700,
            ),
            
            const Divider(height: 15),

            // --- Saldo Pendiente ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SALDO PENDIENTE:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(amountRemaining, style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: quota.isPaid ? Colors.grey : Colors.red,
                )),
              ],
            ),
            const SizedBox(height: 10),

            // --- Botón de Acción ---
            if (!quota.isPaid)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onPayTap,
                  icon: const Icon(Icons.payment, size: 20),
                  label: const Text('REALIZAR PAGO', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Widget auxiliar para las filas de detalle
  Widget _buildDetailRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(child: Text('$label:', style: const TextStyle(fontSize: 14))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}