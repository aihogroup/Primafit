import 'package:primafit/core/database/local_db.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ArtikelDatabase {
  static final ArtikelDatabase instance = ArtikelDatabase._init();
  static Database? _database;

  ArtikelDatabase._init();

  Future<Database> get database async {
    if (_database?.isOpen ?? false) return _database!;
    _database = await _initDB('artikel_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await LocalDb.open(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE artikel(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        content TEXT,
        author TEXT,
        publishedAt TEXT,
        urlToImage TEXT,
        url TEXT,
        source TEXT,
        timestamp INTEGER
      )
    ''');
  }

  // CREATE operation - Save article to favorites
  Future<int> saveArtikel(Map<String, dynamic> artikel) async {
    final db = await instance.database;
    
    // Check if article already exists
    final List<Map<String, dynamic>> existingArticle = await db.query(
      'artikel',
      where: 'url = ?',
      whereArgs: [artikel['url']],
    );
    
    if (existingArticle.isNotEmpty) {
      // Article already exists - update timestamp
      return await db.update(
        'artikel',
        {'timestamp': DateTime.now().millisecondsSinceEpoch},
        where: 'url = ?',
        whereArgs: [artikel['url']],
      );
    } else {
      // Format the article data for database storage
      final formattedArtikel = {
        'title': artikel['title'] ?? '',
        'description': artikel['description'] ?? '',
        'content': artikel['content'] ?? '',
        'author': artikel['author'] ?? '',
        'publishedAt': artikel['publishedAt'] ?? '',
        'urlToImage': artikel['urlToImage'] ?? '',
        'url': artikel['url'] ?? '',
        'source': artikel['source']?['name'] ?? artikel['source'] ?? '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Insert new article
      return await db.insert('artikel', formattedArtikel, 
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // READ operations
  // Get all saved articles
  Future<List<Map<String, dynamic>>> getAllArtikel() async {
    final db = await instance.database;
    
    // Get all articles, ordered by most recently saved first
    final result = await db.query(
      'artikel',
      orderBy: 'timestamp DESC',
    );
    
    return result.map((map) {
      // Convert database format back to the expected article format
      // This includes reconstructing the source object
      final processedMap = Map<String, dynamic>.from(map);
      processedMap['source'] = {'name': map['source']};
      return processedMap;
    }).toList();
  }

  // Get article by ID
  Future<Map<String, dynamic>?> getArtikelById(int id) async {
    final db = await instance.database;
    
    final maps = await db.query(
      'artikel',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      final map = maps.first;
      final processedMap = Map<String, dynamic>.from(map);
      processedMap['source'] = {'name': map['source']};
      return processedMap;
    }
    
    return null;
  }

  // Check if an article is in favorites
  Future<bool> isArtikelFavorite(String url) async {
    final db = await instance.database;
    
    final result = await db.query(
      'artikel',
      where: 'url = ?',
      whereArgs: [url],
    );
    
    return result.isNotEmpty;
  }

  // Search articles
  Future<List<Map<String, dynamic>>> searchArtikel(String query) async {
    final db = await instance.database;
    
    final result = await db.query(
      'artikel',
      where: 'title LIKE ? OR description LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'timestamp DESC',
    );
    
    return result.map((map) {
      final processedMap = Map<String, dynamic>.from(map);
      processedMap['source'] = {'name': map['source']};
      return processedMap;
    }).toList();
  }

  // UPDATE operation
  Future<int> updateArtikel(Map<String, dynamic> artikel) async {
    final db = await instance.database;
    
    // Format the article data
    final id = artikel['id'];
    
    final formattedArticle = {
      'title': artikel['title'] ?? '',
      'description': artikel['description'] ?? '',
      'content': artikel['content'] ?? '',
      'author': artikel['author'] ?? '',
      'publishedAt': artikel['publishedAt'] ?? '',
      'urlToImage': artikel['urlToImage'] ?? '',
      'url': artikel['url'] ?? '',
      'source': artikel['source']?['name'] ?? artikel['source'] ?? '',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    return await db.update(
      'artikel',
      formattedArticle,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE operations
  // Delete a single article
  Future<int> deleteArtikel(String url) async {
    final db = await instance.database;
    
    return await db.delete(
      'artikel',
      where: 'url = ?',
      whereArgs: [url],
    );
  }

  // Delete article by ID
  Future<int> deleteArtikelById(int id) async {
    final db = await instance.database;
    
    return await db.delete(
      'artikel',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all articles
  Future<int> deleteAllArtikel() async {
    final db = await instance.database;
    
    return await db.delete('artikel');
  }

  // Delete articles older than a certain date
  Future<int> deleteOldArtikel(DateTime olderThan) async {
    final db = await instance.database;
    final timestamp = olderThan.millisecondsSinceEpoch;
    
    return await db.delete(
      'artikel',
      where: 'timestamp < ?',
      whereArgs: [timestamp],
    );
  }

  // Close database
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}