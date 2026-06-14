import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/verification_screen.dart';
import 'screens/auth/attente_screen.dart';
import 'screens/auth/refus_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/historique/historique_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'YORMI Prestataire',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFF5A623),
          ),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/verification': (context) => const VerificationScreen(),
          '/attente': (context) => const AttenteScreen(),
          '/refus': (context) => const RefusScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/historique': (context) => const HistoriqueScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<AuthProvider>(context, listen: false).checkAuthStatus(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        // Chargement en cours
        if (auth.isCheckingAuth) {
          return const Scaffold(
            backgroundColor: Color(0xFF1A1F3C),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF5A623),
              ),
            ),
          );
        }

        // Pas connecté
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }

        // Connecté — on redirige selon le statut
        switch (auth.statutVerification) {
          case 'verifie':
            return const DashboardScreen();
          case 'refuse':
            return const RefusScreen();
          case 'en_attente':
          default:
            return const AttenteScreen();
        }
      },
    );
  }
}