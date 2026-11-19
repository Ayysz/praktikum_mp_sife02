import 'package:praktikum_mp_04sife02_ammar/models/task_model.dart';
import 'package:praktikum_mp_04sife02_ammar/models/user_model.dart';
import 'package:praktikum_mp_04sife02_ammar/ptm11/models/mahasiswa_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_praktikum.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
      onOpen: _onOpenDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS tugas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        judul TEXT NOT NULL,
        isi TEXT NOT NULL,
        is_completed BOOLEAN NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS mahasiswa (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nim TEXT NOT NULL UNIQUE,
        nama TEXT NOT NULL,
        jurusan TEXT NOT NULL
      );
    ''');

    await _seedInitialMahasiswa(db);
  }

  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    await _ensureTablesExist(db);
  }

  Future _onOpenDB(Database db) async {
    await _ensureTablesExist(db);
  }

  /// Memastikan seluruh tabel yang dibutuhkan aplikasi selalu ada dan lengkap (Anti-Crash Migration)
  Future _ensureTablesExist(Database db) async {
    // 1. Pastikan tabel users ada
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      );
    ''');

    // 2. Pastikan tabel tugas ada & kolom user_id tersedia
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tugas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        judul TEXT NOT NULL,
        isi TEXT NOT NULL,
        is_completed BOOLEAN NOT NULL
      );
    ''');

    try {
      await db.execute('ALTER TABLE tugas ADD COLUMN user_id TEXT;');
    } catch (_) {
      // Kolom sudah ada
    }

    // 3. Pastikan tabel mahasiswa (Pertemuan 11 - MVVM) ada
    await db.execute('''
      CREATE TABLE IF NOT EXISTS mahasiswa (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nim TEXT NOT NULL UNIQUE,
        nama TEXT NOT NULL,
        jurusan TEXT NOT NULL
      );
    ''');

    // 4. Auto-seed data awal jika tabel mahasiswa masih kosong
    await _seedInitialMahasiswa(db);
  }

  /// Memasukkan data awal contoh mahasiswa jika tabel belum ada isinya
  Future<void> _seedInitialMahasiswa(Database db) async {
    try {
      final countResult = await db.rawQuery('SELECT COUNT(*) as total FROM mahasiswa');
      final int total = Sqflite.firstIntValue(countResult) ?? 0;

      if (total == 0) {
        final initialList = [
          {'nim': '241011750161', 'nama': 'Ammar (Mahasiswa)', 'jurusan': 'Sistem Informasi'},
          {'nim': '241011750002', 'nama': 'Budi Santoso', 'jurusan': 'Teknik Informatika'},
          {'nim': '241011750003', 'nama': 'Citra Kirana', 'jurusan': 'Sistem Informasi'},
          {'nim': '241011750004', 'nama': 'Dedi Prasetyo', 'jurusan': 'Teknik Elektro'},
          {'nim': '241011750005', 'nama': 'Eka Rahmawati', 'jurusan': 'Manajemen Informatika'},
          {'nim': '241011750006', 'nama': 'Fajar Hidayat', 'jurusan': 'Sistem Informasi'},
        ];

        for (final mhs in initialList) {
          await db.insert(
            'mahasiswa',
            mhs,
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    } catch (_) {
      // Abaikan jika database masih dalam inisialisasi transisi
    }
  }

  // =========================================================================
  // CRUD USERS
  // =========================================================================
  Future<int> registerUser(UserModel user) async {
    final db = await instance.database;

    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [user.username],
    );

    if (existing.isNotEmpty) {
      throw Exception('Username "${user.username}" sudah digunakan.');
    }

    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> loginUser(String username, String password) async {
    final db = await instance.database;

    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await instance.database;
    final result = await db.query('users');
    return result.map((json) => UserModel.fromMap(json)).toList();
  }

  // =========================================================================
  // CRUD TUGAS
  // =========================================================================
  Future<List<TaskModel>> getAllTask([String? userId]) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result;
    if (userId != null && userId.isNotEmpty) {
      result = await db.query(
        'tugas',
        where: 'user_id = ? OR user_id IS NULL',
        whereArgs: [userId],
      );
    } else {
      result = await db.query('tugas');
    }
    return result.map((json) => TaskModel.fromMap(json)).toList();
  }

  Future<void> createTask(TaskModel task) async {
    final db = await instance.database;
    await db.insert('tugas', task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await instance.database;
    await db.update(
      'tugas',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<void> deleteTask(int id) async {
    final db = await instance.database;
    await db.delete('tugas', where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================================
  // CRUD MAHASISWA (PERTEMUAN 11 - MVVM)
  // =========================================================================
  Future<List<MahasiswaModel>> getAllMahasiswa() async {
    final db = await instance.database;
    final result = await db.query('mahasiswa', orderBy: 'id DESC');
    return result.map((json) => MahasiswaModel.fromMap(json)).toList();
  }

  Future<int> insertMahasiswa(MahasiswaModel mahasiswa) async {
    final db = await instance.database;

    // Cek apakah NIM sudah terdaftar
    final existing = await db.query(
      'mahasiswa',
      where: 'nim = ?',
      whereArgs: [mahasiswa.nim.trim()],
    );

    if (existing.isNotEmpty) {
      throw Exception('NIM "${mahasiswa.nim}" sudah terdaftar.');
    }

    return await db.insert('mahasiswa', mahasiswa.toMap());
  }

  Future<int> deleteMahasiswa(int id) async {
    final db = await instance.database;
    return await db.delete(
      'mahasiswa',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
