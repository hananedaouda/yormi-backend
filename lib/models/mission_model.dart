import 'package:flutter/material.dart';

class MissionModel {
  final int id;
  final String statut;
  final String serviceType;
  final double? montant;
  final String createdAt;
  final String? adresse;
  final String? description;

  MissionModel({
    required this.id,
    required this.statut,
    required this.serviceType,
    this.montant,
    required this.createdAt,
    this.adresse,
    this.description,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] ?? 0,
      statut: json['statut'] ?? '',
      serviceType: json['service_type'] ?? '',
      montant: json['montant'] != null ? double.parse(json['montant'].toString()) : null,
      createdAt: json['created_at'] ?? '',
      adresse: json['adresse'],
      description: json['description'],
    );
  }

  String get statutLabel {
    switch (statut) {
      case 'en_recherche': return 'En recherche';
      case 'prestataire_notifie': return 'Notifié';
      case 'acceptee': return 'Acceptée';
      case 'en_cours': return 'En cours';
      case 'terminee_attente_validation': return 'En attente validation';
      case 'validee': return 'Validée';
      case 'annulee': return 'Annulée';
      case 'litige': return 'Litige';
      default: return statut;
    }
  }

  Color get statutColor {
    switch (statut) {
      case 'validee': return const Color(0xFF4CAF50);
      case 'en_cours': return const Color(0xFF2196F3);
      case 'acceptee': return const Color(0xFFF5A623);
      case 'annulee': return const Color(0xFFF44336);
      case 'litige': return const Color(0xFFFF5722);
      case 'prestataire_notifie': return const Color(0xFF9C27B0);
      default: return const Color(0xFF9E9E9E);
    }
  }
}