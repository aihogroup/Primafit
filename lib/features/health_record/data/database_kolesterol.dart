import 'package:primafit/core/database/local_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Kolesterol {
  final int? id;
  final String tanggal;
  final String waktu;
  final String hasil;
  final String catatan;
  final String satuan; // mg/dL atau mmol/L

  Kolesterol({
    this.id,
    required this.tanggal,
    required this.waktu,
    required this.hasil,
    required this.catatan,
    this.satuan = 'mg/dL', // Default satuan adalah mg/dL
  });

  // Convert a Kolesterol object into a Map object
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

  // Create a Kolesterol object from a Map
  factory Kolesterol.fromMap(Map<String, dynamic> map) {
    return Kolesterol(
      id: map['id'],
      tanggal: map['tanggal'],
      waktu: map['waktu'],
      hasil: map['hasil'],
      catatan: map['catatan'],
      satuan: map['satuan'] ?? 'mg/dL', // Gunakan default jika tidak ada
    );
  }

  // Konversi nilai kolesterol ke mg/dL (jika perlu)
  double getHasilInMgdL() {
    final double? nilaiAsli = double.tryParse(hasil);
    if (nilaiAsli == null) return 0.0;
    
    if (satuan == 'mmol/L') {
      return convertMmolLToMgdL(nilaiAsli);
    }
    
    return nilaiAsli;
  }
  
  // Konversi nilai kolesterol ke mmol/L (jika perlu)
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

class KolesterolDatabaseHelper {
  static final KolesterolDatabaseHelper instance = KolesterolDatabaseHelper._init();
  static Database? _database;

  KolesterolDatabaseHelper._init();

  Future<Database> get database async {
    if (_database?.isOpen ?? false) return _database!;
    _database = await _initDB('kolesterol.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await LocalDb.open(
      path,
      version: 2, // Upgrade version untuk schema baru
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE kolesterol (
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
      await db.execute('ALTER TABLE kolesterol ADD COLUMN satuan TEXT DEFAULT "mg/dL"');
    }
  }

  // CREATE
  Future<int> insertKolesterol(Kolesterol kolesterol) async {
    final db = await instance.database;
    return await db.insert('kolesterol', kolesterol.toMap());
  }

  // READ - all data
  Future<List<Kolesterol>> getAllKolesterol() async {
    final db = await instance.database;
    final result = await db.query('kolesterol', orderBy: 'tanggal DESC');

    return result.map((map) => Kolesterol.fromMap(map)).toList();
  }

  // READ - single data
  Future<Kolesterol?> getKolesterolById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'kolesterol',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Kolesterol.fromMap(result.first);
    } else {
      return null;
    }
  }

  // UPDATE
  Future<int> updateKolesterol(Kolesterol kolesterol) async {
    final db = await instance.database;
    return await db.update(
      'kolesterol',
      kolesterol.toMap(),
      where: 'id = ?',
      whereArgs: [kolesterol.id],
    );
  }

  // DELETE
  Future<int> deleteKolesterol(int id) async {
    final db = await instance.database;
    return await db.delete(
      'kolesterol',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CLOSE DB
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

// Fungsi untuk mengkonversi mg/dL ke mmol/L (satuan SI)
double convertMgdLToMmolL(double mgdL) {
  // Faktor konversi: 1 mg/dL = 0.02586 mmol/L
  return mgdL * 0.02586;
}

// Fungsi untuk mengkonversi mmol/L ke mg/dL
double convertMmolLToMgdL(double mmolL) {
  // Faktor konversi: 1 mmol/L = 38.67 mg/dL
  return mmolL * 38.67;
}