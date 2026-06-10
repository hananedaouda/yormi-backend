import 'api_service.dart';

class DisponibiliteService {
  final ApiService _apiService = ApiService();

  Future<bool> activerDisponibilite(double latitude, double longitude) async {
    final response = await _apiService.put('/prestataire/disponibilite', {
      'disponible': true,
      'latitude': latitude,
      'longitude': longitude,
    });
    return response.data['disponible'] == true;
  }

  Future<bool> desactiverDisponibilite() async {
    final response = await _apiService.put('/prestataire/disponibilite', {
      'disponible': false,
      'latitude': 0.0,
      'longitude': 0.0,
    });
    return response.data['disponible'] == false;
  }
}