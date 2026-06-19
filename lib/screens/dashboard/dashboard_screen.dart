import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/dashboard_stats_model.dart';
import '../../services/dashboard_service.dart';
import '../../services/disponibilite_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  final DisponibiliteService _disponibiliteService = DisponibiliteService();
  DashboardStatsModel? _stats;
  bool _isLoading = true;
  bool _isDisponible = false;
  bool _isTogglingDisponibilite = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final stats = await _dashboardService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleDisponibilite() async {
    setState(() => _isTogglingDisponibilite = true);

    try {
      if (_isDisponible) {
        await _disponibiliteService.desactiverDisponibilite();
        setState(() => _isDisponible = false);
      } else {
        await _disponibiliteService.activerDisponibilite(6.3654, 2.4183);
        setState(() => _isDisponible = true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors du changement de disponibilité')),
      );
    }

    setState(() => _isTogglingDisponibilite = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final nomComplet = auth.user?.nomComplet ?? 'Prestataire';

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
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/historique'),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final auth =
                  Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF5A623)),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDashboard,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header avec nom du prestataire
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5A623).withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFF5A623),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFFF5A623),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bonjour 👋',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  nomComplet,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Stats
                        _buildStatCard('Missions totales',
                            '${_stats!.missionsTotal}', Icons.check_circle),
                        const SizedBox(height: 16),
                        _buildStatCard('Missions ce mois',
                            '${_stats!.missionsCeMois}', Icons.calendar_month),
                        const SizedBox(height: 16),
                        _buildStatCard('Revenus ce mois',
                            '${_stats!.revenuesCeMois} FCFA', Icons.attach_money),
                        const SizedBox(height: 16),
                        _buildStatCard(
                            'Solde disponible',
                            '${_stats!.soldeDisponible} FCFA',
                            Icons.account_balance_wallet),
                        const SizedBox(height: 16),
                        _buildStatCard('Note moyenne',
                            '${_stats!.noteMoyenne} ⭐', Icons.star),
                        const SizedBox(height: 16),
                        _buildStatCard('Nombre d\'avis',
                            '${_stats!.nbAvis}', Icons.reviews),
                        const SizedBox(height: 32),

                        // Bouton missions
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/missions'),
                            icon: const Icon(Icons.notifications_active, color: Colors.white),
                            label: const Text(
                              'Recevoir des missions',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF5A623),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Toggle disponibilité
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isDisponible
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  _isDisponible ? Colors.green : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isDisponible
                                        ? 'Disponible'
                                        : 'Indisponible',
                                    style: TextStyle(
                                      color: _isDisponible
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _isDisponible
                                        ? 'Vous recevez des missions'
                                        : 'Vous ne recevez pas de missions',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12),
                                  ),
                                ],
                              ),
                              _isTogglingDisponibilite
                                  ? const CircularProgressIndicator(
                                      color: Color(0xFFF5A623))
                                  : Switch(
                                      value: _isDisponible,
                                      onChanged: (_) =>
                                          _toggleDisponibilite(),
                                      activeColor: const Color(0xFFF5A623),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF5A623), size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}