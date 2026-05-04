class Wallet {
  final int walletId;
  final int userId;
  final double balance;

  Wallet({required this.walletId, required this.userId, required this.balance});

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    walletId: json['wallet_id'],
    userId: json['user_id'],
    balance: double.parse(json['balance'].toString()),
  );
}