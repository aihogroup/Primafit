import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseGejalaHelper {
  // Singleton pattern
  DatabaseGejalaHelper._privateConstructor();
  static final DatabaseGejalaHelper instance = DatabaseGejalaHelper._privateConstructor();

  static Database? _database;

  // Nama file database
  static const _dbName = 'health_data_gejala.db';
  static const _dbVersion = 1;

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Inisialisasi database dan buat tabel
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  // Fungsi untuk membuat tabel gejala
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE gejala (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gejala TEXT NOT NULL,
        catatan TEXT,
        tanggal TEXT NOT NULL
      )
    ''');
  }

  // -------------------
  // CRUD OPERATIONS
  // -------------------

  // Create: Menambah data gejala baru
  Future<int> insertGejala(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('gejala', row);
  }

  // Read: Mengambil semua data gejala
  Future<List<Map<String, dynamic>>> getAllGejala() async {
    final db = await database;
    return await db.query(
      'gejala',
      orderBy: 'tanggal DESC', // Mengurutkan berdasarkan tanggal terbaru
    );
  }

  // Read by ID: Mengambil satu data gejala berdasarkan ID
  Future<Map<String, dynamic>?> getGejalaById(int id) async {
    final db = await database;
    final results = await db.query(
      'gejala',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Update: Memperbarui data gejala
  Future<int> updateGejala(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      'gejala',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete: Menghapus data gejala
  Future<int> deleteGejala(int id) async {
    final db = await database;
    return await db.delete(
      'gejala',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}