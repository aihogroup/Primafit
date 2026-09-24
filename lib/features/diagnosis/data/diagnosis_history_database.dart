import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:csv/csv.dart';

class DiagnosisHistoryDatabase {
  static final DiagnosisHistoryDatabase instance = DiagnosisHistoryDatabase._init();
  static Database? _database;

  DiagnosisHistoryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('diagnosis_history.db');
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
    // Tabel utama untuk menyimpan histori diagnosa
    await db.execute('''
    CREATE TABLE diagnosis_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      kategori_penyakit TEXT NOT NULL,
      nama_penyakit TEXT NOT NULL,
      persentase_kecocokan REAL NOT NULL,
      gejala_cocok INTEGER NOT NULL,
      total_gejala INTEGER NOT NULL,
      metode_diagnosa TEXT NOT NULL DEFAULT 'standard',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
    ''');

    // Tabel untuk menyimpan detail gejala yang cocok per diagnosa
    await db.execute('''
    CREATE TABLE diagnosis_symptoms_detail (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      diagnosis_history_id INTEGER NOT NULL,
      nama_gejala TEXT NOT NULL,
      nilai_gejala TEXT NOT NULL,
      is_matched INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (diagnosis_history_id) REFERENCES diagnosis_history (id) ON DELETE CASCADE
    )
    ''');

    // Tabel untuk menyimpan jawaban pengguna per sesi diagnosa
    await db.execute('''
    CREATE TABLE user_answers_history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      diagnosis_history_id INTEGER NOT NULL,
      kategori_penyakit TEXT NOT NULL,
      jawaban_json TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (diagnosis_history_id) REFERENCES diagnosis_history (id) ON DELETE CASCADE
    )
    ''');

    // Tabel untuk menyimpan statistik diagnosa
    await db.execute('''
    CREATE TABLE diagnosis_statistics (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      kategori_penyakit TEXT NOT NULL,
      nama_penyakit TEXT NOT NULL,
      jumlah_diagnosa INTEGER NOT NULL DEFAULT 1,
      rata_rata_persentase REAL NOT NULL,
      first_diagnosed TEXT NOT NULL,
      last_diagnosed TEXT NOT NULL
    )
    ''');

