import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseDokumenHelper {
  // Singleton pattern
  DatabaseDokumenHelper._privateConstructor();
  static final DatabaseDokumenHelper instance = DatabaseDokumenHelper._privateConstructor();

  static Database? _database;

  // Nama file database
  static const _dbName = 'dokumen_data.db';
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

  // Fungsi untuk membuat tabel dokumen dan tabel gambar
  Future _onCreate(Database db, int version) async {
    // Tabel untuk data dokumen
    await db.execute('''
      CREATE TABLE dokumen (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        judul_dokumen TEXT NOT NULL,
        jenis_dokumen TEXT NOT NULL,
        nama_dokter TEXT,
        nama_klinik TEXT NOT NULL,
        tanggal_dokumen TEXT NOT NULL,
        hasil TEXT,
        catatan TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    
    // Tabel untuk menyimpan gambar-gambar dokumen
    await db.execute('''
      CREATE TABLE dokumen_gambar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dokumen_id INTEGER NOT NULL,
        gambar BLOB NOT NULL,
        FOREIGN KEY (dokumen_id) REFERENCES dokumen (id) ON DELETE CASCADE
      )
    ''');
  }

  // -------------------
  // CRUD OPERATIONS
  // -------------------

  // Create: Menambah data dokumen baru
  Future<int> insertDokumen(Map<String, dynamic> dokumen, List<dynamic>? gambarList) async {
    final db = await database;
    
    // Tambahkan timestamp saat ini
    dokumen['created_at'] = DateTime.now().toIso8601String();
    
    // Simpan data dokumen
    final dokumenId = await db.insert('dokumen', {
      'judul_dokumen': dokumen['judul_dokumen'],
      'jenis_dokumen': dokumen['jenis_dokumen'],
      'nama_dokter': dokumen['nama_dokter'],
      'nama_klinik': dokumen['nama_klinik'],
      'tanggal_dokumen': dokumen['tanggal_dokumen'],
      'hasil': dokumen['hasil'],
      'catatan': dokumen['catatan'],
      'created_at': dokumen['created_at'],
    });
    
    // Jika ada gambar, simpan dalam tabel dokumen_gambar
    if (gambarList != null && gambarList.isNotEmpty) {
      for (var gambar in gambarList) {
        await db.insert('dokumen_gambar', {
          'dokumen_id': dokumenId,
          'gambar': gambar,
        });
      }
    }
    
    return dokumenId;
  }

  // Read: Mengambil semua data dokumen
  Future<List<Map<String, dynamic>>> getAllDokumen() async {
    final db = await database;
    return await db.query(
      'dokumen',
      orderBy: 'created_at DESC',  // Mengurutkan berdasarkan tanggal upload terbaru
    );
  }

  // Read by ID: Mengambil satu data dokumen berdasarkan ID
  Future<Map<String, dynamic>?> getDokumenById(int id) async {
    final db = await database;
    final results = await db.query(
      'dokumen',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
  
  // Read: Mengambil semua gambar untuk dokumen tertentu
  Future<List<Map<String, dynamic>>> getGambarByDokumenId(int dokumenId) async {
    final db = await database;
    return await db.query(
      'dokumen_gambar',
      columns: ['id', 'gambar'],
      where: 'dokumen_id = ?',
      whereArgs: [dokumenId],
    );
  }

  // Update: Memperbarui data dokumen
  Future<int> updateDokumen(int id, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(
      'dokumen',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Add gambar to existing dokumen
  Future<int> addGambarToDokumen(int dokumenId, dynamic gambar) async {
    final db = await database;
    return await db.insert('dokumen_gambar', {
      'dokumen_id': dokumenId,
      'gambar': gambar,
    });
  }
  
  // Delete gambar by id
  Future<int> deleteGambar(int gambarId) async {
    final db = await database;
    return await db.delete(
      'dokumen_gambar',
      where: 'id = ?',
      whereArgs: [gambarId],
    );
  }

  // Delete: Menghapus data dokumen (cascade delete juga akan menghapus gambar)
  Future<int> deleteDokumen(int id) async {
    final db = await database;
    return await db.delete(
      'dokumen',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}