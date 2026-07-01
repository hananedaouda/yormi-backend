class MessageModel {
  final int id;
  final String contenu;
  final int expediteurId;
  final String expediteurRole;
  final String createdAt;

  MessageModel({
    required this.id,
    required this.contenu,
    required this.expediteurId,
    required this.expediteurRole,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      contenu: json['contenu'],
      expediteurId: json['expediteur_id'],
      expediteurRole: json['expediteur_role'],
      createdAt: json['created_at'],
    );
  }
}