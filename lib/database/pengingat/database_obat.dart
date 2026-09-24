import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseObatHelper {
  // Singleton pattern
  DatabaseObatHelper._privateConstructor();
  static final DatabaseObatHelper instance = DatabaseObatHelper._privateConstructor();

  static Database? _database;

  // Nama file database
  static const _dbName = 'health_data_obat.db';
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

  // Fungsi untuk membuat tabel obat dan alarm_obat
  Future _onCreate(Database db, int version) async {
    // Tabel obat
    await db.execute('''
      CREATE TABLE obat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        dosis TEXT NOT NULL,
        jenis TEXT NOT NULL,
        deskripsi TEXT,
        stok TEXT NOT NULL,
        frekuensi_harian TEXT NOT NULL,
        instruksi TEXT NOT NULL,
        nada TEXT NOT NULL
      )
    ''');

    // Tabel alarm_obat (untuk menyimpan waktu alarm)
    await db.execute('''
      CREATE TABLE alarm_obat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        obat_id INTEGER,  -- Foreign key yang mengacu pada id obat
        waktu_alarm INTEGER,  -- Waktu alarm dalam format Unix timestamp (INTEGER)
        FOREIGN KEY (obat_id) REFERENCES obat(id)
      )
    ''');
  }

  // -------------------
  // CRUD OPERATIONS
  // -------------------

  // Create: Menambah data obat baru
  Future<int> insertObat(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('obat', row);
  }

  // Create: Menambah data alarm untuk obat
  Future<int> insertAlarmObat(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('alarm_obat', row);
  }

  // Read: Mengambil semua data obat
  Future<List<Map<String, dynamic>>> getAllObat() async {
    final db = await database;
    return await db.query(
      'obat',
      orderBy: 'nama ASC', // Mengurutkan berdasarkan nama obat
    );
  }

  // Read: Mengambil semua alarm untuk obat tertentu
  Future<List<Map<String, dynamic>>> getAlarmsByObatId(int obatId) async {
    final db = await database;
    return await db.query(
      'alarm_obat',
      where: 'obat_id = ?',
      whereArgs: [obatId],
      orderBy: 'waktu_alarm ASC', // Mengurutkan alarm berdasarkan waktu
    );
  }

  // Read by ID: Mengambil satu data obat berdasarkan ID
  Future<Map<String, dynamic>?> getObatById(int id) async {
    final db = await database;
    final results = await db.query(
      'obat',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Update: Memperbarui data obat
  Future<int> updateObat(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      'obat',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update: Memperbarui waktu alarm untuk obat
  Future<int> updateAlarmObat(int alarmId, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      'alarm_obat',
      row,
      where: 'id = ?',
      whereArgs: [alarmId],
    );
  }

  // Delete: Menghapus data obat
  Future<int> deleteObat(int id) async {
    final db = await database;
    return await db.delete(
      'obat',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete: Menghapus alarm berdasarkan ID alarm
  Future<int> deleteAlarmObat(int id) async {
    final db = await database;
    return await db.delete(
      'alarm_obat',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
