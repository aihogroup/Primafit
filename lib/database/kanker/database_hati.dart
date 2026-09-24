import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperHati {
  static final DatabaseHelperHati instance = DatabaseHelperHati._init();
  static Database? _database;

  DatabaseHelperHati._init();

  // Function to manually add sample data to the database
  Future<bool> addSampleData() async {
    try {
      final db = await database;
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM penyakit_hati'));
      if (count != null && count > 0) {
        debugPrint('Data already exists in database, skipping sample data addition');
        return true;
      }
      
      // Define sample risk categories
      List<Map<String, dynamic>> riskCategories = [
        {
          'nama_penyakit': 'Risiko Tinggi',
          'riwayat_keluarga': 'Ya',
          'hepatitis': 'Ya',
          'sirosis': 'Ya',
          'usia_lebih_50': 'Ya',
          'pembesaran_perut': 'Ya',
          'nyeri_perut': 'Ya',
          'penurunan_berat': 'Ya',
          'kelelahan': 'Ya',
          'kulit_kuning': 'Ya',
          'konsumsi_alkohol': 'Ya',
          'nafsu_makan': 'Ya',
          'obesitas': 'Ya',
          'diabetes': 'Ya',
        },
        {
          'nama_penyakit': 'Risiko Sedang',
          'riwayat_keluarga': 'Tidak',
          'hepatitis': 'Ya',
          'sirosis': 'Tidak',
          'usia_lebih_50': 'Ya',
          'pembesaran_perut': 'Mungkin',
          'nyeri_perut': 'Mungkin',
          'penurunan_berat': 'Tidak',
          'kelelahan': 'Ya',
          'kulit_kuning': 'Tidak',
          'konsumsi_alkohol': 'Ya',
          'nafsu_makan': 'Mungkin',
          'obesitas': 'Ya',
          'diabetes': 'Tidak',
        },
        {
          'nama_penyakit': 'Risiko Rendah',
          'riwayat_keluarga': 'Tidak',
          'hepatitis': 'Tidak',
          'sirosis': 'Tidak',
          'usia_lebih_50': 'Ya',
          'pembesaran_perut': 'Tidak',
          'nyeri_perut': 'Tidak',
          'penurunan_berat': 'Tidak',
          'kelelahan': 'Mungkin',
          'kulit_kuning': 'Tidak',
          'konsumsi_alkohol': 'Mungkin',
          'nafsu_makan': 'Tidak',
          'obesitas': 'Ya',
          'diabetes': 'Tidak',
        },
        {
          'nama_penyakit': 'Tidak Ada Risiko',
          'riwayat_keluarga': 'Tidak',
          'hepatitis': 'Tidak',
          'sirosis': 'Tidak',
          'usia_lebih_50': 'Tidak',
          'pembesaran_perut': 'Tidak',
          'nyeri_perut': 'Tidak',
          'penurunan_berat': 'Tidak',
          'kelelahan': 'Tidak',
          'kulit_kuning': 'Tidak',
          'konsumsi_alkohol': 'Tidak',
          'nafsu_makan': 'Tidak',
          'obesitas': 'Tidak',
          'diabetes': 'Tidak',
        }
      ];
      
      // Use batch for better performance
      Batch batch = db.batch();
      for (var category in riskCategories) {
        batch.insert('penyakit_hati', category);
      }
      
      await batch.commit(noResult: true);
      debugPrint('Sample data added successfully');
      return true;
    } catch (e) {
      debugPrint('Error adding sample data: $e');
      return false;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kankerhati_diagnosa.db');
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
    // Tabel untuk menyimpan data penyakit dan gejala
    await db.execute('''
    CREATE TABLE penyakit_hati (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_penyakit TEXT NOT NULL,
      riwayat_keluarga TEXT,
      hepatitis TEXT,
      sirosis TEXT,
      usia_lebih_50 TEXT,
      pembesaran_perut TEXT,
      nyeri_perut TEXT,
      penurunan_berat TEXT,
      kelelahan TEXT,
      kulit_kuning TEXT,
      konsumsi_alkohol TEXT,
      nafsu_makan TEXT,
      obesitas TEXT,
      diabetes TEXT
    )
    ''');

    // Tabel untuk menyimpan jawaban pengguna untuk sesi diagnosa saat ini
    await db.execute('''
    CREATE TABLE user_answers_hati (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      riwayat_keluarga TEXT,
      hepatitis TEXT,
      sirosis TEXT,
      usia_lebih_50 TEXT,
      pembesaran_perut TEXT,
      nyeri_perut TEXT,
      penurunan_berat TEXT,
      kelelahan TEXT,
      kulit_kuning TEXT,
      konsumsi_alkohol TEXT,
      nafsu_makan TEXT,
      obesitas TEXT,
      diabetes TEXT,
      created_at TEXT
    )
    ''');
  }

  // Fungsi untuk menyimpan jawaban user
  Future<int> saveUserAnswers(Map<String, dynamic> answers) async {
    final db = await database;
    
    try {
      // Normalisasi jawaban untuk konsistensi data
      Map<String, dynamic> normalizedAnswers = {};
      
      answers.forEach((key, value) {
        if (value is String) {
          String normalizedValue = value.trim();
          // Standarisasi format Ya/Tidak/Mungkin
          if (normalizedValue.toLowerCase() == 'ya') normalizedValue = 'Ya';
          else if (normalizedValue.toLowerCase() == 'tidak') normalizedValue = 'Tidak';
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
        await txn.delete('user_answers_hati');
        
        // Simpan jawaban baru
        insertId = await txn.insert('user_answers_hati', normalizedAnswers);
      });
      
      debugPrint('Jawaban user berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan jawaban user: $e');
      rethrow; // Re-throw exception untuk penanganan di level yang lebih tinggi
    }
  }

  // Fungsi untuk mendapatkan semua data penyakit
  Future<List<Map<String, dynamic>>> getAllDiseases() async {
    final db = await database;
    return await db.query('penyakit_hati');
  }

  // Fungsi untuk mendapatkan jawaban user terbaru
  Future<Map<String, dynamic>?> getLatestUserAnswers() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'user_answers_hati',
      orderBy: 'created_at DESC',
      limit: 1,
    );
    
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  // Fungsi utama untuk menghitung kemiripan dan mendiagnosis
  Future<List<Map<String, dynamic>>> getDiagnosisResult(double threshold) async {
    // Ambil jawaban pengguna
    final userAnswers = await getLatestUserAnswers();
    if (userAnswers == null) {
      debugPrint('Tidak ada jawaban pengguna ditemukan');
      return [];
    }
    
    debugPrint('Jawaban pengguna: ${userAnswers.toString()}');
    
    // Ambil semua data penyakit
    final diseases = await getAllDiseases();
    if (diseases.isEmpty) {
      debugPrint('Tidak ada data penyakit ditemukan');
      
      // Coba menambahkan data sampel dan mencoba lagi
      if (await addSampleData()) {
        final updatedDiseases = await getAllDiseases();
        if (updatedDiseases.isEmpty) {
          return [];
        }
        
        debugPrint('Data sampel berhasil ditambahkan, lanjutkan dengan analisis');
        // Lanjutkan dengan data sampel yang sudah ditambahkan
      } else {
        return [];
      }
    }
    
    debugPrint('Ditemukan ${diseases.length} data penyakit');

    // Daftar kolom gejala
    final List<String> symptomColumns = [
      'riwayat_keluarga',
      'hepatitis',
      'sirosis',
      'usia_lebih_50',
      'pembesaran_perut',
      'nyeri_perut',
      'penurunan_berat',
      'kelelahan',
      'kulit_kuning',
      'konsumsi_alkohol',
      'nafsu_makan',
      'obesitas',
      'diabetes',
    ];

    // Bobot untuk setiap gejala
    final Map<String, double> symptomWeights = {
      'riwayat_keluarga': 10.0,
      'hepatitis': 14.0,
      'sirosis': 13.0,
      'usia_lebih_50': 7.0,
      'pembesaran_perut': 9.0,
      'nyeri_perut': 8.0,
      'penurunan_berat': 9.0,
      'kelelahan': 6.0,
      'kulit_kuning': 11.0,
      'konsumsi_alkohol': 10.0,
      'nafsu_makan': 6.0,
      'obesitas': 7.0,
      'diabetes': 8.0,
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

    // Menghitung persentase risiko pengguna
    double riskPercentage = (userPositiveWeight / totalPossibleWeight) * 100;
    debugPrint('Calculated user risk percentage: ${riskPercentage.toStringAsFixed(2)}%');

    // Determine risk category
    String riskCategory;
    if (riskPercentage >= 80) {
      riskCategory = 'Risiko Tinggi';
    } else if (riskPercentage >= 50) {
      riskCategory = 'Risiko Sedang';
    } else if (riskPercentage >= 20) {
      riskCategory = 'Risiko Rendah';
    } else {
      riskCategory = 'Tidak Ada Risiko';
    }

    // Create result based on calculated risk
    List<Map<String, dynamic>> diagnosisResults = [
      {
        'penyakit': riskCategory,
        'persentase': riskPercentage,
        'matched_symptoms': userPositiveWeight,
        'total_symptoms': totalPossibleWeight,
        'matched_details': {},
      }
    ];
    
    debugPrint('Hasil diagnosa: ${diagnosisResults.length} penyakit ditemukan');
    for (var result in diagnosisResults) {
      debugPrint('- ${result['penyakit']}: ${result['persentase'].toStringAsFixed(1)}%');
    }

    return diagnosisResults;
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}