import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _db;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initdb();
    return _db!;
  }

  Future<Database> _initdb() async {
    String path = join(await getDatabasesPath(), 'crud_app.db');
    return openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute(
          "create table users(id integer primary key autoincrement,name text,age integer,email text)");
    });
  }

  Future<List<Map<String, dynamic>>> getUser() async {
    final db = await database;
    return db.query('users');
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return db.insert('users', user);
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    return db.update('users', user, whereArgs: [user['id']], where: 'id=?');
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return db.delete('users', whereArgs: [id], where: 'id=?');
  }
}
