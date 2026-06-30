import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../core/theme/app_colors.dart';

class MissionEnCoursScreen extends StatefulWidget {
  final int missionId;
  final String serviceType;
  final String adresse;
  final String clientNom;

  const MissionEnCoursScreen({
    super.key,
    required this.missionId,
    required this.serviceType,
    required this.adresse,
    required this.clientNom,
  });

  @override
  State<MissionEnCoursScreen> createState() => _MissionEnCoursScreenState();
}

class _MissionEnCoursScreenState extends State<MissionEnCoursScreen> {
  final ApiService _apiService = ApiService();
  String _statut = 'acceptee';
  bool _isLoading = false;

  Future<void> _demarrerMission() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.put(
          '/missions/${widget.missionId}/demarrer', {});

      if (response.statusCode == 200) {
        setState(() => _statut = 'en_cours');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mission démarrée !'),
              backgroundColor: AppColors.info,
            ),
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du démarrage'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _terminerMission() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.put(
          '/missions/${widget.missionId}/terminer', {});

      if (response.statusCode == 200) {
        setState(() => _statut = 'terminee_attente_validation');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mission terminée ! En attente de validation client.'),
              backgroundColor: Colors.orange,
            ),
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la terminaison'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  String get _statutLabel {
    switch (_statut) {
      case 'acceptee':
        return 'En route vers le client';
      case 'en_cours':
        return 'Mission en cours';
      case 'terminee_attente_validation':
        return 'En attente de validation';
      default:
        return _statut;
    }
  }

  Color get _statutColor {
    switch (_statut) {
      case 'acceptee':
        return AppColors.accent;
      case 'en_cours':
        return AppColors.info;
      case 'terminee_attente_validation':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTerminee = _statut == 'terminee_attente_validation';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Mission en cours',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
        automaticallyImplyLeading: isTerminee,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statut actuel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _statutColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _statutColor.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _statutColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _statutLabel,
                    style: TextStyle(
                      color: _statutColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Infos mission
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DÉTAILS DE LA MISSION',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.build_outlined, 'Service', widget.serviceType),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.location_on_outlined, 'Adresse', widget.adresse),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.person_outline, 'Client', widget.clientNom),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Étapes visuelles
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROGRESSION',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildEtape(1, 'Mission acceptée', true),
                  _buildEtape(2, 'En route vers le client',
                      _statut != 'acceptee'),
                  _buildEtape(3, 'Travail en cours',
                      _statut == 'en_cours' ||
                          _statut == 'terminee_attente_validation'),
                  _buildEtape(4, 'En attente de validation',
                      _statut == 'terminee_attente_validation'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            if (_statut == 'acceptee')
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _demarrerMission,
                  icon: const Icon(Icons.play_arrow, color: AppColors.textPrimary),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.textPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Je suis arrivé — Démarrer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            if (_statut == 'en_cours')
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _terminerMission,
                  icon: const Icon(Icons.check_circle, color: AppColors.textPrimary),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.textPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Travail terminé',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            if (isTerminee) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.hourglass_empty, color: AppColors.success, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'En attente de validation et paiement du client.',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/dashboard',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home_outlined,
                      color: AppColors.textSecondary),
                  label: const Text(
                    'Retour au dashboard',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEtape(int numero, String label, bool fait) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fait ? AppColors.success : AppColors.cardBorder,
            ),
            child: Center(
              child: fait
                  ? const Icon(Icons.check, color: AppColors.textPrimary, size: 16)
                  : Text(
                      '$numero',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: fait ? AppColors.textPrimary : AppColors.textMuted,
              fontSize: 14,
            ),
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