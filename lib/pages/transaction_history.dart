import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasir_mudah/pages/transaction_detail_page.dart'; // Sesuaikan dengan path project Anda
import '../models/transaction.dart';
import '../services/storage_service.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  // Theme Colors - Konsisten dengan gaya modern & clean
  final Color primaryColor = const Color(0xFF00AA5B); 
  final Color surfaceColor = const Color(0xFFFFFFFF);
  final Color bgColor = const Color(0xFFF7F9FA);
  final Color textDark = const Color(0xFF2E3137);
  final Color textLight = const Color(0xFF6D7588);

  String selectedFilter = 'Semua'; // Default filter sekarang menampilkan semua

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: surfaceColor,
        surfaceTintColor: surfaceColor,
        
        title: Text('Riwayat Transaksi', 
          style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 20)),
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

          // --- LOGIKA FILTER ---
          DateTime now = DateTime.now();
          List<TransactionModel> filteredList = snapshot.data!.where((trx) {
            if (selectedFilter == 'Hari Ini') {
              return trx.date.day == now.day && 
                     trx.date.month == now.month && 
                     trx.date.year == now.year;
            } else if (selectedFilter == '7 Hari') {
              return trx.date.isAfter(now.subtract(const Duration(days: 7)));
            } else if (selectedFilter == '30 Hari') {
              return trx.date.isAfter(now.subtract(const Duration(days: 30)));
            } else {
              // Jika 'Semua', tampilkan seluruh data
              return true; 
            }
          }).toList();

          // --- LOGIKA SORTING (Terbaru di atas) ---
          filteredList.sort((a, b) => b.date.compareTo(a.date));

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Panel Ringkasan Omzet
              SliverToBoxAdapter(child: _buildSimpleAnalytics(filteredList)),
              
              // Filter Chips (Sticky effect jika diperlukan, tapi di sini scroll biasa)
              SliverToBoxAdapter(child: _buildFilterSection()),

              // Daftar Transaksi
              filteredList.isEmpty 
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _buildTransactionCard(filteredList[i]),
                        childCount: filteredList.length,
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSimpleAnalytics(List<TransactionModel> items) {
    int totalOmzet = items.fold(0, (sum, item) => sum + item.total);
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, const Color(0xFF00894A)]
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Pendapatan ($selectedFilter)', 
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
              Text('${items.length} Trx', 
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Rp ${NumberFormat('#,###').format(totalOmzet).replaceAll(',', '.')}', 
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 24),
          
          // Visual Chart Sederhana (Hanya Estetika)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(7, (index) => _buildChartBar(index)),
          )
        ],
      ),
    );
  }

  Widget _buildChartBar(int index) {
    double h = [25.0, 45.0, 20.0, 65.0, 35.0, 55.0, 40.0][index];
    return Container(
      width: 32,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(index == 3 ? 1.0 : 0.25),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildFilterSection() {
    final filters = ['Semua', 'Hari Ini', '7 Hari', '30 Hari'];
    
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: filters.map((f) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ChoiceChip(
            label: Text(f),
            selected: selectedFilter == f,
            onSelected: (val) { if(val) setState(() => selectedFilter = f); },
            selectedColor: primaryColor,
            backgroundColor: surfaceColor,
            elevation: 0,
            pressElevation: 0,
            labelStyle: TextStyle(
              color: selectedFilter == f ? Colors.white : textLight, 
              fontWeight: FontWeight.w800,
              fontSize: 13
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), 
              side: BorderSide(color: selectedFilter == f ? primaryColor : Colors.grey.shade200)
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionModel trx) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 15, 
            offset: const Offset(0, 6)
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => TransactionDetailPage(trx: trx))
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor, 
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: Icon(Icons.receipt_long_rounded, color: primaryColor, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rp ${NumberFormat('#,###').format(trx.total).replaceAll(',', '.')}', 
                        style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 17)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${dateFormat.format(trx.date)} • ${timeFormat.format(trx.date)}', 
                        style: TextStyle(color: textLight, fontSize: 12, fontWeight: FontWeight.w600)
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_toggle_off_rounded, size: 50, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 16),
          Text('Belum ada transaksi', 
            style: TextStyle(color: textDark, fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Transaksi yang Anda buat akan muncul di sini', 
            style: TextStyle(color: textLight, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}