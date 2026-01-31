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
  int _currentIndex = 1; // Default ke Kasir

  final List<Widget> _pages = const [
    ProductPage(),
    CashierPage(),
    TransactionHistoryPage(),
  ];

  // Palette Sesuai Brand "Toko Green"
  final Color primaryColor = const Color(0xFF00AA5B); 
  final Color surfaceColor = const Color(0xFFFFFFFF);
  final Color textLight = const Color(0xFF6D7588);
  final Color textDark = const Color(0xFF2E3137);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      // Gunakan IndexedStack agar state halaman terjaga (tidak reload saat pindah tab)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // Navigation Bar yang solid dan bersih agar tidak menumpuk dengan konten
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              
              // Styling
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent, // Mengikut Container di atas
              elevation: 0,
              selectedItemColor: primaryColor,
              unselectedItemColor: textLight,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, height: 1.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, height: 1.5),
              
              items: [
                _buildNavItem(
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2_rounded,
                  label: 'Produk',
                ),
                _buildNavItem(
                  icon: Icons.point_of_sale_outlined,
                  activeIcon: Icons.point_of_sale_rounded,
                  label: 'Kasir',
                ),
                _buildNavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Riwayat',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(icon),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(activeIcon),
      ),
      label: label,
    );
  }
}