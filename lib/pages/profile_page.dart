import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/storage_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  final Color primaryColor = const Color(0xFF00AA5B);
  final Color bgColor = const Color(0xFFF7F9FA);
  final Color textDark = const Color(0xFF2E3137);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text('Pengaturan',
            style: TextStyle(color: textDark, fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            
            
            // BAGIAN CADANGAN DATA
            _buildSectionTitle('CADANGAN DATA'),
            const SizedBox(height: 12),
            _buildMenuContainer([
              _buildListTile(
                icon: Icons.cloud_upload_rounded,
                title: 'Export Backup',
                subtitle: 'Simpan semua data ke file .json',
                onTap: () => _handleExport(context),
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.cloud_download_rounded,
                title: 'Import Backup',
                subtitle: 'Pulihkan data dari file cadangan',
                onTap: () => _handleImport(context),
              ),
            ]),

            const SizedBox(height: 24),

            // BAGIAN INFORMASI & BANTUAN
            _buildSectionTitle('INFORMASI & BANTUAN'),
            const SizedBox(height: 12),
            _buildMenuContainer([
              _buildListTile(
                icon: Icons.auto_stories_rounded,
                title: 'Panduan Aplikasi',
                subtitle: 'Cara penggunaan dan fitur kasir',
                onTap: () => _showPanduanDialog(context),
              ),
              _buildDivider(),
              _buildListTile(
                icon: Icons.info_outline_rounded,
                title: 'Tentang Kami',
                subtitle: 'Visi dan informasi pengembang',
                onTap: () => _showAboutDialog(context),
              ),
            ]),

            const SizedBox(height: 24),

            // BAGIAN DUKUNGAN (Etis untuk Play Store)
            _buildSectionTitle('APRESIASI'),
            const SizedBox(height: 12),
            _buildMenuContainer([
              _buildListTile(
                icon: Icons.coffee_rounded,
                title: 'Dukung Pengembang',
                subtitle: 'Donasi sukarela via Saweria',
                onTap: () => _showSupportDialog(context),
              ),
            ]),

            const SizedBox(height: 40),
            Text('Versi 1.0.0',
                style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= UI COMPONENTS =================

  

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildMenuContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: bgColor.withOpacity(0.8), indent: 70);
  }

  Widget _buildListTile(
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w900, color: textDark)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500)),
      trailing:
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
    );
  }

  // ================= DIALOGS & LOGIC =================

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Dukung Kami', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
          'Dukungan Anda membantu kami terus mengembangkan fitur gratis. Anda akan diarahkan ke halaman Saweria.',
          style: TextStyle(height: 1.5, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Nanti Saja', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchSaweria(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Lanjutkan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchSaweria(BuildContext context) async {
    // ISI LINK SAWERIA ANDA DI SINI
    final Uri url = Uri.parse('https://saweria.co/waldanstudio');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showSnackBar(context, 'Tidak dapat membuka link dukungan', isError: true);
    }
  }

  void _showAboutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 24),
            Icon(Icons.storefront_rounded, size: 60, color: primaryColor),
            const SizedBox(height: 16),
            Text('Kasir Pintar v1.0', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: textDark)),
            const SizedBox(height: 12),
            Text(
              'Aplikasi manajemen stok dan penjualan UMKM yang dirancang untuk kemudahan operasional harian Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text('Dikembangkan oleh Waldan Zubary', style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w900)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showPanduanDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Panduan Penggunaan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: textDark)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _buildPanduanItem('1', 'Kelola Produk', 'Tambahkan barang dagangan Anda di menu Produk. Pastikan mengisi harga dengan benar.'),
                  _buildPanduanItem('2', 'Transaksi Cepat', 'Gunakan fitur Scan Barcode untuk memasukkan barang ke keranjang.'),
                  _buildPanduanItem('3', 'Pembayaran', 'Masukkan nominal uang tunai, aplikasi akan menghitung kembalian otomatis.'),
                  _buildPanduanItem('4', 'Laporan', 'Pantau riwayat penjualan di menu Transaksi untuk melihat total pemasukan.'),
                  _buildPanduanItem('5', 'Cadangan Data', 'Lakukan "Export Backup" secara rutin agar data aman jika ganti perangkat.'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanduanItem(String step, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Text(step, style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textDark)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.grey.shade600, height: 1.4, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= LOGIKA STORAGE =================

  Future<void> _handleExport(BuildContext context) async {
    try {
      final data = await StorageService.getAllData();
      final String jsonString = jsonEncode(data);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/backup_kasir_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);
      await Share.shareXFiles([XFile(file.path)], text: 'Backup Data Kasir Pintar');
    } catch (e) {
      _showSnackBar(context, 'Gagal export data: $e', isError: true);
    }
  }

  Future<void> _handleImport(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        Map<String, dynamic> data = jsonDecode(content);
        await StorageService.restoreAllData(data);
        _showSuccessDialog(context);
      }
    } catch (e) {
      _showSnackBar(context, 'Format file tidak valid!', isError: true);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF00AA5B), size: 60),
            const SizedBox(height: 16),
            const Text('Import Berhasil', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            const SizedBox(height: 8),
            const Text('Data aplikasi telah diperbarui.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
}