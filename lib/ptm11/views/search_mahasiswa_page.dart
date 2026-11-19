// File: lib/ptm11/views/search_mahasiswa_page.dart
// View untuk modul MVVM SearchView Pertemuan 11

import 'package:flutter/material.dart';
import '../models/mahasiswa_model.dart';
import '../viewmodels/mahasiswa_viewmodel.dart';

class SearchMahasiswaPage extends StatefulWidget {
  const SearchMahasiswaPage({super.key});

  @override
  State<SearchMahasiswaPage> createState() => _SearchMahasiswaPageState();
}

class _SearchMahasiswaPageState extends State<SearchMahasiswaPage> {
  late final MahasiswaViewModel _viewModel;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _viewModel = MahasiswaViewModel();
    _searchController = TextEditingController();
    _viewModel.fetchMahasiswa();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _showAddMahasiswaBottomSheet() {
    final formKey = GlobalKey<FormState>();
    final nimController = TextEditingController();
    final namaController = TextEditingController();
    final jurusanController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> handleSave() async {
              if (!formKey.currentState!.validate()) return;

              setModalState(() => isSaving = true);

              final success = await _viewModel.addMahasiswa(
                nim: nimController.text,
                nama: namaController.text,
                jurusan: jurusanController.text,
              );

              if (!mounted) return;

              if (success) {
                Navigator.pop(bottomSheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mahasiswa baru berhasil disimpan ke SQLite!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                setModalState(() => isSaving = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_viewModel.errorMessage ?? 'Gagal menyimpan mahasiswa'),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }

            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.person_add_rounded,
                            color: Colors.indigo.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Tambah Mahasiswa Baru',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nimController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'NIM (Nomor Induk Mahasiswa)',
                        hintText: 'Contoh: 241011750010',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'NIM wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: namaController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        hintText: 'Contoh: Ahmad Fauzi',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: jurusanController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Jurusan / Program Studi',
                        hintText: 'Contoh: Sistem Informasi',
                        prefixIcon: Icon(Icons.school_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Jurusan wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSaving ? null : handleSave,
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan Mahasiswa',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(MahasiswaModel mhs) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Mahasiswa?'),
        content: Text('Apakah Anda yakin ingin menghapus "${mhs.nama}" (${mhs.nim})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mhs.id != null) {
      final success = await _viewModel.deleteMahasiswa(mhs.id!);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data "${mhs.nama}" berhasil dihapus'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'MVVM - Search Mahasiswa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Segarkan Data',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _viewModel.fetchMahasiswa();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. SearchBar Header (SearchView Widget)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SearchBar(
                  controller: _searchController,
                  hintText: 'Cari nama, NIM, atau jurusan...',
                  leading: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.search, color: Colors.indigo),
                  ),
                  trailing: [
                    ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, _) {
                        if (_viewModel.isSearching) {
                          return IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _viewModel.clearSearch();
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                  onChanged: (value) {
                    _viewModel.search(value);
                  },
                  elevation: const WidgetStatePropertyAll(1.0),
                  backgroundColor: const WidgetStatePropertyAll(Color(0xFFF1F5F9)),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _viewModel.isSearching
                              ? 'Ditemukan: ${_viewModel.filteredCount} dari ${_viewModel.totalCount}'
                              : 'Total Mahasiswa: ${_viewModel.totalCount}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.indigo.shade200),
                          ),
                          child: const Text(
                            'SQLite • MVVM',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 2. Daftar Mahasiswa (Reaktif via ListenableBuilder)
          Expanded(
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                if (_viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_viewModel.errorMessage != null && _viewModel.mahasiswaList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(
                            _viewModel.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => _viewModel.fetchMahasiswa(),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (_viewModel.mahasiswaList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _viewModel.isSearching
                                ? Icons.search_off_rounded
                                : Icons.people_outline_rounded,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _viewModel.isSearching
                                ? 'Tidak ada mahasiswa yang cocok dengan "${_viewModel.searchQuery}"'
                                : 'Belum ada data mahasiswa di SQLite.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (_viewModel.isSearching) ...[
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                _viewModel.clearSearch();
                              },
                              icon: const Icon(Icons.restore),
                              label: const Text('Tampilkan Semua'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  itemCount: _viewModel.mahasiswaList.length,
                  itemBuilder: (context, index) {
                    final mhs = _viewModel.mahasiswaList[index];
                    final initial = mhs.nama.isNotEmpty ? mhs.nama[0].toUpperCase() : '?';

                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade100,
                          foregroundColor: Colors.indigo.shade800,
                          child: Text(
                            initial,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          mhs.nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'NIM: ${mhs.nim}\nJurusan: ${mhs.jurusan}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: 'Hapus Mahasiswa',
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _confirmDelete(mhs),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: _showAddMahasiswaBottomSheet,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Tambah Mahasiswa'),
      ),
    );
  }
}
