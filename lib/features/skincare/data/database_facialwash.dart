import 'package:primafit/core/database/local_db.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperFacial {
  static final DatabaseHelperFacial instance = DatabaseHelperFacial._init();
  static Database? _database;

  DatabaseHelperFacial._init();

  // Fungsi untuk menambahkan data sampel produk ke database
  Future<bool> addSampleProducts() async {
    try {
      final db = await database;
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM facial_products'));
      if (count != null && count > 0) {
        debugPrint('Data produk sudah ada, tidak perlu menambahkan sampel');
        return true;
      }
      
      // Contoh produk facial wash untuk berbagai kategori
      final List<Map<String, dynamic>> products = [
        // Untuk Kulit Berminyak
        {
          'name': 'CeraVe Foaming Facial Cleanser',
          'category': 'untuk_kulit_berminyak',
          'description': 'Membersihkan dan mengendalikan minyak berlebih tanpa mengeringkan kulit',
          'ingredients': 'Ceramides, Niacinamide, Hyaluronic Acid',
          'price': 'Rp150.000 - Rp200.000',
          'texture': 'Foam',
          'skin_type': 'Berminyak, Kombinasi',
          'image_url': 'cerave_foaming.jpg',
          'rating': 4.7
        },
        {
          'name': 'Cosrx Low pH Good Morning Gel Cleanser',
          'category': 'untuk_kulit_berminyak',
          'description': 'Pembersih dengan pH rendah untuk menyeimbangkan kulit berminyak',
          'ingredients': 'Tea Tree Oil, BHA, Betaine Salicylate',
          'price': 'Rp100.000 - Rp150.000',
          'texture': 'Gel',
          'skin_type': 'Berminyak, Kombinasi',
          'image_url': 'cosrx_low_ph.jpg',
          'rating': 4.5
        },
        
        // Untuk Kulit Kering
        {
          'name': 'La Roche-Posay Toleriane Hydrating Gentle Cleanser',
          'category': 'untuk_kulit_kering',
          'description': 'Facial wash lembut dengan formula pelembab untuk kulit kering',
          'ingredients': 'Ceramide, Niacinamide, Glycerin',
          'price': 'Rp200.000 - Rp300.000',
          'texture': 'Cream',
          'skin_type': 'Kering, Normal',
          'image_url': 'laroche_toleriane.jpg',
          'rating': 4.6
        },
        {
          'name': 'Cetaphil Gentle Skin Cleanser',
          'category': 'untuk_kulit_kering',
          'description': 'Pembersih wajah tanpa sabun yang lembut untuk kulit kering dan sensitif',
          'ingredients': 'Glycerin, Propylene Glycol, Cetyl Alcohol',
          'price': 'Rp100.000 - Rp150.000',
          'texture': 'Lotion',
          'skin_type': 'Kering, Sensitif',
          'image_url': 'cetaphil_gentle.jpg',
          'rating': 4.4
        },
        
        // Untuk Kulit Sensitif
        {
          'name': 'Avene Extremely Gentle Cleanser Lotion',
          'category': 'untuk_kulit_sensitif',
          'description': 'Sangat lembut untuk kulit sensitif, bahkan untuk kondisi rosacea',
          'ingredients': 'Avene Thermal Spring Water, Glycerin, Plant-derived cleansing base',
          'price': 'Rp200.000 - Rp300.000',
          'texture': 'Lotion',
          'skin_type': 'Sensitif',
          'image_url': 'avene_extremely.jpg',
          'rating': 4.8
        },
        {
          'name': 'Simple Kind To Skin Refreshing Facial Wash',
          'category': 'untuk_kulit_sensitif',
          'description': 'Formula bebas pewangi dan bahan iritan untuk kulit sensitif',
          'ingredients': 'Pro-Vitamin B5, Vitamin E, Bisabolol',
          'price': 'Rp50.000 - Rp100.000',
          'texture': 'Gel',
          'skin_type': 'Sensitif, Normal',
          'image_url': 'simple_refreshing.jpg',
          'rating': 4.3
        },
        
        // Untuk Anti Jerawat
        {
          'name': 'Salicylic Acid Daily Gentle Cleanser',
          'category': 'untuk_anti_jerawat',
          'description': 'Membersihkan pori dan mencegah jerawat dengan salicylic acid',
          'ingredients': 'Salicylic Acid 2%, Allantoin, Green Tea Extract',
          'price': 'Rp150.000 - Rp200.000',
          'texture': 'Gel',
          'skin_type': 'Berminyak, Berjerawat',
          'image_url': 'paula_salicylic.jpg',
          'rating': 4.6
        },
        {
          'name': 'Neutrogena Oil-Free Acne Wash',
          'category': 'untuk_anti_jerawat',
          'description': 'Menghilangkan jerawat dan mencegah jerawat baru muncul',
          'ingredients': 'Salicylic Acid 2%, Glycerin',
          'price': 'Rp100.000 - Rp150.000',
          'texture': 'Gel',
          'skin_type': 'Berminyak, Berjerawat',
          'image_url': 'neutrogena_acne.jpg',
          'rating': 4.4
        },
        
        // Untuk Pencerah
        {
          'name': 'Hada Labo Shirojyun Premium Whitening Facial Wash',
          'category': 'untuk_pencerah',
          'description': 'Membersihkan dan mencerahkan dengan Vitamin C dan ekstrak buah',
          'ingredients': 'Tranexamic Acid, Vitamin C, Arbutin',
          'price': 'Rp50.000 - Rp100.000',
          'texture': 'Foam',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'hadalabo_shirojyun.jpg',
          'rating': 4.5
        },
        {
          'name': 'Some By Mi AHA-BHA-PHA 30 Days Miracle Cleanser',
          'category': 'untuk_pencerah',
          'description': 'Mengeksfoliasi dan mencerahkan dengan 3 jenis asam',
          'ingredients': 'Tea Tree, AHA, BHA, PHA',
          'price': 'Rp100.000 - Rp150.000',
          'texture': 'Gel',
          'skin_type': 'Kusam, Berjerawat',
          'image_url': 'somebymi_30days.jpg',
          'rating': 4.6
        },
        
        // Untuk Anti Aging
        {
          'name': 'Neutrogena Hydro Boost Hydrating Cleansing Gel',
          'category': 'untuk_anti_aging',
          'description': 'Facial wash dengan hyaluronic acid untuk kulit lebih kenyal dan terlihat muda',
          'ingredients': 'Hyaluronic Acid, Glycerin, Panthenol',
          'price': 'Rp150.000 - Rp200.000',
          'texture': 'Gel',
          'skin_type': 'Normal, Kering',
          'image_url': 'neutrogena_hydroboost.jpg',
          'rating': 4.7
        },
        {
          'name': 'Olay Regenerist Regenerating Cream Cleanser',
          'category': 'untuk_anti_aging',
          'description': 'Membersihkan dan membantu regenerasi sel kulit untuk tampilan lebih muda',
          'ingredients': 'Amino-Peptide Complex, Vitamin E, Glycerin',
          'price': 'Rp150.000 - Rp200.000',
          'texture': 'Cream',
          'skin_type': 'Normal, Kering, Aging',
          'image_url': 'olay_regenerist.jpg',
          'rating': 4.5
        },
        
        // Untuk Pori Besar
        {
          'name': 'Innisfree Volcanic Pore Cleansing Foam',
          'category': 'untuk_pori_besar',
          'description': 'Dengan volcanic cluster untuk mengangkat kotoran dan minyak dalam pori',
          'ingredients': 'Jeju Volcanic Cluster, Salicylic Acid',
          'price': 'Rp100.000 - Rp150.000',
          'texture': 'Foam',
          'skin_type': 'Berminyak, Kombinasi',
          'image_url': 'innisfree_volcanic.jpg',
          'rating': 4.4
        },
        {
          'name': 'The Body Shop Tea Tree Skin Clearing Facial Wash',
          'category': 'untuk_pori_besar',
          'description': 'Tea tree oil untuk membersihkan pori dan mengurangi tampilan pori besar',
          'ingredients': 'Tea Tree Oil, Glycerin, Community Trade Organic Alcohol',
          'price': 'Rp150.000 - Rp200.000',
          'texture': 'Gel',
          'skin_type': 'Berminyak, Kombinasi',
          'image_url': 'bodyshop_teatree.jpg',
          'rating': 4.3
        },
        
        // Untuk Pembersih Mendalam
        {
          'name': 'Garnier Micellar Cleansing Water',
          'category': 'untuk_pembersih_mendalam',
          'description': 'Membersihkan makeup dan kotoran dengan teknologi micellar',
          'ingredients': 'Micellar Technology, Glycerin',
          'price': 'Rp50.000 - Rp100.000',
          'texture': 'Micellar/Water Based',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'garnier_micellar.jpg',
          'rating': 4.6
        },
        {
          'name': 'DHC Deep Cleansing Oil',
          'category': 'untuk_pembersih_mendalam',
          'description': 'Cleansing oil yang membersihkan makeup waterproof dan kotoran',
          'ingredients': 'Olive Oil, Vitamin E, Rosemary Leaf Oil',
          'price': 'Rp200.000 - Rp300.000',
          'texture': 'Oil',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'dhc_cleansing.jpg',
          'rating': 4.8
        },
      ];
      
      // Gunakan batch untuk performa lebih baik
      final Batch batch = db.batch();
      for (var product in products) {
        batch.insert('facial_products', product);
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
    _database = await _initDB('facial_wash_app.db');
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
    // Tabel untuk menyimpan data produk facial wash
    await db.execute('''
    CREATE TABLE facial_products (
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
    CREATE TABLE user_answers_facial (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      jenis_kulit TEXT,
      usia TEXT,
      jerawat TEXT,
      komedo TEXT,
      bekas_jerawat TEXT,
      pori_besar TEXT,
      sensitifitas TEXT,
      kulit_kusam TEXT,
      paparan_sinar TEXT,
      keriput TEXT,
      efek_makeup TEXT,
      cuci_wajah TEXT,
      budget TEXT,
      preferensi_tekstur TEXT,
      bahan_alami TEXT,
      aroma TEXT,
      created_at TEXT
    )
    ''');
    
    // Tabel untuk menyimpan hasil rekomendasi
    await db.execute('''
    CREATE TABLE recommendation_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_answer_id INTEGER,
      product_type TEXT NOT NULL,
      top_category TEXT NOT NULL,
      match_percentage REAL,
      budget_range TEXT,
      created_at TEXT,
      FOREIGN KEY (user_answer_id) REFERENCES user_answers_facial (id)
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
        await txn.delete('user_answers_facial');
        
        // Simpan jawaban baru
        insertId = await txn.insert('user_answers_facial', normalizedAnswers);
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
      
      final int insertId = await db.insert('recommendation_results', resultData);
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
          'facial_products',
          where: 'category = ?',
          whereArgs: [category],
          orderBy: 'rating DESC'
        );
      } else {
        // Filter produk berdasarkan kategori dan budget
        // Catatan: Ini pendekatan sederhana, implementasi sebenarnya mungkin perlu disesuaikan
        // dengan format harga yang disimpan di database
        results = await db.query(
          'facial_products',
          where: 'category = ? AND price LIKE ?',
          whereArgs: [category, '%$budgetRange%'],
          orderBy: 'rating DESC'
        );
        
        // Jika tidak ada produk yang cocok dengan filter budget, tampilkan semua produk kategori
        if (results.isEmpty) {
          results = await db.query(
            'facial_products',
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
        'recommendation_results',
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

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}