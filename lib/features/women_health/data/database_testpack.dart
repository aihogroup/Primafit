import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperKehamilan {
  static final DatabaseHelperKehamilan instance = DatabaseHelperKehamilan._init();
  static Database? _database;

  DatabaseHelperKehamilan._init();

  // Function to manually add sample data to the database
  Future<bool> addSampleData() async {
    try {
      final db = await database;
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM kategori_kehamilan'));
      if (count != null && count > 0) {
        debugPrint('Data sudah ada di database, melewati penambahan data sampel');
        return true;
      }
      
      // Define sample pregnancy categories
      final List<Map<String, dynamic>> pregnancyCategories = [
        {
          'nama_kategori': 'Kemungkinan Besar Hamil',
          'terlambat_menstruasi': 'Ya',
          'mual_muntah': 'Ya',
          'payudara_sensitif': 'Ya',
          'kelelahan': 'Ya',
          'sering_buang_air': 'Ya',
          'perubahan_selera': 'Ya',
          'hubungan_intim': 'Ya',
          'pusing_sakit_kepala': 'Ya',
          'pembesaran_perut': 'Ya',
          // 'uji_kehamilan': 'Ya',
          'kram_perut': 'Ya',
          'emosi_berubah': 'Ya',
        },
        {
          'nama_kategori': 'Kemungkinan Hamil',
          'terlambat_menstruasi': 'Ya',
          'mual_muntah': 'Ya',
          'payudara_sensitif': 'Ya',
          'kelelahan': 'Mungkin',
          'sering_buang_air': 'Mungkin',
          'perubahan_selera': 'Ya',
          'hubungan_intim': 'Ya',
          'pusing_sakit_kepala': 'Tidak',
          'pembesaran_perut': 'Tidak',
          // 'uji_kehamilan': 'Tidak',
          'kram_perut': 'Mungkin',
          'emosi_berubah': 'Ya',
        },
        {
          'nama_kategori': 'Kemungkinan Kecil Hamil',
          'terlambat_menstruasi': 'Ya',
          'mual_muntah': 'Tidak',
          'payudara_sensitif': 'Tidak',
          'kelelahan': 'Ya',
          'sering_buang_air': 'Tidak',
          'perubahan_selera': 'Tidak',
          'hubungan_intim': 'Ya',
          'pusing_sakit_kepala': 'Tidak',
          'pembesaran_perut': 'Tidak',
          // 'uji_kehamilan': 'Tidak',
          'kram_perut': 'Tidak',
          'emosi_berubah': 'Tidak',
        },
        {
          'nama_kategori': 'Kemungkinan Tidak Hamil',
          'terlambat_menstruasi': 'Tidak',
          'mual_muntah': 'Tidak',
          'payudara_sensitif': 'Tidak',
          'kelelahan': 'Tidak',
          'sering_buang_air': 'Tidak',
          'perubahan_selera': 'Tidak',
          'hubungan_intim': 'Tidak',
          'pusing_sakit_kepala': 'Tidak',
          'pembesaran_perut': 'Tidak',
          // 'uji_kehamilan': 'Tidak',
          'kram_perut': 'Tidak',
          'emosi_berubah': 'Tidak',
        }
      ];
      
      // Use batch for better performance
      final Batch batch = db.batch();
      for (var category in pregnancyCategories) {
        batch.insert('kategori_kehamilan', category);
      }
      
      await batch.commit(noResult: true);
      debugPrint('Data sampel berhasil ditambahkan');
      return true;
    } catch (e) {
      debugPrint('Error menambahkan data sampel: $e');
      return false;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kehamilan_diagnosa.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Tabel untuk menyimpan data kategori kehamilan
    // await db.execute('''
    // CREATE TABLE kategori_kehamilan (
    //   id INTEGER PRIMARY KEY AUTOINCREMENT,
    //   nama_kategori TEXT NOT NULL,
    //   terlambat_menstruasi TEXT,
    //   mual_muntah TEXT,
    //   payudara_sensitif TEXT,
    //   kelelahan TEXT,
    //   sering_buang_air TEXT,
    //   perubahan_selera TEXT,
    //   hubungan_intim TEXT,
    //   pusing_sakit_kepala TEXT,
    //   pembesaran_perut TEXT,
    //   uji_kehamilan TEXT,
    //   kram_perut TEXT,
    //   emosi_berubah TEXT
    // )
    // ''');

    await db.execute('''
    CREATE TABLE kategori_kehamilan (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_kategori TEXT NOT NULL,
      terlambat_menstruasi TEXT,
      mual_muntah TEXT,
      payudara_sensitif TEXT,
      kelelahan TEXT,
      sering_buang_air TEXT,
      perubahan_selera TEXT,
      hubungan_intim TEXT,
      pusing_sakit_kepala TEXT,
      pembesaran_perut TEXT,
      kram_perut TEXT,
      emosi_berubah TEXT
    )
    ''');

    // Tabel untuk menyimpan jawaban pengguna untuk sesi diagnosa saat ini
    // await db.execute('''
    // CREATE TABLE user_answers_kehamilan (
    //   id INTEGER PRIMARY KEY AUTOINCREMENT,
    //   terlambat_menstruasi TEXT,
    //   mual_muntah TEXT,
    //   payudara_sensitif TEXT,
    //   kelelahan TEXT,
    //   sering_buang_air TEXT,
    //   perubahan_selera TEXT,
    //   hubungan_intim TEXT,
    //   pusing_sakit_kepala TEXT,
    //   pembesaran_perut TEXT,
    //   uji_kehamilan TEXT,
    //   kram_perut TEXT,
    //   emosi_berubah TEXT,
    //   created_at TEXT
    // )
    // ''');

    await db.execute('''
    CREATE TABLE user_answers_kehamilan (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      terlambat_menstruasi TEXT,
      mual_muntah TEXT,
      payudara_sensitif TEXT,
      kelelahan TEXT,
      sering_buang_air TEXT,
      perubahan_selera TEXT,
      hubungan_intim TEXT,
      pusing_sakit_kepala TEXT,
      pembesaran_perut TEXT,
      kram_perut TEXT,
      emosi_berubah TEXT,
      created_at TEXT
    )
    ''');
  }

  // Fungsi untuk menyimpan jawaban user
  Future<int> saveUserAnswers(Map<String, dynamic> answers) async {
    final db = await database;
    
    try {
      // Normalisasi jawaban untuk konsistensi data
      final Map<String, dynamic> normalizedAnswers = {};
      
      answers.forEach((key, value) {
        if (value is String) {
          String normalizedValue = value.trim();
          // Standarisasi format Ya/Tidak/Mungkin
          if (normalizedValue.toLowerCase() == 'ya') {
            normalizedValue = 'Ya';
          } else if (normalizedValue.toLowerCase() == 'tidak') normalizedValue = 'Tidak';
          else if (normalizedValue.toLowerCase() == 'mungkin') normalizedValue = 'Mungkin';
          
          normalizedAnswers[key] = normalizedValue;
        } else {
          normalizedAnswers[key] = value;
        }
      });
      
      // Tambahkan timestamp
      normalizedAnswers['created_at'] = DateTime.now().toIso8601String();
      
      // Gunakan transaksi untuk memastikan operasi atomik
      int insertId = 0;
      await db.transaction((txn) async {
        // Hapus jawaban sebelumnya
        await txn.delete('user_answers_kehamilan');
        
        // Simpan jawaban baru
        insertId = await txn.insert('user_answers_kehamilan', normalizedAnswers);
      });
      
      debugPrint('Jawaban user berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan jawaban user: $e');
      rethrow; // Re-throw exception untuk penanganan di level yang lebih tinggi
    }
  }

  // Fungsi untuk mendapatkan semua data kategori kehamilan
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query('kategori_kehamilan');
  }

  // Fungsi untuk mendapatkan jawaban user terbaru
  Future<Map<String, dynamic>?> getLatestUserAnswers() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'user_answers_kehamilan',
      orderBy: 'created_at DESC',
      limit: 1,
    );
    
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Fungsi utama untuk menghitung kemungkinan kehamilan
  Future<List<Map<String, dynamic>>> getDiagnosisResult(double threshold) async {
    // Ambil jawaban pengguna
    final userAnswers = await getLatestUserAnswers();
    if (userAnswers == null) {
      debugPrint('Tidak ada jawaban pengguna ditemukan');
      return [];
    }
    
    debugPrint('Jawaban pengguna: ${userAnswers.toString()}');
    
    // Ambil semua data kategori kehamilan
    final categories = await getAllCategories();
    if (categories.isEmpty) {
      debugPrint('Tidak ada data kategori kehamilan ditemukan');
      
      // Coba menambahkan data sampel dan mencoba lagi
      if (await addSampleData()) {
        final updatedCategories = await getAllCategories();
        if (updatedCategories.isEmpty) {
          return [];
        }
        
        debugPrint('Data sampel berhasil ditambahkan, lanjutkan dengan analisis');
        // Lanjutkan dengan data sampel yang sudah ditambahkan
      } else {
        return [];
      }
    }
    
    debugPrint('Ditemukan ${categories.length} data kategori kehamilan');

    // Daftar kolom gejala

    // Bobot untuk setiap gejala
    final Map<String, double> symptomWeights = {
      'terlambat_menstruasi': 12.0,
      'mual_muntah': 8.0,
      'payudara_sensitif': 7.0,
      'kelelahan': 6.0,
      'sering_buang_air': 5.0,
      'perubahan_selera': 4.0,
      'hubungan_intim': 10.0,
      'pusing_sakit_kepala': 4.0,
      'pembesaran_perut': 5.0,
      // 'uji_kehamilan': 15.0,
      'kram_perut': 5.0,
      'emosi_berubah': 4.0,
    };

    // Menghitung bobot total maksimum
    double totalPossibleWeight = 0;
    for (var weight in symptomWeights.values) {
      totalPossibleWeight += weight;
    }

    // Menghitung bobot positif dari jawaban pengguna
    double userPositiveWeight = 0;
    for (var symptom in symptomWeights.keys) {
      if (userAnswers[symptom] == 'Ya') {
        userPositiveWeight += symptomWeights[symptom]!;
      } else if (userAnswers[symptom] == 'Mungkin') {
        userPositiveWeight += symptomWeights[symptom]! / 2;
      }
    }

    // Menghitung persentase kemungkinan kehamilan
    final double pregnancyPercentage = (userPositiveWeight / totalPossibleWeight) * 100;
    debugPrint('Calculated pregnancy percentage: ${pregnancyPercentage.toStringAsFixed(2)}%');

    // Tentukan kategori kehamilan
    String pregnancyCategory;
    if (pregnancyPercentage >= 80) {
      pregnancyCategory = 'Kemungkinan Besar Hamil';
    } else if (pregnancyPercentage >= 50) {
      pregnancyCategory = 'Kemungkinan Hamil';
    } else if (pregnancyPercentage >= 20) {
      pregnancyCategory = 'Kemungkinan Kecil Hamil';
    } else {
      pregnancyCategory = 'Kemungkinan Tidak Hamil';
    }

    // Buat hasil berdasarkan perhitungan
    final List<Map<String, dynamic>> diagnosisResults = [
      {
        'kategori': pregnancyCategory,
        'persentase': pregnancyPercentage,
        'matched_symptoms': userPositiveWeight,
        'total_symptoms': totalPossibleWeight,
        'matched_details': {},
      }
    ];
    
    debugPrint('Hasil diagnosa: ${diagnosisResults.length} kategori ditemukan');
    for (var result in diagnosisResults) {
      debugPrint('- ${result['kategori']}: ${result['persentase'].toStringAsFixed(1)}%');
    }

    return diagnosisResults;
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}