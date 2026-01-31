import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionModel trx;

  const TransactionDetailPage({super.key, required this.trx});

  // Modern Premium Palette
  final Color primaryColor = const Color(0xFF00AA5B);
  final Color surfaceColor = const Color(0xFFFFFFFF);
  final Color bgColor = const Color(0xFFF0F2F5);
  final Color textDark = const Color(0xFF1A1D1E);
  final Color textLight = const Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Transaksi',
          style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildReceiptCard(dateFormat, timeFormat),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(DateFormat dFormat, DateFormat tFormat) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildReceiptHeader(dFormat, tFormat),
          _buildDashedDivider(),
          _buildItemList(),
          _buildDashedDivider(),
          _buildReceiptSummary(),
          const SizedBox(height: 30),
          _buildFooterNote(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReceiptHeader(DateFormat dFormat, DateFormat tFormat) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_rounded, color: primaryColor, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Transaksi Berhasil',
            style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            '#${trx.id}',
            style: TextStyle(color: textLight, fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _headerMeta(Icons.calendar_today_rounded, dFormat.format(trx.date)),
              _headerMeta(Icons.access_time_rounded, tFormat.format(trx.date)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: textLight),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildItemList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DAFTAR BELANJA',
            style: TextStyle(color: textLight, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          ...trx.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    _buildItemImage(item.product.imagePath),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: TextStyle(color: textDark, fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                          Text(
                            'Rp ${NumberFormat("#,###").format(item.product.price)} x ${item.qty}',
                            style: TextStyle(color: textLight, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${NumberFormat("#,###").format(item.subtotal)}',
                      style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildItemImage(String? path) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: path != null && File(path).existsSync()
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(path), fit: BoxFit.cover),
            )
          : Icon(Icons.image_outlined, color: textLight.withOpacity(0.5), size: 20),
    );
  }

  Widget _buildReceiptSummary() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _summaryRow('Total Belanja', trx.total, isTotal: true),
          const SizedBox(height: 12),
          _summaryRow('Bayar (Tunai)', trx.cash),
          const SizedBox(height: 8),
          _summaryRow('Kembalian', trx.change, isHighlight: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, int value, {bool isTotal = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal || isHighlight ? textDark : textLight,
            fontWeight: isTotal || isHighlight ? FontWeight.w800 : FontWeight.w500,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          'Rp ${NumberFormat("#,###").format(value)}',
          style: TextStyle(
            color: isHighlight ? primaryColor : textDark,
            fontWeight: FontWeight.w900,
            fontSize: isTotal ? 20 : 15,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedDivider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _notch(),
          Expanded(
            child: CustomPaint(
              painter: DashedLinePainter(color: bgColor.withOpacity(0.8)),
            ),
          ),
          _notch(isRight: true),
        ],
      ),
    );
  }

  Widget _notch({bool isRight = false}) {
    return Container(
      height: 20,
      width: 10,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.only(
          topRight: isRight ? Radius.zero : const Radius.circular(10),
          bottomRight: isRight ? Radius.zero : const Radius.circular(10),
          topLeft: isRight ? const Radius.circular(10) : Radius.zero,
          bottomLeft: isRight ? const Radius.circular(10) : Radius.zero,
        ),
      ),
    );
  }

  Widget _buildFooterNote() {
    return Column(
      children: [
        Text(
          'Terima kasih telah berbelanja!',
          style: TextStyle(color: textLight, fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          'Simpan struk digital ini sebagai bukti pembayaran sah.',
          textAlign: TextAlign.center,
          style: TextStyle(color: textLight.withOpacity(0.6), fontSize: 11),
        ),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 5, startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}