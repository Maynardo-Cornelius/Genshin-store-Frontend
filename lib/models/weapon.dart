class Weapon {
  final int weaponId;
  final String weaponName;
  final String weaponType;
  final String description;
  final int stock;
  final String? image;
  final double price;

  Weapon({
    required this.weaponId,
    required this.weaponName,
    required this.weaponType,
    required this.description,
    required this.stock,
    this.image,
    required this.price,
  });

  factory Weapon.fromJson(Map<String, dynamic> json) => Weapon(
    weaponId: json['weapon_id'],
    weaponName: json['weapon_name'],
    weaponType: json['weapon_type'],
    description: json['description'] ?? '',
    stock: json['stock'],
    image: json['image'],
    price: double.parse(json['price'].toString()),
  );
}