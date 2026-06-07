class UserModel {
  final int id;
  final String nom;
  final String role;
  final String? avatar;
  final String? statutVerification;

  UserModel({
    required this.id,
    required this.nom,
    required this.role,
    this.avatar,
    this.statutVerification,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nom: json['nom'],
      role: json['role'],
      avatar: json['avatar'],
      statutVerification: json['statut_verification'],
    );
  }
}
