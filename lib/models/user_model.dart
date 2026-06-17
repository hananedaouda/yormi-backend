class UserModel {
  final int id;
  final String nom;
  final String? prenom;
  final String role;
  final String? avatar;
  final String? statutVerification;

  UserModel({
    required this.id,
    required this.nom,
    this.prenom,
    required this.role,
    this.avatar,
    this.statutVerification,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'],
      role: json['role'] ?? '',
      avatar: json['avatar'],
      statutVerification: json['statut_verification'],
    );
  }

  String get nomComplet {
    if (prenom != null && prenom!.isNotEmpty) {
      return '$prenom $nom';
    }
    return nom;
  }
}