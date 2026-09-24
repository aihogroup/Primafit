import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperRahim {
  static final DatabaseHelperRahim instance = DatabaseHelperRahim._init();
  static Database? _database;

  DatabaseHelperRahim._init();

  // Function to manually add sample data to the database
  Future<bool> addSampleData() async {
    try {
      final db = await database;
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM penyakit_rahim'));
      if (count != null && count > 0) {
        debugPrint('Data already exists in database, skipping sample data addition');
        return true;
      }
      
      // Define sample risk categories
      List<Map<String, dynamic>> riskCategories = [
        {
          'nama_penyakit': 'Risiko Tinggi',
          'riwayat_keluarga': 'Ya',
          'pernah_kanker': 'Ya',
          'usia_lebih_50': 'Ya',
          'perdarahan_abnormal': 'Ya',
          'nyeri_panggul': 'Ya',
          'nyeri_saat_berhubungan': 'Ya',
          'keputihan_abnormal': 'Ya',
          'penurunan_berat': 'Ya',
          'kelelahan': 'Ya',
          'obesitas': 'Ya',
          'diabetes': 'Ya',
          'tidak_memiliki_anak': 'Ya',
          'menstruasi_dini': 'Ya',
          'menopause_terlambat': 'Ya',
          'terapi_tamoxifen': 'Ya',
          'terapi_hormon': 'Ya',
          'pcos': 'Ya',
        },
        {
          'nama_penyakit': 'Risiko Sedang',
          'riwayat_keluarga': 'Tidak',
          'pernah_kanker': 'Tidak',
          'usia_lebih_50': 'Ya',
          'perdarahan_abnormal': 'Ya',
          'nyeri_panggul': 'Mungkin',
          'nyeri_saat_berhubungan': 'Tidak',
          'keputihan_abnormal': 'Ya',
          'penurunan_berat': 'Tidak',
          'kelelahan': 'Ya',
          'obesitas': 'Ya',
          'diabetes': 'Ya',
          'tidak_memiliki_anak': 'Ya',
          'menstruasi_dini': 'Mungkin',
          'menopause_terlambat': 'Mungkin',
          'terapi_tamoxifen': 'Tidak',
          'terapi_hormon': 'Ya',
          'pcos': 'Mungkin',
        },
        {
          'nama_penyakit': 'Risiko Rendah',
          'riwayat_keluarga': 'Tidak',
          'pernah_kanker': 'Tidak',
          'usia_lebih_50': 'Tidak',
          'perdarahan_abnormal': 'Mungkin',
          'nyeri_panggul': 'Tidak',
          'nyeri_saat_berhubungan': 'Tidak',
          'keputihan_abnormal': 'Mungkin',
          'penurunan_berat': 'Tidak',
          'kelelahan': 'Tidak',
          'obesitas': 'Ya',
          'diabetes': 'Tidak',
          'tidak_memiliki_anak': 'Ya',
          'menstruasi_dini': 'Tidak',
          'menopause_terlambat': 'Tidak',
          'terapi_tamoxifen': 'Tidak',
          'terapi_hormon': 'Mungkin',
          'pcos': 'Tidak',
        },
        {
          'nama_penyakit': 'Tidak Ada Risiko',
          'riwayat_keluarga': 'Tidak',
          'pernah_kanker': 'Tidak',
          'usia_lebih_50': 'Tidak',
          'perdarahan_abnormal': 'Tidak',
          'nyeri_panggul': 'Tidak',
          'nyeri_saat_berhubungan': 'Tidak',
          'keputihan_abnormal': 'Tidak',
          'penurunan_berat': 'Tidak',
          'kelelahan': 'Tidak',
          'obesitas': 'Tidak',
          'diabetes': 'Tidak',
          'tidak_memiliki_anak': 'Tidak',
          'menstruasi_dini': 'Tidak',
          'menopause_terlambat': 'Tidak',
          'terapi_tamoxifen': 'Tidak',
          'terapi_hormon': 'Tidak',
          'pcos': 'Tidak',
        }
      ];
      
      // Use batch for better performance
      Batch batch = db.batch();
      for (var category in riskCategories) {
        batch.insert('penyakit_rahim', category);
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
    _database = await _initDB('kankerrahim_diagnosa.db');
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
    CREATE TABLE penyakit_rahim (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_penyakit TEXT NOT NULL,
      riwayat_keluarga TEXT,
      pernah_kanker TEXT,
      usia_lebih_50 TEXT,
      perdarahan_abnormal TEXT,
      nyeri_panggul TEXT,
      nyeri_saat_berhubungan TEXT,
      keputihan_abnormal TEXT,
      penurunan_berat TEXT,
      kelelahan TEXT,
      obesitas TEXT,
      diabetes TEXT,
      tidak_memiliki_anak TEXT,
      menstruasi_dini TEXT,
      menopause_terlambat TEXT,
      terapi_tamoxifen TEXT,
      terapi_hormon TEXT,
      pcos TEXT
    )
    ''');

    // Tabel untuk menyimpan jawaban pengguna untuk sesi diagnosa saat ini
    await db.execute('''
    CREATE TABLE user_answers_rahim (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      riwayat_keluarga TEXT,
      pernah_kanker TEXT,
      usia_lebih_50 TEXT,
      perdarahan_abnormal TEXT,
      nyeri_panggul TEXT,
      nyeri_saat_berhubungan TEXT,
      keputihan_abnormal TEXT,
      penurunan_berat TEXT,
      kelelahan TEXT,
      obesitas TEXT,
      diabetes TEXT,
      tidak_memiliki_anak TEXT,
      menstruasi_dini TEXT,
      menopause_terlambat TEXT,
      terapi_tamoxifen TEXT,
      terapi_hormon TEXT,
      pcos TEXT,
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
        await txn.delete('user_answers_rahim');
        
        // Simpan jawaban baru
        insertId = await txn.insert('user_answers_rahim', normalizedAnswers);
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
    return await db.query('penyakit_rahim');
  }

  // Fungsi untuk mendapatkan jawaban user terbaru
  Future<Map<String, dynamic>?> getLatestUserAnswers() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'user_answers_rahim',
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
      'pernah_kanker',
      'usia_lebih_50',
      'perdarahan_abnormal',
      'nyeri_panggul',
      'nyeri_saat_berhubungan',
      'keputihan_abnormal',
      'penurunan_berat',
      'kelelahan',
      'obesitas',
      'diabetes',
      'tidak_memiliki_anak',
      'menstruasi_dini',
      'menopause_terlambat',
      'terapi_tamoxifen',
      'terapi_hormon',
      'pcos',
    ];

    // Bobot untuk setiap gejala
    final Map<String, double> symptomWeights = {
      'riwayat_keluarga': 10.0,
      'pernah_kanker': 10.0,
      'usia_lebih_50': 7.0,
      'perdarahan_abnormal': 12.0,
      'nyeri_panggul': 8.0,
      'nyeri_saat_berhubungan': 7.0,
      'keputihan_abnormal': 9.0,
      'penurunan_berat': 9.0,
      'kelelahan': 6.0,
      'obesitas': 5.0,
      'diabetes': 5.0,
      'tidak_memiliki_anak': 4.0,
      'menstruasi_dini': 4.0,
      'menopause_terlambat': 4.0,
      'terapi_tamoxifen': 8.0,
      'terapi_hormon': 7.0,
      'pcos': 6.0,
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