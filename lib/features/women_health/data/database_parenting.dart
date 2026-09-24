import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseParenting {
  static const _databaseName = 'parenting_database.db';
  static const _databaseVersion = 1;

  // Singleton pattern
  DatabaseParenting._privateConstructor();
  static final DatabaseParenting instance = DatabaseParenting._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table: Children (Data Anak)
    await db.execute('''
      CREATE TABLE children (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        gender TEXT NOT NULL,
        blood_type TEXT,
        birth_weight REAL,
        birth_height REAL,
        parent_name TEXT,
        photo_path TEXT,
        notes TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Table: Milestones Template (Template Milestone berdasarkan usia)
    await db.execute('''
      CREATE TABLE milestone_templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        age_months INTEGER NOT NULL,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        is_critical INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Table: Child Milestones (Pencapaian milestone anak)
    await db.execute('''
      CREATE TABLE child_milestones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        milestone_template_id INTEGER NOT NULL,
        is_achieved INTEGER DEFAULT 0,
        achieved_date TEXT,
        notes TEXT,
        photo_path TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE,
        FOREIGN KEY (milestone_template_id) REFERENCES milestone_templates (id)
      )
    ''');

    // Table: Growth Records (Catatan Pertumbuhan)
    await db.execute('''
      CREATE TABLE growth_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        record_date TEXT NOT NULL,
        weight REAL,
        height REAL,
        head_circumference REAL,
        bmi REAL,
        percentile_weight INTEGER,
        percentile_height INTEGER,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    // Table: Vaccination Schedule (Jadwal Vaksinasi)
    await db.execute('''
      CREATE TABLE vaccination_schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vaccine_name TEXT NOT NULL,
        age_months INTEGER NOT NULL,
        description TEXT,
        is_required INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Table: Child Vaccinations (Catatan Vaksinasi Anak)
    await db.execute('''
      CREATE TABLE child_vaccinations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        vaccination_schedule_id INTEGER NOT NULL,
        vaccination_date TEXT,
        is_completed INTEGER DEFAULT 0,
        doctor_name TEXT,
        clinic_name TEXT,
        batch_number TEXT,
        next_vaccination_date TEXT,
        side_effects TEXT,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE,
        FOREIGN KEY (vaccination_schedule_id) REFERENCES vaccination_schedules (id)
      )
    ''');

    // Table: Health Records (Catatan Kesehatan)
    await db.execute('''
      CREATE TABLE health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        record_date TEXT NOT NULL,
        record_type TEXT NOT NULL, -- 'checkup', 'illness', 'medication', 'allergy'
        title TEXT NOT NULL,
        description TEXT,
        doctor_name TEXT,
        clinic_hospital TEXT,
        diagnosis TEXT,
        medication TEXT,
        dosage TEXT,
        temperature REAL,
        symptoms TEXT,
        treatment TEXT,
        follow_up_date TEXT,
        is_resolved INTEGER DEFAULT 0,
        attachments TEXT, -- JSON array of file paths
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    // Table: Photo Memories (Album Foto)
    await db.execute('''
      CREATE TABLE photo_memories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        photo_path TEXT NOT NULL,
        title TEXT,
        description TEXT,
        photo_date TEXT NOT NULL,
        age_months INTEGER,
        category TEXT, -- 'milestone', 'daily', 'special', 'growth'
        tags TEXT, -- JSON array of tags
        is_favorite INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    // Table: Sleep Records (Catatan Tidur)
    await db.execute('''
      CREATE TABLE sleep_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        sleep_date TEXT NOT NULL,
        bedtime TEXT,
        wake_time TEXT,
        nap_times TEXT, -- JSON array of nap periods
        total_sleep_hours REAL,
        sleep_quality INTEGER, -- 1-5 scale
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    // Table: Nutrition Records (Catatan Nutrisi)
    await db.execute('''
      CREATE TABLE nutrition_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER NOT NULL,
        record_date TEXT NOT NULL,
        meal_type TEXT NOT NULL, -- 'breakfast', 'lunch', 'dinner', 'snack', 'breastfeeding', 'formula'
        food_items TEXT, -- JSON array of food items
        quantity TEXT,
        nutrients TEXT, -- JSON object of nutrients
        calories REAL,
        feeding_time TEXT,
        appetite_level INTEGER, -- 1-5 scale
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    // Table: Parenting Tips (Tips Parenting)
    await db.execute('''
      CREATE TABLE parenting_tips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        age_range TEXT NOT NULL, -- '0-6m', '6-12m', '1-2y', etc.
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        author TEXT,
        source TEXT,
        tags TEXT, -- JSON array
        is_favorite INTEGER DEFAULT 0,
        view_count INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Table: Reminders (Pengingat)
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER,
        title TEXT NOT NULL,
        description TEXT,
        reminder_type TEXT NOT NULL, -- 'vaccination', 'checkup', 'medication', 'milestone', 'custom'
        reminder_date TEXT NOT NULL,
        reminder_time TEXT,
        is_repeat INTEGER DEFAULT 0,
        repeat_pattern TEXT, -- 'daily', 'weekly', 'monthly'
        is_completed INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    // Table: Emergency Contacts (Kontak Darurat)
    await db.execute('''
      CREATE TABLE emergency_contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        relationship TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        email TEXT,
        address TEXT,
        hospital_clinic TEXT,
        specialization TEXT,
        is_primary INTEGER DEFAULT 0,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Table: App Settings (Pengaturan Aplikasi)
    await db.execute('''
      CREATE TABLE app_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        setting_key TEXT UNIQUE NOT NULL,
        setting_value TEXT NOT NULL,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Insert default milestone templates
    await _insertDefaultMilestones(db);
    
    // Insert default vaccination schedules
    await _insertDefaultVaccinations(db);
    
    // Insert default parenting tips
    await _insertDefaultTips(db);
    
    // Insert default app settings
    await _insertDefaultSettings(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  // ==================== CHILDREN CRUD ====================
  
  Future<int> insertChild(Map<String, dynamic> child) async {
    final Database db = await database;
    child['created_at'] = DateTime.now().toIso8601String();
    child['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('children', child);
  }

  Future<List<Map<String, dynamic>>> getAllChildren() async {
    final Database db = await database;
    return await db.query('children', where: 'is_active = ?', whereArgs: [1]);
  }

  Future<Map<String, dynamic>?> getChildById(int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'children',
      where: 'id = ? AND is_active = ?',
      whereArgs: [id, 1],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateChild(int id, Map<String, dynamic> child) async {
    final Database db = await database;
    child['updated_at'] = DateTime.now().toIso8601String();
    return await db.update('children', child, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteChild(int id) async {
    final Database db = await database;
    return await db.update(
      'children',
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== MILESTONES CRUD ====================
  
  Future<List<Map<String, dynamic>>> getMilestoneTemplates({String? category, int? ageMonths}) async {
    final Database db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (category != null && ageMonths != null) {
      whereClause = 'category = ? AND age_months <= ?';
      whereArgs = [category, ageMonths];
    } else if (category != null) {
      whereClause = 'category = ?';
      whereArgs = [category];
    } else if (ageMonths != null) {
      whereClause = 'age_months <= ?';
      whereArgs = [ageMonths];
    }
    
    return await db.query(
      'milestone_templates',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'age_months ASC, category ASC',
    );
  }

  Future<int> insertChildMilestone(Map<String, dynamic> milestone) async {
    final Database db = await database;
    milestone['created_at'] = DateTime.now().toIso8601String();
    milestone['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('child_milestones', milestone);
  }

  Future<List<Map<String, dynamic>>> getChildMilestones(int childId) async {
    final Database db = await database;
    return await db.rawQuery('''
      SELECT cm.*, mt.title, mt.description, mt.category, mt.age_months, mt.is_critical
      FROM child_milestones cm
      JOIN milestone_templates mt ON cm.milestone_template_id = mt.id
      WHERE cm.child_id = ?
      ORDER BY mt.age_months ASC, mt.category ASC
    ''', [childId]);
  }

  Future<int> updateChildMilestone(int id, Map<String, dynamic> milestone) async {
    final Database db = await database;
    milestone['updated_at'] = DateTime.now().toIso8601String();
    return await db.update('child_milestones', milestone, where: 'id = ?', whereArgs: [id]);
  }

  // ==================== GROWTH RECORDS CRUD ====================
  
  Future<int> insertGrowthRecord(Map<String, dynamic> record) async {
    final Database db = await database;
    record['created_at'] = DateTime.now().toIso8601String();
    record['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('growth_records', record);
  }

  Future<List<Map<String, dynamic>>> getGrowthRecords(int childId, {int? limit}) async {
    final Database db = await database;
    return await db.query(
      'growth_records',
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'record_date DESC',
      limit: limit,
    );
  }

  Future<int> updateGrowthRecord(int id, Map<String, dynamic> record) async {
    final Database db = await database;
    record['updated_at'] = DateTime.now().toIso8601String();
    return await db.update('growth_records', record, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteGrowthRecord(int id) async {
    final Database db = await database;
    return await db.delete('growth_records', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== VACCINATIONS CRUD ====================
  
  Future<List<Map<String, dynamic>>> getVaccinationSchedules({int? ageMonths}) async {
    final Database db = await database;
    final String whereClause = ageMonths != null ? 'age_months <= ?' : '';
    final List<dynamic> whereArgs = ageMonths != null ? [ageMonths] : [];
    
    return await db.query(
      'vaccination_schedules',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'age_months ASC',
    );
  }

  Future<int> insertChildVaccination(Map<String, dynamic> vaccination) async {
    final Database db = await database;
    vaccination['created_at'] = DateTime.now().toIso8601String();
    vaccination['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('child_vaccinations', vaccination);
  }

  Future<List<Map<String, dynamic>>> getChildVaccinations(int childId) async {
    final Database db = await database;
    return await db.rawQuery('''
      SELECT cv.*, vs.vaccine_name, vs.age_months, vs.description, vs.is_required
      FROM child_vaccinations cv
      JOIN vaccination_schedules vs ON cv.vaccination_schedule_id = vs.id
      WHERE cv.child_id = ?
      ORDER BY vs.age_months ASC
    ''', [childId]);
  }

  Future<int> updateChildVaccination(int id, Map<String, dynamic> vaccination) async {
    final Database db = await database;
    vaccination['updated_at'] = DateTime.now().toIso8601String();
    return await db.update('child_vaccinations', vaccination, where: 'id = ?', whereArgs: [id]);
  }

  // ==================== HEALTH RECORDS CRUD ====================
  
  Future<int> insertHealthRecord(Map<String, dynamic> record) async {
    final Database db = await database;
    record['created_at'] = DateTime.now().toIso8601String();
    record['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('health_records', record);
  }

  Future<List<Map<String, dynamic>>> getHealthRecords(int childId, {String? recordType}) async {
    final Database db = await database;
    String whereClause = 'child_id = ?';
    final List<dynamic> whereArgs = [childId];
    
    if (recordType != null) {
      whereClause += ' AND record_type = ?';
      whereArgs.add(recordType);
    }
    
    return await db.query(
      'health_records',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'record_date DESC',
    );
  }

  Future<int> updateHealthRecord(int id, Map<String, dynamic> record) async {
    final Database db = await database;
    record['updated_at'] = DateTime.now().toIso8601String();
    return await db.update('health_records', record, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteHealthRecord(int id) async {
    final Database db = await database;
    return await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== PHOTO MEMORIES CRUD ====================
  
  Future<int> insertPhotoMemory(Map<String, dynamic> photo) async {
    final Database db = await database;
    photo['created_at'] = DateTime.now().toIso8601String();
    photo['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('photo_memories', photo);
  }

  Future<List<Map<String, dynamic>>> getPhotoMemories(int childId, {String? category, bool? isFavorite}) async {
    final Database db = await database;
    String whereClause = 'child_id = ?';
    final List<dynamic> whereArgs = [childId];
    
    if (category != null) {
      whereClause += ' AND category = ?';
      whereArgs.add(category);
    }
    
    if (isFavorite != null) {
      whereClause += ' AND is_favorite = ?';
      whereArgs.add(isFavorite ? 1 : 0);
    }
    
    return await db.query(
      'photo_memories',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'photo_date DESC',
    );
  }

  Future<int> updatePhotoMemory(int id, Map<String, dynamic> photo) async {
    final Database db = await database;
    photo['updated_at'] = DateTime.now().toIso8601String();
    return await db.update('photo_memories', photo, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePhotoMemory(int id) async {
    final Database db = await database;
    return await db.delete('photo_memories', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== SLEEP RECORDS CRUD ====================
  
  Future<int> insertSleepRecord(Map<String, dynamic> record) async {
    final Database db = await database;
    record['created_at'] = DateTime.now().toIso8601String();
    record['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('sleep_records', record);
  }

  Future<List<Map<String, dynamic>>> getSleepRecords(int childId, {int? limit}) async {
    final Database db = await database;
    return await db.query(
      'sleep_records',
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'sleep_date DESC',
      limit: limit,
    );
  }

  Future<int> updateSleepRecord(int id, Map<String, dynamic> record) async {
    final Database db = await database;
    record['updated_at'] = DateTime.now().toIso8601String();
    return await db.update('sleep_records', record, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSleepRecord(int id) async {
    final Database db = await database;
    return await db.delete('sleep_records', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== NUTRITION RECORDS CRUD ====================
  
  Future<int> insertNutritionRecord(Map<String, dynamic> record) async {
    final Database db = await database;
    record['created_at'] = DateTime.now().toIso8601String();
    record['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('nutrition_records', record);
  }

  Future<List<Map<String, dynamic>>> getNutritionRecords(int childId, {String? mealType, String? date}) async {
    final Database db = await database;
    String whereClause = 'child_id = ?';
    final List<dynamic> whereArgs = [childId];
    
    if (mealType != null) {
      whereClause += ' AND meal_type = ?';
      whereArgs.add(mealType);
    }
    
    if (date != null) {
      whereClause += ' AND record_date = ?';
      whereArgs.add(date);
    }
    
    return await db.query(
      'nutrition_records',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'record_date DESC, feeding_time DESC',
    );
  }

  Future<int> updateNutritionRecord(int id, Map<String, dynamic> record) async {
    final Database db = await database;
    record['updated_at'] = DateTime.now().toIso8601String();
    return await db.update('nutrition_records', record, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteNutritionRecord(int id) async {
    final Database db = await database;
    return await db.delete('nutrition_records', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== PARENTING TIPS CRUD ====================
  
  Future<List<Map<String, dynamic>>> getParentingTips({String? category, String? ageRange}) async {
    final Database db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (category != null && ageRange != null) {
      whereClause = 'category = ? AND age_range = ?';
      whereArgs = [category, ageRange];
    } else if (category != null) {
      whereClause = 'category = ?';
      whereArgs = [category];
    } else if (ageRange != null) {
      whereClause = 'age_range = ?';
      whereArgs = [ageRange];
    }
    
    return await db.query(
      'parenting_tips',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'view_count DESC, created_at DESC',
    );
  }

  Future<int> updateTipViewCount(int id) async {
    final Database db = await database;
    return await db.rawUpdate(
      'UPDATE parenting_tips SET view_count = view_count + 1, updated_at = ? WHERE id = ?',
      [DateTime.now().toIso8601String(), id],
    );
  }

  Future<int> updateTipFavorite(int id, bool isFavorite) async {
    final Database db = await database;
    return await db.update(
      'parenting_tips',
      {
        'is_favorite': isFavorite ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== REMINDERS CRUD ====================
  
  Future<int> insertReminder(Map<String, dynamic> reminder) async {
    final Database db = await database;
    reminder['created_at'] = DateTime.now().toIso8601String();
    reminder['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('reminders', reminder);
  }

  Future<List<Map<String, dynamic>>> getReminders({int? childId, bool? isActive, bool? isCompleted}) async {
    final Database db = await database;
    String whereClause = '';
    final List<dynamic> whereArgs = [];
    
    final List<String> conditions = [];
    
    if (childId != null) {
      conditions.add('child_id = ?');
      whereArgs.add(childId);
    }
    
    if (isActive != null) {
      conditions.add('is_active = ?');
      whereArgs.add(isActive ? 1 : 0);
    }
    
    if (isCompleted != null) {
      conditions.add('is_completed = ?');
      whereArgs.add(isCompleted ? 1 : 0);
    }
    
    whereClause = conditions.join(' AND ');
    
    return await db.query(
      'reminders',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'reminder_date ASC, reminder_time ASC',
    );
  }

  Future<int> updateReminder(int id, Map<String, dynamic> reminder) async {
    final Database db = await database;
    reminder['updated_at'] = DateTime.now().toIso8601String();
    return await db.update('reminders', reminder, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteReminder(int id) async {
    final Database db = await database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== EMERGENCY CONTACTS CRUD ====================
  
  Future<int> insertEmergencyContact(Map<String, dynamic> contact) async {
    final Database db = await database;
    contact['created_at'] = DateTime.now().toIso8601String();
    contact['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert('emergency_contacts', contact);
  }

  Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    final Database db = await database;
    return await db.query('emergency_contacts', orderBy: 'is_primary DESC, name ASC');
  }

  Future<int> updateEmergencyContact(int id, Map<String, dynamic> contact) async {
    final Database db = await database;
    contact['updated_at'] = DateTime.now().toIso8601String();
    return await db.update('emergency_contacts', contact, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteEmergencyContact(int id) async {
    final Database db = await database;
    return await db.delete('emergency_contacts', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== APP SETTINGS CRUD ====================
  
  Future<int> insertOrUpdateSetting(String key, String value) async {
    final Database db = await database;
    return await db.rawInsert(
      'INSERT OR REPLACE INTO app_settings (setting_key, setting_value, updated_at) VALUES (?, ?, ?)',
      [key, value, DateTime.now().toIso8601String()],
    );
  }

  Future<String?> getSetting(String key) async {
    final Database db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'app_settings',
      where: 'setting_key = ?',
      whereArgs: [key],
    );
    return results.isNotEmpty ? results.first['setting_value'] : null;
  }

  // ==================== ANALYTICS & STATISTICS ====================
  
  Future<Map<String, dynamic>> getChildStatistics(int childId) async {
    final Database db = await database;
    
    // Get child age in months
    final child = await getChildById(childId);
    if (child == null) return {};
    
    final DateTime birthDate = DateTime.parse(child['date_of_birth']);
    final int ageInMonths = DateTime.now().difference(birthDate).inDays ~/ 30;
    
    // Get milestone progress
    final milestoneProgress = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_milestones,
        SUM(CASE WHEN is_achieved = 1 THEN 1 ELSE 0 END) as achieved_milestones
      FROM child_milestones cm
      JOIN milestone_templates mt ON cm.milestone_template_id = mt.id
      WHERE cm.child_id = ? AND mt.age_months <= ?
    ''', [childId, ageInMonths]);
    
    // Get latest growth data
    final latestGrowth = await db.query(
      'growth_records',
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'record_date DESC',
      limit: 1,
    );
    
    // Get vaccination progress
    final vaccinationProgress = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_vaccinations,
        SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed_vaccinations
      FROM child_vaccinations cv
      JOIN vaccination_schedules vs ON cv.vaccination_schedule_id = vs.id
      WHERE cv.child_id = ? AND vs.age_months <= ?
    ''', [childId, ageInMonths]);
    
    // Get total photos
    final photoCount = await db.rawQuery('''
      SELECT COUNT(*) as total_photos
      FROM photo_memories
      WHERE child_id = ?
    ''', [childId]);
    
    return {
      'age_months': ageInMonths,
      'milestone_progress': milestoneProgress.isNotEmpty ? milestoneProgress.first : {},
      'latest_growth': latestGrowth.isNotEmpty ? latestGrowth.first : {},
      'vaccination_progress': vaccinationProgress.isNotEmpty ? vaccinationProgress.first : {},
      'total_photos': photoCount.isNotEmpty ? photoCount.first['total_photos'] : 0,
    };
  }

  Future<List<Map<String, dynamic>>> getUpcomingReminders({int days = 7}) async {
    final Database db = await database;
    final String endDate = DateTime.now().add(Duration(days: days)).toIso8601String().split('T')[0];
    final String today = DateTime.now().toIso8601String().split('T')[0];
    
    return await db.query(
      'reminders',
      where: 'is_active = 1 AND is_completed = 0 AND reminder_date BETWEEN ? AND ?',
      whereArgs: [today, endDate],
      orderBy: 'reminder_date ASC, reminder_time ASC',
    );
  }

  // ==================== DEFAULT DATA INSERTION ====================
  
  Future<void> _insertDefaultMilestones(Database db) async {
    final List<Map<String, dynamic>> milestones = [
      // 0-3 months
      {'age_months': 0, 'category': 'Motor', 'title': 'Mengangkat kepala sebentar', 'description': 'Bayi dapat mengangkat kepala sebentar saat tengkurap', 'is_critical': 1},
      {'age_months': 1, 'category': 'Motor', 'title': 'Menggerakkan tangan dan kaki', 'description': 'Gerakan tangan dan kaki menjadi lebih terarah', 'is_critical': 0},
      {'age_months': 2, 'category': 'Sosial', 'title': 'Tersenyum sosial', 'description': 'Bayi mulai tersenyum sebagai respons sosial', 'is_critical': 1},
      {'age_months': 3, 'category': 'Motor', 'title': 'Mengangkat kepala 45 derajat', 'description': 'Mengangkat kepala dan dada saat tengkurap', 'is_critical': 1},
      
      // 4-6 months
      {'age_months': 4, 'category': 'Motor', 'title': 'Berguling dari tengkurap ke telentang', 'description': 'Bayi dapat berguling dengan bantuan minimal', 'is_critical': 1},
      {'age_months': 5, 'category': 'Kognitif', 'title': 'Meraih benda', 'description': 'Dapat meraih dan memegang benda dengan kedua tangan', 'is_critical': 0},
      {'age_months': 6, 'category': 'Motor', 'title': 'Duduk dengan bantuan', 'description': 'Dapat duduk dengan disangga', 'is_critical': 1},
      {'age_months': 6, 'category': 'Bahasa', 'title': 'Babbling', 'description': 'Mulai mengeluarkan suara seperti "ba-ba", "ma-ma"', 'is_critical': 0},
      
      // 7-12 months
      {'age_months': 7, 'category': 'Motor', 'title': 'Duduk tanpa bantuan', 'description': 'Dapat duduk sendiri tanpa disangga', 'is_critical': 1},
      {'age_months': 8, 'category': 'Motor', 'title': 'Merangkak', 'description': 'Mulai merangkak atau bergerak dengan perut', 'is_critical': 0},
      {'age_months': 9, 'category': 'Kognitif', 'title': 'Memahami "tidak"', 'description': 'Merespons kata "tidak" dengan berhenti sejenak', 'is_critical': 0},
      {'age_months': 10, 'category': 'Motor', 'title': 'Berdiri dengan pegangan', 'description': 'Dapat berdiri sambil berpegang pada furniture', 'is_critical': 0},
      {'age_months': 12, 'category': 'Motor', 'title': 'Berjalan sendiri', 'description': 'Dapat berjalan beberapa langkah tanpa bantuan', 'is_critical': 1},
      {'age_months': 12, 'category': 'Bahasa', 'title': 'Kata pertama', 'description': 'Mengucapkan kata pertama dengan makna', 'is_critical': 1},
      
      // 13-24 months
      {'age_months': 15, 'category': 'Motor', 'title': 'Berjalan stabil', 'description': 'Berjalan dengan stabil dan jarang jatuh', 'is_critical': 1},
      {'age_months': 18, 'category': 'Bahasa', 'title': '10-20 kata', 'description': 'Memiliki kosakata 10-20 kata', 'is_critical': 0},
      {'age_months': 18, 'category': 'Motor', 'title': 'Naik tangga merangkak', 'description': 'Dapat naik tangga dengan merangkak', 'is_critical': 0},
      {'age_months': 24, 'category': 'Bahasa', 'title': 'Kalimat 2 kata', 'description': 'Dapat membuat kalimat sederhana 2 kata', 'is_critical': 1},
      {'age_months': 24, 'category': 'Motor', 'title': 'Lari dan melompat', 'description': 'Dapat berlari dan melompat dengan kedua kaki', 'is_critical': 0},
      
      // 25-36 months
      {'age_months': 30, 'category': 'Sosial', 'title': 'Bermain paralel', 'description': 'Bermain berdampingan dengan anak lain', 'is_critical': 0},
      {'age_months': 36, 'category': 'Bahasa', 'title': 'Kalimat lengkap', 'description': 'Dapat berbicara dalam kalimat lengkap 3-4 kata', 'is_critical': 1},
      {'age_months': 36, 'category': 'Motor', 'title': 'Naik sepeda roda tiga', 'description': 'Dapat mengendarai sepeda roda tiga', 'is_critical': 0},
    ];
    
    for (var milestone in milestones) {
      await db.insert('milestone_templates', milestone);
    }
  }

  Future<void> _insertDefaultVaccinations(Database db) async {
    final List<Map<String, dynamic>> vaccinations = [
      {'vaccine_name': 'Hepatitis B1', 'age_months': 0, 'description': 'Vaksin Hepatitis B dosis pertama (0-24 jam setelah lahir)', 'is_required': 1},
      {'vaccine_name': 'BCG', 'age_months': 0, 'description': 'Vaksin BCG untuk mencegah tuberkulosis (0-2 bulan)', 'is_required': 1},
      {'vaccine_name': 'Polio 1', 'age_months': 0, 'description': 'Vaksin Polio tetes dosis pertama (0-1 bulan)', 'is_required': 1},
      
      {'vaccine_name': 'DPT-HB-Hib 1', 'age_months': 2, 'description': 'Vaksin kombinasi DPT, Hepatitis B, dan Hib dosis pertama', 'is_required': 1},
      {'vaccine_name': 'Polio 2', 'age_months': 2, 'description': 'Vaksin Polio dosis kedua', 'is_required': 1},
      {'vaccine_name': 'PCV 1', 'age_months': 2, 'description': 'Vaksin Pneumokokus dosis pertama', 'is_required': 1},
      {'vaccine_name': 'Rotavirus 1', 'age_months': 2, 'description': 'Vaksin Rotavirus dosis pertama', 'is_required': 0},
      
      {'vaccine_name': 'DPT-HB-Hib 2', 'age_months': 3, 'description': 'Vaksin kombinasi DPT, Hepatitis B, dan Hib dosis kedua', 'is_required': 1},
      {'vaccine_name': 'Polio 3', 'age_months': 3, 'description': 'Vaksin Polio dosis ketiga', 'is_required': 1},
      {'vaccine_name': 'PCV 2', 'age_months': 3, 'description': 'Vaksin Pneumokokus dosis kedua', 'is_required': 1},
      {'vaccine_name': 'Rotavirus 2', 'age_months': 3, 'description': 'Vaksin Rotavirus dosis kedua', 'is_required': 0},
      
      {'vaccine_name': 'DPT-HB-Hib 3', 'age_months': 4, 'description': 'Vaksin kombinasi DPT, Hepatitis B, dan Hib dosis ketiga', 'is_required': 1},
      {'vaccine_name': 'Polio 4', 'age_months': 4, 'description': 'Vaksin Polio dosis keempat', 'is_required': 1},
      {'vaccine_name': 'PCV 3', 'age_months': 4, 'description': 'Vaksin Pneumokokus dosis ketiga', 'is_required': 1},
      {'vaccine_name': 'IPV', 'age_months': 4, 'description': 'Vaksin Polio suntik (IPV)', 'is_required': 1},
      {'vaccine_name': 'Rotavirus 3', 'age_months': 4, 'description': 'Vaksin Rotavirus dosis ketiga', 'is_required': 0},
      
      {'vaccine_name': 'Campak', 'age_months': 9, 'description': 'Vaksin Campak dosis pertama', 'is_required': 1},
      {'vaccine_name': 'PCV Booster', 'age_months': 12, 'description': 'Vaksin Pneumokokus booster', 'is_required': 1},
      {'vaccine_name': 'MMR 1', 'age_months': 15, 'description': 'Vaksin MMR (Campak, Gondongan, Rubella) dosis pertama', 'is_required': 1},
      {'vaccine_name': 'Varicella 1', 'age_months': 15, 'description': 'Vaksin Cacar Air dosis pertama', 'is_required': 0},
      
      {'vaccine_name': 'DPT Booster', 'age_months': 18, 'description': 'Vaksin DPT booster', 'is_required': 1},
      {'vaccine_name': 'MMR 2', 'age_months': 24, 'description': 'Vaksin MMR dosis kedua', 'is_required': 1},
      {'vaccine_name': 'Varicella 2', 'age_months': 24, 'description': 'Vaksin Cacar Air dosis kedua', 'is_required': 0},
    ];
    
    for (var vaccination in vaccinations) {
      await db.insert('vaccination_schedules', vaccination);
    }
  }

  Future<void> _insertDefaultTips(Database db) async {
    final List<Map<String, dynamic>> tips = [
      {
        'category': 'Feeding',
        'age_range': '0-6m',
        'title': 'ASI Eksklusif untuk Bayi Baru Lahir',
        'content': 'Berikan ASI eksklusif selama 6 bulan pertama. ASI mengandung semua nutrisi yang dibutuhkan bayi dan membantu membangun sistem kekebalan tubuh. Frekuensi menyusui sekitar 8-12 kali per hari.',
        'author': 'Dr. Sarah Pediatri',
        'source': 'IDAI',
        'tags': '["ASI", "nutrisi", "imunitas"]',
      },
      {
        'category': 'Sleep',
        'age_range': '0-3m',
        'title': 'Pola Tidur Bayi Baru Lahir',
        'content': 'Bayi baru lahir tidur 14-17 jam per hari dengan pola tidur yang belum teratur. Ciptakan lingkungan tidur yang aman: telentang, kasur keras, tanpa bantal atau selimut tebal.',
        'author': 'Dr. Ahmad Sleep Specialist',
        'source': 'Sleep Foundation',
        'tags': '["tidur", "keamanan", "SIDS"]',
      },
      {
        'category': 'Development',
        'age_range': '6-12m',
        'title': 'Stimulasi Motorik Halus',
        'content': 'Berikan mainan yang dapat digenggam, ajak bayi bermain cilukba, dan biarkan bayi memegang makanan fingerfood. Kegiatan ini membantu perkembangan koordinasi mata-tangan.',
        'author': 'Terapis Okupasi Lisa',
        'source': 'Child Development Center',
        'tags': '["motorik", "stimulasi", "mainan"]',
      },
      {
        'category': 'Health',
        'age_range': '1-2y',
        'title': 'Toilet Training yang Tepat',
        'content': 'Mulai toilet training saat anak menunjukkan tanda-tanda siap: bisa berjalan stabil, dapat mengomunikasikan kebutuhan buang air. Jangan terburu-buru dan gunakan positive reinforcement.',
        'author': 'Psikolog Anak Maya',
        'source': 'Parenting Institute',
        'tags': '["toilet training", "kemandirian", "psikologi"]',
      },
      {
        'category': 'Nutrition',
        'age_range': '6-12m',
        'title': 'MPASI Pertama yang Aman',
        'content': 'Mulai MPASI di usia 6 bulan dengan tekstur halus. Perkenalkan satu jenis makanan dalam 3-4 hari untuk melihat reaksi alergi. Mulai dengan buah dan sayuran yang dihaluskan.',
        'author': 'Nutritionist Dewi',
        'source': 'WHO Guidelines',
        'tags': '["MPASI", "alergi", "nutrisi"]',
      },
    ];
    
    for (var tip in tips) {
      await db.insert('parenting_tips', tip);
    }
  }

  Future<void> _insertDefaultSettings(Database db) async {
    final List<Map<String, dynamic>> settings = [
      {'setting_key': 'notification_enabled', 'setting_value': 'true'},
      {'setting_key': 'reminder_time_before', 'setting_value': '60'}, // minutes
      {'setting_key': 'growth_chart_unit', 'setting_value': 'metric'}, // metric or imperial
      {'setting_key': 'language', 'setting_value': 'id'}, // Indonesian
      {'setting_key': 'theme_mode', 'setting_value': 'system'}, // light, dark, system
      {'setting_key': 'backup_enabled', 'setting_value': 'false'},
      {'setting_key': 'export_format', 'setting_value': 'pdf'}, // pdf, excel
      {'setting_key': 'privacy_mode', 'setting_value': 'false'},
    ];
    
    for (var setting in settings) {
      await db.insert('app_settings', setting);
    }
  }

  // ==================== UTILITY METHODS ====================
  
  Future<void> closeDatabase() async {
    final Database db = await database;
    await db.close();
  }

  // Future<void> deleteDatabase() async {
  //   Directory documentsDirectory = await getApplicationDocumentsDirectory();
  //   String path = join(documentsDirectory.path, _databaseName);
  //   await deleteDatabase(path);
  // }

  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final Database db = await database;
    
    final List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
    );
    
    final Map<String, dynamic> info = {
      'database_name': _databaseName,
      'version': _databaseVersion,
      'tables': [],
    };
    
    for (var table in tables) {
      final String tableName = table['name'];
      final List<Map<String, dynamic>> count = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      info['tables'].add({
        'name': tableName,
        'count': count.first['count']
      });
    }
    
    return info;
  }

  // ==================== BACKUP & RESTORE ====================
  
  Future<String> exportData() async {
    final Database db = await database;
    final Map<String, dynamic> exportData = {};
    
    // Export all tables data
    final List<String> tableNames = [
      'children', 'milestone_templates', 'child_milestones', 'growth_records',
      'vaccination_schedules', 'child_vaccinations', 'health_records',
      'photo_memories', 'sleep_records', 'nutrition_records', 'parenting_tips',
      'reminders', 'emergency_contacts', 'app_settings'
    ];
    
    for (String tableName in tableNames) {
      exportData[tableName] = await db.query(tableName);
    }
    
    exportData['export_date'] = DateTime.now().toIso8601String();
    exportData['version'] = _databaseVersion;
    
    return exportData.toString(); // In real app, use json.encode()
  }

  Future<bool> importData(String jsonData) async {
    try {
      final Database db = await database;
      // In real app, use json.decode()
      final Map<String, dynamic> importData = {}; // Parse jsonData
      
      // Clear existing data (optional)
      // await _clearAllTables(db);
      
      // Import data table by table
      for (String tableName in importData.keys) {
        if (tableName != 'export_date' && tableName != 'version') {
          final List<dynamic> tableData = importData[tableName];
          for (var record in tableData) {
            await db.insert(tableName, record, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      return false;
    }
  }


  // ==================== SEARCH FUNCTIONALITY ====================
  
  Future<List<Map<String, dynamic>>> searchHealthRecords(int childId, String query) async {
    final Database db = await database;
    return await db.query(
      'health_records',
      where: 'child_id = ? AND (title LIKE ? OR description LIKE ? OR diagnosis LIKE ?)',
      whereArgs: [childId, '%$query%', '%$query%', '%$query%'],
      orderBy: 'record_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> searchPhotos(int childId, String query) async {
    final Database db = await database;
    return await db.query(
      'photo_memories',
      where: 'child_id = ? AND (title LIKE ? OR description LIKE ? OR tags LIKE ?)',
      whereArgs: [childId, '%$query%', '%$query%', '%$query%'],
      orderBy: 'photo_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> searchTips(String query) async {
    final Database db = await database;
    return await db.query(
      'parenting_tips',
      where: 'title LIKE ? OR content LIKE ? OR tags LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'view_count DESC',
    );
  }
}