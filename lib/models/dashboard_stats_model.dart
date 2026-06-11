class DashboardStatsModel {
  final int missionsTotal;
  final int missionsCeMois;
  final double revenuesCeMois;
  final double soldeDisponible;
  final double noteMoyenne;
  final int nbAvis;

  DashboardStatsModel({
    required this.missionsTotal,
    required this.missionsCeMois,
    required this.revenuesCeMois,
    required this.soldeDisponible,
    required this.noteMoyenne,
    required this.nbAvis,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      missionsTotal: json['missions_total'] ?? 0,
      missionsCeMois: json['missions_ce_mois'] ?? 0,
      revenuesCeMois: double.parse(json['revenus_ce_mois'].toString()),
      soldeDisponible: double.parse(json['solde_disponible'].toString()),
      noteMoyenne: double.parse(json['note_moyenne'].toString()),
      nbAvis: json['nb_avis'] ?? 0,
    );
  }
}