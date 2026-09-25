import 'package:primafit/core/database/local_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class ProfileDatabaseHelper {
  static final ProfileDatabaseHelper _instance = ProfileDatabaseHelper._internal();
  factory ProfileDatabaseHelper() => _instance;

  static Database? _database;
  ProfileDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database?.isOpen ?? false) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'health_data.db');
    return await LocalDb.open(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        foto TEXT,
        nama TEXT,
        tanggalLahir TEXT, -- disimpan dalam format yyyy-MM-dd
        gender TEXT,
        golonganDarah TEXT,
        telepon TEXT
      )
    ''');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Tambahkan perubahan versi jika perlu
  }

  // Simpan profile (pastikan tanggal dalam format yyyy-MM-dd)
  Future<int> insertProfile(Map<String, dynamic> profile) async {
    final db = await database;

    // Format tanggal sebelum disimpan
    if (profile.containsKey('tanggalLahir') && profile['tanggalLahir'] is DateTime) {
      profile['tanggalLahir'] = DateFormat('yyyy-MM-dd').format(profile['tanggalLahir']);
    }

    return await db.insert('profile', profile);
  }

  // Ambil data profile
  Future<List<Map<String, dynamic>>> getProfiles() async {
    final db = await database;
    return await db.query('profile');
  }

  // Update profile
  Future<int> updateProfile(Map<String, dynamic> profile, int id) async {
    final db = await database;

    if (profile.containsKey('tanggalLahir') && profile['tanggalLahir'] is DateTime) {
      profile['tanggalLahir'] = DateFormat('yyyy-MM-dd').format(profile['tanggalLahir']);
    }

    return await db.update(
      'profile',
      profile,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hapus profile
  Future<int> deleteProfile(int id) async {
    final db = await database;
    return await db.delete(
      'profile',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
