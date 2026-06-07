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
      missionsTotal: json['missions_total'],
      missionsCeMois: json['missions_ce_mois'],
      revenuesCeMois: (json['revenus_ce_mois'] as num).toDouble(),
      soldeDisponible: (json['solde_disponible'] as num).toDouble(),
      noteMoyenne: (json['note_moyenne'] as num).toDouble(),
      nbAvis: json['nb_avis'],
    );
  }
}
