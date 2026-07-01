import 'api_service.dart';
import '../models/message_model.dart';

class ChatService {
  final ApiService _apiService = ApiService();

  Future<List<MessageModel>> getMessages(int missionId) async {
    final response = await _apiService.get('/missions/$missionId/messages');
    final List<dynamic> data = response.data['messages'];
    return data.map((json) => MessageModel.fromJson(json)).toList();
  }

  Future<void> envoyerMessage(int missionId, String contenu) async {
    await _apiService.post('/missions/$missionId/messages', {
      'contenu': contenu,
    });
  }
}