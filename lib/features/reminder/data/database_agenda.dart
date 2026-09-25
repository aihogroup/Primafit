import 'package:primafit/core/database/local_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:primafit/features/reminder/presentation/jadwal/notification_service.dart';

class Agenda {
  int? id;
  String title;
  String? description;
  String date;
  String time;
  int isCompleted;
  String? reminderTime; // '15min', '30min', '1hour', '1day', null (tidak ada reminder)
  String? repeatType; // 'daily', 'weekly', 'monthly', 'yearly', null (tidak berulang)
  int? repeatInterval; // interval pengulangan (1 = setiap hari, 2 = setiap 2 hari, dst)
  String color; // Warna untuk agenda

  Agenda({
    this.id,
    required this.title,
    this.description,
    required this.date,
    required this.time,
    this.isCompleted = 0,
    this.reminderTime,
    this.repeatType,
    this.repeatInterval,
    this.color = '#64D1DE', // Default warna tema
  });

  // Convert from Map (for database)
  factory Agenda.fromMap(Map<String, dynamic> map) {
    return Agenda(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
      time: map['time'],
      isCompleted: map['isCompleted'],
      reminderTime: map['reminderTime'],
      repeatType: map['repeatType'],
      repeatInterval: map['repeatInterval'],
      color: map['color'] ?? '#64D1DE',
    );
  }

  // Convert to Map (for database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'isCompleted': isCompleted,
      'reminderTime': reminderTime,
      'repeatType': repeatType,
      'repeatInterval': repeatInterval,
      'color': color,
    };
  }

  // Clone agenda untuk membuat agenda berulang berikutnya
  Agenda copyWithNewDate(String newDate) {
    return Agenda(
      title: title,
      description: description,
      date: newDate,
      time: time,
      isCompleted: 0, // Reset status completed
      reminderTime: reminderTime,
      repeatType: repeatType,
      repeatInterval: repeatInterval,
      color: color,
    );
  }
}

class DatabaseAgenda {
  static Database? _database;

  // Singleton pattern
  static final DatabaseAgenda instance = DatabaseAgenda._internal();
  DatabaseAgenda._internal();

  Future<Database> get database async {
    if (_database?.isOpen ?? false) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Init DB
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'agenda.db');

