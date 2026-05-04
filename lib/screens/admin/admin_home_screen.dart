import 'package:flutter/material.dart';
import 'weapon_manage_screen.dart';
import 'transaction_log_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    WeaponManageScreen(),
    TransactionLogScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1B2A4A),
        selectedItemColor: const Color(0xFFFFD700),
        unselectedItemColor: Colors.white38,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Weapons'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transactions'),
        ],
      ),
    );
  }
}