import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/misi_model.dart';
import '../model/poin_model.dart';
import '../model/user_model.dart';

class EvergreenDb {
  static final EvergreenDb _instance = EvergreenDb._internal();
  factory EvergreenDb() => _instance;
  EvergreenDb._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "evergreen.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {

        await db.execute('''
          CREATE TABLE misi(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT,
            deskripsi TEXT,
            poin INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE poin(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            total INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE user(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            email TEXT,
            password TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertMisi(Misi misi) async {
    final db = await database;
    return await db.insert("misi", misi.toMap());
  }

  Future<List<Misi>> getAllMisi() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("misi");
    return maps.map((e) => Misi.fromMap(e)).toList();
  }

  Future<void> clearMisi() async {
    final db = await database;
    await db.delete("misi");
  }


  Future<int> insertPoin(Poin poin) async {
    final db = await database;
    return await db.insert("poin", poin.toMap());
  }

  Future<int> updatePoin(int id, int total) async {
    final db = await database;
    return await db.update(
      "poin",
      {"total": total},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<int> getTotalPoin() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query("poin");
    if (result.isNotEmpty) {
      return result.first["total"] as int;
    }
    return 0;
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, "evergreen.db");

    await deleteDatabase(path);
    _db = null;
  }

  Future<int> insertUser(User user) async {
  final db = await database;
  return await db.insert("user", user.toMap());
}

Future<User?> getUserByEmail(String email, String password) async {
  final db = await database;
  final result = await db.query(
    "user",
    where: "email = ? AND password = ?",
    whereArgs: [email, password],
  );
  if (result.isNotEmpty) {
    return User.fromMap(result.first);
  }
  return null;
}

}
