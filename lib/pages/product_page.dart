import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// Pastikan import ini sesuai dengan struktur project Anda
import '../models/product.dart';
import '../services/storage_service.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Product> products = [];
  List<String> categories = [];
  
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController categoryCtrl = TextEditingController();

  String imagePath = '';
  String scannedBarcode = '';
  String selectedCategory = '';
  String filterCategory = '';
  bool isScanning = false;

  // Modern Color Palette
  final Color primaryColor = const Color(0xFF00AA5B); 
  final Color surfaceColor = const Color(0xFFFFFFFF);
  final Color bgColor = const Color(0xFFF7F9FA);
  final Color textDark = const Color(0xFF2E3137);
  final Color textLight = const Color(0xFF6D7588);

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await loadProducts();
    await loadCategories();
  }

  Future<void> loadProducts() async {
    final data = await StorageService.loadProducts();
    if (mounted) {
      setState(() => products = data);
    }
  }

  Future<void> loadCategories() async {
    final data = await StorageService.loadCategories();
    if (mounted) {
      setState(() => categories = data);
    }
  }

  // ================= LOGIC FUNCTIONS =================

  void _deleteProduct(String id) async {
    setState(() => products.removeWhere((p) => p.id == id));
    await StorageService.saveProducts(products);
    _showToast("Produk berhasil dihapus");
  }

  void _addCategory(String cat) {
    if (cat.isEmpty) return;
    if (!categories.contains(cat)) {
      categories.add(cat);
      StorageService.saveCategories(categories);
    }
    setState(() {
      selectedCategory = cat;
      categoryCtrl.clear();
    });
  }

  void _showToast(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : textDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ================= UI BUILDERS =================

  @override
  Widget build(BuildContext context) {
    final filteredItems = filterCategory.isEmpty
        ? products
        : products.where((p) => p.category == filterCategory).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          _buildCategoryFilter(),
          filteredItems.isEmpty 
              ? _buildEmptyState() 
              : _buildProductList(filteredItems),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      pinned: true,
      elevation: 0,
      backgroundColor: surfaceColor,
      surfaceTintColor: surfaceColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text('Katalog Produk', 
          style: TextStyle(color: textDark, fontWeight: FontWeight.w900, fontSize: 22)),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            _buildFilterChip('Semua', filterCategory.isEmpty, () => setState(() => filterCategory = '')),
            ...categories.map((cat) => _buildFilterChip(cat, filterCategory == cat, () => setState(() => filterCategory = cat))),
            IconButton(
              onPressed: _showAddCategoryDialog,
              icon: Icon(Icons.add_circle_outline_rounded, color: primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool active, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => onTap(),
        selectedColor: primaryColor,
        backgroundColor: Colors.white,
        elevation: 0,
        pressElevation: 0,
        labelStyle: TextStyle(
          color: active ? Colors.white : textLight, 
          fontWeight: active ? FontWeight.w800 : FontWeight.w500,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: active ? primaryColor : Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildProductList(List<Product> items) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _buildProductCard(items[i]),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(Product p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), 
            blurRadius: 20, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openEditProduct(p),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _buildProductImage(p.imagePath),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.category.toUpperCase(), 
                          style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                        const SizedBox(height: 4),
                        Text(p.name, style: TextStyle(color: textDark, fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Rp ${p.price}', 
                          style: TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _showActionMenu(p),
                  icon: Icon(Icons.more_vert_rounded, color: textLight.withOpacity(0.6)),
                ),
                _buildBarcodeBadge(p.barcode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(String path) {
    return Container(
      width: 85, height: 85,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(16),
      ),
      child: path.isNotEmpty && File(path).existsSync()
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16), 
              child: Image.file(
                File(path), 
                fit: BoxFit.cover,
                key: ValueKey(path), // Mencegah caching gambar lama
              ))
          : Icon(Icons.inventory_2_rounded, color: Colors.grey.shade300, size: 28),
    );
  }

  Widget _buildBarcodeBadge(String code) {
    return Container(
      width: 35,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.6),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: RotatedBox(
        quarterTurns: 1,
        child: Center(
          child: Text(code, 
            style: TextStyle(fontSize: 8, color: textLight.withOpacity(0.5), fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showScanBarcode,
      backgroundColor: primaryColor,
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
      label: const Text('TAMBAH PRODUK', 
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }

  // ================= MODALS & ACTIONS =================

  void _showActionMenu(Product p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text(p.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textDark)),
            const SizedBox(height: 20),
            _buildActionItem(Icons.edit_rounded, 'Edit Produk', Colors.blue, () {
              Navigator.pop(context);
              _openEditProduct(p);
            }),
            _buildActionItem(Icons.delete_outline_rounded, 'Hapus Produk', Colors.redAccent, () async {
              Navigator.pop(context);
              final confirm = await _confirmDelete();
              if (confirm) _deleteProduct(p.id);
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color),
      ),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: textDark)),
    );
  }

  void _openEditProduct(Product p) {
    nameCtrl.text = p.name;
    priceCtrl.text = p.price.toString();
    selectedCategory = p.category;
    imagePath = p.imagePath;
    scannedBarcode = p.barcode;
    _showProductForm(isEdit: true, productId: p.id);
  }

  void _showScanBarcode() {
    isScanning = false;
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode', style: TextStyle(fontWeight: FontWeight.w900)), backgroundColor: primaryColor),
      body: MobileScanner(onDetect: (cap) {
        if (isScanning) return;
        final code = cap.barcodes.first.rawValue;
        if (code != null) {
          isScanning = true;
          Navigator.pop(context);
          _handleScanned(code);
        }
      }),
    )));
  }

  void _handleScanned(String code) {
    final existing = products.where((p) => p.barcode == code).toList();
    if (existing.isNotEmpty) {
      _openEditProduct(existing.first);
      _showToast("Produk ditemukan!");
      return;
    }
    nameCtrl.clear(); priceCtrl.clear(); imagePath = '';
    scannedBarcode = code;
    _showProductForm();
  }

  void _showProductForm({bool isEdit = false, String? productId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModal) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 24),
                Text(isEdit ? 'Ubah Informasi' : 'Lengkapi Produk', 
                  style: TextStyle(color: textDark, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 24),
                
                GestureDetector(
                  onTap: () => _pickImage(setModal),
                  child: Container(
                    height: 160, width: double.infinity,
                    decoration: BoxDecoration(
                      color: bgColor, borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: imagePath.isEmpty
                        ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt_rounded, color: primaryColor, size: 40), const SizedBox(height: 8), Text('Ketuk untuk Foto', style: TextStyle(color: textLight, fontWeight: FontWeight.w700))])
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(24), 
                            child: Image.file(
                              File(imagePath), 
                              fit: BoxFit.cover,
                              key: ValueKey(imagePath),
                            )),
                  ),
                ),
                
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedCategory.isEmpty ? null : selectedCategory,
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                  onChanged: (v) => setModal(() => selectedCategory = v ?? ''),
                  decoration: _inputDeco('Kategori Produk', Icons.grid_view_rounded),
                ),
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: _inputDeco('Nama Produk', Icons.edit_note_rounded)),
                const SizedBox(height: 16),
                TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: _inputDeco('Harga Jual (Rp)', Icons.local_offer_rounded)),
                const SizedBox(height: 24),
                _buildBarcodeStatus(),
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity, height: 60,
                  child: ElevatedButton(
                    onPressed: () => _saveProcess(isEdit, productId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: Text(isEdit ? 'SIMPAN PERUBAHAN' : 'KONFIRMASI & SIMPAN', 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= HELPERS & PROCESSORS =================

  void _saveProcess(bool isEdit, String? productId) async {
    if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty || selectedCategory.isEmpty) {
      _showToast("Mohon lengkapi semua data", isError: true);
      return;
    }

    final newProduct = Product(
      id: isEdit ? productId! : DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameCtrl.text,
      price: int.tryParse(priceCtrl.text) ?? 0,
      imagePath: imagePath,
      barcode: scannedBarcode,
      category: selectedCategory,
    );

    setState(() {
      if (isEdit) {
        final idx = products.indexWhere((p) => p.id == productId);
        if (idx != -1) products[idx] = newProduct;
      } else {
        products.add(newProduct);
      }
    });

    await StorageService.saveProducts(products);
    
    // Tutup modal dulu baru clear form
    if (mounted) Navigator.pop(context);
    
    nameCtrl.clear(); 
    priceCtrl.clear(); 
    imagePath = '';
    
    _initData(); // Refresh data dari storage untuk sinkronisasi
    _showToast(isEdit ? "Produk diperbarui" : "Produk berhasil disimpan");
  }

  Future<bool> _confirmDelete() async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Produk?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Data produk ini akan dihapus permanen dari katalog.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Batal', style: TextStyle(color: textLight, fontWeight: FontWeight.w700))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ) ?? false;
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      labelText: hint,
      prefixIcon: Icon(icon, color: primaryColor, size: 22),
      filled: true, fillColor: bgColor,
      labelStyle: TextStyle(color: textLight, fontWeight: FontWeight.w600),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: primaryColor, width: 2)),
    );
  }

  Widget _buildBarcodeStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        Icon(Icons.qr_code_2_rounded, color: primaryColor), 
        const SizedBox(width: 12), 
        Text('Barcode: $scannedBarcode', style: TextStyle(fontWeight: FontWeight.w900, color: primaryColor, letterSpacing: 1))
      ]),
    );
  }

  Future<void> _pickImage(StateSetter setModal) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img != null) {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_${p.basename(img.path)}";
      final saved = await File(img.path).copy('${dir.path}/$fileName');
      
      // Update state di dalam modal
      setModal(() => imagePath = saved.path);
      // Update state utama (untuk jaga-jaga)
      setState(() => imagePath = saved.path);
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Kategori Baru', style: TextStyle(fontWeight: FontWeight.w900)),
        content: TextField(controller: categoryCtrl, decoration: _inputDeco('Contoh: Minuman', Icons.category_rounded)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: TextStyle(color: textLight, fontWeight: FontWeight.w700))),
          ElevatedButton(
            onPressed: () { _addCategory(categoryCtrl.text); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(backgroundColor: textDark, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey.shade200),
            const SizedBox(height: 16),
            Text('Katalog kosong di kategori ini', style: TextStyle(color: textLight, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}