import 'package:primafit/core/database/local_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SuhuTubuh {
  final int? id;
  final String tanggal;
  final String waktu;
  final String hasil;
  final String catatan;
  final String satuan; // Celsius atau Fahrenheit

  SuhuTubuh({
    this.id,
    required this.tanggal,
    required this.waktu,
    required this.hasil,
    required this.catatan,
    this.satuan = '°C', // Default satuan adalah Celsius
  });

  // Convert a SuhuTubuh object into a Map object
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

  // Create a SuhuTubuh object from a Map
  factory SuhuTubuh.fromMap(Map<String, dynamic> map) {
    return SuhuTubuh(
      id: map['id'],
      tanggal: map['tanggal'],
      waktu: map['waktu'],
      hasil: map['hasil'],
      catatan: map['catatan'],
      satuan: map['satuan'] ?? '°C', // Gunakan default jika tidak ada
    );
  }

  // Konversi nilai suhu ke Celsius (jika perlu)
  double getHasilInCelsius() {
    final double? nilaiAsli = double.tryParse(hasil);
    if (nilaiAsli == null) return 0.0;
    
    if (satuan == '°F') {
      return convertFahrenheitToCelsius(nilaiAsli);
    }
    
    return nilaiAsli;
  }
  
  // Konversi nilai suhu ke Fahrenheit (jika perlu)
  double getHasilInFahrenheit() {
    final double? nilaiAsli = double.tryParse(hasil);
    if (nilaiAsli == null) return 0.0;
    
    if (satuan == '°C') {
      return convertCelsiusToFahrenheit(nilaiAsli);
    }
    
    return nilaiAsli;
  }
  
  // Fungsi untuk mendapatkan nilai dengan satuan yang sesuai
  String getHasilDenganSatuan() {
    return '$hasil $satuan';
  }
}

class SuhuDatabaseHelper {
  static final SuhuDatabaseHelper instance = SuhuDatabaseHelper._init();
  static Database? _database;

  SuhuDatabaseHelper._init();

  Future<Database> get database async {
    if (_database?.isOpen ?? false) return _database!;
    _database = await _initDB('suhu_tubuh.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await LocalDb.open(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE suhu_tubuh (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT,
        waktu TEXT,
        hasil TEXT,
        catatan TEXT,
        satuan TEXT
      )
    ''');
  }

  // CREATE
  Future<int> insertSuhu(SuhuTubuh suhu) async {
    final db = await instance.database;
    return await db.insert('suhu_tubuh', suhu.toMap());
  }

  // READ - all data
  Future<List<SuhuTubuh>> getAllSuhu() async {
    final db = await instance.database;
    final result = await db.query('suhu_tubuh', orderBy: 'tanggal DESC');

    return result.map((map) => SuhuTubuh.fromMap(map)).toList();
  }

  // READ - single data
  Future<SuhuTubuh?> getSuhuById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'suhu_tubuh',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return SuhuTubuh.fromMap(result.first);
    } else {
      return null;
    }
  }

  // UPDATE
  Future<int> updateSuhu(SuhuTubuh suhu) async {
    final db = await instance.database;
    return await db.update(
      'suhu_tubuh',
      suhu.toMap(),
      where: 'id = ?',
      whereArgs: [suhu.id],
    );
  }

  // DELETE
  Future<int> deleteSuhu(int id) async {
    final db = await instance.database;
    return await db.delete(
      'suhu_tubuh',
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

// Fungsi untuk mengkonversi Celsius ke Fahrenheit
double convertCelsiusToFahrenheit(double celsius) {
  return (celsius * 9/5) + 32;
}

// Fungsi untuk mengkonversi Fahrenheit ke Celsius
double convertFahrenheitToCelsius(double fahrenheit) {
  return (fahrenheit - 32) * 5/9;
}