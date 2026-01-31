import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasir_mudah/pages/transaction_detail_page.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  // Theme Colors
  final Color primaryColor = const Color(0xFF00AA5B); 
  final Color surfaceColor = const Color(0xFFFFFFFF);
  final Color bgColor = const Color(0xFFF7F9FA);
  final Color textDark = const Color(0xFF2E3137);
  final Color textLight = const Color(0xFF6D7588);

  String selectedFilter = 'Hari Ini'; // Default filter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: surfaceColor,
        title: Text('Riwayat Transaksi', 
          style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 22)),
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

          // 1. FILTER LOGIC
          DateTime now = DateTime.now();
          List<TransactionModel> filteredList = snapshot.data!.where((trx) {
            if (selectedFilter == 'Hari Ini') {
              return trx.date.day == now.day && trx.date.month == now.month && trx.date.year == now.year;
            } else if (selectedFilter == '7 Hari') {
              return trx.date.isAfter(now.subtract(const Duration(days: 7)));
            } else {
              return trx.date.isAfter(now.subtract(const Duration(days: 30)));
            }
          }).toList();

          // 2. SORTING LOGIC (Terbaru di atas)
          filteredList.sort((a, b) => b.date.compareTo(a.date));

          return CustomScrollView(
            slivers: [
              // Chart & Ringkasan
              SliverToBoxAdapter(child: _buildSimpleAnalytics(filteredList)),
              
              // Filter Chips
              SliverToBoxAdapter(child: _buildFilterSection()),

              // Transaction List
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryColor, const Color(0xFF00894A)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Pendapatan ($selectedFilter)', 
            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Rp ${NumberFormat('#,###').format(totalOmzet).replaceAll(',', '.')}', 
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          
          // Visual Chart Sederhana (Bar Chart Mini)
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
    // Dummy chart height untuk estetika UI
    double h = [30.0, 50.0, 20.0, 70.0, 40.0, 60.0, 45.0][index];
    return Container(
      width: 30,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(index == 3 ? 1.0 : 0.3), // Highlight bar tengah
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: ['Hari Ini', '7 Hari', '30 Hari'].map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(f),
            selected: selectedFilter == f,
            onSelected: (val) { if(val) setState(() => selectedFilter = f); },
            selectedColor: primaryColor,
            backgroundColor: surfaceColor,
            labelStyle: TextStyle(color: selectedFilter == f ? Colors.white : textLight, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade100)),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionDetailPage(trx: trx))),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
          child: Icon(Icons.receipt_long_rounded, color: primaryColor),
        ),
        title: Text('Rp ${NumberFormat('#,###').format(trx.total).replaceAll(',', '.')}', 
          style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 17)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${dateFormat.format(trx.date)} • ${timeFormat.format(trx.date)}', 
            style: TextStyle(color: textLight, fontSize: 12)),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_graph_rounded, size: 60, color: Colors.grey.shade200),
          const SizedBox(height: 12),
          Text('Tidak ada transaksi di periode ini', style: TextStyle(color: textLight, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}