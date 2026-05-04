import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/weapon_service.dart';

class AddWeaponScreen extends StatefulWidget {
  const AddWeaponScreen({super.key});

  @override
  State<AddWeaponScreen> createState() => _AddWeaponScreenState();
}

class _AddWeaponScreenState extends State<AddWeaponScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedType = 'sword';
  File? _imageFile;
  bool _isLoading = false;
  final WeaponService _weaponService = WeaponService();
  final ImagePicker _picker = ImagePicker();

  final List<String> _types = ['sword', 'claymore', 'polearm', 'bow', 'catalyst'];

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _submit() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _stockController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama, harga, dan stok wajib diisi'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    final token = context.read<AuthProvider>().token!;

    final result = await _weaponService.createWeapon(
      token: token,
      weaponName: _nameController.text.trim(),
      weaponType: _selectedType,
      description: _descController.text.trim(),
      stock: int.parse(_stockController.text),
      price: double.parse(_priceController.text),
      imageFile: _imageFile,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['weapon_id'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weapon berhasil ditambahkan'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Gagal'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Tambah Weapon', style: TextStyle(color: Color(0xFFFFD700))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2A4A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, color: Colors.white38, size: 48),
                          SizedBox(height: 8),
                          Text('Tap untuk pilih gambar', style: TextStyle(color: Colors.white38)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            _buildTextField(_nameController, 'Nama Weapon', Icons.shield),
            const SizedBox(height: 16),

            // Type dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1B2A4A),
                  style: const TextStyle(color: Colors.white),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                  items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildTextField(_descController, 'Deskripsi', Icons.description, maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField(_stockController, 'Stok', Icons.inventory, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(_priceController, 'Harga', Icons.monetization_on, keyboardType: TextInputType.number),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                    : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
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