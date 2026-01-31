import 'package:flutter/material.dart';
import 'package:kasir_mudah/pages/product_page.dart';
import 'package:kasir_mudah/pages/cashier_page.dart';
import 'package:kasir_mudah/pages/transaction_history.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 1; // default ke Kasir

  // JANGAN pakai const supaya page bisa rebuild
  final List<Widget> _pages = [
    const ProductPage(),
    const CashierPage(),
    const TransactionHistoryPage(),
  ];

  // Color palette
  final Color primaryColor = const Color(0xFF00AA5B);
  final Color surfaceColor = const Color(0xFFFFFFFF);
  final Color bgColor = const Color(0xFFF7F9FA);
  final Color textLight = const Color(0xFF6D7588);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      // ⬇️ INI KUNCI AUTO REFRESH
      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.12),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (_currentIndex != index) {
                  setState(() => _currentIndex = index);
                }
              },

              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,

              selectedItemColor: primaryColor,
              unselectedItemColor: textLight,
              selectedFontSize: 12,
              unselectedFontSize: 12,

              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
