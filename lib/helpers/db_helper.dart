import 'package:praktikum_mp_04sife02_ammar/models/user_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DbHelper{

  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if(_database != null) return _database!;
    _database = await _initDB('app_praktikum.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 1, 
      onCreate: _createDB
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');
  }

  Future<int> registerUser(UserModel user) async {
    final db = await  instance.database;

    // validator apa username sudah terdaftar?
    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [user.username],
    );

    if(existing.isNotEmpty){
      throw Exception('Username "${user.username}" sudah digunakan.');
    }

    return await db.insert(
      'users',
      user.toMap(),
    );
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

  // Close database
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }

}
