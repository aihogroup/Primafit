import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GulaDarah {
  final int? id;
  final String tanggal;
  final String waktu;
  final String hasil;  // dalam mg/dL
  final String catatan;
  final String satuan; // mg/dL atau mmol/L

  GulaDarah({
    this.id,
    required this.tanggal,
    required this.waktu,
    required this.hasil,
    required this.catatan,
    this.satuan = 'mg/dL', // Default satuan adalah mg/dL
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal,
      'waktu': waktu,
      'hasil': hasil,
      'catatan': catatan,
      'satuan': satuan,
    };
  }

  factory GulaDarah.fromMap(Map<String, dynamic> map) {
    return GulaDarah(
      id: map['id'],
      tanggal: map['tanggal'],
      waktu: map['waktu'],
      hasil: map['hasil'],
      catatan: map['catatan'],
      satuan: map['satuan'] ?? 'mg/dL', // Gunakan default jika tidak ada
    );
  }

  // Konversi nilai gula darah ke mg/dL (jika perlu)
  double getHasilInMgdL() {
    final double? nilaiAsli = double.tryParse(hasil);
    if (nilaiAsli == null) return 0.0;
    
    if (satuan == 'mmol/L') {
      return convertMmolLToMgdL(nilaiAsli);
    }
    
    return nilaiAsli;
  }
  
  // Konversi nilai gula darah ke mmol/L (jika perlu)
  double getHasilInMmolL() {
    final double? nilaiAsli = double.tryParse(hasil);
    if (nilaiAsli == null) return 0.0;
    
    if (satuan == 'mg/dL') {
      return convertMgdLToMmolL(nilaiAsli);
    }
    
    return nilaiAsli;
  }
  
  // Fungsi untuk mendapatkan nilai dengan satuan yang sesuai
  String getHasilDenganSatuan() {
    return '$hasil $satuan';
  }
}

class GulaDarahDatabaseHelper {
  static final GulaDarahDatabaseHelper instance = GulaDarahDatabaseHelper._init();
  static Database? _database;

  GulaDarahDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('guladarah.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Upgrade version untuk schema baru
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE gula_darah (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT,
        waktu TEXT,
        hasil TEXT,
        catatan TEXT,
        satuan TEXT
      )
    ''');
  }

  // Fungsi untuk upgrade database jika versi lama
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Tambahkan kolom satuan jika belum ada
      await db.execute('ALTER TABLE gula_darah ADD COLUMN satuan TEXT DEFAULT "mg/dL"');
    }
  }

  // CREATE
  Future<int> insertGulaDarah(GulaDarah gulaDarah) async {
    final db = await instance.database;
    return await db.insert('gula_darah', gulaDarah.toMap());
  }

  // READ - all data
  Future<List<GulaDarah>> getAllGulaDarah() async {
    final db = await instance.database;
    final result = await db.query('gula_darah', orderBy: 'tanggal DESC');

    return result.map((map) => GulaDarah.fromMap(map)).toList();
  }

  // READ - single data
  Future<GulaDarah?> getGulaDarahById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'gula_darah',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return GulaDarah.fromMap(result.first);
    } else {
      return null;
    }
  }

  // UPDATE
  Future<int> updateGulaDarah(GulaDarah gulaDarah) async {
    final db = await instance.database;
    return await db.update(
      'gula_darah',
      gulaDarah.toMap(),
      where: 'id = ?',
      whereArgs: [gulaDarah.id],
    );
  }

  // DELETE
  Future<int> deleteGulaDarah(int id) async {
    final db = await instance.database;
    return await db.delete(
      'gula_darah',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CLOSE
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

// Fungsi untuk mengkonversi mg/dL ke mmol/L (satuan SI untuk gula darah)
double convertMgdLToMmolL(double mgdL) {
  // Faktor konversi: 1 mg/dL = 0.0555 mmol/L
  return mgdL * 0.0555;
}

// Fungsi untuk mengkonversi mmol/L ke mg/dL
double convertMmolLToMgdL(double mmolL) {
  // Faktor konversi: 1 mmol/L = 18.018 mg/dL
  return mmolL * 18.018;
}