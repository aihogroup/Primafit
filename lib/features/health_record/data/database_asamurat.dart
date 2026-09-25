import 'package:primafit/core/database/local_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AsamUrat {
  final int? id;
  final String tanggal;
  final String waktu;
  final String hasil;  // dalam mg/dL
  final String catatan;
  final String satuan; // mg/dL atau µmol/L

  AsamUrat({
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

  factory AsamUrat.fromMap(Map<String, dynamic> map) {
    return AsamUrat(
      id: map['id'],
      tanggal: map['tanggal'],
      waktu: map['waktu'],
      hasil: map['hasil'],
      catatan: map['catatan'],
      satuan: map['satuan'] ?? 'mg/dL', // Gunakan default jika tidak ada
    );
  }

  // Konversi nilai asam urat ke mg/dL (jika perlu)
  double getHasilInMgdL() {
    final double? nilaiAsli = double.tryParse(hasil);
    if (nilaiAsli == null) return 0.0;
    
    if (satuan == 'µmol/L') {
      return convertMicroMolLToMgdL(nilaiAsli);
    }
    
    return nilaiAsli;
  }
  
  // Konversi nilai asam urat ke µmol/L (jika perlu)
  double getHasilInMicroMolL() {
    final double? nilaiAsli = double.tryParse(hasil);
    if (nilaiAsli == null) return 0.0;
    
    if (satuan == 'mg/dL') {
      return convertMgdLToMicroMolL(nilaiAsli);
    }
    
    return nilaiAsli;
  }
  
  // Fungsi untuk mendapatkan nilai dengan satuan yang sesuai
  String getHasilDenganSatuan() {
    return '$hasil $satuan';
  }
}

class AsamUratDatabaseHelper {
  static final AsamUratDatabaseHelper instance = AsamUratDatabaseHelper._init();
  static Database? _database;

  AsamUratDatabaseHelper._init();

  Future<Database> get database async {
    if (_database?.isOpen ?? false) return _database!;
    _database = await _initDB('asamurat.db');
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
      CREATE TABLE asam_urat (
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
      await db.execute('ALTER TABLE asam_urat ADD COLUMN satuan TEXT DEFAULT "mg/dL"');
    }
  }

  // CREATE
  Future<int> insertAsamUrat(AsamUrat asamUrat) async {
    final db = await instance.database;
    return await db.insert('asam_urat', asamUrat.toMap());
  }

  // READ - all data
  Future<List<AsamUrat>> getAllAsamUrat() async {
    final db = await instance.database;
    final result = await db.query('asam_urat', orderBy: 'tanggal DESC');

    return result.map((map) => AsamUrat.fromMap(map)).toList();
  }

  // READ - single data
  Future<AsamUrat?> getAsamUratById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'asam_urat',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return AsamUrat.fromMap(result.first);
    } else {
      return null;
    }
  }

  // UPDATE
  Future<int> updateAsamUrat(AsamUrat asamUrat) async {
    final db = await instance.database;
    return await db.update(
      'asam_urat',
      asamUrat.toMap(),
      where: 'id = ?',
      whereArgs: [asamUrat.id],
    );
  }

  // DELETE
  Future<int> deleteAsamUrat(int id) async {
    final db = await instance.database;
    return await db.delete(
      'asam_urat',
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

// Fungsi untuk mengkonversi mg/dL ke µmol/L (satuan SI)
double convertMgdLToMicroMolL(double mgdL) {
  // Faktor konversi: 1 mg/dL = 59.48 µmol/L
  return mgdL * 59.48;
}

// Fungsi untuk mengkonversi µmol/L ke mg/dL
double convertMicroMolLToMgdL(double microMolL) {
  // Faktor konversi: 1 µmol/L = 0.01681 mg/dL
  return microMolL * 0.01681;
}