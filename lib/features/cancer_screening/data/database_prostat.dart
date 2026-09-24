import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperProstat {
  static final DatabaseHelperProstat instance = DatabaseHelperProstat._init();
  static Database? _database;

  DatabaseHelperProstat._init();

  // Function to manually add sample data to the database
  Future<bool> addSampleData() async {
    try {
      final db = await database;
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM penyakit_prostat'));
      if (count != null && count > 0) {
        debugPrint('Data already exists in database, skipping sample data addition');
        return true;
      }
      
      // Define sample risk categories
      final List<Map<String, dynamic>> riskCategories = [
        {
          'nama_penyakit': 'Risiko Tinggi',
          'riwayat_keluarga': 'Ya',
          'usia_lebih_50': 'Ya',
          'kesulitan_buang_air': 'Ya',
          'sering_buang_air': 'Ya',
          'bangun_malam_kencing': 'Ya',
          'aliran_urine_lemah': 'Ya',
          'mengedan_kencing': 'Ya',
          'urine_terputus': 'Ya',
          'rasa_tidak_tuntas': 'Ya',
          'nyeri_saat_kencing': 'Ya',
          'darah_urine': 'Ya',
          'darah_air_mani': 'Ya',
          'nyeri_panggul': 'Ya',
          'nyeri_punggung': 'Ya',
          'disfungsi_ereksi': 'Ya',
          'penurunan_berat': 'Ya',
          'ras_afrika': 'Ya',
        },
        {
          'nama_penyakit': 'Risiko Sedang',
          'riwayat_keluarga': 'Tidak',
          'usia_lebih_50': 'Ya',
          'kesulitan_buang_air': 'Ya',
          'sering_buang_air': 'Ya',
          'bangun_malam_kencing': 'Ya',
          'aliran_urine_lemah': 'Mungkin',
          'mengedan_kencing': 'Mungkin',
          'urine_terputus': 'Mungkin',
          'rasa_tidak_tuntas': 'Ya',
          'nyeri_saat_kencing': 'Tidak',
          'darah_urine': 'Tidak',
          'darah_air_mani': 'Tidak',
          'nyeri_panggul': 'Tidak',
          'nyeri_punggung': 'Tidak',
          'disfungsi_ereksi': 'Mungkin',
          'penurunan_berat': 'Tidak',
          'ras_afrika': 'Mungkin',
        },
        {
          'nama_penyakit': 'Risiko Rendah',
          'riwayat_keluarga': 'Tidak',
          'usia_lebih_50': 'Tidak',
          'kesulitan_buang_air': 'Mungkin',
          'sering_buang_air': 'Mungkin',
          'bangun_malam_kencing': 'Mungkin',
          'aliran_urine_lemah': 'Tidak',
          'mengedan_kencing': 'Tidak',
          'urine_terputus': 'Tidak',
          'rasa_tidak_tuntas': 'Mungkin',
          'nyeri_saat_kencing': 'Tidak',
          'darah_urine': 'Tidak',
          'darah_air_mani': 'Tidak',
          'nyeri_panggul': 'Tidak',
          'nyeri_punggung': 'Tidak',
          'disfungsi_ereksi': 'Tidak',
          'penurunan_berat': 'Tidak',
          'ras_afrika': 'Tidak',
        },
        {
          'nama_penyakit': 'Tidak Ada Risiko',
          'riwayat_keluarga': 'Tidak',
          'usia_lebih_50': 'Tidak',
          'kesulitan_buang_air': 'Tidak',
          'sering_buang_air': 'Tidak',
          'bangun_malam_kencing': 'Tidak',
          'aliran_urine_lemah': 'Tidak',
          'mengedan_kencing': 'Tidak',
          'urine_terputus': 'Tidak',
          'rasa_tidak_tuntas': 'Tidak',
          'nyeri_saat_kencing': 'Tidak',
          'darah_urine': 'Tidak',
          'darah_air_mani': 'Tidak',
          'nyeri_panggul': 'Tidak',
          'nyeri_punggung': 'Tidak',
          'disfungsi_ereksi': 'Tidak',
          'penurunan_berat': 'Tidak',
          'ras_afrika': 'Tidak',
        }
      ];
      
      // Use batch for better performance
      final Batch batch = db.batch();
      for (var category in riskCategories) {
        batch.insert('penyakit_prostat', category);
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
    _database = await _initDB('kankerprostat_diagnosa.db');
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
    CREATE TABLE penyakit_prostat (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_penyakit TEXT NOT NULL,
      riwayat_keluarga TEXT,
      usia_lebih_50 TEXT,
      kesulitan_buang_air TEXT,
      sering_buang_air TEXT,
      bangun_malam_kencing TEXT,
      aliran_urine_lemah TEXT,
      mengedan_kencing TEXT,
      urine_terputus TEXT,
      rasa_tidak_tuntas TEXT,
      nyeri_saat_kencing TEXT,
      darah_urine TEXT,
      darah_air_mani TEXT,
      nyeri_panggul TEXT,
      nyeri_punggung TEXT,
      disfungsi_ereksi TEXT,
      penurunan_berat TEXT,
      ras_afrika TEXT
    )
    ''');

    // Tabel untuk menyimpan jawaban pengguna untuk sesi diagnosa saat ini
    await db.execute('''
    CREATE TABLE user_answers_prostat (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      riwayat_keluarga TEXT,
      usia_lebih_50 TEXT,
      kesulitan_buang_air TEXT,
      sering_buang_air TEXT,
      bangun_malam_kencing TEXT,
      aliran_urine_lemah TEXT,
      mengedan_kencing TEXT,
      urine_terputus TEXT,
      rasa_tidak_tuntas TEXT,
      nyeri_saat_kencing TEXT,
      darah_urine TEXT,
      darah_air_mani TEXT,
      nyeri_panggul TEXT,
      nyeri_punggung TEXT,
      disfungsi_ereksi TEXT,
      penurunan_berat TEXT,
      ras_afrika TEXT,
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
        await txn.delete('user_answers_prostat');
        
        // Simpan jawaban baru
        insertId = await txn.insert('user_answers_prostat', normalizedAnswers);
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
    return await db.query('penyakit_prostat');
  }

  // Fungsi untuk mendapatkan jawaban user terbaru
  Future<Map<String, dynamic>?> getLatestUserAnswers() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'user_answers_prostat',
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

    // Bobot untuk setiap gejala
    final Map<String, double> symptomWeights = {
      'riwayat_keluarga': 10.0,
      'usia_lebih_50': 8.0,
      'kesulitan_buang_air': 9.0,
      'sering_buang_air': 7.0,
      'bangun_malam_kencing': 7.0,
      'aliran_urine_lemah': 8.0,
      'mengedan_kencing': 6.0,
      'urine_terputus': 6.0,
      'rasa_tidak_tuntas': 5.0,
      'nyeri_saat_kencing': 8.0,
      'darah_urine': 10.0,
      'darah_air_mani': 10.0,
      'nyeri_panggul': 9.0,
      'nyeri_punggung': 7.0,
      'disfungsi_ereksi': 6.0,
      'penurunan_berat': 9.0,
      'ras_afrika': 4.0,
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
    final double riskPercentage = (userPositiveWeight / totalPossibleWeight) * 100;
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
    final List<Map<String, dynamic>> diagnosisResults = [
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