    return await LocalDb.open(
      path,
      version: 2, // Versi ditingkatkan karena struktur tabel berubah
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // Create table
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE agenda (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        reminderTime TEXT,
        repeatType TEXT,
        repeatInterval INTEGER,
        color TEXT
      )
    ''');
  }

  // Upgrade database when structure changes
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for version 2
      await db.execute('ALTER TABLE agenda ADD COLUMN reminderTime TEXT');
      await db.execute('ALTER TABLE agenda ADD COLUMN repeatType TEXT');
      await db.execute('ALTER TABLE agenda ADD COLUMN repeatInterval INTEGER');
      await db.execute('ALTER TABLE agenda ADD COLUMN color TEXT DEFAULT "#64D1DE"');
    }
  }

  // Create
  Future<int> insertAgenda(Agenda agenda) async {
    final db = await instance.database;
    final id = await db.insert('agenda', agenda.toMap());
    
    // Jadwalkan notifikasi untuk agenda baru
    agenda.id = id;
    await NotificationService().scheduleAgendaNotification(agenda);
    
    // Jika agenda berulang, buat juga agenda berikutnya
    if (agenda.repeatType != null && agenda.repeatInterval != null) {
      await _scheduleNextRepeatingAgenda(agenda);
    }
    
    return id;
  }

  // Schedule the next occurrence for a repeating agenda
  Future<void> _scheduleNextRepeatingAgenda(Agenda agenda) async {
    if (agenda.repeatType == null || agenda.repeatInterval == null) return;
    
    DateTime date = DateTime.parse(agenda.date);
    
    switch (agenda.repeatType) {
      case 'daily':
        date = date.add(Duration(days: agenda.repeatInterval!));
        break;
      case 'weekly':
        date = date.add(Duration(days: 7 * agenda.repeatInterval!));
        break;
      case 'monthly':
        date = DateTime(date.year, date.month + agenda.repeatInterval!, date.day);
        break;
      case 'yearly':
        date = DateTime(date.year + agenda.repeatInterval!, date.month, date.day);
        break;
    }
    
    // Format date to string in yyyy-MM-dd format
    final String nextDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    
    // Create next agenda
    final Agenda nextAgenda = agenda.copyWithNewDate(nextDate);
    
    // Don't await this, let it run in background
    insertAgenda(nextAgenda);
  }

  // Read all
  Future<List<Agenda>> getAllAgenda() async {
    final db = await instance.database;
    final result = await db.query('agenda', orderBy: 'date ASC, time ASC');
    return result.map((map) => Agenda.fromMap(map)).toList();
  }

  // Read agenda for a specific date range
  Future<List<Agenda>> getAgendaInDateRange(String startDate, String endDate) async {
    final db = await instance.database;
    final result = await db.query(
      'agenda',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC, time ASC',
    );
    return result.map((map) => Agenda.fromMap(map)).toList();
  }

  // Get agenda for a specific date
  Future<List<Agenda>> getAgendaByDate(String date) async {
    final db = await instance.database;
    final result = await db.query(
      'agenda',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'time ASC',
    );
    return result.map((map) => Agenda.fromMap(map)).toList();
  }

  // Read with pagination (for better performance with large datasets)
  Future<List<Agenda>> getAgendaByPage(int page, int pageSize) async {
    final db = await instance.database;
    final offset = page * pageSize;
    
    final result = await db.query(
      'agenda',
      orderBy: 'date ASC, time ASC',
      limit: pageSize,
      offset: offset,
    );
    
    return result.map((map) => Agenda.fromMap(map)).toList();
  }

  // Read by ID
  Future<Agenda?> getAgendaById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'agenda',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Agenda.fromMap(result.first);
    }
    return null;
  }

  // Update
  Future<int> updateAgenda(Agenda agenda) async {
    final db = await instance.database;
    final result = await db.update(
      'agenda',
      agenda.toMap(),
      where: 'id = ?',
      whereArgs: [agenda.id],
    );
    
    // Batalkan notifikasi lama dan jadwalkan yang baru
    if (agenda.id != null) {
      await NotificationService().cancelNotification(agenda.id!);
      
      // Jika belum selesai, jadwalkan notifikasi baru
      if (agenda.isCompleted == 0) {
        await NotificationService().scheduleAgendaNotification(agenda);
      }
    }
    
    return result;
  }

  // Toggle completion status
  Future<int> toggleAgendaCompletion(int id, bool isCompleted) async {
    final db = await instance.database;
    final status = isCompleted ? 1 : 0;
    
    final result = await db.update(
      'agenda',
      {'isCompleted': status},
      where: 'id = ?',
      whereArgs: [id],
    );
    
    // If completed, cancel notification
    if (isCompleted) {
      await NotificationService().cancelNotification(id);
    } else {
      // If uncompleted, reschedule notification
      final agenda = await getAgendaById(id);
      if (agenda != null) {
        await NotificationService().scheduleAgendaNotification(agenda);
      }
    }
    
    return result;
  }

  // Delete
  Future<int> deleteAgenda(int id) async {
    final db = await instance.database;
    
    // Batalkan notifikasi saat agenda dihapus
    await NotificationService().cancelNotification(id);
    
    return await db.delete(
      'agenda',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete agendas with date before specified date
  Future<int> deleteOldAgendas(String date) async {
    final db = await instance.database;
    
    // Get IDs of agendas to delete
    final result = await db.query(
      'agenda',
      columns: ['id'],
      where: 'date < ?',
      whereArgs: [date],
    );
    
    // Cancel notifications for all deleted agendas
    for (var row in result) {
      final id = row['id'] as int;
      await NotificationService().cancelNotification(id);
    }
    
    return await db.delete(
      'agenda',
      where: 'date < ?',
      whereArgs: [date],
    );
  }

  // Close DB
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}