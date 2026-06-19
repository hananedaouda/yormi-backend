import 'package:flutter/material.dart';
import '../../services/reverb_service.dart';

class MissionReceptionScreen extends StatefulWidget {
  const MissionReceptionScreen({super.key});

  @override
  State<MissionReceptionScreen> createState() => _MissionReceptionScreenState();
}

class _MissionReceptionScreenState extends State<MissionReceptionScreen> {
  final ReverbService _reverbService = ReverbService();
  Map<String, dynamic>? _missionEnAttente;
  bool _isConnecting = true;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _connecterReverb();
  }

  Future<void> _connecterReverb() async {
    await _reverbService.connect(
      onMissionReceived: (mission) {
        if (mounted) {
          setState(() {
            _missionEnAttente = mission;
          });
          _demarrerTimer();
        }
      },
    );
    if (mounted) {
      setState(() => _isConnecting = false);
    }
  }

  int _secondesRestantes = 180;
  bool _timerActif = false;

  void _demarrerTimer() {
    _secondesRestantes = 180;
    _timerActif = true;
    _tickTimer();
  }

  void _tickTimer() async {
    while (_timerActif && _secondesRestantes > 0 && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _secondesRestantes--);
      }
    }
    if (_secondesRestantes == 0 && mounted) {
      setState(() {
        _missionEnAttente = null;
        _timerActif = false;
      });
    }
  }

  @override
  void dispose() {
    _timerActif = false;
    _reverbService.disconnect();
    super.dispose();
  }

  String _formatTimer(int secondes) {
    final min = (secondes ~/ 60).toString().padLeft(2, '0');
    final sec = (secondes % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F3C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3C),
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Missions',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(width: 10),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _reverbService.isConnected ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isConnecting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFF5A623)),
                  SizedBox(height: 16),
                  Text(
                    'Connexion au serveur...',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
          : _missionEnAttente == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5A623).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Color(0xFFF5A623),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'En attente de missions...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Vous serez notifié dès qu\'une demande arrive.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : _buildMissionCard(),
    );
  }

  Widget _buildMissionCard() {
    final mission = _missionEnAttente!;
    final double pourcentage = _secondesRestantes / 180;
    final Color timerColor = _secondesRestantes > 60
        ? Colors.green
        : _secondesRestantes > 30
            ? Colors.orange
            : Colors.red;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Timer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: timerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: timerColor.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                Text(
                  'Expire dans',
                  style: TextStyle(color: timerColor, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTimer(_secondesRestantes),
                  style: TextStyle(
                    color: timerColor,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: pourcentage,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Carte mission
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5A623).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '🔔 Nouvelle demande !',
                        style: TextStyle(
                          color: Color(0xFFF5A623),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.build_outlined,
                    'Service', mission['service_type'] ?? '-'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.location_on_outlined,
                    'Adresse', mission['adresse'] ?? '-'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.description_outlined,
                    'Description', mission['description'] ?? '-'),
                if (mission['montant'] != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.attach_money,
                      'Montant', '${mission['montant']} FCFA'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Boutons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isAccepting
                      ? null
                      : () {
                          setState(() {
                            _missionEnAttente = null;
                            _timerActif = false;
                          });
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white54,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Décliner',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isAccepting ? null : _accepterMission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isAccepting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Accepter',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _accepterMission() async {
    setState(() => _isAccepting = true);
    _timerActif = false;

    try {
      // TODO: appeler POST /missions/{id}/accepter
      final missionId = _missionEnAttente!['id'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mission #$missionId acceptée !'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _missionEnAttente = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de l\'acceptation'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isAccepting = false);
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFF5A623), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}