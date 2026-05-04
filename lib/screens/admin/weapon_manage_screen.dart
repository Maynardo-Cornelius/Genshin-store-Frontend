import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/weapon.dart';
import '../../providers/auth_provider.dart';
import '../../services/weapon_service.dart';
import 'add_weapon_screen.dart';
import 'edit_weapon_screen.dart';

class WeaponManageScreen extends StatefulWidget {
  const WeaponManageScreen({super.key});

  @override
  State<WeaponManageScreen> createState() => _WeaponManageScreenState();
}

class _WeaponManageScreenState extends State<WeaponManageScreen> {
  final WeaponService _weaponService = WeaponService();
  List<Weapon> _weapons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeapons();
  }

  Future<void> _loadWeapons() async {
    setState(() => _isLoading = true);
    final token = context.read<AuthProvider>().token!;
    final weapons = await _weaponService.getWeapons(token);
    setState(() {
      _weapons = weapons;
      _isLoading = false;
    });
  }

  Future<void> _deleteWeapon(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B2A4A),
        title: const Text('Hapus Weapon', style: TextStyle(color: Colors.white)),
        content: const Text('Yakin ingin menghapus weapon ini?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final token = context.read<AuthProvider>().token!;
    final result = await _weaponService.deleteWeapon(token, id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Weapon dihapus'),
        backgroundColor: Colors.green,
      ),
    );
    _loadWeapons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('Kelola Weapon', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFD700),
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddWeaponScreen()));
          _loadWeapons();
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : _weapons.isEmpty
              ? const Center(
                  child: Text('Belum ada weapon', style: TextStyle(color: Colors.white54)),
                )
              : RefreshIndicator(
                  onRefresh: _loadWeapons,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _weapons.length,
                    itemBuilder: (context, index) {
                      final weapon = _weapons[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2A4A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: weapon.image != null
                                ? CachedNetworkImage(
                                    imageUrl: 'http://10.0.2.2:3000/uploads/${weapon.image}',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.white10,
                                      child: const Icon(Icons.shield, color: Colors.white24),
                                    ),
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.white10,
                                    child: const Icon(Icons.shield, color: Colors.white24),
                                  ),
                          ),
                          title: Text(weapon.weaponName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(weapon.weaponType.toUpperCase(),
                                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12)),
                              Text('Rp ${weapon.price.toStringAsFixed(0)} • Stock: ${weapon.stock}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => EditWeaponScreen(weapon: weapon)),
                                  );
                                  _loadWeapons();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteWeapon(weapon.weaponId),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}