import 'package:flutter/material.dart';
import '../models/product_model.dart';

class SearchOptionMenuPage extends StatefulWidget {
  const SearchOptionMenuPage({super.key});

  @override
  State<SearchOptionMenuPage> createState() => _SearchOptionMenuPageState();
}

class _SearchOptionMenuPageState extends State<SearchOptionMenuPage> {
  // Master list & list yang telah terfilter
  late List<ProductModel> _allProducts;
  late List<ProductModel> _filteredProducts;

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _currentSort = 'default';

  @override
  void initState() {
    super.initState();
    _allProducts = List.from(ProductModel.initialData);
    _filteredProducts = List.from(_allProducts);
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterData);
    _searchController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // 1. FILTERING DATA BERDASARKAN SEARCH VIEW & KATEGORI
  // ===========================================================================
  void _filterData() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final matchesQuery = product.nama.toLowerCase().contains(query) ||
            product.kategori.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == 'Semua' ||
            product.kategori == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();

      _applySorting();
    });
  }

  void _applySorting() {
    if (_currentSort == 'name_asc') {
      _filteredProducts.sort((a, b) => a.nama.compareTo(b.nama));
    } else if (_currentSort == 'price_asc') {
      _filteredProducts.sort((a, b) => a.harga.compareTo(b.harga));
    } else if (_currentSort == 'price_desc') {
      _filteredProducts.sort((a, b) => b.harga.compareTo(a.harga));
    }
  }

  // ===========================================================================
  // 2. DIALOG TAMBAH DATA (OPTION MENU ACTION: TAMBAH DATA)
  // ===========================================================================
  void _showAddProductDialog() {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final hargaController = TextEditingController();
    final stokController = TextEditingController();
    String kategori = 'Elektronik';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.add_shopping_cart, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Tambah Produk Baru'),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Produk',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: kategori,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          prefixIcon: Icon(Icons.category_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Elektronik', child: Text('Elektronik')),
                          DropdownMenuItem(value: 'Aksesoris', child: Text('Aksesoris')),
                          DropdownMenuItem(value: 'Audio', child: Text('Audio')),
                          DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => kategori = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: hargaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Harga (Rp)',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Harga wajib diisi';
                          if (int.tryParse(v.trim()) == null) return 'Masukkan angka valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: stokController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Stok',
                          prefixIcon: Icon(Icons.numbers),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Stok wajib diisi';
                          if (int.tryParse(v.trim()) == null) return 'Masukkan angka valid';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final newProduct = ProductModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        nama: namaController.text.trim(),
                        kategori: kategori,
                        harga: int.parse(hargaController.text.trim()),
                        stok: int.parse(stokController.text.trim()),
                      );

                      setState(() {
                        _allProducts.insert(0, newProduct);
                        _filterData();
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Produk "${newProduct.nama}" berhasil ditambahkan!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // 3. DIALOG INFORMASI APLIKASI (OPTION MENU ACTION: INFO)
  // ===========================================================================
  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text('Informasi Aplikasi'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pertemuan 12 - Mobile Programming',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('Fitur yang diimplementasikan:'),
              SizedBox(height: 4),
              Text('• Search View: Widget SearchBar untuk pencarian kata kunci real-time.'),
              Text('• Option Menu: Widget PopupMenuButton pada AppBar dengan beragam aksi.'),
              SizedBox(height: 12),
              Text(
                'Versi: 1.0.12\nFramework: Flutter 3.x (Material 3)',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 4. RESET DATA & DIALOG KELUAR
  // ===========================================================================
  void _resetData() {
    setState(() {
      _allProducts = List.from(ProductModel.initialData);
      _searchController.clear();
      _selectedCategory = 'Semua';
      _currentSort = 'default';
      _filterData();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data katalog produk telah di-reset ke kondisi awal.'),
      ),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari halaman modul Pertemuan 12?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  // Helper format rupiah
  String _formatRupiah(int nominal) {
    return 'Rp ${nominal.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Semua', 'Elektronik', 'Aksesoris', 'Audio', 'Lainnya'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog & Search View'),
        actions: [
          // ===================================================================
          // WIDGET OPTION MENU: PopupMenuButton
          // ===================================================================
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Option Menu',
            onSelected: (value) {
              switch (value) {
                case 'tambah':
                  _showAddProductDialog();
                  break;
                case 'sort_name':
                  setState(() {
                    _currentSort = 'name_asc';
                    _applySorting();
                  });
                  break;
                case 'sort_price_asc':
                  setState(() {
                    _currentSort = 'price_asc';
                    _applySorting();
                  });
                  break;
                case 'sort_price_desc':
                  setState(() {
                    _currentSort = 'price_desc';
                    _applySorting();
                  });
                  break;
                case 'info':
                  _showAppInfoDialog();
                  break;
                case 'reset':
                  _resetData();
                  break;
                case 'keluar':
                  _confirmExit();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'tambah',
                child: ListTile(
                  leading: Icon(Icons.add_circle_outline, color: Colors.blue),
                  title: Text('Tambah Data'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'sort_name',
                child: ListTile(
                  leading: Icon(Icons.sort_by_alpha),
                  title: Text('Urutkan Nama (A-Z)'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'sort_price_asc',
                child: ListTile(
                  leading: Icon(Icons.arrow_upward),
                  title: Text('Harga Termurah'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'sort_price_desc',
                child: ListTile(
                  leading: Icon(Icons.arrow_downward),
                  title: Text('Harga Tertinggi'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'info',
                child: ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.teal),
                  title: Text('Informasi Aplikasi'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'reset',
                child: ListTile(
                  leading: Icon(Icons.refresh, color: Colors.orange),
                  title: Text('Reset Data'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuItem<String>(
                value: 'keluar',
                child: ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.red),
                  title: Text('Keluar', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ===================================================================
          // WIDGET SEARCH VIEW: SearchBar (Material 3)
          // ===================================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Cari produk atau kategori...',
              leading: const Icon(Icons.search, color: Colors.blue),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  ),
              ],
              elevation: const WidgetStatePropertyAll(1),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // Horizontal Filter Chip untuk Kategori
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                        _filterData();
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Info total produk
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Menampilkan ${_filteredProducts.length} produk',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_currentSort != 'default')
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentSort = 'default';
                        _filterData();
                      });
                    },
                    child: const Text(
                      'Hapus Urutan',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ===================================================================
          // DAFTAR PRODUK (ListView)
          // ===================================================================
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada produk yang cocok dengan "${_searchController.text}"',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _selectedCategory = 'Semua');
                            _filterData();
                          },
                          child: const Text('Reset Pencarian'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final item = _filteredProducts[index];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            foregroundColor: Colors.blue.shade700,
                            child: Icon(
                              item.kategori == 'Elektronik'
                                  ? Icons.laptop_chromebook
                                  : item.kategori == 'Audio'
                                      ? Icons.headphones
                                      : Icons.devices_other,
                            ),
                          ),
                          title: Text(
                            item.nama,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.kategori,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Stok: ${item.stok}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _formatRupiah(item.harga),
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            tooltip: 'Hapus produk',
                            onPressed: () {
                              setState(() {
                                _allProducts.removeWhere((p) => p.id == item.id);
                                _filterData();
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Produk "${item.nama}" dihapus.'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
