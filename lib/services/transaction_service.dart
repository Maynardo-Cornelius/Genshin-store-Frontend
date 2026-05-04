import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api.dart';

class TransactionService {
  Future<Map<String, dynamic>> buyWeapon(String token, List<Map<String, dynamic>> items) async {
    final response = await http.post(
      Uri.parse(ApiConstants.buy),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'items': items}),
    );
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getTransactionLogs(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.transactionLogs),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }
}