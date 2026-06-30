import 'package:flutter/material.dart';
import '../../services/reverb_service.dart';
import '../../services/api_service.dart';
import '../../core/theme/app_colors.dart';

class MissionReceptionScreen extends StatefulWidget {
  const MissionReceptionScreen({super.key});

  @override
  State<MissionReceptionScreen> createState() => _MissionReceptionScreenState();
}

class _MissionReceptionScreenState extends State<MissionReceptionScreen> {
  final ReverbService _reverbService = ReverbService();
  final ApiService _apiService = ApiService();
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

  int _secondesRestantes = 300;
  bool _timerActif = false;

  void _demarrerTimer() {
    _secondesRestantes = 300;
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
      if (_missionEnAttente != null) {
        try {
          final missionId = _missionEnAttente!['id'];
          await _apiService.post('/missions/$missionId/refuser', {
            'raison': 'Délai expiré',
          });
        } catch (e) {
          // On continue même si erreur
        }
      }
      if (mounted) {
        setState(() {
          _missionEnAttente = null;
          _timerActif = false;
        });
      }
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

  Future<void> _accepterMission() async {
    setState(() => _isAccepting = true);
    _timerActif = false;

    try {
      final missionId = _missionEnAttente!['id'];
      final response =
          await _apiService.post('/missions/$missionId/accepter', {});

      if (response.statusCode == 200) {
        if (mounted) {
          final data = response.data;
          Navigator.pushReplacementNamed(
            context,
            '/mission-en-cours',
            arguments: {
              'missionId': _missionEnAttente!['id'],
              'serviceType': _missionEnAttente!['service_type'] ?? '-',
              'adresse': data['mission']?['adresse'] ??
                  _missionEnAttente!['adresse'] ??
                  '-',
              'clientNom': data['client']?['nom'] ?? 'Client',
            },
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur serveur (${response.statusCode})'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        _timerActif = true;
        _tickTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'acceptation'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      _timerActif = true;
      _tickTimer();
    }

    if (mounted) setState(() => _isAccepting = false);
  }

  Future<void> _declinerMission() async {
    _timerActif = false;

    try {
      final missionId = _missionEnAttente!['id'];
      await _apiService.post('/missions/$missionId/refuser', {
        'raison': 'Prestataire indisponible',
      });
    } catch (e) {
      // On continue même si erreur
    }

    if (mounted) {
      setState(() => _missionEnAttente = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Missions',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
            ),
            const SizedBox(width: 10),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _reverbService.isConnected
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isConnecting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.accent),
                  SizedBox(height: 16),
                  Text(
                    'Connexion au serveur...',
                    style: TextStyle(color: AppColors.textSecondary),
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
                          color: AppColors.accent.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search,
                          color: AppColors.accent,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'En attente de missions...',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Vous serez notifié dès qu\'une demande arrive.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : _buildMissionCard(),
    );
  }

  Widget _buildMissionCard() {
    final mission = _missionEnAttente!;
    final double pourcentage = _secondesRestantes / 300;
    final Color timerColor = _secondesRestantes > 60
        ? AppColors.success
        : _secondesRestantes > 30
            ? Colors.orange
            : AppColors.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
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
                  backgroundColor: AppColors.cardBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🔔 Nouvelle demande !',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                    Icons.build_outlined, 'Service', mission['service_type'] ?? '-'),
                const SizedBox(height: 12),
                _buildInfoRow(
                    Icons.location_on_outlined, 'Adresse', mission['adresse'] ?? '-'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.description_outlined, 'Description',
                    mission['description'] ?? '-'),
                if (mission['montant'] != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.attach_money, 'Montant',
                      '${mission['montant']} FCFA'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isAccepting ? null : _declinerMission,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.cardBorder),
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
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.textPrimary,
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
                            color: AppColors.textPrimary,
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accent, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}