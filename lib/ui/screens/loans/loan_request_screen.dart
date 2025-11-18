// lib/ui/screens/loans/loan_request_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/loan_model.dart';
import '../../../../services/firestore_service.dart';
import '../../../../config/app_routes.dart';
import '../../../../state/auth_provider.dart';
import '../../../../state/loan_provider.dart'; // Necesitas importar esto si usas Riverpod

// Usamos ConsumerStatefulWidget para interactuar con Riverpod
class LoanRequestScreen extends ConsumerStatefulWidget {
  const LoanRequestScreen({super.key});

  @override
  ConsumerState<LoanRequestScreen> createState() => _LoanRequestScreenState();
}

class _LoanRequestScreenState extends ConsumerState<LoanRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double _amount = 1000.0;
  int _termMonths = 12;
  // Tasa de interés fija para el ejemplo
  final double _interestRate = 0.05; 
  bool _isLoading = false;

  Future<void> _submitLoanRequest() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Obtener el UID del usuario actual usando Riverpod
      final userId = ref.read(currentUserIdProvider);
      final firestoreService = ref.read(firestoreServiceProvider);

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Usuario no identificado. Vuelva a iniciar sesión.')),
          );
        }
        return;
      }

      setState(() => _isLoading = true);

      final newLoan = LoanModel(
        userId: userId,
        amount: _amount,
        termMonths: _termMonths,
        interestRate: _interestRate,
        requestDate: DateTime.now(),
        status: 'Pending', 
      );

      try {
        // Llama al servicio para guardar el préstamo y generar cuotas
        await firestoreService.requestNewLoan(newLoan); 
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Solicitud de préstamo enviada con éxito.')),
          );
          Navigator.popAndPushNamed(context, AppRoutes.home); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al procesar la solicitud: $e')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar Nuevo Préstamo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Monto Solicitado
              const Text('Monto Solicitado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Slider(
                value: _amount,
                min: 500,
                max: 5000,
                divisions: 9,
                label: '\$${_amount.toStringAsFixed(0)}',
                onChanged: (double value) {
                  setState(() => _amount = value);
                },
              ),
              Center(child: Text('\$${_amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
              
              const SizedBox(height: 30),
              
              // Plazo en meses
              const Text('Plazo (Meses)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Slider(
                value: _termMonths.toDouble(),
                min: 6,
                max: 36,
                divisions: 10,
                label: '$_termMonths meses',
                onChanged: (double value) {
                  setState(() => _termMonths = value.round());
                },
              ),
              Center(child: Text('$_termMonths Meses', style: const TextStyle(fontSize: 20))),

              const SizedBox(height: 30),

              // Tasa de Interés Fija (informativa)
              ListTile(
                title: const Text('Tasa de Interés Anual (TNA)'),
                trailing: Text('${(_interestRate * 100).toStringAsFixed(1)}%'),
              ),

              const SizedBox(height: 40),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitLoanRequest,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Enviar Solicitud', style: TextStyle(fontSize: 18)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}