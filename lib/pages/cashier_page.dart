import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/storage_service.dart';
import 'dart:io';
import 'package:intl/intl.dart';

import '../models/transaction.dart';

class CashierPage extends StatefulWidget {
  const CashierPage({super.key});

  @override
  State<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends State<CashierPage> {
  List<Product> products = [];
  List<CartItem> cart = [];
  bool isScanning = false;
  final TextEditingController cashCtrl = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  final Color primaryColor = const Color(0xFF00AA5B); 
  final Color surfaceColor = const Color(0xFFFFFFFF);
  final Color bgColor = const Color(0xFFF7F9FA);
  final Color textDark = const Color(0xFF2E3137);
  final Color textLight = const Color(0xFF6D7588);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await StorageService.loadProducts();
    setState(() => products = data);
  }
  
  Future<void> _saveTransaction() async {
    final trx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      items: List.from(cart),
      total: total,
      cash: cash,
      change: change,
    );
    await StorageService.saveTransaction(trx);
  }

  void _handleScan(String barcode) {
    final found = products.where((p) => p.barcode == barcode).toList();
    if (found.isEmpty) {
      _showToast("Produk tidak ditemukan!", isError: true);
      return;
    }
    final index = cart.indexWhere((c) => c.product.barcode == barcode);
    setState(() {
      if (index >= 0) {
        cart[index].qty++;
      } else {
        cart.add(CartItem(product: found.first));
      }
    });
  }

  int get total => cart.fold(0, (s, c) => s + (c.product.price * c.qty));
  int get cash => int.tryParse(cashCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  int get change => cash - total;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // PENTING: Mencegah overflow saat keyboard muncul
      resizeToAvoidBottomInset: true, 
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildScannerTrigger(),
          Expanded(child: _buildCartSection()),
          _buildCheckoutPanel(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: surfaceColor,
      title: Text('Kasir Pintar', style: TextStyle(color: textDark, fontWeight: FontWeight.w900)),
      actions: [
        if (cart.isNotEmpty)
          IconButton(
            onPressed: () => setState(() => cart.clear()),
            icon: const Icon(Icons.refresh_rounded, color: Colors.redAccent),
          ),
      ],
    );
  }

  Widget _buildScannerTrigger() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: surfaceColor,
      child: InkWell(
        onTap: _openScanner,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryColor.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner_rounded, color: primaryColor),
              const SizedBox(width: 8),
              Text('SCAN BARCODE', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartSection() {
    if (cart.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: cart.length,
      itemBuilder: (context, index) {
        final item = cart[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Row(
            children: [
              _buildThumb(item.product.imagePath),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name, style: TextStyle(color: textDark, fontWeight: FontWeight.w700)),
                    Text(currencyFormat.format(item.product.price), style: TextStyle(color: primaryColor, fontSize: 13)),
                  ],
                ),
              ),
              _buildQtyController(item),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckoutPanel() {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20, // Menyesuaikan keyboard
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      // Mencegah overflow jika isi panel terlalu banyak
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _rowSummary('Total Belanja', currencyFormat.format(total), isPrimary: true),
            const SizedBox(height: 16),
            TextField(
              controller: cashCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: TextStyle(fontWeight: FontWeight.w800, color: textDark),
              decoration: InputDecoration(
                hintText: 'Uang Tunai...',
                prefixIcon: Icon(Icons.payments_rounded, color: primaryColor),
                filled: true, fillColor: bgColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            if (cash > 0) ...[
              const SizedBox(height: 12),
              _rowSummary('Kembalian', currencyFormat.format(change), 
                color: change >= 0 ? primaryColor : Colors.red),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: (total > 0 && change >= 0) ? _showSuccessDialog : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: textDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('PROSES TRANSAKSI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODALS (WARNA PUTIH) ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white, // Putih Bersih
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF00AA5B), size: 80),
            const SizedBox(height: 16),
            const Text('Berhasil!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
            const SizedBox(height: 20),
            _rowModalInfo('Total', currencyFormat.format(total)),
            _rowModalInfo('Kembali', currencyFormat.format(change), isBold: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _saveTransaction();
                  Navigator.pop(context);
                  setState(() { cart.clear(); cashCtrl.clear(); });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('TRANSAKSI BARU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---
  Widget _rowSummary(String label, String val, {Color? color, bool isPrimary = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textLight, fontWeight: FontWeight.w600)),
        Text(val, style: TextStyle(
          color: color ?? textDark, 
          fontSize: isPrimary ? 20 : 16, 
          fontWeight: FontWeight.w900
        )),
      ],
    );
  }

  Widget _rowModalInfo(String label, String val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textLight)),
          Text(val, style: TextStyle(fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, color: textDark)),
        ],
      ),
    );
  }

Widget _buildEmptyState() {
  return LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView( // Agar bisa di-scroll jika layar sangat kecil (misal saat keyboard muncul)
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(minHeight: constraints.maxHeight), // Memenuhi layar
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Efek bayangan lembut pada Icon agar terlihat Premium
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade200),
              ),
              const SizedBox(height: 24),
              Text(
                'Keranjang Kosong', 
                style: TextStyle(
                  color: textDark, 
                  fontWeight: FontWeight.w900, // Heavier weight sesuai gaya Anda
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mulai tambahkan item untuk melihat\nkatalog produk Anda di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textLight, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildThumb(String? path) {
  final fileExists = path != null && File(path).existsSync();

  return Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: fileExists
          ? Image.file(
              File(path!),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _placeholderImage();
              },
            )
          : _placeholderImage(),
    ),
  );
}

Widget _placeholderImage() {
  return Container(
    color: bgColor,
    child: Icon(
      Icons.inventory_2_outlined,
      color: Colors.grey.shade400,
      size: 24,
    ),
  );
}


  Widget _buildQtyController(CartItem item) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          _circleBtn(Icons.remove, () => setState(() => item.qty > 1 ? item.qty-- : cart.remove(item))),
          const SizedBox(width: 8),
          Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          _circleBtn(Icons.add, () => setState(() => item.qty++)),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(radius: 14, backgroundColor: Colors.white, child: Icon(icon, size: 14, color: primaryColor)),
    );
  }

  void _openScanner() {
    isScanning = false;
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(onDetect: (cap) {
        if (isScanning) return;
        final code = cap.barcodes.first.rawValue;
        if (code != null) {
          isScanning = true; Navigator.pop(context); _handleScan(code);
        }
      }),
    )));
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: isError ? Colors.redAccent : primaryColor,
      behavior: SnackBarBehavior.floating,
    ));
  }
}