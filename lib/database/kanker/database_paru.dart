import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Function to manually add sample data to the database
  Future<bool> addSampleData() async {
    try {
      final db = await database;
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM penyakit_paru'));
      if (count != null && count > 0) {
        debugPrint('Data already exists in database, skipping sample data addition');
        return true;
      }
      
      // Define sample risk categories
      List<Map<String, dynamic>> riskCategories = [
        {
          'nama_penyakit': 'Risiko Tinggi',
          'perokok_aktif': 'Ya',
          'perokok_pasif': 'Ya',
          'bekas_perokok': 'Ya',
          'riwayat_kanker': 'Ya',
          'riwayat_keluarga': 'Ya',
          'paparan_karsinogen': 'Ya',
          'polusi_tinggi': 'Ya',
          'rumah_tidak_sehat': 'Ya',
          'riwayat_penyakit_paru': 'Ya',
          'gejala_respirasi': 'Ya'
        },
        {
          'nama_penyakit': 'Risiko Sedang',
          'perokok_aktif': 'Ya',
          'perokok_pasif': 'Ya',
          'bekas_perokok': 'Tidak',
          'riwayat_kanker': 'Tidak',
          'riwayat_keluarga': 'Ya',
          'paparan_karsinogen': 'Ya',
          'polusi_tinggi': 'Ya',
          'rumah_tidak_sehat': 'Tidak',
          'riwayat_penyakit_paru': 'Tidak',
          'gejala_respirasi': 'Mungkin'
        },
        {
          'nama_penyakit': 'Risiko Rendah',
          'perokok_aktif': 'Tidak',
          'perokok_pasif': 'Ya',
          'bekas_perokok': 'Tidak',
          'riwayat_kanker': 'Tidak',
          'riwayat_keluarga': 'Tidak',
          'paparan_karsinogen': 'Tidak',
          'polusi_tinggi': 'Mungkin',
          'rumah_tidak_sehat': 'Tidak',
          'riwayat_penyakit_paru': 'Tidak',
          'gejala_respirasi': 'Tidak'
        },
        {
          'nama_penyakit': 'Tidak Ada Risiko',
          'perokok_aktif': 'Tidak',
          'perokok_pasif': 'Tidak',
          'bekas_perokok': 'Tidak',
          'riwayat_kanker': 'Tidak',
          'riwayat_keluarga': 'Tidak',
          'paparan_karsinogen': 'Tidak',
          'polusi_tinggi': 'Tidak',
          'rumah_tidak_sehat': 'Tidak',
          'riwayat_penyakit_paru': 'Tidak',
          'gejala_respirasi': 'Tidak'
        }
      ];
      
      // Use batch for better performance
      Batch batch = db.batch();
      for (var category in riskCategories) {
        batch.insert('penyakit_paru', category);
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
    _database = await _initDB('kankerparu_diagnosa.db');
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
    CREATE TABLE penyakit_paru (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_penyakit TEXT NOT NULL,
      perokok_aktif TEXT,
      perokok_pasif TEXT,
      bekas_perokok TEXT,
      riwayat_kanker TEXT,
      riwayat_keluarga TEXT,
      paparan_karsinogen TEXT,
      polusi_tinggi TEXT,
      rumah_tidak_sehat TEXT,
      riwayat_penyakit_paru TEXT,
      gejala_respirasi TEXT
    )
    ''');

    // Tabel untuk menyimpan jawaban pengguna untuk sesi diagnosa saat ini
    await db.execute('''
    CREATE TABLE user_answers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      perokok_aktif TEXT,
      perokok_pasif TEXT,
      bekas_perokok TEXT,
      riwayat_kanker TEXT,
      riwayat_keluarga TEXT,
      paparan_karsinogen TEXT,
      polusi_tinggi TEXT,
      rumah_tidak_sehat TEXT,
      riwayat_penyakit_paru TEXT,
      gejala_respirasi TEXT,
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
          else if (normalizedValue.toLowerCase() == 'Mungkin') normalizedValue = 'Mungkin';
          
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
        await txn.delete('user_answers');
        
        // Simpan jawaban baru
        insertId = await txn.insert('user_answers', normalizedAnswers);
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
    return await db.query('penyakit_paru');
  }

  // Fungsi untuk mendapatkan jawaban user terbaru
  Future<Map<String, dynamic>?> getLatestUserAnswers() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'user_answers',
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
      'perokok_aktif',
      'perokok_pasif',
      'bekas_perokok',
      'riwayat_kanker',
      'riwayat_keluarga',
      'paparan_karsinogen',
      'polusi_tinggi',
      'rumah_tidak_sehat',
      'riwayat_penyakit_paru',
      'gejala_respirasi',
    ];

    // Bobot untuk setiap gejala
final Map<String, double> symptomWeights = {
  'perokok_aktif': 50.0,
  'perokok_pasif': 35.0,
  'bekas_perokok': 40.0,
  'riwayat_kanker': 9.0,
  'riwayat_keluarga': 6.0,
  'paparan_karsinogen': 8.0,
  'polusi_tinggi': 7.0,
  'rumah_tidak_sehat': 6.0,
  'riwayat_penyakit_paru': 8.0,
  'gejala_respirasi': 9.0,
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


    // Determine risk category - Align with PenyakitParu.penyakitInfo categories
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