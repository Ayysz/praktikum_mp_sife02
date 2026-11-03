// File: lib/ptm8/order_page.dart
// Dashboard Kitchen Order Management untuk Chef menggunakan REST API (package:http) + Supabase

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../navbar.dart';
import 'supabase_config.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // Filter status aktif ('ALL', 'PENDING', 'COOKING', 'DONE')
  String _activeFilter = 'ALL';

  // Controller form tambah order
  final _formKey = GlobalKey<FormState>();
  final _menuController = TextEditingController();
  final _tableController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initAndFetch();
  }

  Future<void> _initAndFetch() async {
    try {
      await SupabaseConfig.initialize();
    } catch (_) {}
    if (mounted) {
      fetchOrders();
    }
  }

  @override
  void dispose() {
    _menuController.dispose();
    _tableController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String get _accessToken =>
      Supabase.instance.client.auth.currentSession?.accessToken ??
      SupabaseConfig.supabaseAnonKey;

  User? get _currentUser => Supabase.instance.client.auth.currentUser;

  // ===========================================================================
  // 1. READ (GET): Mengambil daftar pesanan dapur
  // ===========================================================================
  Future<void> fetchOrders() async {
    final token = _accessToken;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // FIFO: Urutkan order terlama di atas agar dikerjakan duluan
      final uri = Uri.parse(
        '${SupabaseConfig.ordersEndpoint}?select=*&order=created_at.asc',
      );

      final response = await http.get(
        uri,
        headers: SupabaseConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> decodedJson = jsonDecode(response.body);
        setState(() {
          _orders = decodedJson
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        });
      } else {
        setState(() {
          _errorMessage =
              'Gagal memuat pesanan dapur (Kode HTTP: ${response.statusCode})';
        });
      }
    } on SocketException {
      setState(() {
        _errorMessage = 'Koneksi terputus. Periksa jaringan internet Anda.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ===========================================================================
  // 2. CREATE (POST): Menambahkan pesanan baru ke dapur
  // ===========================================================================
  Future<void> addOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final token = _accessToken;
    final user = _currentUser;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final uri = Uri.parse(SupabaseConfig.ordersEndpoint);

      final Map<String, dynamic> bodyData = {
        'menu_name': _menuController.text.trim(),
        'table_number': _tableController.text.trim(),
        'notes': _notesController.text.trim(),
        'status': 'PENDING',
      };
      if (user != null) {
        bodyData['chef_id'] = user.id;
      }

      final response = await http.post(
        uri,
        headers: SupabaseConfig.getHeaders(token),
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 201) {
        final List<dynamic> createdList = jsonDecode(response.body);
        final newOrder = Map<String, dynamic>.from(createdList.first as Map);

        setState(() {
          _orders.add(newOrder);
          _menuController.clear();
          _tableController.clear();
          _notesController.clear();
        });

        _showSnackBar('Pesanan baru berhasil dikirim ke dapur! 🍳');
      } else {
        _showSnackBar(
          'Gagal menambah pesanan (Kode: ${response.statusCode})',
          isError: true,
        );
      }
    } on SocketException {
      _showSnackBar('Koneksi internet terputus saat menyimpan.', isError: true);
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ===========================================================================
  // 3. UPDATE STATUS (PATCH): Mengubah status PENDING -> COOKING -> DONE
  // ===========================================================================
  Future<void> updateOrderStatus(Map<String, dynamic> order, String newStatus) async {
    final token = _accessToken;
    final int id = order['id'] as int;

    try {
      final uri = Uri.parse('${SupabaseConfig.ordersEndpoint}?id=eq.$id');

      final response = await http.patch(
        uri,
        headers: SupabaseConfig.getHeaders(token),
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          final index = _orders.indexWhere((item) => item['id'] == id);
          if (index != -1) {
            _orders[index]['status'] = newStatus;
          }
        });

        String msg = newStatus == 'COOKING'
            ? 'Pesanan sedang mulai dimasak! 👨‍🍳'
            : 'Pesanan telah selesai! Siap disajikan 🍽️';
        _showSnackBar(msg);
      } else {
        _showSnackBar(
          'Gagal memperbarui status (Kode: ${response.statusCode})',
          isError: true,
        );
      }
    } on SocketException {
      _showSnackBar('Tidak ada koneksi internet.', isError: true);
    } catch (e) {
      _showSnackBar('Gagal update status: $e', isError: true);
    }
  }

  // ===========================================================================
  // 4. DELETE (DELETE): Menghapus pesanan dari antrian/arsip
  // ===========================================================================
  Future<void> deleteOrder(int id) async {
    final token = _accessToken;

    try {
      final uri = Uri.parse('${SupabaseConfig.ordersEndpoint}?id=eq.$id');

      final response = await http.delete(
        uri,
        headers: SupabaseConfig.getHeaders(token),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _orders.removeWhere((item) => item['id'] == id);
        });
        _showSnackBar('Pesanan telah dihapus dari sistem.');
      } else {
        _showSnackBar(
          'Gagal menghapus pesanan (Kode: ${response.statusCode})',
          isError: true,
        );
      }
    } on SocketException {
      _showSnackBar('Tidak ada koneksi internet.', isError: true);
    } catch (e) {
      _showSnackBar('Gagal menghapus pesanan: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFB91C1C) : const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hitung ringkasan order
    final pendingCount =
        _orders.where((item) => item['status'] == 'PENDING').length;
    final cookingCount =
        _orders.where((item) => item['status'] == 'COOKING').length;
    final doneCount =
        _orders.where((item) => item['status'] == 'DONE').length;

    // Filter daftar yang ditampilkan
    final filteredOrders = _activeFilter == 'ALL'
        ? _orders
        : _orders.where((item) => item['status'] == _activeFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Navigator.canPop(context)
            ? null
            : IconButton(
                tooltip: 'Menu Utama',
                icon: const Icon(Icons.dashboard_outlined, color: Color(0xFF1E293B)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Navbar()),
                  );
                },
              ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.restaurant, color: Color(0xFFEA580C), size: 20),
                SizedBox(width: 8),
                Text(
                  'Kitchen Order Dapur',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            Text(
              _currentUser?.email ?? 'Mode Terbuka (Tanpa Login)',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Pesanan',
            onPressed: _isLoading ? null : fetchOrders,
            icon: const Icon(Icons.refresh, color: Color(0xFF1E293B)),
          ),
          if (_currentUser != null)
            IconButton(
              tooltip: 'Keluar Akun Chef',
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (mounted) fetchOrders();
              },
              icon: const Icon(Icons.logout, color: Color(0xFFB91C1C)),
            ),
        ],
      ),
      body: Column(
        children: [
          // 1. Form Tambah Pesanan Baru
          _buildAddOrderForm(),

          // 2. Baris Counter & Filter Tab
          _buildSummaryAndFilters(
            total: _orders.length,
            pending: pendingCount,
            cooking: cookingCount,
            done: doneCount,
          ),

          // 3. Konten Daftar Pesanan
          Expanded(
            child: _buildOrderList(filteredOrders),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOrderForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _menuController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Menu Makanan / Minuman',
                      hintText: 'Contoh: Nasi Goreng Spesial',
                      prefixIcon: Icon(Icons.lunch_dining_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Nama menu wajib diisi';
                      }
                      if (v.trim().length < 3) {
                        return 'Minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _tableController,
                    decoration: const InputDecoration(
                      labelText: 'Meja / Area',
                      hintText: 'Meja 5 / Take Away',
                      prefixIcon: Icon(Icons.table_restaurant_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Nomor meja wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Khusus (Opsional)',
                      hintText: 'Contoh: Tidak pedas, kuah pisah',
                      prefixIcon: Icon(Icons.note_alt_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                    ),
                    onPressed: _isSubmitting ? null : addOrder,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add),
                    label: Text(_isSubmitting ? 'Mengirim...' : 'Kirim Order'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryAndFilters({
    required int total,
    required int pending,
    required int cooking,
    required int done,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Semua ($total)',
              value: 'ALL',
              color: const Color(0xFF475569),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Antrian ($pending)',
              value: 'PENDING',
              color: const Color(0xFFD97706),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Dimasak ($cooking)',
              value: 'COOKING',
              color: const Color(0xFF0284C7),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Selesai ($done)',
              value: 'DONE',
              color: const Color(0xFF16A34A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required Color color,
  }) {
    final isSelected = _activeFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withValues(alpha: 0.18),
      side: BorderSide(
        color: isSelected ? color : const Color(0xFFCBD5E1),
      ),
      labelStyle: TextStyle(
        color: isSelected ? color : const Color(0xFF475569),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      onSelected: (_) {
        setState(() {
          _activeFilter = value;
        });
      },
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> items) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFEA580C)),
            SizedBox(height: 12),
            Text('Mengambil pesanan dapur dari Supabase API...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: Color(0xFFB91C1C),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFB91C1C)),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: fetchOrders,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: fetchOrders,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 80),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.soup_kitchen_outlined,
                    size: 64,
                    color: Colors.black26,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Tidak ada pesanan pada filter ini.\nSemua orderan beres!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black45),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final order = items[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = (order['status'] ?? 'PENDING') as String;
    final id = order['id'] as int;
    final menuName = order['menu_name']?.toString() ?? '-';
    final tableNumber = order['table_number']?.toString() ?? '-';
    final notes = order['notes']?.toString() ?? '';

    Color badgeColor;
    Color badgeBg;
    String badgeText;
    IconData statusIcon;

    if (status == 'COOKING') {
      badgeColor = const Color(0xFF0284C7);
      badgeBg = const Color(0xFFE0F2FE);
      badgeText = 'SEDANG DIMASAK';
      statusIcon = Icons.outdoor_grill_outlined;
    } else if (status == 'DONE') {
      badgeColor = const Color(0xFF16A34A);
      badgeBg = const Color(0xFFDCFCE7);
      badgeText = 'SELESAI';
      statusIcon = Icons.check_circle_outline;
    } else {
      badgeColor = const Color(0xFFD97706);
      badgeBg = const Color(0xFFFEF3C7);
      badgeText = 'MENUNGGU';
      statusIcon = Icons.schedule;
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: status == 'COOKING'
              ? const Color(0xFFBAE6FD)
              : const Color(0xFFE2E8F0),
          width: status == 'COOKING' ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Atas: Badge Status & Nomor Meja
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: badgeColor),
                      const SizedBox(width: 4),
                      Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.table_restaurant,
                          size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        tableNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Nama Menu
            Text(
              menuName,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                decoration:
                    status == 'DONE' ? TextDecoration.lineThrough : null,
                color: status == 'DONE'
                    ? const Color(0xFF64748B)
                    : const Color(0xFF0F172A),
              ),
            ),

            // Catatan
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFEF3C7)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: Color(0xFFB45309)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Catatan: $notes',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 24),

            // Tombol Aksi Sesuai State
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'PENDING') ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                    ),
                    onPressed: () => updateOrderStatus(order, 'COOKING'),
                    icon: const Icon(Icons.outdoor_grill, size: 18),
                    label: const Text('Mulai Masak'),
                  ),
                ] else if (status == 'COOKING') ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                    ),
                    onPressed: () => updateOrderStatus(order, 'DONE'),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Pesanan Selesai ✓'),
                  ),
                ] else if (status == 'DONE') ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB91C1C),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                    ),
                    onPressed: () => _confirmDelete(id),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus Order'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pesanan?'),
        content: const Text(
          'Pesanan ini sudah selesai dan akan dihapus permanen dari antrian dapur.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              deleteOrder(id);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
