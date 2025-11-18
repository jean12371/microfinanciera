import 'package:flutter/material.dart';

// ----------------- Importaciones de Pantallas -----------------
import '../ui/screens/home_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/register_screen.dart';

// Préstamos
import '../ui/screens/loans/loan_request_screen.dart';
import '../ui/screens/loans/loan_detail_screen.dart';

// Cuotas
import '../ui/screens/quotas/quota_list_screen.dart';

// Pagos (Solo una importación por archivo, SIN ALIAS)
import '../ui/screens/payments/payment_screen.dart';
import '../ui/screens/payments/payment_history_screen.dart';


// ----------------- Modelos -----------------
import '../models/loan_model.dart';
import '../models/quota_model.dart';

class AppRoutes {
  static const String initialRoute = login;

  // ---------- Nombres de rutas ----------
  static const String login = 'login';
  static const String register = 'register';
  static const String home = 'home';

  static const String loanRequest = 'loanRequest';
  static const String loanDetail = 'loanDetail';

  static const String quotasList = 'quotasList';

  static const String payment = 'payment';
  static const String paymentHistory = 'paymentHistory';

  // ---------- Rutas sin argumentos ----------
  static Map<String, Widget Function(BuildContext)> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    loanRequest: (context) => const LoanRequestScreen(),
  };

  // ---------- Rutas con argumentos ----------
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {

      case loanDetail:
        final loan = settings.arguments as LoanModel;
        return MaterialPageRoute(
          builder: (_) => LoanDetailScreen(loan: loan),
        );

      case quotasList:
        final loanId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => QuotaListScreen(loanId: loanId),
        );

      case payment:
        final quota = settings.arguments as QuotaModel;
        return MaterialPageRoute(
          // Sin alias, usando el nombre directo de la clase PaymentScreen
          builder: (_) => PaymentScreen(quota: quota), 
        );

      case paymentHistory:
        final loanId = settings.arguments as String;
        return MaterialPageRoute(
          // Sin alias, usando el nombre directo de la clase PaymentHistoryScreen
          builder: (_) => PaymentHistoryScreen(loanId: loanId), 
        );

      // -------- RUTA POR DEFECTO ---------
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
    }
  }
}