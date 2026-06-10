import '../models/dashboard_stats_model.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _apiService = ApiService();

  Future<DashboardStatsModel> getDashboardStats() async {
    final response = await _apiService.get('/prestataire/dashboard');
    return DashboardStatsModel.fromJson(response.data);
  }
}