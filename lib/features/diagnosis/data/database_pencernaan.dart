import 'package:primafit/core/database/local_db.dart';
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
    if (_database?.isOpen ?? false) return _database!;
    _database = await _initDB('pencernaan_diagnosa.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await LocalDb.open(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Tabel untuk menyimpan data penyakit dan gejala
    await db.execute('''
    CREATE TABLE penyakit_pencernaan (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nama_penyakit TEXT NOT NULL,
          nyeri_perut TEXT,
          kembung TEXT,
          mual TEXT,
          muntah TEXT,
          diare TEXT,
          konstipasi TEXT,
          perubahan_bab TEXT,
          feses_berdarah TEXT,
          nyeri_bab TEXT,
          penurunan_nafsu_makan TEXT,
          penurunan_bb TEXT,
          heartburn TEXT,
          regurgitasi TEXT,
          sulit_menelan TEXT,
          nyeri_menelan TEXT,
          rasa_pahit_mulut TEXT,
          kenyang_cepat TEXT,
          kentut_berlebihan TEXT,
          kulit_kuning TEXT,
          gatal_tubuh TEXT,
          urin_gelap TEXT,
          feses_pucat TEXT,
          demam TEXT,
          gejala_anemia TEXT,
          perut_berdebar TEXT
        )
    ''');

    // Tabel untuk menyimpan jawaban pengguna untuk sesi diagnosa saat ini
    await db.execute('''
    CREATE TABLE user_answers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nyeri_perut TEXT,
      kembung TEXT,
      mual TEXT,
      muntah TEXT,
      diare TEXT,
      konstipasi TEXT,
      perubahan_bab TEXT,
      feses_berdarah TEXT,
      nyeri_bab TEXT,
      penurunan_nafsu_makan TEXT,
      penurunan_bb TEXT,
      heartburn TEXT,
      regurgitasi TEXT,
      sulit_menelan TEXT,
      nyeri_menelan TEXT,
      rasa_pahit_mulut TEXT,
      kenyang_cepat TEXT,
      kentut_berlebihan TEXT,
      kulit_kuning TEXT,
      gatal_tubuh TEXT,
      urin_gelap TEXT,
      feses_pucat TEXT,
      demam TEXT,
      gejala_anemia TEXT,
      perut_berdebar TEXT,
      created_at TEXT
    )
    ''');
  }

  // Fungsi untuk mengimport data dari file CSV ke database SQLite
  Future<bool> importCSV() async {
    try {
      final db = await database;
      
      // Periksa apakah data sudah diimpor (untuk menghindari import berulang)
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM penyakit_pencernaan'));
      if (count != null && count > 0) {
        debugPrint('Data sudah ada di database, skip import');
        return true;
      }

      // Baca file CSV dari assets
      late String csvString;
      try {
        csvString = await rootBundle.loadString('assets/csv/pencernaan.csv');
        debugPrint('File CSV berhasil dibaca');
      } catch (e) {
        debugPrint('Error membaca file CSV: $e');
        // Coba path alternatif jika path default gagal
        try {
          csvString = await rootBundle.loadString('assets/csv/pencernaan.csv');
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
        batch.insert('penyakit_pencernaan', rowData);
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
    return await db.query('penyakit_pencernaan');
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
      'nyeri_perut',
      'kembung',
      'mual',
      'muntah',
      'diare',
      'konstipasi',
      'perubahan_bab',
      'feses_berdarah',
      'nyeri_bab',
      'penurunan_nafsu_makan',
      'penurunan_bb',
      'heartburn',
      'regurgitasi',
      'sulit_menelan',
      'nyeri_menelan',
      'rasa_pahit_mulut',
      'kenyang_cepat',
      'kentut_berlebihan',
      'kulit_kuning',
      'gatal_tubuh',
      'urin_gelap',
      'feses_pucat',
      'demam',
      'gejala_anemia',
      'perut_berdebar'
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

    // Definisikan bobot untuk setiap gejala sistem pencernaan (gejala yang lebih spesifik memiliki bobot lebih tinggi)
    final Map<String, double> symptomWeights = {
      // Nyeri perut (gejala umum tetapi penting, bobot sedang)
      'nyeri_perut': 0.6,

      // Gejala kembung (relatif umum, bobot sedang)
      'kembung': 0.5,

      // Gejala mual dan muntah (lebih spesifik, bobot sedang-tinggi)
      'mual': 0.6,
      'muntah': 0.7,

      // Gejala buang air besar (spesifik untuk kondisi tertentu)
      'diare': 0.7,
      'konstipasi': 0.7,
      'perubahan_bab': 0.7,
      'feses_berdarah': 1.0,  // Sangat signifikan diagnostik
      'nyeri_bab': 0.8,

      // Gejala sistemik (beragam bobot tergantung spesifisitas)
      'penurunan_nafsu_makan': 0.6,
      'penurunan_bb': 0.7,

      // Gejala refluks (spesifik untuk GERD dan kondisi terkait)
      'heartburn': 0.8,
      'regurgitasi': 0.9,

      // Gejala esofagus (spesifik untuk gangguan esofagus)
      'sulit_menelan': 0.9,
      'nyeri_menelan': 0.9,
      'rasa_pahit_mulut': 0.8,

      // Gejala lambung (spesifik untuk gangguan lambung)
      'kenyang_cepat': 0.8,
      'kentut_berlebihan': 0.6,

      // Gejala hepatobilier (sangat spesifik, bobot tinggi)
      'kulit_kuning': 1.0,  // Sangat diagnostik untuk kondisi hati/empedu
      'gatal_tubuh': 0.8,
      'urin_gelap': 0.9,
      'feses_pucat': 0.9,

      // Gejala umum (bobot rendah-sedang karena kurang spesifik)
      'demam': 0.6,
      'gejala_anemia': 0.8,
      'perut_berdebar': 0.7,
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

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}