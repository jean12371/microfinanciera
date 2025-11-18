// lib/ui/screens/payments/payment_screen.dart (CÓDIGO CORREGIDO)

import 'package:flutter/material.dart';
import '../../../models/quota_model.dart';
import '../../../services/firestore_service.dart';

class PaymentScreen extends StatefulWidget {
  // 1. Ahora el widget requiere el objeto QuotaModel en su constructor
  final QuotaModel quota; 

  // 2. Constructor actualizado
  const PaymentScreen({super.key, required this.quota});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _paymentMethod = 'Transferencia Bancaria';
  
  // Usamos 'late' y lo inicializamos en initState
  late TextEditingController _amountController; 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 3. Inicializar el controlador usando widget.quota dentro de initState
    _amountController = TextEditingController(
      // Establecer el texto inicial al saldo pendiente
      text: (widget.quota.amountDue - widget.quota.amountPaid).toStringAsFixed(2),
    );
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }


  // Método de pago actualizado para usar widget.quota
  Future<void> _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final double paymentAmount = double.tryParse(_amountController.text) ?? 0.0;
      
      try {
        await _firestoreService.registerPayment(
          // Usamos el objeto quota del widget (que fue pasado por AppRoutes)
          quota: widget.quota, 
          paymentAmount: paymentAmount,
          paymentMethod: _paymentMethod,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pago registrado con éxito.')),
          );
          Navigator.pop(context); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al procesar el pago: $e')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 4. Accedemos a la cuota a través de widget.quota
    final quota = widget.quota;
    
    // Ya no es necesario el ModalRoute.of(context) ni la verificación de nulidad.
    // El widget ahora asume que tiene una cuota válida.

    return Scaffold(
      appBar: AppBar(title: Text('Pagar Cuota #${quota.quotaNumber}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Resumen de la Cuota
              Card(
                elevation: 3,
                child: ListTile(
                  title: Text('Monto Total a Pagar: \$${quota.amountDue.toStringAsFixed(2)}'),
                  subtitle: Text('Pagado hasta ahora: \$${quota.amountPaid.toStringAsFixed(2)}'),
                  trailing: Text('Pendiente: \$${(quota.amountDue - quota.amountPaid).toStringAsFixed(2)}', 
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de Monto a Pagar
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto del Pago',
                  prefixText: '\$',
                ),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  if (amount == null || amount <= 0) {
                    return 'Ingrese un monto válido.';
                  }
                  // La lógica de validación ahora usa directamente el objeto quota
                  if (amount > (quota.amountDue - quota.amountPaid) && !quota.isPaid) {
                     return 'El monto excede el saldo pendiente de esta cuota.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Selector de Método de Pago
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Método de Pago'),
                items: <String>['Transferencia Bancaria', 'Efectivo', 'Tarjeta de Débito']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _paymentMethod = newValue!;
                  });
                },
              ),

              const SizedBox(height: 40),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      // Llama al método sin argumentos, ya que usa widget.quota
                      onPressed: _processPayment, 
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Confirmar Pago', style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}