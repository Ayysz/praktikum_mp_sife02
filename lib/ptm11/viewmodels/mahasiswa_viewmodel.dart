// File: lib/ptm11/viewmodels/mahasiswa_viewmodel.dart
// ViewModel untuk modul SearchView MVVM Pertemuan 11

import 'package:flutter/foundation.dart';
import '../../helpers/db_helper.dart';
import '../models/mahasiswa_model.dart';

class MahasiswaViewModel extends ChangeNotifier {
  final DbHelper _dbHelper = DbHelper.instance;

  List<MahasiswaModel> _allMahasiswa = [];
  List<MahasiswaModel> _filteredMahasiswa = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  List<MahasiswaModel> get mahasiswaList => _filteredMahasiswa;
  int get totalCount => _allMahasiswa.length;
  int get filteredCount => _filteredMahasiswa.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isSearching => _searchQuery.trim().isNotEmpty;

  /// 1. Mengambil data mahasiswa dari database SQLite lokal
  Future<void> fetchMahasiswa() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allMahasiswa = await _dbHelper.getAllMahasiswa();
      _applyFilter();
    } catch (e) {
      _errorMessage = 'Gagal memuat data mahasiswa: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 2. Melakukan filter/search data berdasarkan query (Nama atau NIM)
  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  /// 3. Mengosongkan query pencarian
  void clearSearch() {
    _searchQuery = '';
    _applyFilter();
    notifyListeners();
  }

  /// Logika internal filter pencarian (Case-insensitive)
  void _applyFilter() {
    if (_searchQuery.trim().isEmpty) {
      _filteredMahasiswa = List.from(_allMahasiswa);
    } else {
      final q = _searchQuery.trim().toLowerCase();
      _filteredMahasiswa = _allMahasiswa.where((mhs) {
        final matchNama = mhs.nama.toLowerCase().contains(q);
        final matchNim = mhs.nim.toLowerCase().contains(q);
        final matchJurusan = mhs.jurusan.toLowerCase().contains(q);
        return matchNama || matchNim || matchJurusan;
      }).toList();
    }
  }

  /// 4. Menambahkan data mahasiswa baru ke SQLite
  Future<bool> addMahasiswa({
    required String nim,
    required String nama,
    required String jurusan,
  }) async {
    _errorMessage = null;
    try {
      final newMhs = MahasiswaModel(
        nim: nim.trim(),
        nama: nama.trim(),
        jurusan: jurusan.trim(),
      );

      await _dbHelper.insertMahasiswa(newMhs);
      // Refresh data dari database
      await fetchMahasiswa();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// 5. Menghapus data mahasiswa dari SQLite
  Future<bool> deleteMahasiswa(int id) async {
    _errorMessage = null;
    try {
      await _dbHelper.deleteMahasiswa(id);
      await fetchMahasiswa();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus data: $e';
      notifyListeners();
      return false;
    }
  }
}
