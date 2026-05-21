import 'package:flutter/material.dart';
import 'package:genshin_store_app/widgets/background_wrapper.dart';
import 'package:genshin_store_app/widgets/weapon_image.dart';
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
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false, 
          backgroundColor: const Color(0xFF0D1B2A).withOpacity(0.8),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Weapon Store',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              onPressed: () => context.read<AuthProvider>().logout(),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _types.length,
                itemBuilder: (context, index) {
                  final type = _types[index];
                  final isSelected = _selectedType == type['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () => _filterByType(type['value']!),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFD700) : const Color(0xFF1B2A4A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : const Color(0xFFFFD700).withOpacity(0.3),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Text(
                          type['label']!,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                    )
                  : _filtered.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          color: const Color(0xFFFFD700),
                          backgroundColor: const Color(0xFF1B2A4A),
                          onRefresh: _loadWeapons,
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.68,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text(
            'Senjata tidak ditemukan',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _WeaponCard extends StatelessWidget {
  final Weapon weapon;
  const _WeaponCard({required this.weapon});

  String _formatRupiah(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'sword': return Colors.blueAccent;
      case 'claymore': return Colors.redAccent;
      case 'polearm': return Colors.orangeAccent;
      case 'bow': return Colors.greenAccent;
      case 'catalyst': return Colors.purpleAccent;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = weapon.stock == 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WeaponDetailScreen(weapon: weapon)),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1B2A4A).withOpacity(0.9),
              const Color(0xFF0D1B2A).withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'weapon-${weapon.weaponId}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: WeaponImage(
                          image: weapon.image,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    
                    if (isOutOfStock)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        ),
                        child: const Center(
                          child: Text(
                            'HABIS',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weapon.weaponName,
                          style: TextStyle(
                            color: isOutOfStock ? Colors.white54 : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _typeColor(weapon.weaponType).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: _typeColor(weapon.weaponType).withOpacity(0.5)),
                          ),
                          child: Text(
                            weapon.weaponType.toUpperCase(),
                            style: TextStyle(
                              color: _typeColor(weapon.weaponType),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rp ${_formatRupiah(weapon.price)}',
                          style: TextStyle(
                            color: isOutOfStock ? Colors.white38 : const Color(0xFFFFD700),
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Stok: ${weapon.stock}',
                          style: TextStyle(
                            color: isOutOfStock ? Colors.redAccent : Colors.white54,
                            fontSize: 11,
                            fontWeight: isOutOfStock ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}