    // Buat index untuk optimasi query
    await db.execute('CREATE INDEX idx_diagnosis_kategori ON diagnosis_history(kategori_penyakit)');
    await db.execute('CREATE INDEX idx_diagnosis_created_at ON diagnosis_history(created_at)');
    await db.execute('CREATE INDEX idx_diagnosis_nama_penyakit ON diagnosis_history(nama_penyakit)');
    await db.execute('CREATE INDEX idx_statistics_kategori ON diagnosis_statistics(kategori_penyakit)');
  }

  // Fungsi utama untuk auto-save histori (dipanggil otomatis dari database lain)
  static Future<void> autoSaveDiagnosisHistory({
    required String kategoriPenyakit,
    required List<Map<String, dynamic>> diagnosisResults,
    required Map<String, dynamic> userAnswers,
    String metodeDiagnosa = 'standard',
  }) async {
    try {
      debugPrint('🔄 Auto-saving diagnosis history for category: $kategoriPenyakit');
      
      final historyDB = DiagnosisHistoryDatabase.instance;
      await historyDB.saveDiagnosisToHistory(
        kategoriPenyakit: kategoriPenyakit,
        diagnosisResults: diagnosisResults,
        userAnswers: userAnswers,
        metodeDiagnosa: metodeDiagnosa,
      );
      
      debugPrint('✅ Diagnosis history auto-saved successfully for: $kategoriPenyakit');
    } catch (e) {
      debugPrint('❌ Error auto-saving diagnosis history: $e');
      // Tidak throw error agar tidak mengganggu proses diagnosa utama
    }
  }

  // Fungsi untuk menyimpan hasil diagnosa ke histori
  Future<int> saveDiagnosisToHistory({
    required String kategoriPenyakit,
    required List<Map<String, dynamic>> diagnosisResults,
    required Map<String, dynamic> userAnswers,
    String metodeDiagnosa = 'standard',
  }) async {
    final db = await database;
    final timestamp = DateTime.now().toIso8601String();
    
    try {
      int mainHistoryId = 0;
      
      await db.transaction((txn) async {
        // Simpan diagnosa utama (hasil teratas)
        if (diagnosisResults.isNotEmpty) {
          final topResult = diagnosisResults.first;
          
          mainHistoryId = await txn.insert('diagnosis_history', {
            'kategori_penyakit': kategoriPenyakit,
            'nama_penyakit': topResult['penyakit'],
            'persentase_kecocokan': topResult['persentase'],
            'gejala_cocok': topResult['matched_symptoms'],
            'total_gejala': topResult['total_symptoms'],
            'metode_diagnosa': metodeDiagnosa,
            'created_at': timestamp,
            'updated_at': timestamp,
          });

          // Simpan detail gejala yang cocok
          if (topResult['matched_details'] != null) {
            final Map<String, bool> matchedDetails = Map<String, bool>.from(topResult['matched_details']);
            
            for (var entry in userAnswers.entries) {
              if (entry.key != 'id' && entry.key != 'created_at') {
                await txn.insert('diagnosis_symptoms_detail', {
                  'diagnosis_history_id': mainHistoryId,
                  'nama_gejala': entry.key,
                  'nilai_gejala': entry.value?.toString() ?? 'Tidak',
                  'is_matched': matchedDetails[entry.key] == true ? 1 : 0,
                });
              }
            }
          }

          // Simpan jawaban pengguna dalam format JSON
          await txn.insert('user_answers_history', {
            'diagnosis_history_id': mainHistoryId,
            'kategori_penyakit': kategoriPenyakit,
            'jawaban_json': _mapToJsonString(userAnswers),
            'created_at': timestamp,
          });

          // Update statistik diagnosa
          await _updateDiagnosisStatistics(txn, kategoriPenyakit, topResult['penyakit'], topResult['persentase'], timestamp);
        }
      });

      debugPrint('Histori diagnosa berhasil disimpan dengan ID: $mainHistoryId');
      return mainHistoryId;
    } catch (e) {
      debugPrint('Error menyimpan histori diagnosa: $e');
      rethrow;
    }
  }

  // Fungsi untuk mengupdate statistik diagnosa
  Future<void> _updateDiagnosisStatistics(
    Transaction txn,
    String kategori,
    String namaPenyakit,
    double persentase,
    String timestamp,
  ) async {
    // Cek apakah statistik untuk penyakit ini sudah ada
    final existing = await txn.query(
      'diagnosis_statistics',
      where: 'kategori_penyakit = ? AND nama_penyakit = ?',
      whereArgs: [kategori, namaPenyakit],
    );

    if (existing.isEmpty) {
      // Insert statistik baru
      await txn.insert('diagnosis_statistics', {
        'kategori_penyakit': kategori,
        'nama_penyakit': namaPenyakit,
        'jumlah_diagnosa': 1,
        'rata_rata_persentase': persentase,
        'first_diagnosed': timestamp,
        'last_diagnosed': timestamp,
      });
    } else {
      // Update statistik yang sudah ada
      final stat = existing.first;
      final jumlahBaru = (stat['jumlah_diagnosa'] as int) + 1;
      final rataRataBaru = ((stat['rata_rata_persentase'] as double) * (stat['jumlah_diagnosa'] as int) + persentase) / jumlahBaru;

      await txn.update(
        'diagnosis_statistics',
        {
          'jumlah_diagnosa': jumlahBaru,
          'rata_rata_persentase': rataRataBaru,
          'last_diagnosed': timestamp,
        },
        where: 'id = ?',
        whereArgs: [stat['id']],
      );
    }
  }

  // Fungsi untuk mendapatkan histori diagnosa dengan filter
  Future<List<Map<String, dynamic>>> getDiagnosisHistory({
    String? kategoriPenyakit,
    String? namaPenyakit,
    DateTime? startDate,
    DateTime? endDate,
    String orderBy = 'created_at DESC',
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    
    try {
      String whereClause = '';
      final List<dynamic> whereArgs = [];

      // Build WHERE clause
      final List<String> conditions = [];
      
      if (kategoriPenyakit != null && kategoriPenyakit.isNotEmpty) {
        conditions.add('kategori_penyakit = ?');
        whereArgs.add(kategoriPenyakit);
      }
      
      if (namaPenyakit != null && namaPenyakit.isNotEmpty) {
        conditions.add('nama_penyakit LIKE ?');
        whereArgs.add('%$namaPenyakit%');
      }
      
      if (startDate != null) {
        conditions.add('created_at >= ?');
        whereArgs.add(startDate.toIso8601String());
      }
      
      if (endDate != null) {
        conditions.add('created_at <= ?');
        whereArgs.add(endDate.toIso8601String());
      }

      if (conditions.isNotEmpty) {
        whereClause = conditions.join(' AND ');
      }

      final results = await db.query(
        'diagnosis_history',
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );

      // Format hasil dengan tambahan informasi
      final List<Map<String, dynamic>> formattedResults = [];
      for (var result in results) {
        final Map<String, dynamic> formatted = Map<String, dynamic>.from(result);
        
        // Parse created_at menjadi DateTime yang lebih readable
        if (formatted['created_at'] != null) {
          try {
            final dateTime = DateTime.parse(formatted['created_at']);
            formatted['created_at_formatted'] = _formatDateTime(dateTime);
            formatted['created_at_date'] = _formatDate(dateTime);
            formatted['created_at_time'] = _formatTime(dateTime);
          } catch (e) {
            formatted['created_at_formatted'] = formatted['created_at'];
          }
        }
        
        formattedResults.add(formatted);
      }

      return formattedResults;
    } catch (e) {
      debugPrint('Error mengambil histori diagnosa: $e');
      return [];
    }
  }

  // Fungsi untuk mendapatkan detail gejala dari histori diagnosa
  Future<List<Map<String, dynamic>>> getDiagnosisSymptomsDetail(int diagnosisHistoryId) async {
    final db = await database;
    
    try {
      final results = await db.query(
        'diagnosis_symptoms_detail',
        where: 'diagnosis_history_id = ?',
        whereArgs: [diagnosisHistoryId],
        orderBy: 'nama_gejala ASC',
      );

      return results;
    } catch (e) {
      debugPrint('Error mengambil detail gejala: $e');
      return [];
    }
  }

  // Fungsi untuk mendapatkan jawaban pengguna dari histori
  Future<Map<String, dynamic>?> getUserAnswersFromHistory(int diagnosisHistoryId) async {
    final db = await database;
    
    try {
      final results = await db.query(
        'user_answers_history',
        where: 'diagnosis_history_id = ?',
        whereArgs: [diagnosisHistoryId],
        limit: 1,
      );

      if (results.isNotEmpty) {
        final result = results.first;
        return {
          'id': result['id'],
          'kategori_penyakit': result['kategori_penyakit'],
          'jawaban': _jsonStringToMap(result['jawaban_json'] as String),
          'created_at': result['created_at'],
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error mengambil jawaban pengguna dari histori: $e');
      return null;
    }
  }

  // Fungsi untuk mendapatkan statistik diagnosa
  Future<List<Map<String, dynamic>>> getDiagnosisStatistics({String? kategoriPenyakit}) async {
    final db = await database;
    
    try {
      String whereClause = '';
      final List<dynamic> whereArgs = [];

      if (kategoriPenyakit != null && kategoriPenyakit.isNotEmpty) {
        whereClause = 'kategori_penyakit = ?';
        whereArgs.add(kategoriPenyakit);
      }

      final results = await db.query(
        'diagnosis_statistics',
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'jumlah_diagnosa DESC, rata_rata_persentase DESC',
      );

      // Format hasil dengan informasi tambahan
      final List<Map<String, dynamic>> formattedResults = [];
      for (var result in results) {
        final Map<String, dynamic> formatted = Map<String, dynamic>.from(result);
        
        // Format tanggal
        if (formatted['first_diagnosed'] != null) {
          try {
            final firstDate = DateTime.parse(formatted['first_diagnosed']);
            formatted['first_diagnosed_formatted'] = _formatDate(firstDate);
          } catch (e) {
            formatted['first_diagnosed_formatted'] = formatted['first_diagnosed'];
          }
        }
        
        if (formatted['last_diagnosed'] != null) {
          try {
            final lastDate = DateTime.parse(formatted['last_diagnosed']);
            formatted['last_diagnosed_formatted'] = _formatDate(lastDate);
          } catch (e) {
            formatted['last_diagnosed_formatted'] = formatted['last_diagnosed'];
          }
        }
        
        formattedResults.add(formatted);
      }

      return formattedResults;
    } catch (e) {
      debugPrint('Error mengambil statistik diagnosa: $e');
      return [];
    }
  }

  // Fungsi untuk mendapatkan kategori penyakit yang tersedia
  Future<List<String>> getAvailableCategories() async {
    final db = await database;
    
    try {
      final results = await db.rawQuery('''
        SELECT DISTINCT kategori_penyakit 
        FROM diagnosis_history 
        ORDER BY kategori_penyakit ASC
      ''');

      return results.map((row) => row['kategori_penyakit'] as String).toList();
    } catch (e) {
      debugPrint('Error mengambil kategori yang tersedia: $e');
      return [];
    }
  }

  // Fungsi untuk menghitung total diagnosa per kategori
  Future<Map<String, int>> getDiagnosisCountByCategory() async {
    final db = await database;
    
    try {
      final results = await db.rawQuery('''
        SELECT kategori_penyakit, COUNT(*) as total 
        FROM diagnosis_history 
        GROUP BY kategori_penyakit
        ORDER BY total DESC
      ''');

      final Map<String, int> counts = {};
      for (var row in results) {
        counts[row['kategori_penyakit'] as String] = row['total'] as int;
      }

      return counts;
    } catch (e) {
      debugPrint('Error menghitung diagnosa per kategori: $e');
      return {};
    }
  }

  // Fungsi untuk menghapus histori diagnosa
  Future<bool> deleteDiagnosisHistory(int id) async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        // Hapus detail gejala
        await txn.delete(
          'diagnosis_symptoms_detail',
          where: 'diagnosis_history_id = ?',
          whereArgs: [id],
        );

        // Hapus jawaban pengguna
        await txn.delete(
          'user_answers_history',
          where: 'diagnosis_history_id = ?',
          whereArgs: [id],
        );

        // Hapus histori utama
        await txn.delete(
          'diagnosis_history',
          where: 'id = ?',
          whereArgs: [id],
        );
      });

      debugPrint('Histori diagnosa dengan ID $id berhasil dihapus');
      return true;
    } catch (e) {
      debugPrint('Error menghapus histori diagnosa: $e');
      return false;
    }
  }

  // Fungsi untuk menghapus semua histori dari kategori tertentu
  Future<bool> deleteHistoryByCategory(String kategoriPenyakit) async {
    final db = await database;
    
    try {
      await db.transaction((txn) async {
        // Ambil semua ID histori untuk kategori ini
        final historyIds = await txn.query(
          'diagnosis_history',
          columns: ['id'],
          where: 'kategori_penyakit = ?',
          whereArgs: [kategoriPenyakit],
        );

        for (var row in historyIds) {
          final id = row['id'] as int;
          
          // Hapus detail gejala
          await txn.delete(
            'diagnosis_symptoms_detail',
            where: 'diagnosis_history_id = ?',
            whereArgs: [id],
          );

          // Hapus jawaban pengguna
          await txn.delete(
            'user_answers_history',
            where: 'diagnosis_history_id = ?',
            whereArgs: [id],
          );
        }

        // Hapus histori utama
        await txn.delete(
          'diagnosis_history',
          where: 'kategori_penyakit = ?',
          whereArgs: [kategoriPenyakit],
        );

        // Hapus statistik
        await txn.delete(
          'diagnosis_statistics',
          where: 'kategori_penyakit = ?',
          whereArgs: [kategoriPenyakit],
        );
      });

      debugPrint('Semua histori untuk kategori $kategoriPenyakit berhasil dihapus');
      return true;
    } catch (e) {
      debugPrint('Error menghapus histori kategori: $e');
      return false;
    }
  }

  // Fungsi untuk export histori ke CSV
  Future<String> exportHistoryToCSV({String? kategoriPenyakit}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = kategoriPenyakit != null 
          ? 'histori_diagnosa_${kategoriPenyakit.toLowerCase()}.csv'
          : 'histori_diagnosa_semua.csv';
      final path = '${directory.path}/$fileName';
      final file = File(path);

      // Ambil data histori
      final historyData = await getDiagnosisHistory(kategoriPenyakit: kategoriPenyakit);

      // Buat konten CSV
      final List<List<dynamic>> csvData = [];

      // Header
      csvData.add([
        'ID',
        'Kategori Penyakit',
        'Nama Penyakit',
        'Persentase Kecocokan (%)',
        'Gejala Cocok',
        'Total Gejala',
        'Metode Diagnosa',
        'Tanggal Diagnosa',
        'Waktu Diagnosa'
      ]);

      // Data rows
      for (var history in historyData) {
        csvData.add([
          history['id'],
          history['kategori_penyakit'],
          history['nama_penyakit'],
          history['persentase_kecocokan']?.toStringAsFixed(1) ?? '0.0',
          history['gejala_cocok'],
          history['total_gejala'],
          history['metode_diagnosa'],
          history['created_at_date'] ?? '',
          history['created_at_time'] ?? '',
        ]);
      }

      // Konversi ke string CSV
      final String csv = const ListToCsvConverter().convert(csvData);

      // Tulis ke file
      await file.writeAsString(csv);
      debugPrint('Histori diagnosa berhasil diekspor ke CSV: $path');

      return path;
    } catch (e) {
      debugPrint('Error ekspor histori ke CSV: $e');
      return '';
    }
  }

  // Helper function untuk mengkonversi Map ke JSON string
  String _mapToJsonString(Map<String, dynamic> map) {
    try {
      // Menghapus key yang tidak perlu
      final Map<String, dynamic> cleanMap = Map<String, dynamic>.from(map);
      cleanMap.removeWhere((key, value) => key == 'id' || key == 'created_at');
      
      // Sederhana JSON-like string format
      final List<String> pairs = [];
      cleanMap.forEach((key, value) {
        pairs.add('"$key":"${value?.toString() ?? ''}"');
      });
      return '{${pairs.join(',')}}';
    } catch (e) {
      debugPrint('Error converting map to JSON: $e');
      return '{}';
    }
  }

  // Helper function untuk mengkonversi JSON string ke Map
  Map<String, dynamic> _jsonStringToMap(String jsonString) {
    try {
      // Simple JSON-like string parser
      final Map<String, dynamic> result = {};
      final String cleaned = jsonString.replaceAll('{', '').replaceAll('}', '');
      
      if (cleaned.isEmpty) return result;
      
      final List<String> pairs = cleaned.split(',');
      for (String pair in pairs) {
        final List<String> keyValue = pair.split(':');
        if (keyValue.length == 2) {
          final String key = keyValue[0].replaceAll('"', '').trim();
          final String value = keyValue[1].replaceAll('"', '').trim();
          result[key] = value;
        }
      }
      return result;
    } catch (e) {
      debugPrint('Error parsing JSON string: $e');
      return {};
    }
  }

  // Helper functions untuk formatting tanggal
  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Fungsi untuk menutup database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

// ========================================
// EXTENSION UNTUK INTEGRASI OTOMATIS
// ========================================

// Mixin untuk ditambahkan ke setiap DatabaseHelper
mixin DiagnosisHistoryMixin {
  // Auto-save histori setelah diagnosa
  Future<void> saveToHistory({
    required String kategoriPenyakit,
    required List<Map<String, dynamic>> diagnosisResults,
    required Map<String, dynamic> userAnswers,
    String metodeDiagnosa = 'standard',
  }) async {
    // Jalankan di background tanpa mengganggu proses utama
    Future.microtask(() async {
      await DiagnosisHistoryDatabase.autoSaveDiagnosisHistory(
        kategoriPenyakit: kategoriPenyakit,
        diagnosisResults: diagnosisResults,
        userAnswers: userAnswers,
        metodeDiagnosa: metodeDiagnosa,
      );
    });
  }
}