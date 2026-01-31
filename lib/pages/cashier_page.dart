import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/storage_service.dart';
import 'dart:io';

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

  // Modern Color Palette
  final Color primaryColor = const Color(0xFF00AA5B); // Toko Green
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
    products = await StorageService.loadProducts();
    setState(() {});
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


  // Logic Scan & Handle
  void _handleScan(String barcode) {
    final found = products.where((p) => p.barcode == barcode).toList();
    if (found.isEmpty) {
      _showToast("Produk tidak terdaftar", isError: true);
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

  int get total => cart.fold(0, (s, c) => s + c.subtotal);
  int get cash => int.tryParse(cashCtrl.text) ?? 0;
  int get change => cash - total;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
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
      centerTitle: false,
      title: Text('Transaksi Baru', 
        style: TextStyle(color: textDark, fontWeight: FontWeight.w800, fontSize: 20)),
      actions: [
        if (cart.isNotEmpty)
          TextButton.icon(
            onPressed: () => setState(() => cart.clear()),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            label: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildScannerTrigger() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: InkWell(
        onTap: _openScanner,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.qr_code_scanner_rounded, color: primaryColor),
              const SizedBox(width: 12),
              Text('Ketuk untuk scan barcode produk...', 
                style: TextStyle(color: textLight, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartSection() {
    if (cart.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Keranjang masih kosong', 
            style: TextStyle(color: textLight, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: cart.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = cart[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
             Container(
  width: 50,
  height: 50,
  decoration: BoxDecoration(
    color: bgColor,
    borderRadius: BorderRadius.circular(10),
  ),
  child: item.product.imagePath != null && item.product.imagePath!.isNotEmpty
      ? ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(item.product.imagePath!),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.broken_image,
              color: textLight.withOpacity(0.5),
            ),
          ),
        )
      : Icon(
          Icons.inventory_2_rounded,
          color: textLight.withOpacity(0.5),
        ),
),

              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name, 
                      style: TextStyle(color: textDark, fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('Rp ${item.product.price}', 
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
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

  Widget _buildQtyController(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _circleBtn(Icons.remove, () => setState(() {
            if (item.qty > 1) item.qty--;
            else cart.remove(item);
          })),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('${item.qty}', style: TextStyle(fontWeight: FontWeight.w800, color: textDark)),
          ),
          _circleBtn(Icons.add, () => setState(() => item.qty++)),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(shape: BoxShape.circle, color: surfaceColor, border: Border.all(color: Colors.grey.shade300)),
        child: Icon(icon, size: 16, color: primaryColor),
      ),
    );
  }

  Widget _buildCheckoutPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _summaryRow('Total Belanja', 'Rp $total', isBold: true),
          const SizedBox(height: 16),
          TextField(
            controller: cashCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.bold),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Masukkan jumlah uang...',
              prefixIcon: Icon(Icons.payments_outlined, color: primaryColor),
              filled: true,
              fillColor: bgColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          if (cash > 0) ...[
            const SizedBox(height: 12),
            _summaryRow('Kembalian', 'Rp $change', color: change >= 0 ? primaryColor : Colors.red),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: (total > 0 && change >= 0) ? _showSuccessDialog : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('SELESAIKAN PEMBAYARAN', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textLight, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(
          color: color ?? textDark, 
          fontSize: isBold ? 18 : 15, 
          fontWeight: isBold ? FontWeight.w900 : FontWeight.w700
        )),
      ],
    );
  }

  // Scanner & Dialogs...
  void _openScanner() {
    isScanning = false;
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(onDetect: (cap) {
        if (isScanning) return;
        final code = cap.barcodes.first.rawValue;
        if (code != null) {
          isScanning = true;
          Navigator.pop(context);
          _handleScan(code);
        }
      }),
    )));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF00AA5B), size: 100),
            const SizedBox(height: 16),
            const Text('Pembayaran Berhasil!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 8),
            Text('Kembalian: Rp $change', style: TextStyle(color: textLight)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
  await _saveTransaction(); // ⬅️ SIMPAN KE JSON
  Navigator.pop(context);
  setState(() {
    cart.clear();
    cashCtrl.clear();
  });
},

                style: ElevatedButton.styleFrom(backgroundColor: textDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Transaksi Baru', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}