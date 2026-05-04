import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api.dart';
import '../models/weapon.dart';

class WeaponService {
  Future<List<Weapon>> getWeapons(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.weapons),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      final List data = jsonDecode(response.body);
      return data.map((e) => Weapon.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Weapon> getWeaponById(String token, int id) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.weapons}/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return Weapon.fromJson(jsonDecode(response.body));
  }

  Future<Map<String, dynamic>> createWeapon({
    required String token,
    required String weaponName,
    required String weaponType,
    required String description,
    required int stock,
    required double price,
    File? imageFile,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(ApiConstants.weapons));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['weapon_name'] = weaponName;
      request.fields['weapon_type'] = weaponType;
      request.fields['description'] = description;
      request.fields['stock'] = stock.toString();
      request.fields['price'] = price.toString();

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      final response = await request.send().timeout(const Duration(seconds: 30));
      final body = await response.stream.bytesToString();
      return jsonDecode(body);
    } catch (e) {
      return {'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateWeapon({
    required String token,
    required int id,
    required String weaponName,
    required String weaponType,
    required String description,
    required int stock,
    required double price,
    File? imageFile,
  }) async {
    try {
      final request = http.MultipartRequest('PUT', Uri.parse('${ApiConstants.weapons}/$id'));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['weapon_name'] = weaponName;
      request.fields['weapon_type'] = weaponType;
      request.fields['description'] = description;
      request.fields['stock'] = stock.toString();
      request.fields['price'] = price.toString();

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      final response = await request.send().timeout(const Duration(seconds: 30));
      final body = await response.stream.bytesToString();
      return jsonDecode(body);
    } catch (e) {
      return {'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteWeapon(String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.weapons}/$id'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(response.body);
    } catch (e) {
      return {'message': e.toString()};
    }
  }
}