import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _role;
  final AuthService _authService = AuthService();

  String? get token => _token;
  String? get role => _role;
  bool get isLoggedIn => _token != null;
  bool get isAdmin => _role == 'admin';
  bool get isPlayer => _role == 'player';

  Future<void> loadSession() async {
    _token = await _authService.getToken();
    _role = await _authService.getRole();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final result = await _authService.login(email, password);
      if (result['token'] != null) {
        _token = result['token'];
        _role = result['role'];
        await _authService.saveToken(_token!, _role!);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    _role = null;
    notifyListeners();
  }
}
