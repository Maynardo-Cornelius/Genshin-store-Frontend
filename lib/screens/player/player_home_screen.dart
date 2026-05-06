import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Tambahkan import ini
import 'package:genshin_store_app/widgets/background_wrapper.dart';
import 'weapon_store_screen.dart';
import 'wallet_screen.dart';
import 'inventory_screen.dart';

class PlayerHomeScreen extends StatefulWidget {
  const PlayerHomeScreen({super.key});

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    WeaponStoreScreen(),
    WalletScreen(),
    InventoryScreen(),
  ];

  final List<String> bannerImages = [
    'assets/images/Carousel1.png',
    'assets/images/Carousel2.png',
    'assets/images/Carousel3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Genshin Import',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1B2A4A).withOpacity(0.9),
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            if (_currentIndex == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 160.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: const Duration(
                      milliseconds: 800,
                    ),
                    viewportFraction: 0.85,
                  ),
                  items: bannerImages
                      .map(
                        (item) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Image.asset(
                              item,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: const Color(0xFF1B2A4A),
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.white54,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

            Expanded(child: _screens[_currentIndex]),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF1B2A4A),
          selectedItemColor: const Color(0xFFFFD700),
          unselectedItemColor: Colors.white38,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.backpack),
              label: 'Inventory',
            ),
          ],
        ),
      ),
    );
  }
}
