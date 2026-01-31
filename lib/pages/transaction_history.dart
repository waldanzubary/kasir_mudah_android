import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasir_mudah/pages/transaction_detail_page.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  // Modern Color Palette (Sesuai preferensi yang disimpan)
  final Color primaryColor = const Color(0xFF00AA5B); // Toko Green
  final Color surfaceColor = const Color(0xFFFFFFFF);
  final Color bgColor = const Color(0xFFF7F9FA);
  final Color textDark = const Color(0xFF2E3137);
  final Color textLight = const Color(0xFF6D7588);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: surfaceColor,
        centerTitle: false,
        iconTheme: IconThemeData(color: textDark),
        title: Text(
          'Riwayat Transaksi',
          style: TextStyle(
            color: textDark, 
            fontWeight: FontWeight.w800, 
            fontSize: 20
          ),
        ),
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: StorageService.loadTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final list = snapshot.data!.reversed.toList(); // Terbaru di atas
          final format = DateFormat('dd MMM yyyy • HH:mm');

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final trx = list[i];
              return _buildTransactionCard(context, trx, format);

            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              color: textLight, 
              fontSize: 16, 
              fontWeight: FontWeight.w600
            ),
          ),
        ],
      ),
    );
  }

Widget _buildTransactionCard(
  BuildContext context,
  TransactionModel trx,
  DateFormat format,
) {

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
         onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => TransactionDetailPage(trx: trx),
    ),
  );
},

          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Status / Type
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.shopping_bag_rounded, color: primaryColor),
                ),
                const SizedBox(width: 16),
                // Informasi Transaksi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Transaksi',
                        style: TextStyle(
                          color: textLight, 
                          fontSize: 12, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rp ${trx.total}',
                        style: TextStyle(
                          color: textDark, 
                          fontWeight: FontWeight.w900, 
                          fontSize: 16
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        format.format(trx.date),
                        style: TextStyle(
                          color: textLight, 
                          fontSize: 12
                        ),
                      ),
                    ],
                  ),
                ),
                // Indikator Status atau Navigasi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Selesai',
                    style: TextStyle(
                      color: primaryColor, 
                      fontSize: 11, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
      ),
    );
  }
}