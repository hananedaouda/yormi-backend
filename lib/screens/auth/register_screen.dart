import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _metierController = TextEditingController();
  final _villeController = TextEditingController();

  DateTime? _dateNaissance;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  static const List<String> _metiers = [
    'Électricien',
    'Plombier',
    'Mécanicien',
    'Coiffeur / Coiffeuse',
    'Maçon',
    'Peintre',
    'Menuisier',
    'Soudeur',
    'Carreleur',
    'Technicien climatisation',
    'Femme de ménage',
    'Photographe',
    'Déménagement',
    'Informaticien',
  ];

  static const List<String> _villes = [
    'Abomey',
    'Abomey-Calavi',
    'Adjarra',
    'Adjohoun',
    'Adja-Ouèrè',
    'Agbangnizoun',
    'Aguégués',
    'Aplahoué',
    'Athiémé',
    'Avrankou',
    'Bantè',
    'Bassila',
    'Bohicon',
    'Bonou',
    'Bopa',
    'Borgou',
    'Cotonou',
    'Cobly',
    'Copargo',
    'Comè',
    'Dangbo',
    'Dassa-Zoumè',
    'Djidja',
    'Djougou',
    'Dodji-Bata',
    'Glazoué',
    'Grand-Popo',
    'Houéyogbé',
    'Ifangni',
    'Kalalé',
    'Kandi',
    'Kérou',
    'Ketou',
    'Kilibo',
    'Kouandé',
    'Kpomassè',
    'Lokossa',
    'Malanville',
    'Matéri',
    'Missérété',
    'Natitingou',
    'Nikki',
    'Ouidah',
    'Ouèssè',
    'Parakou',
    'Pehonko',
    'Péhunco',
    'Pobè',
    'Porto-Novo',
    'Sakété',
    'Savalou',
    'Savè',
    'Sèmè-Podji',
    'Sinendé',
    'So-Ava',
    'Tanguiéta',
    'Tchaourou',
    'Toffo',
    'Tori-Bossito',
    'Toviklin',
    'Zagnanado',
    'Zè',
    'Zogbodomey',
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _metierController.dispose();
    _villeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFF5A623),
              surface: Color(0xFF1A1F3C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateNaissance = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateNaissance == null) {
      setState(() =>
          _errorMessage = 'Veuillez sélectionner votre date de naissance');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.register(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        dateNaissance: _formatDate(_dateNaissance!),
        email: _emailController.text.trim(),
        telephone: _telephoneController.text.trim(),
        password: _passwordController.text,
        metier: _metierController.text.trim(),
        ville: _villeController.text.trim(),
      );

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/verification');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _autocompleteDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: const Color(0xFFF5A623)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.07),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF5A623), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F3C),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rejoignez YORMI en tant que prestataire',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 32),

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

                _buildField(
                  controller: _nomController,
                  label: 'Nom',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _prenomController,
                  label: 'Prénom',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),

                // Date de naissance
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cake_outlined,
                            color: Color(0xFFF5A623)),
                        const SizedBox(width: 12),
                        Text(
                          _dateNaissance == null
                              ? 'Date de naissance'
                              : _formatDate(_dateNaissance!),
                          style: TextStyle(
                            color: _dateNaissance == null
                                ? Colors.white54
                                : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.calendar_today,
                            color: Colors.white38, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildField(
                  controller: _emailController,
                  label: 'Adresse email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Champ requis';
                    if (!v.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _telephoneController,
                  label: 'Numéro de téléphone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),

                // Métier avec autocomplete
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) return _metiers;
                    return _metiers.where((m) => m
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String selection) {
                    _metierController.text = selection;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    controller.text = _metierController.text;
                    controller.addListener(() {
                      _metierController.text = controller.text;
                    });
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      style: const TextStyle(color: Colors.white),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Champ requis' : null,
                      decoration: _autocompleteDecoration(
                          'Métier / Spécialité', Icons.build_outlined),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: const Color(0xFF252B4B),
                        borderRadius: BorderRadius.circular(12),
                        elevation: 4,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                title: Text(
                                  option,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                onTap: () => onSelected(option),
                                hoverColor:
                                    const Color(0xFFF5A623).withOpacity(0.1),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Ville avec autocomplete
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) return _villes;
                    return _villes.where((v) => v
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String selection) {
                    _villeController.text = selection;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                    controller.text = _villeController.text;
                    controller.addListener(() {
                      _villeController.text = controller.text;
                    });
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      style: const TextStyle(color: Colors.white),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Champ requis' : null,
                      decoration: _autocompleteDecoration(
                          'Ville', Icons.location_city_outlined),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        color: const Color(0xFF252B4B),
                        borderRadius: BorderRadius.circular(12),
                        elevation: 4,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                title: Text(
                                  option,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                onTap: () => onSelected(option),
                                hoverColor:
                                    const Color(0xFFF5A623).withOpacity(0.1),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                _buildPasswordField(),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                            "S'inscrire",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                Center(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: RichText(
                      text: const TextSpan(
                        text: 'Vous avez déjà un compte ? ',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Connectez-vous',
                            style: TextStyle(
                              color: Color(0xFFF5A623),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: const Color(0xFFF5A623)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF5A623), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Champ requis';
        if (v.length < 8) return 'Minimum 8 caractères';
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFF5A623)),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.white38,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF5A623), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}