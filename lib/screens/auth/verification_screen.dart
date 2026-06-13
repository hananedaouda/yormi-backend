import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/api_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _profilType;
  PlatformFile? _carteIdentite;
  PlatformFile? _diplome;
  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _profils = [
    {
      'value': 'patron',
      'label': 'Patron / Responsable d\'atelier',
      'icon': Icons.business_center_outlined,
      'description': 'Pièce d\'identité + Diplôme/Certificat requis',
    },
    {
      'value': 'ouvrier',
      'label': 'Ouvrier / Employé d\'atelier',
      'icon': Icons.engineering_outlined,
      'description': 'Pièce d\'identité requise',
    },
    {
      'value': 'apprenti',
      'label': 'Apprenti',
      'icon': Icons.school_outlined,
      'description': 'Pièce d\'identité requise',
    },
  ];

  Future<void> _pickFile(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        if (type == 'carte_identite') {
          _carteIdentite = result.files.first;
        } else {
          _diplome = result.files.first;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_profilType == null) {
      setState(() => _errorMessage = 'Veuillez sélectionner votre profil');
      return;
    }
    if (_carteIdentite == null) {
      setState(() => _errorMessage = 'Veuillez ajouter votre pièce d\'identité');
      return;
    }
    if (_profilType == 'patron' && _diplome == null) {
      setState(() => _errorMessage = 'Les patrons doivent fournir un diplôme ou certificat');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _storage.read(key: 'token');
      final dio = Dio();

      final formData = FormData.fromMap({
        'profil_type': _profilType,
        'carte_identite': MultipartFile.fromBytes(
          _carteIdentite!.bytes!,
          filename: _carteIdentite!.name,
        ),
        if (_profilType == 'patron' && _diplome != null)
          'diplome': MultipartFile.fromBytes(
            _diplome!.bytes!,
            filename: _diplome!.name,
          ),
      });

      await dio.post(
        '${ApiService.baseUrl}/prestataire/verification',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/attente');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Envoi impossible. Vérifiez votre connexion.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F3C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3C),
        elevation: 0,
        title: const Text(
          'Vérification du compte',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Votre profil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sélectionnez votre profil et fournissez vos documents pour activer votre compte.',
                style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Text(
                'TYPE DE PROFIL',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              ..._profils.map((profil) => _buildProfilCard(profil)),
              const SizedBox(height: 28),

              const Text(
                'DOCUMENTS',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              _buildUploadCard(
                label: 'Pièce d\'identité',
                subtitle: 'JPG, PNG ou PDF — max 5MB',
                icon: Icons.badge_outlined,
                file: _carteIdentite,
                onTap: () => _pickFile('carte_identite'),
                required: true,
              ),
              const SizedBox(height: 12),

              if (_profilType == 'patron') ...[
                _buildUploadCard(
                  label: 'Diplôme / Certificat professionnel',
                  subtitle: 'JPG, PNG ou PDF — max 5MB',
                  icon: Icons.workspace_premium_outlined,
                  file: _diplome,
                  onTap: () => _pickFile('diplome'),
                  required: true,
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFF5A623), size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Votre compte sera activé après vérification par l\'équipe YORMI.',
                        style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A623),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Envoyer mes documents',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilCard(Map<String, dynamic> profil) {
    final isSelected = _profilType == profil['value'];
    return GestureDetector(
      onTap: () => setState(() {
        _profilType = profil['value'];
        if (profil['value'] != 'patron') _diplome = null;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF5A623).withOpacity(0.1)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF5A623)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              profil['icon'] as IconData,
              color: isSelected ? const Color(0xFFF5A623) : Colors.white38,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profil['label'] as String,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFF5A623) : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    profil['description'] as String,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFFF5A623), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String label,
    required String subtitle,
    required IconData icon,
    required PlatformFile? file,
    required VoidCallback onTap,
    required bool required,
  }) {
    final hasFile = file != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasFile
              ? Colors.green.withOpacity(0.08)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile
                ? Colors.green.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasFile ? Icons.check_circle_outline : icon,
              color: hasFile ? Colors.green : const Color(0xFFF5A623),
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (required)
                        const Text(
                          ' *',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasFile ? file!.name : subtitle,
                    style: TextStyle(
                      color: hasFile ? Colors.green : Colors.white38,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              hasFile ? Icons.edit_outlined : Icons.upload_outlined,
              color: Colors.white38,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}