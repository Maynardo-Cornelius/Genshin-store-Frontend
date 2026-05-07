import 'dart:io';
import 'package:flutter/material.dart';
import 'package:genshin_store_app/widgets/background_wrapper.dart';
import 'package:genshin_store_app/widgets/weapon_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/weapon.dart';
import '../../providers/auth_provider.dart';
import '../../services/weapon_service.dart';

class EditWeaponScreen extends StatefulWidget {
  final Weapon weapon;
  const EditWeaponScreen({super.key, required this.weapon});

  @override
  State<EditWeaponScreen> createState() => _EditWeaponScreenState();
}

class _EditWeaponScreenState extends State<EditWeaponScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _stockController;
  late TextEditingController _priceController;
  late String _selectedType;
  File? _imageFile;
  bool _isLoading = false;
  final WeaponService _weaponService = WeaponService();
  final ImagePicker _picker = ImagePicker();

  final List<String> _types = [
    'sword',
    'claymore',
    'polearm',
    'bow',
    'catalyst',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.weapon.weaponName);
    _descController = TextEditingController(text: widget.weapon.description);
    _stockController = TextEditingController(
      text: widget.weapon.stock.toString(),
    );

    _priceController = TextEditingController(
      text: widget.weapon.price.toStringAsFixed(0),
    );
    _selectedType = widget.weapon.weaponType.toLowerCase();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess
            ? Colors.green.shade700
            : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty) {
      _showSnackBar('Nama, harga, dan stok wajib diisi', false);
      return;
    }

    setState(() => _isLoading = true);
    final token = context.read<AuthProvider>().token!;

    final result = await _weaponService.updateWeapon(
      token: token,
      id: widget.weapon.weaponId,
      weaponName: _nameController.text.trim(),
      weaponType: _selectedType,
      description: _descController.text.trim(),
      stock: int.parse(_stockController.text),
      price: double.parse(_priceController.text),
      imageFile:
          _imageFile,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['weapon_id'] != null || result['message'] == 'Weapon updated') {
      _showSnackBar('Data senjata berhasil diperbarui', true);
      Navigator.pop(
        context,
        true,
      );
    } else {
      _showSnackBar(result['message'] ?? 'Gagal mengupdate senjata', false);
    }
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
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Edit Weapon',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gambar Senjata',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1B2A).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : WeaponImage(
                                image: widget.weapon.image,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                        Container(
                          color: Colors.black.withOpacity(0.4),
                        ),
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit, color: Colors.white, size: 36),
                              SizedBox(height: 8),
                              Text(
                                'Tap untuk ubah gambar',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Detail Informasi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                _nameController,
                'Nama Weapon',
                Icons.shield_outlined,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedType,
                dropdownColor: const Color(0xFF1B2A4A),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFFFFD700),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Tipe Senjata',
                  labelStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(
                    Icons.category_outlined,
                    color: Colors.white54,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0D1B2A).withOpacity(0.5),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFD700)),
                  ),
                ),
                items: _types
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                _descController,
                'Deskripsi Senjata',
                Icons.description_outlined,
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildTextField(
                      _stockController,
                      'Stok',
                      Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      _priceController,
                      'Harga',
                      Icons.monetization_on_outlined,
                      keyboardType: TextInputType.number,
                      prefixText: 'Rp ',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.update),
                  label: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Update Weapon',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFFFFD700).withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefixText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          color: Color(0xFFFFD700),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        filled: true,
        fillColor: const Color(0xFF0D1B2A).withOpacity(0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD700)),
        ),
      ),
    );
  }
}
