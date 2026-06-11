import '../models/mission_model.dart';
import 'api_service.dart';

class MissionService {
  final ApiService _apiService = ApiService();

  Future<List<MissionModel>> getMissions() async {
    final response = await _apiService.get('/missions');
    final List<dynamic> data = response.data['missions'] ?? response.data;
    return data.map((json) => MissionModel.fromJson(json)).toList();
  }
}