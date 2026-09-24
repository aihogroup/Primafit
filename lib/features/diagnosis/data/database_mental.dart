import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:csv/csv.dart';
import 'diagnosis_history_database.dart'; // Import file history database

class DatabaseHelper with DiagnosisHistoryMixin {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mental_diagnosa.db');
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
    CREATE TABLE penyakit_mental (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama_penyakit TEXT NOT NULL,
      perasaan_sedih TEXT,
      sedih_berkelanjutan TEXT,
      kehilangan_minat TEXT,
      kehilangan_minat_durasi TEXT,
      kecemasan_berlebihan TEXT,
      cemas_mengganggu TEXT,
      serangan_panik TEXT,
      gejala_fisik_panik TEXT,
      gangguan_tidur TEXT,
      tipe_gangguan_tidur TEXT,
      mudah_marah TEXT,
      kontrol_emosi TEXT,
      sulit_konsentrasi TEXT,
      konsentrasi_mengganggu TEXT,
      perubahan_nafsu_makan TEXT,
      nafsu_makan_meningkat TEXT,
      pikiran_menyakiti_diri TEXT,
      rencana_bunuh_diri TEXT,
      perasaan_tidak_berharga TEXT,
      bersalah_persisten TEXT,
      menarik_diri TEXT,
      isolasi_sengaja TEXT,
      delusi TEXT,
      tipe_delusi TEXT,
      halusinasi TEXT,
      jenis_halusinasi TEXT,
      perubahan_suasana_hati TEXT,
      mood_swing_cepat TEXT,
      perilaku_kompulsif TEXT,
      waktu_kompulsi TEXT,
      kehilangan_motivasi TEXT,
      kehilangan_energi_fisik TEXT,
      takut_sosial TEXT,
      menghindari_sosial TEXT,
      kecanduan TEXT,
      dampak_kecanduan TEXT,
      masalah_identitas TEXT,
      perubahan_identitas TEXT,
      perilaku_impulsif TEXT,
      menyesal_impulsif TEXT,
      disosiasi TEXT,
      disosiasi_sering TEXT,
      mimpi_buruk TEXT,
      mimpi_trauma TEXT,
      ketergantungan_emosional TEXT,
      takut_ditinggalkan TEXT,
      kesulitan_fungsi TEXT,
      bantuan_fungsi TEXT,
      gejala_somatik TEXT,
      intensitas_somatik TEXT
    )
    ''');

    // Tabel untuk menyimpan jawaban pengguna untuk sesi diagnosa saat ini
    await db.execute('''
    CREATE TABLE user_answers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      perasaan_sedih TEXT,
      sedih_berkelanjutan TEXT,
      kehilangan_minat TEXT,
      kehilangan_minat_durasi TEXT,
      kecemasan_berlebihan TEXT,
      cemas_mengganggu TEXT,
      serangan_panik TEXT,
      gejala_fisik_panik TEXT,
      gangguan_tidur TEXT,
      tipe_gangguan_tidur TEXT,
      mudah_marah TEXT,
      kontrol_emosi TEXT,
      sulit_konsentrasi TEXT,
      konsentrasi_mengganggu TEXT,
      perubahan_nafsu_makan TEXT,
      nafsu_makan_meningkat TEXT,
      pikiran_menyakiti_diri TEXT,
      rencana_bunuh_diri TEXT,
      perasaan_tidak_berharga TEXT,
      bersalah_persisten TEXT,
      menarik_diri TEXT,
      isolasi_sengaja TEXT,
      delusi TEXT,
      tipe_delusi TEXT,
      halusinasi TEXT,
      jenis_halusinasi TEXT,
      perubahan_suasana_hati TEXT,
      mood_swing_cepat TEXT,
      perilaku_kompulsif TEXT,
      waktu_kompulsi TEXT,
      kehilangan_motivasi TEXT,
      kehilangan_energi_fisik TEXT,
      takut_sosial TEXT,
      menghindari_sosial TEXT,
      kecanduan TEXT,
      dampak_kecanduan TEXT,
      masalah_identitas TEXT,
      perubahan_identitas TEXT,
      perilaku_impulsif TEXT,
      menyesal_impulsif TEXT,
      disosiasi TEXT,
      disosiasi_sering TEXT,
      mimpi_buruk TEXT,
      mimpi_trauma TEXT,
      ketergantungan_emosional TEXT,
      takut_ditinggalkan TEXT,
      kesulitan_fungsi TEXT,
      bantuan_fungsi TEXT,
      gejala_somatik TEXT,
      intensitas_somatik TEXT,
      created_at TEXT
    )
    ''');
  }

  // Fungsi untuk mengimport data dari file CSV ke database SQLite
  Future<bool> importCSV() async {
    try {
      final db = await database;
      
      // Periksa apakah data sudah diimpor (untuk menghindari import berulang)
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM penyakit_mental'));
      if (count != null && count > 0) {
        debugPrint('Data sudah ada di database, skip import');
        return true;
      }

      // Baca file CSV dari assets
      late String csvString;
      try {
        csvString = await rootBundle.loadString('assets/csv/mental.csv');
        debugPrint('File CSV berhasil dibaca');
      } catch (e) {
        debugPrint('Error membaca file CSV: $e');
        // Coba path alternatif jika path default gagal
        try {
          csvString = await rootBundle.loadString('assets/csv/mental.csv');
          debugPrint('File CSV berhasil dibaca dari path alternatif');
        } catch (e) {
          debugPrint('Error membaca file CSV dari semua path: $e');
          return false;
        }
      }

      // Parse CSV
      List<List<dynamic>> csvData;
      try {
        csvData = const CsvToListConverter().convert(csvString, eol: '\n');
        debugPrint('CSV berhasil diconvert, ${csvData.length} baris ditemukan');
      } catch (e) {
        debugPrint('Error parsing CSV: $e');
        return false;
      }

      if (csvData.isEmpty) {
        debugPrint('CSV tidak memiliki data');
        return false;
      }

      // Extract headers dan normalisasi
      final List<String> headers = [];
      for (var header in csvData[0]) {
        // Normalisasi header
        String normalizedHeader = header.toString().trim().toLowerCase();
        
        // Khusus untuk kolom pertama, ganti 'penyakit' menjadi 'nama_penyakit'
        if (normalizedHeader == 'penyakit') {
          normalizedHeader = 'nama_penyakit';
        }
        
        headers.add(normalizedHeader);
      }

      debugPrint('Headers: $headers');

      // Periksa apakah headers valid
      if (!headers.contains('nama_penyakit')) {
        debugPrint('Header CSV tidak valid: tidak ada kolom nama_penyakit');
        return false;
      }

      // Insert each row into database dengan batch untuk kinerja lebih baik
      final Batch batch = db.batch();
      int importedRows = 0;

      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        if (row.length != headers.length) {
          debugPrint('Baris ${i+1} memiliki jumlah kolom yang tidak sesuai, melewati...');
          continue;
        }

        final Map<String, dynamic> rowData = {};

        // Map data berdasarkan header yang sudah dinormalisasi
        for (int j = 0; j < headers.length && j < row.length; j++) {
          String value = row[j].toString().trim();
          
          // Normalisasi nilai Ya/Tidak/Kadang
          if (value.toLowerCase() == 'ya') {
            value = 'Ya';
          } else if (value.toLowerCase() == 'tidak') value = 'Tidak';
          else if (value.toLowerCase() == 'kadang') value = 'Kadang';
          
          rowData[headers[j]] = value;
        }

        // Insert into database batch
        batch.insert('penyakit_mental', rowData);
        importedRows++;
      }

      // Execute batch
      await batch.commit(noResult: true);
      debugPrint('Import CSV berhasil, $importedRows baris berhasil diimport');
      return true;
    } catch (e) {
      debugPrint('Error importing CSV: $e');
      return false;
    }
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
          // Standarisasi format Ya/Tidak/Kadang
          if (normalizedValue.toLowerCase() == 'ya') {
            normalizedValue = 'Ya';
          } else if (normalizedValue.toLowerCase() == 'tidak') normalizedValue = 'Tidak';
          else if (normalizedValue.toLowerCase() == 'kadang') normalizedValue = 'Kadang';
          
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
    return await db.query('penyakit_mental');
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
      return [];
    }
    
    debugPrint('Ditemukan ${diseases.length} data penyakit');

    // Daftar kolom gejala
    final List<String> symptomColumns = [
      'perasaan_sedih',
      'sedih_berkelanjutan',
      'kehilangan_minat',
      'kehilangan_minat_durasi',
      'kecemasan_berlebihan',
      'cemas_mengganggu',
      'serangan_panik',
      'gejala_fisik_panik',
      'gangguan_tidur',
      'tipe_gangguan_tidur',
      'mudah_marah',
      'kontrol_emosi',
      'sulit_konsentrasi',
      'konsentrasi_mengganggu',
      'perubahan_nafsu_makan',
      'nafsu_makan_meningkat',
      'pikiran_menyakiti_diri',
      'rencana_bunuh_diri',
      'perasaan_tidak_berharga',
      'bersalah_persisten',
      'menarik_diri',
      'isolasi_sengaja',
      'delusi',
      'tipe_delusi',
      'halusinasi',
      'jenis_halusinasi',
      'perubahan_suasana_hati',
      'mood_swing_cepat',
      'perilaku_kompulsif',
      'waktu_kompulsi',
      'kehilangan_motivasi',
      'kehilangan_energi_fisik',
      'takut_sosial',
      'menghindari_sosial',
      'kecanduan',
      'dampak_kecanduan',
      'masalah_identitas',
      'perubahan_identitas',
      'perilaku_impulsif',
      'menyesal_impulsif',
      'disosiasi',
      'disosiasi_sering',
      'mimpi_buruk',
      'mimpi_trauma',
      'ketergantungan_emosional',
      'takut_ditinggalkan',
      'kesulitan_fungsi',
      'bantuan_fungsi',
      'gejala_somatik',
      'intensitas_somatik',
    ];

    // Hasil diagnosa dengan persentase kecocokan
    final List<Map<String, dynamic>> diagnosisResults = [];
    
    // Dictionary untuk melacak jawaban pengguna per gejala yang valid
    final Map<String, String> validUserAnswers = {};
    
    // Verifikasi jawaban pengguna dan konversi ke format standar
    for (var symptom in symptomColumns) {
      if (userAnswers[symptom] != null) {
        final String answer = userAnswers[symptom].toString().trim();
        // Standarisasi jawaban
        if (answer.toLowerCase() == 'ya') {
          validUserAnswers[symptom] = 'Ya';
        } else if (answer.toLowerCase() == 'tidak') {
          validUserAnswers[symptom] = 'Tidak';
        } else if (answer.toLowerCase() == 'kadang') {
          validUserAnswers[symptom] = 'Kadang';
        } else {
          // Jawaban tidak valid, gunakan default
          validUserAnswers[symptom] = 'Tidak';
        }
      } else {
        // Jika tidak ada jawaban, gunakan default
        validUserAnswers[symptom] = 'Tidak';
      }
    }
    
    debugPrint('Jawaban pengguna yang valid: $validUserAnswers');

    // Hitung kemiripan untuk setiap penyakit
    for (var disease in diseases) {
      int totalSymptoms = 0;
      int matchedSymptoms = 0;
      final Map<String, bool> matchedDetails = {};
      
      // Periksa setiap gejala
      for (var symptom in symptomColumns) {
        // Jika data gejala tersedia untuk penyakit ini
        if (disease[symptom] != null) {
          final String diseaseValue = disease[symptom].toString().trim();
          final String userValue = validUserAnswers[symptom] ?? 'Tidak';
          
          // Hanya perhatikan gejala yang relevan (bukan nilai kosong atau default)
          if (diseaseValue.isNotEmpty && diseaseValue != '-') {
            totalSymptoms++;
            
            // Perbandingan langsung (Lebih akurat untuk Ya/Tidak/Kadang)
            if (diseaseValue == userValue) {
              matchedSymptoms++;
              matchedDetails[symptom] = true;
            } 
            // Penanganan khusus untuk "Kadang"
            else if (userValue == 'Kadang' && diseaseValue == 'Ya') {
              // "Kadang" dihitung sebagai setengah kecocokan dengan "Ya"
              matchedSymptoms += 0.5.toInt();
              matchedDetails[symptom] = true;
            }
          }
        }
      }

      // Hitung persentase kecocokan
      final double matchPercentage = totalSymptoms > 0 
        ? (matchedSymptoms / totalSymptoms) * 100 
        : 0.0;
      
      // Atur minimum threshold yang lebih rendah untuk mendapatkan hasil
      // bahkan jika kecocokan tidak terlalu tinggi
      if (matchPercentage >= threshold || 
          (diagnosisResults.isEmpty && matchPercentage >= threshold * 0.8)) {
        diagnosisResults.add({
          'penyakit': disease['nama_penyakit'],
          'persentase': matchPercentage,
          'matched_symptoms': matchedSymptoms,
          'total_symptoms': totalSymptoms,
          'matched_details': matchedDetails,
        });
      }
    }

    // Urutkan hasil berdasarkan persentase kecocokan (dari tertinggi ke terendah)
    diagnosisResults.sort((a, b) => b['persentase'].compareTo(a['persentase']));
    
    // Pastikan selalu mengembalikan setidaknya 1 hasil dengan persentase tertinggi
    if (diagnosisResults.isEmpty && diseases.isNotEmpty) {
      // Jika tidak ada hasil yang memenuhi threshold, tampilkan hasil terbaik
      double highestPercentage = 0;
      Map<String, dynamic>? bestMatch;
      
      for (var disease in diseases) {
        int matched = 0, total = 0;
        final Map<String, bool> details = {};
        
        for (var symptom in symptomColumns) {
          if (disease[symptom] != null && disease[symptom].toString().trim().isNotEmpty) {
            total++;
            if (disease[symptom].toString().trim() == (validUserAnswers[symptom] ?? 'Tidak')) {
              matched++;
              details[symptom] = true;
            }
          }
        }
        
        final double percentage = total > 0 ? (matched / total) * 100 : 0;
        if (percentage > highestPercentage) {
          highestPercentage = percentage;
          bestMatch = {
            'penyakit': disease['nama_penyakit'],
            'persentase': percentage,
            'matched_symptoms': matched,
            'total_symptoms': total,
            'matched_details': details,
          };
        }
      }
      
      if (bestMatch != null) {
        diagnosisResults.add(bestMatch);
        debugPrint('Tidak ada hasil yang memenuhi threshold, menampilkan hasil terbaik: ${bestMatch['penyakit']} (${bestMatch['persentase']}%)');
      }
    }
    
    debugPrint('Hasil diagnosa: ${diagnosisResults.length} penyakit ditemukan');
    for (var result in diagnosisResults) {
      debugPrint('- ${result['penyakit']}: ${result['persentase'].toStringAsFixed(1)}%');
    }

    // 🔥 AUTO-SAVE KE HISTORY DATABASE (INTEGRASI UTAMA)
    if (diagnosisResults.isNotEmpty && userAnswers.isNotEmpty) {
      debugPrint('💾 Auto-saving diagnosis to history...');
      
      // Simpan ke history menggunakan mixin
      await saveToHistory(
        kategoriPenyakit: 'Penyakit Umum', // Sesuaikan dengan kategori database Anda
        diagnosisResults: diagnosisResults,
        userAnswers: userAnswers,
        metodeDiagnosa: 'standard',
      );
      
      debugPrint('✅ Diagnosis history auto-saved successfully!');
    }

    return diagnosisResults;
  }

  // Metode alternatif menggunakan algoritma pencocokan berbobot
  Future<List<Map<String, dynamic>>> getWeightedDiagnosisResult(double threshold) async {
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
      return [];
    }
    
    debugPrint('Ditemukan ${diseases.length} data penyakit');

    // Definisikan bobot untuk setiap gejala (gejala yang lebih spesifik memiliki bobot lebih tinggi)
    final Map<String, double> symptomWeights = {
      'perasaan_sedih': 0.7,
      'sedih_berkelanjutan': 0.9,
      'kehilangan_minat': 0.8,
      'kehilangan_minat_durasi': 0.9,
      'kecemasan_berlebihan': 0.8,
      'cemas_mengganggu': 0.9,
      'serangan_panik': 1.0,
      'gejala_fisik_panik': 0.9,
      'gangguan_tidur': 0.7,
      'tipe_gangguan_tidur': 0.8,
      'mudah_marah': 0.6,
      'kontrol_emosi': 0.7,
      'sulit_konsentrasi': 0.7,
      'konsentrasi_mengganggu': 0.8,
      'perubahan_nafsu_makan': 0.6,
      'nafsu_makan_meningkat': 0.5,
      'pikiran_menyakiti_diri': 1.0,
      'rencana_bunuh_diri': 1.0,
      'perasaan_tidak_berharga': 0.9,
      'bersalah_persisten': 0.8,
      'menarik_diri': 0.7,
      'isolasi_sengaja': 0.8,
      'delusi': 1.0,
      'tipe_delusi': 0.9,
      'halusinasi': 1.0,
      'jenis_halusinasi': 0.9,
      'perubahan_suasana_hati': 0.7,
      'mood_swing_cepat': 0.9,
      'perilaku_kompulsif': 0.8,
      'waktu_kompulsi': 0.7,
      'kehilangan_motivasi': 0.8,
      'kehilangan_energi_fisik': 0.7,
      'takut_sosial': 0.6,
      'menghindari_sosial': 0.7,
      'kecanduan': 0.8,
      'dampak_kecanduan': 0.9,
      'masalah_identitas': 0.8,
      'perubahan_identitas': 0.9,
      'perilaku_impulsif': 0.7,
      'menyesal_impulsif': 0.6,
      'disosiasi': 0.8,
      'disosiasi_sering': 0.9,
      'mimpi_buruk': 0.7,
      'mimpi_trauma': 0.9,
      'ketergantungan_emosional': 0.7,
      'takut_ditinggalkan': 0.8,
      'kesulitan_fungsi': 0.8,
      'bantuan_fungsi': 0.9,
      'gejala_somatik': 0.6,
      'intensitas_somatik': 0.7,
    };

    // Hasil diagnosa dengan persentase kecocokan
    final List<Map<String, dynamic>> diagnosisResults = [];
    
    // Dictionary untuk melacak jawaban pengguna per gejala yang valid
    final Map<String, String> validUserAnswers = {};
    
    // Verifikasi jawaban pengguna dan konversi ke format standar
    for (var symptom in symptomWeights.keys) {
      if (userAnswers[symptom] != null) {
        final String answer = userAnswers[symptom].toString().trim();
        // Standarisasi jawaban
        if (answer.toLowerCase() == 'ya') {
          validUserAnswers[symptom] = 'Ya';
        } else if (answer.toLowerCase() == 'tidak') {
          validUserAnswers[symptom] = 'Tidak';
        } else if (answer.toLowerCase() == 'kadang') {
          validUserAnswers[symptom] = 'Kadang';
        } else {
          validUserAnswers[symptom] = 'Tidak';
        }
      } else {
        validUserAnswers[symptom] = 'Tidak';
      }
    }

    // Hitung kemiripan untuk setiap penyakit
    for (var disease in diseases) {
      double totalWeight = 0.0;
      double matchedWeight = 0.0;
      int matchedSymptoms = 0;
      int totalSymptoms = 0;
      
      // Map untuk melacak gejala yang cocok
      final Map<String, bool> matchedSymptomDetails = {};

      // Periksa setiap gejala
      for (var symptom in symptomWeights.keys) {
        // Jika data gejala tersedia untuk penyakit ini
        if (disease[symptom] != null) {
          final String diseaseValue = disease[symptom].toString().trim();
          final String userValue = validUserAnswers[symptom] ?? 'Tidak';
          
          // Hanya perhatikan gejala yang relevan (bukan nilai kosong atau default)
          if (diseaseValue.isNotEmpty && diseaseValue != '-') {
            final double weight = symptomWeights[symptom] ?? 0.5;  // Default weight if not specified
            totalWeight += weight;
            totalSymptoms++;
            
            // Untuk jawaban 'Ya', periksa apakah penyakit memang menunjukkan gejala tersebut
            if (userValue == 'Ya' && diseaseValue == 'Ya') {
              matchedWeight += weight;
              matchedSymptoms++;
              matchedSymptomDetails[symptom] = true;
            } 
            // Untuk jawaban 'Tidak', periksa apakah penyakit memang tidak menunjukkan gejala
            else if (userValue == 'Tidak' && diseaseValue == 'Tidak') {
              matchedWeight += weight * 0.5; // Kecocokan 'Tidak' diberi bobot lebih rendah
              matchedSymptoms++;
              matchedSymptomDetails[symptom] = true;
            }
            // Untuk jawaban 'Kadang', periksa kemiripan
            else if (userValue == 'Kadang') {
              // Kadang dianggap setengah cocok dengan 'Ya'
              if (diseaseValue == 'Ya') {
                matchedWeight += weight * 0.7;
                matchedSymptoms++;
                matchedSymptomDetails[symptom] = true;
              }
              // Dan seperempat cocok dengan 'Tidak'
              else if (diseaseValue == 'Tidak') {
                matchedWeight += weight * 0.3;
                matchedSymptomDetails[symptom] = true;
              }
            }
          }
        }
      }

      // Hitung persentase kecocokan berbobot
      final double weightedPercentage = totalWeight > 0 
        ? (matchedWeight / totalWeight) * 100 
        : 0.0;
      
      // Atur minimum threshold yang lebih rendah untuk mendapatkan hasil
      // bahkan jika kecocokan tidak terlalu tinggi
      if (weightedPercentage >= threshold || 
          (diagnosisResults.isEmpty && weightedPercentage >= threshold * 0.8)) {
        diagnosisResults.add({
          'penyakit': disease['nama_penyakit'],
          'persentase': weightedPercentage,
          'matched_symptoms': matchedSymptoms,
          'total_symptoms': totalSymptoms,
          'matched_details': matchedSymptomDetails,
        });
      }
    }

    // Urutkan hasil berdasarkan persentase kecocokan (dari tertinggi ke terendah)
    diagnosisResults.sort((a, b) => b['persentase'].compareTo(a['persentase']));
    
    // Pastikan selalu mengembalikan setidaknya 1 hasil dengan persentase tertinggi
    if (diagnosisResults.isEmpty && diseases.isNotEmpty) {
      // Jika tidak ada hasil yang memenuhi threshold, tampilkan hasil terbaik
      double highestPercentage = 0;
      Map<String, dynamic>? bestMatch;
      
      for (var disease in diseases) {
        double totalWeight = 0.0, matchedWeight = 0.0;
        int matched = 0, total = 0;
        final Map<String, bool> details = {};
        
        for (var symptom in symptomWeights.keys) {
          if (disease[symptom] != null && disease[symptom].toString().trim().isNotEmpty && disease[symptom].toString().trim() != '-') {
            final double weight = symptomWeights[symptom] ?? 0.5;
            totalWeight += weight;
            total++;
            
            final String diseaseValue = disease[symptom].toString().trim();
            final String userValue = validUserAnswers[symptom] ?? 'Tidak';
            
            if (userValue == 'Ya' && diseaseValue == 'Ya') {
              matchedWeight += weight;
              matched++;
              details[symptom] = true;
            } else if (userValue == 'Tidak' && diseaseValue == 'Tidak') {
              matchedWeight += weight * 0.5;
              matched++;
              details[symptom] = true;
            } else if (userValue == 'Kadang' && diseaseValue == 'Ya') {
              matchedWeight += weight * 0.7;
              matched++;
              details[symptom] = true;
            }
          }
        }
        
        final double percentage = totalWeight > 0 ? (matchedWeight / totalWeight) * 100 : 0;
        if (percentage > highestPercentage) {
          highestPercentage = percentage;
          bestMatch = {
            'penyakit': disease['nama_penyakit'],
            'persentase': percentage,
            'matched_symptoms': matched,
            'total_symptoms': total,
            'matched_details': details,
          };
        }
      }
      
      if (bestMatch != null) {
        diagnosisResults.add(bestMatch);
        debugPrint('Tidak ada hasil yang memenuhi threshold, menampilkan hasil terbaik: ${bestMatch['penyakit']} (${bestMatch['persentase']}%)');
      }
    }
    
    debugPrint('Hasil diagnosa (weighted): ${diagnosisResults.length} penyakit ditemukan');
    for (var result in diagnosisResults) {
      debugPrint('- ${result['penyakit']}: ${result['persentase'].toStringAsFixed(1)}%');
    }

    // 🔥 AUTO-SAVE KE HISTORY DATABASE (INTEGRASI UTAMA)
    if (diagnosisResults.isNotEmpty && userAnswers.isNotEmpty) {
      debugPrint('💾 Auto-saving weighted diagnosis to history...');
      
      // Simpan ke history menggunakan mixin
      await saveToHistory(
        kategoriPenyakit: 'Penyakit Umum', // Sesuaikan dengan kategori database Anda
        diagnosisResults: diagnosisResults,
        userAnswers: userAnswers,
        metodeDiagnosa: 'weighted',
      );
      
      debugPrint('✅ Weighted diagnosis history auto-saved successfully!');
    }

    // 🔥 AUTO-SAVE KE HISTORY DATABASE (INTEGRASI UTAMA)
    if (diagnosisResults.isNotEmpty && userAnswers.isNotEmpty) {
      debugPrint('💾 Auto-saving weighted diagnosis to history...');
      
      // Simpan ke history menggunakan mixin
      await saveToHistory(
        kategoriPenyakit: 'Penyakit Umum', // Sesuaikan dengan kategori database Anda
        diagnosisResults: diagnosisResults,
        userAnswers: userAnswers,
        metodeDiagnosa: 'weighted',
      );
      
      debugPrint('✅ Weighted diagnosis history auto-saved successfully!');
    }

    return diagnosisResults;
  }

  // Fungsi untuk export hasil diagnosa ke CSV
  Future<String> exportDiagnosisResultToCSV(List<Map<String, dynamic>> results) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/diagnosis_result.csv';
      final file = File(path);
      
      // Buat konten CSV
      final List<List<dynamic>> csvData = [];
      
      // Header
      csvData.add(['Penyakit', 'Persentase Kecocokan', 'Gejala Cocok', 'Total Gejala']);
      
      // Data rows
      for (var result in results) {
        csvData.add([
          result['penyakit'],
          '${result['persentase'].toStringAsFixed(1)}%',
          result['matched_symptoms'],
          result['total_symptoms'],
        ]);
      }
      
      // Konversi ke string CSV
      final String csv = const ListToCsvConverter().convert(csvData);
      
      // Tulis ke file
      await file.writeAsString(csv);
      debugPrint('Hasil diagnosa berhasil diekspor ke CSV: $path');
      
      return path;
    } catch (e) {
      debugPrint('Error ekspor hasil diagnosa ke CSV: $e');
      return '';
    }
  }

  

  // 🆕 FUNGSI TAMBAHAN UNTUK INTEGRASI HISTORY

  // Fungsi untuk mendapatkan histori diagnosa penyakit umum
  Future<List<Map<String, dynamic>>> getDiagnosisHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? namaPenyakit,
    int? limit,
  }) async {
    try {
      final historyDB = DiagnosisHistoryDatabase.instance;
      return await historyDB.getDiagnosisHistory(
        kategoriPenyakit: 'Penyakit Umum',
        startDate: startDate,
        endDate: endDate,
        namaPenyakit: namaPenyakit,
        limit: limit,
      );
    } catch (e) {
      debugPrint('Error mendapatkan histori diagnosa: $e');
      return [];
    }
  }

  // Fungsi untuk mendapatkan statistik diagnosa penyakit umum
  Future<List<Map<String, dynamic>>> getDiagnosisStatistics() async {
    try {
      final historyDB = DiagnosisHistoryDatabase.instance;
      return await historyDB.getDiagnosisStatistics(kategoriPenyakit: 'Penyakit Umum');
    } catch (e) {
      debugPrint('Error mendapatkan statistik diagnosa: $e');
      return [];
    }
  }

  // Fungsi untuk export histori ke CSV
  Future<String> exportHistoryToCSV() async {
    try {
      final historyDB = DiagnosisHistoryDatabase.instance;
      return await historyDB.exportHistoryToCSV(kategoriPenyakit: 'Penyakit Umum');
    } catch (e) {
      debugPrint('Error export histori ke CSV: $e');
      return '';
    }
  }

  // Fungsi untuk menghapus histori diagnosa berdasarkan ID
  Future<bool> deleteDiagnosisHistory(int historyId) async {
    try {
      final historyDB = DiagnosisHistoryDatabase.instance;
      return await historyDB.deleteDiagnosisHistory(historyId);
    } catch (e) {
      debugPrint('Error menghapus histori diagnosa: $e');
      return false;
    }
  }

  // Fungsi untuk menghapus semua histori penyakit umum
  Future<bool> clearAllHistory() async {
    try {
      final historyDB = DiagnosisHistoryDatabase.instance;
      return await historyDB.deleteHistoryByCategory('Penyakit Umum');
    } catch (e) {
      debugPrint('Error menghapus semua histori: $e');
      return false;
    }
  }

  // Fungsi untuk mendapatkan detail gejala dari histori diagnosa
  Future<List<Map<String, dynamic>>> getHistorySymptomsDetail(int historyId) async {
    try {
      final historyDB = DiagnosisHistoryDatabase.instance;
      return await historyDB.getDiagnosisSymptomsDetail(historyId);
    } catch (e) {
      debugPrint('Error mendapatkan detail gejala histori: $e');
      return [];
    }
  }

  // Fungsi untuk mendapatkan jawaban pengguna dari histori
  Future<Map<String, dynamic>?> getHistoryUserAnswers(int historyId) async {
    try {
      final historyDB = DiagnosisHistoryDatabase.instance;
      return await historyDB.getUserAnswersFromHistory(historyId);
    } catch (e) {
      debugPrint('Error mendapatkan jawaban pengguna dari histori: $e');
      return null;
    }
  }

  // Fungsi untuk mendapatkan penyakit yang paling sering didiagnosa
  Future<Map<String, dynamic>?> getMostFrequentDiagnosis() async {
    try {
      final stats = await getDiagnosisStatistics();
      if (stats.isNotEmpty) {
        // Urutkan berdasarkan jumlah diagnosa
        stats.sort((a, b) => (b['jumlah_diagnosa'] as int).compareTo(a['jumlah_diagnosa'] as int));
        return stats.first;
      }
      return null;
    } catch (e) {
      debugPrint('Error mendapatkan diagnosa tersering: $e');
      return null;
    }
  }

  // Fungsi untuk mendapatkan rata-rata persentase kecocokan per penyakit
  Future<Map<String, double>> getAverageMatchPercentage() async {
    try {
      final stats = await getDiagnosisStatistics();
      final Map<String, double> averages = {};
      
      for (var stat in stats) {
        averages[stat['nama_penyakit']] = stat['rata_rata_persentase']?.toDouble() ?? 0.0;
      }
      
      return averages;
    } catch (e) {
      debugPrint('Error mendapatkan rata-rata persentase: $e');
      return {};
    }
  }

  // Fungsi untuk mendapatkan total jumlah diagnosa yang pernah dilakukan
  Future<int> getTotalDiagnosisCount() async {
    try {
      final history = await getDiagnosisHistory();
      return history.length;
    } catch (e) {
      debugPrint('Error mendapatkan total diagnosa: $e');
      return 0;
    }
  }

  // Fungsi untuk mengecek apakah ada diagnosa yang dilakukan hari ini
  Future<bool> hasDiagnosisToday() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final history = await getDiagnosisHistory(
        startDate: startOfDay,
        endDate: endOfDay,
        limit: 1,
      );
      
      return history.isNotEmpty;
    } catch (e) {
      debugPrint('Error mengecek diagnosa hari ini: $e');
      return false;
    }
  }

  // Fungsi untuk mendapatkan diagnosa terakhir
  Future<Map<String, dynamic>?> getLastDiagnosis() async {
    try {
      final history = await getDiagnosisHistory(limit: 1);
      if (history.isNotEmpty) {
        return history.first;
      }
      return null;
    } catch (e) {
      debugPrint('Error mendapatkan diagnosa terakhir: $e');
      return null;
    }
  }

  // Fungsi untuk melakukan diagnosa ulang berdasarkan histori
  Future<List<Map<String, dynamic>>> rediagnoseFromHistory(int historyId, {double? newThreshold}) async {
    try {
      // Ambil jawaban pengguna dari histori
      final historyAnswers = await getHistoryUserAnswers(historyId);
      if (historyAnswers == null || historyAnswers['jawaban'] == null) {
        debugPrint('Tidak dapat menemukan jawaban pengguna dari histori');
        return [];
      }

      // Simpan jawaban pengguna ke tabel user_answers sementara
      final answers = Map<String, dynamic>.from(historyAnswers['jawaban']);
      await saveUserAnswers(answers);

      // Lakukan diagnosa ulang
      final threshold = newThreshold ?? 60.0; // Default threshold
      final results = await getDiagnosisResult(threshold);

      debugPrint('Diagnosa ulang berhasil dilakukan dari histori ID: $historyId');
      return results;
    } catch (e) {
      debugPrint('Error melakukan diagnosa ulang: $e');
      return [];
    }
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}