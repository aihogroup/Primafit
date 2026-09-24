import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class IndeksMassaTubuh {
  final int? id;
  final String tanggal;
  final String waktu;
  final String berat;   // dalam kilogram
  final String tinggi;  // dalam sentimeter
  final String bmi;     // hasil perhitungan BMI
  final String catatan;

  IndeksMassaTubuh({
    this.id,
    required this.tanggal,
    required this.waktu,
    required this.berat,
    required this.tinggi,
    required this.bmi,
    required this.catatan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal,
      'waktu': waktu,
      'berat': berat,
      'tinggi': tinggi,
      'bmi': bmi,
      'catatan': catatan,
    };
  }

  factory IndeksMassaTubuh.fromMap(Map<String, dynamic> map) {
    return IndeksMassaTubuh(
      id: map['id'],
      tanggal: map['tanggal'],
      waktu: map['waktu'],
      berat: map['berat'],
      tinggi: map['tinggi'],
      bmi: map['bmi'],
      catatan: map['catatan'],
    );
  }
}

class IndeksMassaTubuhDatabaseHelper {
  static final IndeksMassaTubuhDatabaseHelper instance = IndeksMassaTubuhDatabaseHelper._init();
  static Database? _database;

  IndeksMassaTubuhDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('indeksmassatubuh.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE indeks_massa_tubuh (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT,
        waktu TEXT,
        berat TEXT,
        tinggi TEXT,
        bmi TEXT,
        catatan TEXT
      )
    ''');
  }

  // Fungsi menghitung BMI - PERBAIKAN
  String _calculateBMI(String beratStr, String tinggiStr) {
    try {
      // Parsing nilai berat (kg) dan tinggi (cm)
      final berat = double.parse(beratStr);
      final tinggiCm = double.parse(tinggiStr);
      
      // Konversi tinggi dari cm ke meter
      final tinggiMeter = tinggiCm / 100.0;

      if (tinggiMeter <= 0) return '0';

      // Rumus BMI: berat (kg) / (tinggi (m))²
      final bmi = berat / (tinggiMeter * tinggiMeter);

      // Return 1 angka di belakang koma untuk lebih mudah dibaca
      return bmi.toStringAsFixed(1);
    } catch (e) {
      debugPrint('Error calculating BMI: $e');
      return '0';
    }
  }

  // CREATE
  Future<int> insertIndeksMassaTubuh(IndeksMassaTubuh data) async {
    final db = await instance.database;

    // Hitung BMI otomatis
    final calculatedBmi = _calculateBMI(data.berat, data.tinggi);

    // Buat data baru dengan BMI yang sudah dihitung
    final Map<String, dynamic> newData = {
      'tanggal': data.tanggal,
      'waktu': data.waktu,
      'berat': data.berat,
      'tinggi': data.tinggi,
      'bmi': calculatedBmi,  // Gunakan BMI yang sudah dihitung
      'catatan': data.catatan,
    };

    return await db.insert('indeks_massa_tubuh', newData);
  }

  // READ - all data
  Future<List<IndeksMassaTubuh>> getAllIndeksMassaTubuh() async {
    final db = await instance.database;
    final result = await db.query('indeks_massa_tubuh', orderBy: 'tanggal DESC');

    return result.map((map) => IndeksMassaTubuh.fromMap(map)).toList();
  }

  // READ - single data
  Future<IndeksMassaTubuh?> getIndeksMassaTubuhById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'indeks_massa_tubuh',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return IndeksMassaTubuh.fromMap(result.first);
    } else {
      return null;
    }
  }

  // UPDATE
  Future<int> updateIndeksMassaTubuh(IndeksMassaTubuh data) async {
    final db = await instance.database;

    // Recalculate BMI saat update
    final calculatedBmi = _calculateBMI(data.berat, data.tinggi);
    
    // Update data dengan BMI yang sudah dihitung ulang
    final Map<String, dynamic> updatedData = {
      'tanggal': data.tanggal,
      'waktu': data.waktu,
      'berat': data.berat,
      'tinggi': data.tinggi,
      'bmi': calculatedBmi,  // Gunakan BMI yang sudah dihitung
      'catatan': data.catatan,
    };

    return await db.update(
      'indeks_massa_tubuh',
      updatedData,
      where: 'id = ?',
      whereArgs: [data.id],
    );
  }

  // DELETE
  Future<int> deleteIndeksMassaTubuh(int id) async {
    final db = await instance.database;
    return await db.delete(
      'indeks_massa_tubuh',
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

// Extension untuk copyWith
extension IndeksMassaTubuhCopy on IndeksMassaTubuh {
  IndeksMassaTubuh copyWith({
    int? id,
    String? tanggal,
    String? waktu,
    String? berat,
    String? tinggi,
    String? bmi,
    String? catatan,
  }) {
    return IndeksMassaTubuh(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      waktu: waktu ?? this.waktu,
      berat: berat ?? this.berat,
      tinggi: tinggi ?? this.tinggi,
      bmi: bmi ?? this.bmi,
      catatan: catatan ?? this.catatan,
    );
  }
}