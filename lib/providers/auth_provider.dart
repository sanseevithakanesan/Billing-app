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
      _error = res['message'] ?? 'Login தோல்வியடைந்தது';
      _isLoading = false; notifyListeners(); return false;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('401') || msg.contains('unauthorized')) {
        _error = 'Email அல்லது Password தவறு!';
      } else if (msg.contains('Timeout') || msg.contains('Socket')) {
        _error = 'Server connect ஆகவில்லை. WiFi check செய்யுங்கள்.';
      } else {
        _error = 'Login தோல்வியடைந்தது. மீண்டும் try செய்யுங்கள்.';
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
      _error = res['message'] ?? 'Registration தோல்வியடைந்தது';
      _isLoading = false; notifyListeners(); return false;
    } catch (e) {
      _error = 'Registration தோல்வியடைந்தது.';
      _isLoading = false; notifyListeners(); return false;
    }
  }

  Future<void> logout() async {
    try { await _api.post('/auth/logout', {}); } catch (_) {}
    await _storage.delete(key: 'auth_token');
    _isLoggedIn = false; _userName = null; notifyListeners();
  }
}



