import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:primafit/features/women_health/presentation/menstruasi/model_menstruasi.dart';

class DatabaseHelperMenstrual {
  static final DatabaseHelperMenstrual instance = DatabaseHelperMenstrual._init();
  static Database? _database;

  DatabaseHelperMenstrual._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('menstrual_tracker.db');
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
    // Tabel untuk siklus menstruasi
    await db.execute('''
    CREATE TABLE menstrual_cycles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      start_date TEXT NOT NULL,
      end_date TEXT,
      cycle_length INTEGER DEFAULT 28,
      period_length INTEGER DEFAULT 5,
      notes TEXT,
      mood INTEGER DEFAULT 3,
      created_at TEXT NOT NULL
    )
    ''');
    
    // Tabel untuk gejala
    await db.execute('''
    CREATE TABLE menstrual_symptoms (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cycle_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      type INTEGER NOT NULL,
      intensity INTEGER DEFAULT 3,
      notes TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY (cycle_id) REFERENCES menstrual_cycles (id) ON DELETE CASCADE
    )
    ''');
    
    // Tabel untuk pengaturan 
    await db.execute('''
    CREATE TABLE menstrual_settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      average_cycle_length INTEGER DEFAULT 28,
      average_period_length INTEGER DEFAULT 5,
      notification_enabled INTEGER DEFAULT 1,
      notification_time TEXT DEFAULT '08:00',
      notifications_before_period INTEGER DEFAULT 2,
      last_updated TEXT NOT NULL
    )
    ''');
  }

  // Menyimpan siklus menstruasi baru
  Future<int> insertCycle(MenstrualCycle cycle) async {
    final db = await database;
    
    final Map<String, dynamic> data = cycle.toMap();
    data['created_at'] = DateTime.now().toIso8601String();
    
    final id = await db.insert('menstrual_cycles', data);
    debugPrint('Siklus menstruasi berhasil disimpan dengan ID: $id');
    return id;
  }
  
  // Memperbarui siklus menstruasi
  Future<int> updateCycle(MenstrualCycle cycle) async {
    final db = await database;
    
    return db.update(
      'menstrual_cycles',
      cycle.toMap(),
      where: 'id = ?',
      whereArgs: [cycle.id],
    );
  }
  
  // Mengakhiri siklus menstruasi (mengisi end_date)
  Future<int> endCycle(int id, DateTime endDate) async {
    final db = await database;
    
    return db.update(
      'menstrual_cycles',
      {
        'end_date': endDate.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Menghapus siklus menstruasi
  Future<int> deleteCycle(int id) async {
    final db = await database;
    
    return db.delete(
      'menstrual_cycles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Mendapatkan siklus menstruasi terbaru
  Future<MenstrualCycle?> getLatestCycle() async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'menstrual_cycles',
      orderBy: 'start_date DESC',
      limit: 1,
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    final cycle = MenstrualCycle.fromMap(maps.first);
    
    // Ambil gejala untuk siklus ini
    final symptoms = await getSymptomsForCycle(cycle.id);
    cycle.symptoms = symptoms;
    
    return cycle;
  }
  
  // Mendapatkan semua siklus menstruasi
  Future<List<MenstrualCycle>> getAllCycles() async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'menstrual_cycles',
      orderBy: 'start_date DESC',
    );
    
    final cycles = maps.map((map) => MenstrualCycle.fromMap(map)).toList();
    
    // Ambil gejala untuk setiap siklus
    for (var cycle in cycles) {
      cycle.symptoms = await getSymptomsForCycle(cycle.id);
    }
    
    return cycles;
  }
  
  // Mendapatkan siklus menstruasi berdasarkan rentang tanggal
  Future<List<MenstrualCycle>> getCyclesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'menstrual_cycles',
      where: 'start_date BETWEEN ? AND ? OR end_date BETWEEN ? AND ?',
      whereArgs: [
        start.toIso8601String(), 
        end.toIso8601String(),
        start.toIso8601String(), 
        end.toIso8601String(),
      ],
      orderBy: 'start_date DESC',
    );
    
    final cycles = maps.map((map) => MenstrualCycle.fromMap(map)).toList();
    
    // Ambil gejala untuk setiap siklus
    for (var cycle in cycles) {
      cycle.symptoms = await getSymptomsForCycle(cycle.id);
    }
    
    return cycles;
  }
  
  // Menambahkan gejala
  Future<int> insertSymptom(MenstrualSymptom symptom) async {
    final db = await database;
    
    final Map<String, dynamic> data = symptom.toMap();
    data['created_at'] = DateTime.now().toIso8601String();
    
    final id = await db.insert('menstrual_symptoms', data);
    debugPrint('Gejala berhasil disimpan dengan ID: $id');
    return id;
  }
  
  // Memperbarui gejala
  Future<int> updateSymptom(MenstrualSymptom symptom) async {
    final db = await database;
    
    return db.update(
      'menstrual_symptoms',
      symptom.toMap(),
      where: 'id = ?',
      whereArgs: [symptom.id],
    );
  }
  
  // Menghapus gejala
  Future<int> deleteSymptom(int id) async {
    final db = await database;
    
    return db.delete(
      'menstrual_symptoms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Mendapatkan gejala untuk siklus tertentu
  Future<List<MenstrualSymptom>> getSymptomsForCycle(int cycleId) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'menstrual_symptoms',
      where: 'cycle_id = ?',
      whereArgs: [cycleId],
      orderBy: 'date ASC',
    );
    
    return maps.map((map) => MenstrualSymptom.fromMap(map)).toList();
  }
  
  // Mendapatkan gejala berdasarkan tanggal
  Future<List<MenstrualSymptom>> getSymptomsByDate(DateTime date) async {
    final db = await database;
    
    final dateString = date.toIso8601String().split('T')[0];
    
    final List<Map<String, dynamic>> maps = await db.query(
      'menstrual_symptoms',
      where: "date LIKE '$dateString%'",
      orderBy: 'date ASC',
    );
    
    return maps.map((map) => MenstrualSymptom.fromMap(map)).toList();
  }
  
  // Menghitung panjang siklus rata-rata
  Future<double> getAverageCycleLength() async {
    final db = await database;
    
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT AVG(cycle_length) as avg_length FROM menstrual_cycles WHERE cycle_length > 0'
    );
    
    return result.first['avg_length'] ?? 28.0;
  }
  
  // Menghitung panjang periode rata-rata
  Future<double> getAveragePeriodLength() async {
    final db = await database;
    
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT AVG(period_length) as avg_length FROM menstrual_cycles WHERE period_length > 0'
    );
    
    return result.first['avg_length'] ?? 5.0;
  }
  
  // Mendapatkan prediksi 3 siklus ke depan berdasarkan riwayat
  Future<List<DateTime>> predictFutureCycles(int numberOfPredictions) async {
    final latestCycle = await getLatestCycle();
    if (latestCycle == null) {
      return [];
    }
    
    // Dapatkan panjang siklus rata-rata
    final avgCycleLength = await getAverageCycleLength();
    
    final List<DateTime> predictions = [];
    DateTime nextDate = latestCycle.startDate;
    
    for (int i = 0; i < numberOfPredictions; i++) {
      nextDate = nextDate.add(Duration(days: avgCycleLength.round()));
      predictions.add(nextDate);
    }
    
    return predictions;
  }
  
  // Menyimpan pengaturan
  Future<void> saveSettings({
    required int averageCycleLength,
    required int averagePeriodLength,
    required bool notificationEnabled,
    required String notificationTime,
    required int notificationsBeforePeriod,
  }) async {
    final db = await database;
    
    // Periksa apakah pengaturan sudah ada
    final List<Map<String, dynamic>> settings = await db.query('menstrual_settings');
    
    if (settings.isEmpty) {
      // Buat pengaturan baru
      await db.insert('menstrual_settings', {
        'average_cycle_length': averageCycleLength,
        'average_period_length': averagePeriodLength,
        'notification_enabled': notificationEnabled ? 1 : 0,
        'notification_time': notificationTime,
        'notifications_before_period': notificationsBeforePeriod,
        'last_updated': DateTime.now().toIso8601String(),
      });
    } else {
      // Perbarui pengaturan yang ada
      await db.update(
        'menstrual_settings',
        {
          'average_cycle_length': averageCycleLength,
          'average_period_length': averagePeriodLength,
          'notification_enabled': notificationEnabled ? 1 : 0,
          'notification_time': notificationTime,
          'notifications_before_period': notificationsBeforePeriod,
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
    
    final List<Map<String, dynamic>> settings = await db.query('menstrual_settings');
    
    if (settings.isEmpty) {
      // Buat pengaturan default
      final id = await db.insert('menstrual_settings', {
        'average_cycle_length': 28,
        'average_period_length': 5,
        'notification_enabled': 1,
        'notification_time': '08:00',
        'notifications_before_period': 2,
        'last_updated': DateTime.now().toIso8601String(),
      });
      
      return {
        'id': id,
        'average_cycle_length': 28,
        'average_period_length': 5,
        'notification_enabled': true,
        'notification_time': '08:00',
        'notifications_before_period': 2,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } else {
      final setting = settings.first;
      return {
        'id': setting['id'],
        'average_cycle_length': setting['average_cycle_length'],
        'average_period_length': setting['average_period_length'],
        'notification_enabled': setting['notification_enabled'] == 1,
        'notification_time': setting['notification_time'],
        'notifications_before_period': setting['notifications_before_period'],
        'last_updated': setting['last_updated'],
      };
    }
  }
  
  // Mendapatkan ringkasan statistik siklus
  Future<Map<String, dynamic>> getCycleStatistics() async {
    final db = await database;
    
    // Jumlah siklus yang direkam
    final int cycleCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM menstrual_cycles')
    ) ?? 0;
    
    // Rata-rata panjang siklus
    final double avgCycleLength = await getAverageCycleLength();
    
    // Rata-rata panjang periode
    final double avgPeriodLength = await getAveragePeriodLength();
    
    // Siklus terpanjang
    final int maxCycleLength = Sqflite.firstIntValue(
      await db.rawQuery('SELECT MAX(cycle_length) FROM menstrual_cycles')
    ) ?? 0;
    
    // Siklus terpendek
    final int minCycleLength = Sqflite.firstIntValue(
      await db.rawQuery('SELECT MIN(cycle_length) FROM menstrual_cycles WHERE cycle_length > 0')
    ) ?? 0;
    
    // Gejala yang paling sering dilaporkan
    final List<Map<String, dynamic>> commonSymptoms = await db.rawQuery('''
      SELECT type, COUNT(*) as count 
      FROM menstrual_symptoms 
      GROUP BY type 
      ORDER BY count DESC 
      LIMIT 3
    ''');
    
    final List<Map<String, dynamic>> topSymptoms = [];
    for (var symptom in commonSymptoms) {
      topSymptoms.add({
        'type': SymptomType.values[symptom['type'] as int],
        'count': symptom['count'],
      });
    }
    
    return {
      'cycle_count': cycleCount,
      'avg_cycle_length': avgCycleLength,
      'avg_period_length': avgPeriodLength,
      'max_cycle_length': maxCycleLength,
      'min_cycle_length': minCycleLength,
      'top_symptoms': topSymptoms,
    };
  }

  // Menutup database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}