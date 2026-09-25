import 'package:primafit/core/database/local_db.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:primafit/features/women_health/presentation/kehamilan/model_kehamilan.dart';

class DatabaseHelperPregnancy {
  static final DatabaseHelperPregnancy instance = DatabaseHelperPregnancy._init();
  static Database? _database;

  DatabaseHelperPregnancy._init();

  Future<Database> get database async {
    if (_database?.isOpen ?? false) return _database!;
    _database = await _initDB('pregnancy_tracker.db');
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
    // Tabel untuk kehamilan
    await db.execute('''
    CREATE TABLE pregnancies (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      start_date TEXT NOT NULL,
      due_date TEXT NOT NULL,
      birth_date TEXT,
      current_week INTEGER NOT NULL,
      is_active INTEGER DEFAULT 1,
      created_at TEXT NOT NULL
    )
    ''');
    
    // Tabel untuk gejala kehamilan
    await db.execute('''
    CREATE TABLE pregnancy_symptoms (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pregnancy_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      type INTEGER NOT NULL,
      intensity INTEGER DEFAULT 3,
      notes TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (pregnancy_id) REFERENCES pregnancies (id) ON DELETE CASCADE
    )
    ''');
    
    // Tabel untuk pemeriksaan kehamilan
    await db.execute('''
    CREATE TABLE pregnancy_checkups (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pregnancy_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      type INTEGER NOT NULL,
      weight REAL NOT NULL,
      bp_systolic REAL NOT NULL,
      bp_diastolic REAL NOT NULL,
      fetal_heart_rate REAL DEFAULT 0,
      fundus_height REAL DEFAULT 0,
      doctor_notes TEXT,
      next_steps TEXT,
      medications TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (pregnancy_id) REFERENCES pregnancies (id) ON DELETE CASCADE
    )
    ''');
    
    // Tabel untuk berat badan
    await db.execute('''
    CREATE TABLE pregnancy_weights (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pregnancy_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      weight REAL NOT NULL,
      notes TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (pregnancy_id) REFERENCES pregnancies (id) ON DELETE CASCADE
    )
    ''');
    
    // Tabel untuk catatan kehamilan
    await db.execute('''
    CREATE TABLE pregnancy_notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      pregnancy_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      type INTEGER DEFAULT 0,
      created_at TEXT NOT NULL,
      FOREIGN KEY (pregnancy_id) REFERENCES pregnancies (id) ON DELETE CASCADE
    )
    ''');
    
    // Tabel untuk pengaturan
    await db.execute('''
    CREATE TABLE pregnancy_settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      notification_enabled INTEGER DEFAULT 1,
      notification_time TEXT DEFAULT '08:00',
      weekly_summary_enabled INTEGER DEFAULT 1,
      kick_counter_enabled INTEGER DEFAULT 1,
      weight_unit TEXT DEFAULT 'kg',
      height_unit TEXT DEFAULT 'cm',
      last_updated TEXT NOT NULL
    )
    ''');
  }

  // PREGNANCY CRUD OPERATIONS
  // ========================

  // Menyimpan kehamilan baru
  Future<int> insertPregnancy(Pregnancy pregnancy) async {
    final db = await database;
    
    final Map<String, dynamic> data = pregnancy.toMap();
    data['created_at'] = DateTime.now().toIso8601String();
    
    final id = await db.insert('pregnancies', data);
    debugPrint('Kehamilan berhasil disimpan dengan ID: $id');
    return id;
  }
  
  // Memperbarui data kehamilan
  Future<int> updatePregnancy(Pregnancy pregnancy) async {
    final db = await database;
    
    return db.update(
      'pregnancies',
      pregnancy.toMap(),
      where: 'id = ?',
      whereArgs: [pregnancy.id],
    );
  }
  
