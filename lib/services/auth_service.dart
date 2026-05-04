import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api.dart';
import 'dart:async';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body);
    } on SocketException {
      return {'message': 'Tidak dapat terhubung ke server'};
    } on TimeoutException {
      return {'message': 'Koneksi timeout, coba lagi'};
    } catch (e) {
      return {'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'email': email, 'password': password, 'role': role}),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body);
    } on SocketException {
      return {'message': 'Tidak dapat terhubung ke server'};
    } on TimeoutException {
      return {'message': 'Koneksi timeout, coba lagi'};
    } catch (e) {
      return {'message': 'Error: ${e.toString()}'};
    }
  }

  Future<void> saveToken(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
  }
}