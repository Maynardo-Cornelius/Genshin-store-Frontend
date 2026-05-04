import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api.dart';
import '../models/inventory.dart';

class InventoryService {
  Future<List<Inventory>> getInventory(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.inventory),
      headers: {'Authorization': 'Bearer $token'},
    );
    final List data = jsonDecode(response.body);
    return data.map((e) => Inventory.fromJson(e)).toList();
  }
}