  // Memperbarui minggu kehamilan saat ini
  Future<int> updateCurrentWeek(int id, int currentWeek) async {
    final db = await database;
    
    return db.update(
      'pregnancies',
      {
        'current_week': currentWeek,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Menandai kehamilan telah berakhir (melahirkan)
  Future<int> endPregnancy(int id, DateTime birthDate) async {
    final db = await database;
    
    return db.update(
      'pregnancies',
      {
        'birth_date': birthDate.toIso8601String(),
        'is_active': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Menghapus data kehamilan
  Future<int> deletePregnancy(int id) async {
    final db = await database;
    
    return db.delete(
      'pregnancies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Mendapatkan kehamilan aktif
  Future<Pregnancy?> getActivePregnancy() async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'pregnancies',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    final pregnancy = Pregnancy.fromMap(maps.first);
    
    // Ambil data terkait untuk kehamilan ini
    pregnancy.symptoms = await getSymptomsForPregnancy(pregnancy.id);
    pregnancy.checkups = await getCheckupsForPregnancy(pregnancy.id);
    pregnancy.weightRecords = await getWeightsForPregnancy(pregnancy.id);
    pregnancy.notes = await getNotesForPregnancy(pregnancy.id);
    
    return pregnancy;
  }
  
  // Mendapatkan semua riwayat kehamilan
  Future<List<Pregnancy>> getAllPregnancies() async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'pregnancies',
      orderBy: 'start_date DESC',
    );
    
    final pregnancies = maps.map((map) => Pregnancy.fromMap(map)).toList();
    
    // Ambil data terkait untuk setiap kehamilan
    for (var pregnancy in pregnancies) {
      pregnancy.symptoms = await getSymptomsForPregnancy(pregnancy.id);
      pregnancy.checkups = await getCheckupsForPregnancy(pregnancy.id);
      pregnancy.weightRecords = await getWeightsForPregnancy(pregnancy.id);
      pregnancy.notes = await getNotesForPregnancy(pregnancy.id);
    }
    
    return pregnancies;
  }
  
  // SYMPTOM OPERATIONS
  // =================
  
  // Menambahkan gejala
  Future<int> insertSymptom(PregnancySymptom symptom) async {
    final db = await database;
    
    final Map<String, dynamic> data = symptom.toMap();
    data['created_at'] = DateTime.now().toIso8601String();
    
    final id = await db.insert('pregnancy_symptoms', data);
    debugPrint('Gejala kehamilan berhasil disimpan dengan ID: $id');
    return id;
  }
  
  // Memperbarui gejala
  Future<int> updateSymptom(PregnancySymptom symptom) async {
    final db = await database;
    
    return db.update(
      'pregnancy_symptoms',
      symptom.toMap(),
      where: 'id = ?',
      whereArgs: [symptom.id],
    );
  }
  
  // Menghapus gejala
  Future<int> deleteSymptom(int id) async {
    final db = await database;
    
    return db.delete(
      'pregnancy_symptoms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Mendapatkan gejala untuk kehamilan tertentu
  Future<List<PregnancySymptom>> getSymptomsForPregnancy(int pregnancyId) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'pregnancy_symptoms',
      where: 'pregnancy_id = ?',
      whereArgs: [pregnancyId],
      orderBy: 'date ASC',
    );
    
    return maps.map((map) => PregnancySymptom.fromMap(map)).toList();
  }
  
  // Mendapatkan gejala berdasarkan tanggal
  Future<List<PregnancySymptom>> getSymptomsByDate(int pregnancyId, DateTime date) async {
    final db = await database;
    
    final dateString = date.toIso8601String().split('T')[0];
    
    final List<Map<String, dynamic>> maps = await db.query(
      'pregnancy_symptoms',
      where: "pregnancy_id = ? AND date LIKE '$dateString%'",
      whereArgs: [pregnancyId],
      orderBy: 'date ASC',
    );
    
    return maps.map((map) => PregnancySymptom.fromMap(map)).toList();
  }
  
  // CHECKUP OPERATIONS
  // =================
  
  // Menambahkan pemeriksaan
  Future<int> insertCheckup(PregnancyCheckup checkup) async {
    final db = await database;
    
    final Map<String, dynamic> data = checkup.toMap();
    data['created_at'] = DateTime.now().toIso8601String();
    
    final id = await db.insert('pregnancy_checkups', data);
    debugPrint('Pemeriksaan kehamilan berhasil disimpan dengan ID: $id');
    return id;
  }
  
  // Memperbarui pemeriksaan
  Future<int> updateCheckup(PregnancyCheckup checkup) async {
    final db = await database;
    
    return db.update(
      'pregnancy_checkups',
      checkup.toMap(),
      where: 'id = ?',
      whereArgs: [checkup.id],
    );
  }
  
  // Menghapus pemeriksaan
  Future<int> deleteCheckup(int id) async {
    final db = await database;
    
    return db.delete(
      'pregnancy_checkups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Mendapatkan pemeriksaan untuk kehamilan tertentu
  Future<List<PregnancyCheckup>> getCheckupsForPregnancy(int pregnancyId) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'pregnancy_checkups',
      where: 'pregnancy_id = ?',
      whereArgs: [pregnancyId],
      orderBy: 'date ASC',
    );
    
    return maps.map((map) => PregnancyCheckup.fromMap(map)).toList();
  }
  
  // Mendapatkan pemeriksaan terakhir
  Future<PregnancyCheckup?> getLatestCheckup(int pregnancyId) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'pregnancy_checkups',
      where: 'pregnancy_id = ?',
      whereArgs: [pregnancyId],
      orderBy: 'date DESC',
      limit: 1,
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    return PregnancyCheckup.fromMap(maps.first);
  }
  
  // WEIGHT OPERATIONS
  // ================
  
  // Menambahkan catatan berat badan
  Future<int> insertWeight(PregnancyWeight weight) async {
    final db = await database;
    
    final Map<String, dynamic> data = weight.toMap();
    data['created_at'] = DateTime.now().toIso8601String();
    
    final id = await db.insert('pregnancy_weights', data);
    debugPrint('Berat badan kehamilan berhasil disimpan dengan ID: $id');
    return id;
  }
  
  // Memperbarui catatan berat badan
  Future<int> updateWeight(PregnancyWeight weight) async {
    final db = await database;
    
    return db.update(
      'pregnancy_weights',
      weight.toMap(),
      where: 'id = ?',
      whereArgs: [weight.id],
    );
  }
  
  // Menghapus catatan berat badan
  Future<int> deleteWeight(int id) async {
    final db = await database;
    
    return db.delete(
      'pregnancy_weights',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Mendapatkan riwayat berat badan untuk kehamilan tertentu
  Future<List<PregnancyWeight>> getWeightsForPregnancy(int pregnancyId) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'pregnancy_weights',
      where: 'pregnancy_id = ?',
      whereArgs: [pregnancyId],
      orderBy: 'date ASC',
    );
    
    return maps.map((map) => PregnancyWeight.fromMap(map)).toList();
  }
  
  // Mendapatkan berat badan terakhir
  Future<PregnancyWeight?> getLatestWeight(int pregnancyId) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'pregnancy_weights',
      where: 'pregnancy_id = ?',
      whereArgs: [pregnancyId],
      orderBy: 'date DESC',
      limit: 1,
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    return PregnancyWeight.fromMap(maps.first);
  }
  
  // NOTE OPERATIONS
  // ==============
  
  // Menambahkan catatan
  Future<int> insertNote(PregnancyNote note) async {
    final db = await database;
    
    final Map<String, dynamic> data = note.toMap();
    data['created_at'] = DateTime.now().toIso8601String();
    
    final id = await db.insert('pregnancy_notes', data);
    debugPrint('Catatan kehamilan berhasil disimpan dengan ID: $id');
    return id;
  }
  
  // Memperbarui catatan
  Future<int> updateNote(PregnancyNote note) async {
    final db = await database;
    
    return db.update(
      'pregnancy_notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
  
  // Menghapus catatan
  Future<int> deleteNote(int id) async {
    final db = await database;
    
    return db.delete(
      'pregnancy_notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Mendapatkan catatan untuk kehamilan tertentu
  Future<List<PregnancyNote>> getNotesForPregnancy(int pregnancyId) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'pregnancy_notes',
      where: 'pregnancy_id = ?',
      whereArgs: [pregnancyId],
      orderBy: 'date DESC',
    );
    
    return maps.map((map) => PregnancyNote.fromMap(map)).toList();
  }
  
  // Mendapatkan catatan berdasarkan tipe
  Future<List<PregnancyNote>> getNotesByType(int pregnancyId, NoteType type) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'pregnancy_notes',
      where: 'pregnancy_id = ? AND type = ?',
      whereArgs: [pregnancyId, type.index],
      orderBy: 'date DESC',
    );
    
    return maps.map((map) => PregnancyNote.fromMap(map)).toList();
  }
  
  // SETTINGS OPERATIONS
  // =================
  
  // Menyimpan pengaturan
  Future<void> saveSettings({
    required bool notificationEnabled,
    required String notificationTime,
    required bool weeklySummaryEnabled,
    required bool kickCounterEnabled,
    required String weightUnit,
    required String heightUnit,
  }) async {
    final db = await database;
    
    // Periksa apakah pengaturan sudah ada
    final List<Map<String, dynamic>> settings = await db.query('pregnancy_settings');
    
    if (settings.isEmpty) {
      // Buat pengaturan baru
      await db.insert('pregnancy_settings', {
        'notification_enabled': notificationEnabled ? 1 : 0,
        'notification_time': notificationTime,
        'weekly_summary_enabled': weeklySummaryEnabled ? 1 : 0,
        'kick_counter_enabled': kickCounterEnabled ? 1 : 0,
        'weight_unit': weightUnit,
        'height_unit': heightUnit,
        'last_updated': DateTime.now().toIso8601String(),
      });
    } else {
      // Perbarui pengaturan yang ada
      await db.update(
        'pregnancy_settings',
        {
          'notification_enabled': notificationEnabled ? 1 : 0,
          'notification_time': notificationTime,
          'weekly_summary_enabled': weeklySummaryEnabled ? 1 : 0,
          'kick_counter_enabled': kickCounterEnabled ? 1 : 0,
          'weight_unit': weightUnit,
          'height_unit': heightUnit,
          'last_updated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [settings.first['id']],
      );
    }
  }
  
  // Mendapatkan pengaturan
  Future<Map<String, dynamic>> getSettings() async {
    final db = await database;
    
    final List<Map<String, dynamic>> settings = await db.query('pregnancy_settings');
    
    if (settings.isEmpty) {
      // Buat pengaturan default
      final id = await db.insert('pregnancy_settings', {
        'notification_enabled': 1,
        'notification_time': '08:00',
        'weekly_summary_enabled': 1,
        'kick_counter_enabled': 1,
        'weight_unit': 'kg',
        'height_unit': 'cm',
        'last_updated': DateTime.now().toIso8601String(),
      });
      
      return {
        'id': id,
        'notification_enabled': true,
        'notification_time': '08:00',
        'weekly_summary_enabled': true,
        'kick_counter_enabled': true,
        'weight_unit': 'kg',
        'height_unit': 'cm',
        'last_updated': DateTime.now().toIso8601String(),
      };
    } else {
      final setting = settings.first;
      return {
        'id': setting['id'],
        'notification_enabled': setting['notification_enabled'] == 1,
        'notification_time': setting['notification_time'],
        'weekly_summary_enabled': setting['weekly_summary_enabled'] == 1,
        'kick_counter_enabled': setting['kick_counter_enabled'] == 1,
        'weight_unit': setting['weight_unit'],
        'height_unit': setting['height_unit'],
        'last_updated': setting['last_updated'],
      };
    }
  }
  
  // STATISTICS OPERATIONS
  // ===================
  
  // Mendapatkan statistik gejala selama kehamilan
  Future<Map<PregnancySymptomType, int>> getSymptomStatistics(int pregnancyId) async {
    final db = await database;
    
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT type, COUNT(*) as count 
      FROM pregnancy_symptoms 
      WHERE pregnancy_id = ? 
      GROUP BY type 
      ORDER BY count DESC
    ''', [pregnancyId]);
    
    final Map<PregnancySymptomType, int> symptomCounts = {};
    for (var row in result) {
      final type = PregnancySymptomType.values[row['type'] as int];
      symptomCounts[type] = row['count'] as int;
    }
    
    return symptomCounts;
  }
  
  // Mendapatkan statistik perubahan berat badan
  Future<Map<String, dynamic>> getWeightStatistics(int pregnancyId) async {
    final weights = await getWeightsForPregnancy(pregnancyId);
    
    if (weights.isEmpty) {
      return {
        'total_gain': 0.0,
        'first_weight': 0.0,
        'current_weight': 0.0,
        'min_weight': 0.0,
        'max_weight': 0.0,
      };
    }
    
    final firstWeight = weights.first.weight;
    final currentWeight = weights.last.weight;
    final totalGain = currentWeight - firstWeight;
    
    // Find min and max values
    double minWeight = weights.first.weight;
    double maxWeight = weights.first.weight;
    
    for (var record in weights) {
      if (record.weight < minWeight) minWeight = record.weight;
      if (record.weight > maxWeight) maxWeight = record.weight;
    }
    
    return {
      'total_gain': totalGain,
      'first_weight': firstWeight,
      'current_weight': currentWeight,
      'min_weight': minWeight,
      'max_weight': maxWeight,
    };
  }

  // Menutup database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}