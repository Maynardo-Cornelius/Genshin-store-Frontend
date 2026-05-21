import 'package:flutter/material.dart';
import 'package:genshin_store_app/widgets/background_wrapper.dart';
import 'package:genshin_store_app/widgets/weapon_image.dart';
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

  Future<void> _deleteWeapon(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B2A4A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
            const SizedBox(width: 8),
            const Text('Hapus Weapon', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Tindakan ini tidak dapat dibatalkan. Yakin ingin menghapus weapon ini dari katalog?',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.redAccent)),
    );

    final token = context.read<AuthProvider>().token!;
    final result = await _weaponService.deleteWeapon(token, id);

    if (!mounted) return;
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(result['message'] ?? 'Weapon berhasil dihapus'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    _loadWeapons();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D1B2A).withOpacity(0.9),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Katalog Admin',
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
              tooltip: 'Logout',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFFFD700),
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text(
            'Tambah',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddWeaponScreen()),
            );
            _loadWeapons();
          },
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFD700)),
              )
            : _weapons.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    color: const Color(0xFFFFD700),
                    backgroundColor: const Color(0xFF1B2A4A),
                    onRefresh: _loadWeapons,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
                      itemCount: _weapons.length,
                      itemBuilder: (context, index) {
                        final weapon = _weapons[index];
                        final isOutOfStock = weapon.stock == 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B2A4A).withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isOutOfStock ? Colors.redAccent.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                                  child: WeaponImage(
                                    image: weapon.image,
                                    width: 80,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        weapon.weaponName,
                                        style: TextStyle(
                                          color: isOutOfStock ? Colors.white54 : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
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
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Rp ${_formatRupiah(weapon.price)}',
                                            style: const TextStyle(
                                              color: Color(0xFFFFD700),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        isOutOfStock ? 'STOK HABIS' : 'Tersedia: ${weapon.stock} unit',
                                        style: TextStyle(
                                          color: isOutOfStock ? Colors.redAccent : Colors.white54,
                                          fontSize: 12,
                                          fontWeight: isOutOfStock ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_square, color: Colors.lightBlueAccent, size: 22),
                                    tooltip: 'Edit',
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditWeaponScreen(weapon: weapon),
                                        ),
                                      );
                                      _loadWeapons();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 22),
                                    tooltip: 'Hapus',
                                    onPressed: () => _deleteWeapon(weapon.weaponId),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
            child: const Icon(Icons.inventory_2, size: 64, color: Colors.white38),
          ),
          const SizedBox(height: 24),
          const Text(
            'Katalog Kosong',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap tombol Tambah untuk memasukkan senjata.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}