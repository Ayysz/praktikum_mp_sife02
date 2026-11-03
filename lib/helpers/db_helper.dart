import 'package:praktikum_mp_04sife02_ammar/models/task_model.dart';
import 'package:praktikum_mp_04sife02_ammar/models/user_model.dart';
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
      version: 4,
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
  }

  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    await _ensureTablesExist(db);
  }

  Future _onOpenDB(Database db) async {
    await _ensureTablesExist(db);
  }

  /// Memastikan tabel `tugas` dan `users` selalu ada dan memiliki struktur lengkap
  Future _ensureTablesExist(Database db) async {
    // 1. Buat tabel jika belum ada
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

    // 2. Pastikan kolom user_id ada jika database lama belum memilikinya
    try {
      await db.execute('ALTER TABLE tugas ADD COLUMN user_id TEXT;');
    } catch (_) {
      // Kolom sudah ada, abaikan
    }
  }

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

  // Create task
  Future<void> createTask(TaskModel task) async {
    final db = await instance.database;
    await db.insert('tugas', task.toMap());
  }

  // Update task
  Future<void> updateTask(TaskModel task) async {
    final db = await instance.database;
    await db.update(
      'tugas',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete task
  Future<void> deleteTask(int id) async {
    final db = await instance.database;
    await db.delete('tugas', where: 'id = ?', whereArgs: [id]);
  }

  // Close database
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
