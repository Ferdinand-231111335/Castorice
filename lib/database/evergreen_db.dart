import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/berita_model.dart';
import '../model/misi_model.dart';
import '../model/poin_model.dart';

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
          CREATE TABLE berita(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT,
            isi TEXT
          )
        ''');

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
      },
    );
  }

  // ===== Berita =====
  Future<int> insertBerita(Berita berita) async {
    final db = await database;
    return await db.insert("berita", berita.toMap());
  }

  Future<List<Berita>> getAllBerita() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query("berita", orderBy: "id DESC");
    return maps.map((e) => Berita.fromMap(e)).toList();
  }

  Future<void> clearBerita() async {
    final db = await database;
    await db.delete("berita");
  }

  // ===== Misi =====
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

  // ===== Poin =====
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
}
