// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _api     = ApiService();

  bool    _isLoggedIn = false;
  bool    _isLoading  = false;
  String? _error;
  String? _userName;

  bool    get isLoggedIn => _isLoggedIn;
  bool    get isLoading  => _isLoading;
  String? get error      => _error;
  String? get userName   => _userName;

  Future<void> checkLoginStatus() async {
    final token = await _storage.read(key: 'auth_token');
    _isLoggedIn = token != null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final res = await _api.post('/auth/login', {'email': email, 'password': password});
      if (res['token'] != null) {
        await _storage.write(key: 'auth_token', value: res['token']);
        _isLoggedIn = true; _userName = res['user']?['name'];
        _isLoading = false; notifyListeners(); return true;
      }
      _error = res['message'] ?? 'Login Failed';
      _isLoading = false; notifyListeners(); return false;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('401') || msg.contains('unauthorized')) {
        _error = 'Invalid Email or Password.';
      } else if (msg.contains('Timeout') || msg.contains('Socket')) {
        _error = 'Failed to connect to the server. Please check your WiFi connection.';
      } else {
        _error = 'Login Failed. Please try again.';
      }
      _isLoading = false; notifyListeners(); return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final res = await _api.post('/auth/register', {
        'name': name, 'email': email,
        'password': password, 'password_confirmation': password,
      });
      if (res['token'] != null) {
        await _storage.write(key: 'auth_token', value: res['token']);
        _isLoggedIn = true; _userName = res['user']?['name'];
        _isLoading = false; notifyListeners(); return true;
      }
      _error = res['message'] ?? 'Registration Failed';
      _isLoading = false; notifyListeners(); return false;
    } catch (e) {
      _error = 'Registration Failed. Please try again.';
      _isLoading = false; notifyListeners(); return false;
    }
  }

  Future<void> logout() async {
    try { await _api.post('/auth/logout', {}); } catch (_) {}
    await _storage.delete(key: 'auth_token');
    _isLoggedIn = false; _userName = null; notifyListeners();
  }
}



