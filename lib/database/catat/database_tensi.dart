import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TekananDarah {
  final int? id;
  final String tanggal;
  final String waktu;
  final String sistolik;
  final String diastolik;
  final String catatan;

  TekananDarah({
    this.id,
    required this.tanggal,
    required this.waktu,
    required this.sistolik,
    required this.diastolik,
    required this.catatan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal,
      'waktu': waktu,
      'sistolik': sistolik,
      'diastolik': diastolik,
      'catatan': catatan,
    };
  }

  factory TekananDarah.fromMap(Map<String, dynamic> map) {
    return TekananDarah(
      id: map['id'],
      tanggal: map['tanggal'],
      waktu: map['waktu'],
      sistolik: map['sistolik'],
      diastolik: map['diastolik'],
      catatan: map['catatan'],
    );
  }
}

class TekananDarahDatabaseHelper {
  static final TekananDarahDatabaseHelper instance = TekananDarahDatabaseHelper._init();
  static Database? _database;

  TekananDarahDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tekanandarah.db');
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
      CREATE TABLE tekanan_darah (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT,
        waktu TEXT,
        sistolik TEXT,
        diastolik TEXT,
        catatan TEXT
      )
    ''');
  }

  // CREATE
  Future<int> insertTekananDarah(TekananDarah tekanan) async {
    final db = await instance.database;
    return await db.insert('tekanan_darah', tekanan.toMap());
  }

  // READ - all data
  Future<List<TekananDarah>> getAllTekananDarah() async {
    final db = await instance.database;
    final result = await db.query('tekanan_darah', orderBy: 'tanggal DESC');

    return result.map((map) => TekananDarah.fromMap(map)).toList();
  }

  // READ - single data
  Future<TekananDarah?> getTekananDarahById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'tekanan_darah',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return TekananDarah.fromMap(result.first);
    } else {
      return null;
    }
  }

  // UPDATE
  Future<int> updateTekananDarah(TekananDarah tekanan) async {
    final db = await instance.database;
    return await db.update(
      'tekanan_darah',
      tekanan.toMap(),
      where: 'id = ?',
      whereArgs: [tekanan.id],
    );
  }

  // DELETE
  Future<int> deleteTekananDarah(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tekanan_darah',
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