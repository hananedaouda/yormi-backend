import 'package:flutter/material.dart';
import '../../models/mission_model.dart';
import '../../services/mission_service.dart';

class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  final MissionService _missionService = MissionService();
  List<MissionModel> _missions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    try {
      final missions = await _missionService.getMissions();
      setState(() {
        _missions = missions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F3C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3C),
        title: const Text(
          'Historique',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMissions,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _missions.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucune mission pour le moment',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadMissions,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _missions.length,
                        itemBuilder: (context, index) {
                          final mission = _missions[index];
                          return _buildMissionCard(mission);
                        },
                      ),
                    ),
    );
  }

  Widget _buildMissionCard(MissionModel mission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: mission.statutColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.serviceType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${mission.montant != null ? mission.montant!.toStringAsFixed(0) : "—"} FCFA',
                  style: const TextStyle(
                    color: Color(0xFFF5A623),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mission.createdAt.substring(0, 10),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: mission.statutColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: mission.statutColor),
            ),
            child: Text(
              mission.statutLabel,
              style: TextStyle(
                color: mission.statutColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}