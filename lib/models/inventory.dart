import 'package:genshin_store_app/models/weapon.dart';

class Inventory {
  final int inventoryId;
  final int quantity;
  final Weapon weapon;

  Inventory({required this.inventoryId, required this.quantity, required this.weapon});

  factory Inventory.fromJson(Map<String, dynamic> json) => Inventory(
    inventoryId: json['inventory_id'],
    quantity: json['quantity'],
    weapon: Weapon.fromJson(json['Weapon']),
  );
}