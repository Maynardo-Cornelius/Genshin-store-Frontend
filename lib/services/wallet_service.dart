import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api.dart';
import '../models/wallet.dart';

class WalletService {
  Future<Wallet> getWallet(String token) async {
    final response = await http.get(
      Uri.parse(ApiConstants.wallet),
      headers: {'Authorization': 'Bearer $token'},
    );
    return Wallet.fromJson(jsonDecode(response.body));
  }

  Future<Map<String, dynamic>> topUp(String token, double amount) async {
    final response = await http.post(
      Uri.parse(ApiConstants.topUp),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount}),
    );
    return jsonDecode(response.body);
  }
}