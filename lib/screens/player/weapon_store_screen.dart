import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/weapon.dart';
import '../../providers/auth_provider.dart';
import '../../services/weapon_service.dart';
import 'weapon_detail_screen.dart';

class WeaponStoreScreen extends StatefulWidget {
  const WeaponStoreScreen({super.key});

  @override
  State<WeaponStoreScreen> createState() => _WeaponStoreScreenState();
}

class _WeaponStoreScreenState extends State<WeaponStoreScreen> {
  final WeaponService _weaponService = WeaponService();
  List<Weapon> _weapons = [];
  List<Weapon> _filtered = [];
  bool _isLoading = true;
  String _selectedType = 'all';

  final List<Map<String, String>> _types = [
    {'value': 'all', 'label': 'All'},
    {'value': 'sword', 'label': 'Sword'},
    {'value': 'claymore', 'label': 'Claymore'},
    {'value': 'polearm', 'label': 'Polearm'},
    {'value': 'bow', 'label': 'Bow'},
    {'value': 'catalyst', 'label': 'Catalyst'},
  ];

  @override
  void initState() {
    super.initState();
    _loadWeapons();
  }

  Future<void> _loadWeapons() async {
    final token = context.read<AuthProvider>().token!;
    final weapons = await _weaponService.getWeapons(token);
    setState(() {
      _weapons = weapons;
      _filtered = weapons;
      _isLoading = false;
    });
  }

  void _filterByType(String type) {
    setState(() {
      _selectedType = type;
      _filtered = type == 'all'
          ? _weapons
          : _weapons.where((w) => w.weaponType == type).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('Weapon Store', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _types.length,
              itemBuilder: (context, index) {
                final type = _types[index];
                final isSelected = _selectedType == type['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(type['label']!),
                    selected: isSelected,
                    onSelected: (_) => _filterByType(type['value']!),
                    backgroundColor: const Color(0xFF1B2A4A),
                    selectedColor: const Color(0xFFFFD700),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    checkmarkColor: Colors.black,
                  ),
                );
              },
            ),
          ),

          // Weapon grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
                : _filtered.isEmpty
                    ? const Center(child: Text('Tidak ada weapon', style: TextStyle(color: Colors.white54)))
                    : RefreshIndicator(
                        onRefresh: _loadWeapons,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final weapon = _filtered[index];
                            return _WeaponCard(weapon: weapon);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _WeaponCard extends StatelessWidget {
  final Weapon weapon;
  const _WeaponCard({required this.weapon});

  Color _typeColor(String type) {
    switch (type) {
      case 'sword': return Colors.blue;
      case 'claymore': return Colors.red;
      case 'polearm': return Colors.orange;
      case 'bow': return Colors.green;
      case 'catalyst': return Colors.purple;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WeaponDetailScreen(weapon: weapon)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B2A4A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: weapon.image != null
                    ? CachedNetworkImage(
                        imageUrl: 'http://10.0.2.2:3000/uploads/${weapon.image}',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                        ),
                        errorWidget: (_, __, ___) => const Icon(Icons.shield, size: 60, color: Colors.white24),
                      )
                    : const Center(child: Icon(Icons.shield, size: 60, color: Colors.white24)),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weapon.weaponName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _typeColor(weapon.weaponType).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      weapon.weaponType.toUpperCase(),
                      style: TextStyle(color: _typeColor(weapon.weaponType), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${weapon.price.toStringAsFixed(0)}',
                    style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    'Stock: ${weapon.stock}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}