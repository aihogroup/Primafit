import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// import 'dart:typed_data';

class DatabaseBpjsHelper {
  // Singleton pattern
  DatabaseBpjsHelper._privateConstructor();
  static final DatabaseBpjsHelper instance = DatabaseBpjsHelper._privateConstructor();

  static Database? _database;

  // Nama file database
  static const _dbName = 'bpjs_data.db';
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

  // Fungsi untuk membuat tabel bpjs
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bpjs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomor_bpjs TEXT NOT NULL,
        nama TEXT NOT NULL,
        foto BLOB,  -- Menyimpan foto kartu BPJS dalam format BLOB
        tanggal_lahir TEXT NOT NULL
      )
    ''');
  }

  // -------------------
  // CRUD OPERATIONS
  // -------------------

  // Create: Menambah data BPJS baru
  Future<int> insertBpjs(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('bpjs', row);
  }

  // Read: Mengambil semua data BPJS
  Future<List<Map<String, dynamic>>> getAllBpjs() async {
    final db = await database;
    return await db.query(
      'bpjs',
      orderBy: 'nama ASC',  // Mengurutkan berdasarkan nama
    );
  }

  // Read by ID: Mengambil satu data BPJS berdasarkan ID
  Future<Map<String, dynamic>?> getBpjsById(int id) async {
    final db = await database;
    final results = await db.query(
      'bpjs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Update: Memperbarui data BPJS
  Future<int> updateBpjs(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      'bpjs',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete: Menghapus data BPJS
  Future<int> deleteBpjs(int id) async {
    final db = await database;
    return await db.delete(
      'bpjs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}