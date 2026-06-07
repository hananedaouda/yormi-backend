class MissionModel {
  final int id;
  final String statut;
  final String serviceType;
  final double montant;
  final String createdAt;
  final String? adresse;
  final String? description;

  MissionModel({
    required this.id,
    required this.statut,
    required this.serviceType,
    required this.montant,
    required this.createdAt,
    this.adresse,
    this.description,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'],
      statut: json['statut'],
      serviceType: json['service_type'],
      montant: (json['montant'] as num).toDouble(),
      createdAt: json['created_at'],
      adresse: json['adresse'],
      description: json['description'],
    );
  }
}
