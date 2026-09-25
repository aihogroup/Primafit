import 'package:primafit/core/database/local_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// import 'dart:typed_data';

class DatabaseVaksinHelper {
  // Singleton pattern
  DatabaseVaksinHelper._privateConstructor();
  static final DatabaseVaksinHelper instance = DatabaseVaksinHelper._privateConstructor();

  static Database? _database;

  // Nama file database
  static const _dbName = 'vaksin_data.db';
  static const _dbVersion = 1;

  // Get database instance
  Future<Database> get database async {
    if (_database?.isOpen ?? false) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Inisialisasi database dan buat tabel
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await LocalDb.open(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  // Fungsi untuk membuat tabel vaksin
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vaksin (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomor_vaksin TEXT NOT NULL,
        nama_vaksin TEXT NOT NULL,
        foto BLOB,  -- Menyimpan foto kartu vaksin dalam format BLOB
        tanggal_vaksin TEXT NOT NULL
      )
    ''');
  }

  // -------------------
  // CRUD OPERATIONS
  // -------------------

  // Create: Menambah data vaksin baru
  Future<int> insertVaksin(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('vaksin', row);
  }

  // Read: Mengambil semua data vaksin
  Future<List<Map<String, dynamic>>> getAllVaksin() async {
    final db = await database;
    return await db.query(
      'vaksin',
      orderBy: 'nama_vaksin ASC',  // Mengurutkan berdasarkan nama vaksin
    );
  }

  // Read by ID: Mengambil satu data vaksin berdasarkan ID
  Future<Map<String, dynamic>?> getVaksinById(int id) async {
    final db = await database;
    final results = await db.query(
      'vaksin',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Update: Memperbarui data vaksin
  Future<int> updateVaksin(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      'vaksin',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete: Menghapus data vaksin
  Future<int> deleteVaksin(int id) async {
    final db = await database;
    return await db.delete(
      'vaksin',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}