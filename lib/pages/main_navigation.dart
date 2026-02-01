import 'package:flutter/material.dart';
import 'package:kasir_mudah/pages/product_page.dart';
import 'package:kasir_mudah/pages/cashier_page.dart';
import 'package:kasir_mudah/pages/transaction_history.dart';
import 'package:kasir_mudah/pages/profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 1; // Default ke Kasir

  // List halaman tetap sama
  final List<Widget> _pages = [
    const ProductPage(),
    const CashierPage(),
    const TransactionHistoryPage(),
    const ProfilePage(),
  ];

  // Design System Colors
  final Color primaryColor = const Color(0xFF00AA5B);
  final Color surfaceColor = const Color(0xFFFFFFFF);
  final Color bgColor = const Color(0xFFF7F9FA);
  final Color textLight = const Color(0xFF6D7588);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // Menggunakan AnimatedSwitcher untuk efek transisi halus saat refresh
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: _pages[_currentIndex], 
        // Key membantu Flutter mengenali perubahan halaman untuk refresh
        key: ValueKey<int>(_currentIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            // Saat di-tap, setState akan mentrigger build ulang halaman tujuan (Refresh)
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: primaryColor,
            unselectedItemColor: textLight,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            // Tipografi Berat untuk Informasi Penting (Selected)
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
            // Tipografi Ringan untuk Label Pendukung (Unselected)
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2_rounded),
                label: 'Produk',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.point_of_sale_outlined),
                activeIcon: Icon(Icons.point_of_sale_rounded),
                label: 'Kasir',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long_rounded),
                label: 'Riwayat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Pengaturan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}