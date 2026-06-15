import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  UserModel? _user;
  bool _isLoading = false;
  bool _isCheckingAuth = true;
  String? _errorMessage;
  String? _statutVerification;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  String? get errorMessage => _errorMessage;
  String? get statutVerification => _statutVerification;
  bool get isAuthenticated => _user != null;

  Future<void> checkAuthStatus() async {
    _isCheckingAuth = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'token');

      if (token == null) {
        _user = null;
        _statutVerification = null;
        _isCheckingAuth = false;
        notifyListeners();
        return;
      }

      // On essaie d'appeler le dashboard
      try {
        final response = await _apiService.get('/prestataire/dashboard');
        if (response.statusCode == 200) {
          _user = UserModel(
            id: 0,
            nom: 'Prestataire',
            role: 'prestataire',
          );
          _statutVerification = 'verifie';
          await _storage.write(key: 'statut_verification', value: 'verifie');
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 403) {
          // Le token est valide mais le compte n'est pas validé
          // On lit le statut stocké localement
          final statutLocal = await _storage.read(key: 'statut_verification');
          _user = UserModel(
            id: 0,
            nom: 'Prestataire',
            role: 'prestataire',
          );
          _statutVerification = statutLocal ?? 'en_attente';
        } else {
          // Vraie erreur réseau ou autre
          await _storage.delete(key: 'token');
          await _storage.delete(key: 'statut_verification');
          _user = null;
          _statutVerification = null;
        }
      }
    } catch (e) {
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'statut_verification');
      _user = null;
      _statutVerification = null;
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

      final statutFromBackend = data['user']['statut_verification'];
      if (statutFromBackend != null) {
        await _storage.write(key: 'statut_verification', value: statutFromBackend);
        _statutVerification = statutFromBackend;
      } else {
        _statutVerification = await _storage.read(key: 'statut_verification') ?? 'en_attente';
      }

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
    await _storage.delete(key: 'statut_verification');
    _user = null;
    _statutVerification = null;
    notifyListeners();
  }

  Future<void> register({
    required String nom,
    required String prenom,
    required String dateNaissance,
    required String email,
    required String telephone,
    required String password,
    required String metier,
    required String ville,
  }) async {
    try {
      final response = await _apiService.post('/auth/register/prestataire', {
        'nom': nom,
        'prenom': prenom,
        'date_naissance': dateNaissance,
        'email': email,
        'telephone': telephone,
        'password': password,
        'metier': metier,
        'ville': ville,
      });

      final data = response.data;
      await _storage.write(key: 'token', value: data['token']);
      await _storage.write(
          key: 'statut_verification',
          value: data['user']['statut_verification'] ?? 'en_attente');
      _statutVerification = data['user']['statut_verification'] ?? 'en_attente';
    } catch (e) {
      throw Exception('Inscription impossible. Vérifiez vos informations.');
    }
  }
}