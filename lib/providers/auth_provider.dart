import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UserModel? _user;
  bool _isLoading = false;
  bool _isCheckingAuth = true;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> checkAuthStatus() async {
    _isCheckingAuth = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'token');
      if (token != null) {
        final response = await _apiService.get('/prestataire/dashboard');
        if (response.statusCode == 200) {
          _user = UserModel(
            id: 0,
            nom: 'Prestataire',
            role: 'prestataire',
          );
        }
      }
    } catch (e) {
      await _storage.delete(key: 'token');
      _user = null;
    }

    _isCheckingAuth = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final data = response.data;
      await _storage.write(key: 'token', value: data['token']);
      _user = UserModel.fromJson(data['user']);
      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Email ou mot de passe incorrect';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout', {});
    } catch (e) {
      // on continue même si erreur
    }
    await _storage.delete(key: 'token');
    _user = null;
    notifyListeners();
  }
}