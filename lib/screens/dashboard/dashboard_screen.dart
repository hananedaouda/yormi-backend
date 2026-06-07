import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F3C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3C),
        title: const Text(
          'YORMI',
          style: TextStyle(
            color: Color(0xFFF5A623),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Dashboard — Coming Soon 🔥',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}