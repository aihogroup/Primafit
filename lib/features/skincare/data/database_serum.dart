import 'package:primafit/core/database/local_db.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperSerum {
  static final DatabaseHelperSerum instance = DatabaseHelperSerum._init();
  static Database? _database;

  DatabaseHelperSerum._init();

  // Fungsi untuk menambahkan data sampel produk ke database
  Future<bool> addSampleProducts() async {
    try {
      final db = await database;
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM serum_products'));
      if (count != null && count > 0) {
        debugPrint('Data produk sudah ada, tidak perlu menambahkan sampel');
        return true;
      }
      
      // Contoh produk serum untuk berbagai kategori
      final List<Map<String, dynamic>> products = [
        // Untuk Anti Jerawat
        {
          'name': 'The Ordinary Niacinamide 10% + Zinc 1%',
          'category': 'untuk_anti_jerawat',
          'description': 'Serum dengan niacinamide dan zinc untuk mengurangi sebum berlebih dan meredakan peradangan jerawat',
          'ingredients': 'Niacinamide 10%, Zinc PCA 1%, Glycerin',
          'price': 'Rp150.000 - Rp200.000',
          'texture': 'Cair/ringan (watery)',
          'skin_type': 'Berminyak, Berjerawat',
          'image_url': 'ordinary_niacinamide.jpg',
          'rating': 4.7
        },
        {
          'name': 'Paula\'s Choice 2% BHA Liquid Exfoliant',
          'category': 'untuk_anti_jerawat',
          'description': 'Exfoliant berbahan dasar salicylic acid yang membersihkan pori dan mencegah jerawat',
          'ingredients': 'Salicylic Acid 2%, Green Tea Extract',
          'price': 'Rp250.000 - Rp500.000',
          'texture': 'Cair/ringan (watery)',
          'skin_type': 'Berminyak, Kombinasi',
          'image_url': 'paulas_bha.jpg',
          'rating': 4.8
        },
        
        // Untuk Kulit Kering
        {
          'name': 'Laneige Water Bank Blue Hyaluronic Serum',
          'category': 'untuk_kulit_kering',
          'description': 'Memberikan hidrasi intensif dengan teknologi Blue Hyaluronic Acid',
          'ingredients': 'Blue Hyaluronic Acid, Green Tea, Probiotics',
          'price': 'Rp500.000 - Rp1.000.000',
          'texture': 'Gel ringan',
          'skin_type': 'Kering, Normal',
          'image_url': 'laneige_waterbank.jpg',
          'rating': 4.6
        },
        {
          'name': 'The Inkey List Hyaluronic Acid Serum',
          'category': 'untuk_kulit_kering',
          'description': 'Serum hidrasi dengan 2% hyaluronic acid kompleks untuk semua jenis kulit',
          'ingredients': 'Hyaluronic Acid 2%, Matrixyl 3000, Glycerin',
          'price': 'Rp100.000 - Rp250.000',
          'texture': 'Gel ringan',
          'skin_type': 'Kering, Dehidrasi',
          'image_url': 'inkey_hyaluronic.jpg',
          'rating': 4.5
        },
        
        // Untuk Kulit Sensitif
        {
          'name': 'Avène Tolérance Extrême Emulsion',
          'category': 'untuk_kulit_sensitif',
          'description': 'Formula minimal dengan hanya 7 bahan untuk kulit yang sangat sensitif',
          'ingredients': 'Avène Thermal Spring Water, Squalane, Glycerin',
          'price': 'Rp250.000 - Rp500.000',
          'texture': 'Gel ringan',
          'skin_type': 'Sensitif',
          'image_url': 'avene_tolerance.jpg',
          'rating': 4.6
        },
        {
          'name': 'Klairs Midnight Blue Calming Serum',
          'category': 'untuk_kulit_sensitif',
          'description': 'Serum menenangkan dengan guaiazulene dan peptida untuk kulit iritasi',
          'ingredients': 'Guaiazulene, Centella Asiatica Extract, Peptides',
          'price': 'Rp250.000 - Rp500.000',
          'texture': 'Gel kental',
          'skin_type': 'Sensitif, Iritasi',
          'image_url': 'klairs_midnight.jpg',
          'rating': 4.7
        },
        
        // Untuk Anti Aging
        {
          'name': 'Estée Lauder Advanced Night Repair Serum',
          'category': 'untuk_anti_aging',
          'description': 'Serum multi-fungsi untuk mengurangi tanda penuaan dan meningkatkan perbaikan kulit di malam hari',
          'ingredients': 'Hyaluronic Acid, Chronolux Power Signal Technology, Antioxidants',
          'price': '> Rp1.000.000',
          'texture': 'Gel ringan',
          'skin_type': 'Semua jenis kulit, Aging',
          'image_url': 'estee_anr.jpg',
          'rating': 4.9
        },
        {
          'name': 'The Ordinary Retinol 0.5% in Squalane',
          'category': 'untuk_anti_aging',
          'description': 'Serum retinol menengah untuk memperbaiki tekstur kulit dan tanda penuaan',
          'ingredients': 'Retinol 0.5%, Squalane',
          'price': 'Rp100.000 - Rp250.000',
          'texture': 'Serba oil',
          'skin_type': 'Normal, Kering, Aging',
          'image_url': 'ordinary_retinol.jpg',
          'rating': 4.5
        },
        
        // Untuk Pencerah
        {
          'name': 'Skinceuticals C E Ferulic',
          'category': 'untuk_pencerah',
          'description': 'Serum antioksidan dengan Vitamin C untuk mencerahkan dan melindungi kulit',
          'ingredients': 'L-Ascorbic Acid 15%, Vitamin E, Ferulic Acid',
          'price': '> Rp1.000.000',
          'texture': 'Cair/ringan (watery)',
          'skin_type': 'Normal, Kering, Kombinasi',
          'image_url': 'skinceuticals_ce.jpg',
          'rating': 4.8
        },
        {
          'name': 'Cosrx Triple C Lightning Liquid',
          'category': 'untuk_pencerah',
          'description': 'Serum Vitamin C 20.5% yang mencerahkan kulit dan memudarkan hiperpigmentasi',
          'ingredients': 'Ascorbic Acid 20.5%, Black Chokeberry, Licorice Root Extract',
          'price': 'Rp250.000 - Rp500.000',
          'texture': 'Cair/ringan (watery)',
          'skin_type': 'Normal, Kombinasi',
          'image_url': 'cosrx_triple.jpg',
          'rating': 4.6
        },
        
        // Untuk Hidrasi
        {
          'name': 'Vichy Minéral 89 Hyaluronic Acid Serum',
          'category': 'untuk_hidrasi',
          'description': 'Serum dengan 89% Vichy Volcanic Water dan hyaluronic acid untuk hidrasi intensif',
          'ingredients': 'Vichy Volcanic Water, Hyaluronic Acid, Glycerin',
          'price': 'Rp250.000 - Rp500.000',
          'texture': 'Gel ringan',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'vichy_mineral.jpg',
          'rating': 4.7
        },
        {
          'name': 'Hada Labo Gokujyun Premium Lotion',
          'category': 'untuk_hidrasi',
          'description': 'Essence/serum dengan 5 jenis hyaluronic acid untuk hidrasi mendalam',
          'ingredients': '5 types of Hyaluronic Acid, Glycerin',
          'price': 'Rp100.000 - Rp250.000',
          'texture': 'Cair/ringan (watery)',
          'skin_type': 'Semua jenis kulit, Dehidrasi',
          'image_url': 'hadalabo_premium.jpg',
          'rating': 4.8
        },
        
        // Untuk Cerahkan Kulit
        {
          'name': 'Dear, Klairs Freshly Juiced Vitamin Drop',
          'category': 'untuk_cerahkan_kulit',
          'description': 'Serum vitamin C 5% yang lembut untuk pemula, mencerahkan dan meratakan warna kulit',
          'ingredients': 'Ascorbic Acid 5%, Centella Asiatica Extract, Yuja Extract',
          'price': 'Rp250.000 - Rp500.000',
          'texture': 'Cair/ringan (watery)',
          'skin_type': 'Sensitif, Normal',
          'image_url': 'klairs_vitamin.jpg',
          'rating': 4.5
        },
        {
          'name': 'Some By Mi Galactomyces Pure Vitamin C Glow Serum',
          'category': 'untuk_cerahkan_kulit',
          'description': 'Serum pencerah dengan galactomyces dan vitamin C untuk kulit kusam',
          'ingredients': 'Galactomyces Ferment Filtrate, Ascorbic Acid, Niacinamide',
          'price': 'Rp100.000 - Rp250.000',
          'texture': 'Gel ringan',
          'skin_type': 'Normal, Kombinasi, Kusam',
          'image_url': 'somebymi_galactomyces.jpg',
          'rating': 4.4
        },
        
        // Untuk Menenangkan
        {
          'name': 'Dr. Jart+ Cicapair Serum',
          'category': 'untuk_menenangkan',
          'description': 'Serum menenangkan dengan kompleks Centella Asiatica untuk kulit iritasi dan kemerahan',
          'ingredients': 'Centella Asiatica Complex, Madecassoside, Tiger Grass',
          'price': 'Rp500.000 - Rp1.000.000',
          'texture': 'Gel ringan',
          'skin_type': 'Sensitif, Iritasi, Kemerahan',
          'image_url': 'drjart_cicapair.jpg',
          'rating': 4.6
        },
        {
          'name': 'Purito Centella Unscented Serum',
          'category': 'untuk_menenangkan',
          'description': 'Serum tanpa parfum dengan Centella Asiatica yang menenangkan kulit sensitif',
          'ingredients': 'Centella Asiatica Extract, Madecassic Acid, Asiaticoside',
          'price': 'Rp100.000 - Rp250.000',
          'texture': 'Gel ringan',
          'skin_type': 'Sensitif, Berjerawat',
          'image_url': 'purito_centella.jpg',
          'rating': 4.7
        },
        
        // Untuk Antioksidan
        {
          'name': 'Paula\'s Choice Resist Super Antioxidant Serum',
          'category': 'untuk_anti_oksidan',
          'description': 'Serum kaya antioksidan untuk melindungi kulit dari kerusakan lingkungan',
          'ingredients': 'Vitamin C, Vitamin E, Coenzyme Q10, Peptides',
          'price': 'Rp500.000 - Rp1.000.000',
          'texture': 'Gel kental',
          'skin_type': 'Semua jenis kulit, Aging',
          'image_url': 'paulas_antioxidant.jpg',
          'rating': 4.6
        },
        {
          'name': 'Timeless 20% Vitamin C + E Ferulic Acid Serum',
          'category': 'untuk_anti_oksidan',
          'description': 'Serum antioksidan dengan formula mirip Skinceuticals C E Ferulic namun lebih terjangkau',
          'ingredients': 'Vitamin C 20%, Vitamin E, Ferulic Acid',
          'price': 'Rp250.000 - Rp500.000',
          'texture': 'Cair/ringan (watery)',
          'skin_type': 'Normal, Kombinasi',
          'image_url': 'timeless_vitamin.jpg',
          'rating': 4.5
        },
      ];
      
      // Gunakan batch untuk performa lebih baik
      final Batch batch = db.batch();
      for (var product in products) {
        batch.insert('serum_products', product);
      }
      
      await batch.commit(noResult: true);
      debugPrint('Sample products added successfully');
      return true;
    } catch (e) {
      debugPrint('Error adding sample products: $e');
      return false;
    }
  }

  Future<Database> get database async {
    if (_database?.isOpen ?? false) return _database!;
    _database = await _initDB('serum_app.db');
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
    // Tabel untuk menyimpan data produk serum
    await db.execute('''
    CREATE TABLE serum_products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      description TEXT,
      ingredients TEXT,
      price TEXT,
      texture TEXT,
      skin_type TEXT,
      image_url TEXT,
      rating REAL
    )
    ''');

    // Tabel untuk menyimpan jawaban user untuk sesi rekomendasi
    await db.execute('''
    CREATE TABLE user_answers_serum (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      jenis_kulit TEXT,
      usia TEXT,
      masalah_utama TEXT,
      jerawat TEXT,
      bekas_jerawat TEXT,
      tekstur_kulit TEXT,
      sensitivitas TEXT,
      kulit_kusam TEXT,
      paparan_sinar TEXT,
      keriput TEXT,
      hidrasi TEXT,
      elastisitas TEXT,
      penggunaan_retinol TEXT,
      budget TEXT,
      preferensi_tekstur TEXT,
      bahan_alami TEXT,
      rutinitas TEXT,
      created_at TEXT
    )
    ''');
    
    // Tabel untuk menyimpan hasil rekomendasi
    await db.execute('''
    CREATE TABLE recommendation_results_serum (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_answer_id INTEGER,
      product_type TEXT NOT NULL,
      top_category TEXT NOT NULL,
      match_percentage REAL,
      budget_range TEXT,
      created_at TEXT,
      FOREIGN KEY (user_answer_id) REFERENCES user_answers_serum (id)
    )
    ''');
  }

  // Fungsi untuk menyimpan jawaban user
  Future<int> saveUserAnswers(Map<String, dynamic> answers) async {
    final db = await database;
    
    try {
      // Normalisasi jawaban
      final Map<String, dynamic> normalizedAnswers = {...answers};
      
      // Tambahkan timestamp
      normalizedAnswers['created_at'] = DateTime.now().toIso8601String();
      
      // Gunakan transaksi untuk operasi atomik
      int insertId = 0;
      await db.transaction((txn) async {
        // Hapus jawaban sebelumnya (opsional, tergantung kebutuhan aplikasi)
        await txn.delete('user_answers_serum');
        
        // Simpan jawaban baru
        insertId = await txn.insert('user_answers_serum', normalizedAnswers);
      });
      
      debugPrint('Jawaban user berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan jawaban user: $e');
      rethrow;
    }
  }

  // Fungsi untuk menyimpan hasil rekomendasi
  Future<int> saveRecommendationResult(int userAnswerId, Map<String, dynamic> result) async {
    final db = await database;
    
    try {
      final Map<String, dynamic> resultData = {
        'user_answer_id': userAnswerId,
        'product_type': result['productType'],
        'top_category': result['topCategory'],
        'match_percentage': result['matchPercentage'],
        'budget_range': result['budgetRange'],
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final int insertId = await db.insert('recommendation_results_serum', resultData);
      debugPrint('Hasil rekomendasi berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan hasil rekomendasi: $e');
      rethrow;
    }
  }

  // Fungsi untuk mendapatkan produk berdasarkan kategori dan filter budget
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category, String budgetRange) async {
    final db = await database;
    
    try {
      // Pastikan tabel produk tidak kosong
      await addSampleProducts();
      
      List<Map<String, dynamic>> results;
      
      if (budgetRange == 'Semua harga' || budgetRange.isEmpty) {
        // Jika tidak ada filter budget, ambil semua produk dalam kategori
        results = await db.query(
          'serum_products',
          where: 'category = ?',
          whereArgs: [category],
          orderBy: 'rating DESC'
        );
      } else {
        // Filter produk berdasarkan kategori dan budget
        results = await db.query(
          'serum_products',
          where: 'category = ? AND price LIKE ?',
          whereArgs: [category, '%$budgetRange%'],
          orderBy: 'rating DESC'
        );
        
        // Jika tidak ada produk yang cocok dengan filter budget, tampilkan semua produk kategori
        if (results.isEmpty) {
          results = await db.query(
            'serum_products',
            where: 'category = ?',
            whereArgs: [category],
            orderBy: 'rating DESC'
          );
        }
      }
      
      return results;
    } catch (e) {
      debugPrint('Error getting products: $e');
      return [];
    }
  }

  // Fungsi untuk mendapatkan hasil rekomendasi terbaru
  Future<Map<String, dynamic>?> getLatestRecommendation() async {
    final db = await database;
    
    try {
      // Ambil hasil rekomendasi terbaru
      final List<Map<String, dynamic>> recommendationResults = await db.query(
        'recommendation_results_serum',
        orderBy: 'created_at DESC',
        limit: 1
      );
      
      if (recommendationResults.isEmpty) {
        return null;
      }
      
      final recommendation = recommendationResults.first;
      final String topCategory = recommendation['top_category'];
      final String budgetRange = recommendation['budget_range'];
      
      // Ambil produk sesuai rekomendasi
      final List<Map<String, dynamic>> products = await getProductsByCategory(topCategory, budgetRange);
      
      return {
        'recommendation': recommendation,
        'products': products,
      };
    } catch (e) {
      debugPrint('Error getting latest recommendation: $e');
      return null;
    }
  }

  // Fungsi untuk mendapatkan semua hasil rekomendasi dengan data lengkap
  Future<List<Map<String, dynamic>>> getAllRecommendations() async {
    final db = await database;
    
    try {
      // Ambil semua hasil rekomendasi
      final List<Map<String, dynamic>> recommendationResults = await db.query(
        'recommendation_results_serum',
        orderBy: 'created_at DESC'
      );
      
      final List<Map<String, dynamic>> fullResults = [];
      
      for (var recommendation in recommendationResults) {
        final String topCategory = recommendation['top_category'];
        final String budgetRange = recommendation['budget_range'];
        final int userAnswerId = recommendation['user_answer_id'];
        
        // Ambil jawaban user
        final List<Map<String, dynamic>> userAnswers = await db.query(
          'user_answers_serum',
          where: 'id = ?',
          whereArgs: [userAnswerId]
        );
        
        // Ambil produk sesuai rekomendasi
        final List<Map<String, dynamic>> products = await getProductsByCategory(
          topCategory, 
          budgetRange
        );
        
        fullResults.add({
          'recommendation': recommendation,
          'user_answers': userAnswers.isNotEmpty ? userAnswers.first : null,
          'products': products,
          'timestamp': recommendation['created_at'],
        });
      }
      
      return fullResults;
    } catch (e) {
      debugPrint('Error getting all recommendations: $e');
      return [];
    }
  }

  // Fungsi untuk mencari produk berdasarkan nama
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final db = await database;
    
    try {
      // Pastikan tabel produk tidak kosong
      await addSampleProducts();
      
      // Cari produk berdasarkan nama atau deskripsi
      return await db.query(
        'serum_products',
        where: 'name LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'rating DESC'
      );
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  // Fungsi untuk hapus history rekomendasi
  Future<int> deleteRecommendationHistory() async {
    final db = await database;
    
    try {
      // Gunakan transaksi untuk konsistensi data
      int result = 0;
      await db.transaction((txn) async {
        // Hapus semua hasil rekomendasi
        result = await txn.delete('recommendation_results_serum');
        
        // Hapus semua jawaban user
        await txn.delete('user_answers_serum');
      });
      
      debugPrint('History rekomendasi berhasil dihapus: $result item');
      return result;
    } catch (e) {
      debugPrint('Error deleting recommendation history: $e');
      return -1;
    }
  }

  // Fungsi untuk mendapatkan rekomendasi berdasarkan ID
  Future<Map<String, dynamic>?> getRecommendationById(int id) async {
    final db = await database;
    
    try {
      // Ambil rekomendasi berdasarkan ID
      final List<Map<String, dynamic>> recommendationResults = await db.query(
        'recommendation_results_serum',
        where: 'id = ?',
        whereArgs: [id]
      );
      
      if (recommendationResults.isEmpty) {
        return null;
      }
      
      final recommendation = recommendationResults.first;
      final String topCategory = recommendation['top_category'];
      final String budgetRange = recommendation['budget_range'];
      final int userAnswerId = recommendation['user_answer_id'];
      
      // Ambil jawaban user
      final List<Map<String, dynamic>> userAnswers = await db.query(
        'user_answers_serum',
        where: 'id = ?',
        whereArgs: [userAnswerId]
      );
      
      // Ambil produk sesuai rekomendasi
      final List<Map<String, dynamic>> products = await getProductsByCategory(topCategory, budgetRange);
      
      return {
        'recommendation': recommendation,
        'user_answers': userAnswers.isNotEmpty ? userAnswers.first : null,
        'products': products,
      };
    } catch (e) {
      debugPrint('Error getting recommendation by ID: $e');
      return null;
    }
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}