class ApiConstants {
  // Untuk emulator Android
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // Auth
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String googleAuth = '$baseUrl/auth/google';
  static const String googleSignIn = '$baseUrl/auth/google/signin';
  // Weapons
  static const String weapons = '$baseUrl/weapons';

  // Wallet
  static const String wallet = '$baseUrl/wallet';
  static const String topUp = '$baseUrl/wallet/topup';

  // Inventory
  static const String inventory = '$baseUrl/inventory';

  // Transactions
  static const String buy = '$baseUrl/transactions/buy';
  static const String transactionLogs = '$baseUrl/transactions/logs';
}