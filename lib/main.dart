import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/verification_screen.dart';
import 'screens/auth/attente_screen.dart';
import 'screens/auth/refus_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/historique/historique_screen.dart';
import 'screens/mission/mission_reception_screen.dart';
import 'screens/mission/mission_en_cours_screen.dart';
import 'screens/chat/chat_screen.dart';

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
            seedColor: AppColors.accent,
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
          '/missions': (context) => const MissionReceptionScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/mission-en-cours') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => MissionEnCoursScreen(
                missionId: args['missionId'],
                serviceType: args['serviceType'],
                adresse: args['adresse'],
                clientNom: args['clientNom'],
              ),
            );
          }

          if (settings.name == '/chat') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ChatScreen(
                missionId: args['missionId'],
                clientNom: args['clientNom'],
              ),
            );
          }

          return null;
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
      () =>
          Provider.of<AuthProvider>(context, listen: false).checkAuthStatus(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isCheckingAuth) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }

        switch (auth.statutVerification) {
          case 'verifie':
            return const DashboardScreen();
          case 'refuse':
          case 'rejete':
            return const RefusScreen();
          case 'en_attente':
          default:
            return const AttenteScreen();
        }
      },
    );
  }
}