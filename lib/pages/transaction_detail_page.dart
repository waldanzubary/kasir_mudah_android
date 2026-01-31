import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionModel trx;

  const TransactionDetailPage({super.key, required this.trx});

  // Color Palette (SAMA PERSIS)
  final Color primaryColor = const Color(0xFF00AA5B);
  final Color surfaceColor = const Color(0xFFFFFFFF);
  final Color bgColor = const Color(0xFFF7F9FA);
  final Color textDark = const Color(0xFF2E3137);
  final Color textLight = const Color(0xFF6D7588);

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('dd MMM yyyy • HH:mm');

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: surfaceColor,
        iconTheme: IconThemeData(color: textDark),
        title: Text(
          'Detail Transaksi',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(format),
          Expanded(child: _buildItemList()),
          _buildSummary(),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(DateFormat format) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ID Transaksi',
            style: TextStyle(color: textLight, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            trx.id,
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            format.format(trx.date),
            style: TextStyle(color: textLight),
          ),
        ],
      ),
    );
  }

  // ================= ITEM LIST =================
  Widget _buildItemList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: trx.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final item = trx.items[i];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // IMAGE
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: item.product.imagePath != null &&
                        item.product.imagePath!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(item.product.imagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(Icons.inventory_2_rounded,
                        color: textLight.withOpacity(0.5)),
              ),
              const SizedBox(width: 12),

              // INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${item.product.price} x ${item.qty}',
                      style: TextStyle(color: textLight, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // SUBTOTAL
              Text(
                'Rp ${item.subtotal}',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= SUMMARY =================
  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row('Total', trx.total),
          const SizedBox(height: 8),
          _row('Tunai', trx.cash),
          const SizedBox(height: 8),
          _row('Kembalian', trx.change, highlight: true),
        ],
      ),
    );
  }

  Widget _row(String label, int value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textLight)),
        Text(
          'Rp $value',
          style: TextStyle(
            color: highlight ? primaryColor : textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
  