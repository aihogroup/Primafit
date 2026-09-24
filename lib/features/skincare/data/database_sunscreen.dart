import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperSunscreen {
  static final DatabaseHelperSunscreen instance = DatabaseHelperSunscreen._init();
  static Database? _database;

  DatabaseHelperSunscreen._init();

  // Fungsi untuk menambahkan data sampel produk ke database
  Future<bool> addSampleProducts() async {
    try {
      final db = await database;
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM sunscreen_products'));
      if (count != null && count > 0) {
        debugPrint('Data produk sudah ada, tidak perlu menambahkan sampel');
        return true;
      }
      
      // Contoh produk sunscreen untuk berbagai kategori
      final List<Map<String, dynamic>> products = [
        // Untuk Kulit Berminyak
        {
          'name': 'Bioré UV Aqua Rich Watery Essence SPF50+ PA++++',
          'category': 'untuk_kulit_berminyak',
          'description': 'Formula ringan berbasis air, cepat menyerap tanpa rasa lengket',
          'ingredients': 'Aqua, Alcohol, Ethylhexyl Methoxycinnamate, Ethylhexyl Triazone, Isopropyl Palmitate',
          'price': 'Rp150.000 - Rp200.000',
          'texture': 'Essence',
          'spf_level': 'SPF 50+ PA++++',
          'skin_type': 'Berminyak, Kombinasi',
          'image_url': 'biore_aqua_rich.jpg',
          'rating': 4.7
        },
        {
          'name': 'Neutrogena Clear Face Break-Out Free Liquid Lotion SPF 50',
          'category': 'untuk_kulit_berminyak',
          'description': 'Dirancang khusus untuk kulit berjerawat, tidak menyumbat pori',
          'ingredients': 'Avobenzone, Homosalate, Octisalate, Octocrylene, Zinc Oxide',
          'price': 'Rp200.000 - Rp250.000',
          'texture': 'Liquid',
          'spf_level': 'SPF 50',
          'skin_type': 'Berminyak, Berjerawat',
          'image_url': 'neutrogena_clear_face.jpg',
          'rating': 4.5
        },
        
        // Untuk Kulit Kering
        {
          'name': 'La Roche-Posay Anthelios Hydrating Cream SPF 50',
          'category': 'untuk_kulit_kering',
          'description': 'Sunscreen pelembab untuk kulit kering dengan formula yang menenangkan',
          'ingredients': 'Avobenzone, Homosalate, Octisalate, Octocrylene, Glycerin, Vitamin E',
          'price': 'Rp300.000 - Rp400.000',
          'texture': 'Cream',
          'spf_level': 'SPF 50',
          'skin_type': 'Kering, Normal',
          'image_url': 'laroche_anthelios.jpg',
          'rating': 4.6
        },
        {
          'name': 'CeraVe Hydrating Mineral Sunscreen SPF 30',
          'category': 'untuk_kulit_kering',
          'description': 'Dengan 3 ceramide esensial dan niacinamide untuk membantu memulihkan skin barrier',
          'ingredients': 'Zinc Oxide, Titanium Dioxide, Ceramides, Niacinamide, Hyaluronic Acid',
          'price': 'Rp250.000 - Rp300.000',
          'texture': 'Lotion',
          'spf_level': 'SPF 30',
          'skin_type': 'Kering, Sensitif',
          'image_url': 'cerave_hydrating.jpg',
          'rating': 4.4
        },
        
        // Untuk Kulit Sensitif
        {
          'name': 'Avène Very High Protection Mineral Cream SPF 50+',
          'category': 'untuk_kulit_sensitif',
          'description': 'Sunscreen mineral untuk kulit sensitif dan reaktif, cocok untuk rosacea',
          'ingredients': 'Titanium Dioxide, Zinc Oxide, Avène Thermal Spring Water, Vitamin E',
          'price': 'Rp350.000 - Rp450.000',
          'texture': 'Cream',
          'spf_level': 'SPF 50+',
          'skin_type': 'Sensitif',
          'image_url': 'avene_mineral.jpg',
          'rating': 4.8
        },
        {
          'name': 'EltaMD UV Clear Broad-Spectrum SPF 46',
          'category': 'untuk_kulit_sensitif',
          'description': 'Bebas pewangi, tidak memicu jerawat, ideal untuk kulit sensitif',
          'ingredients': 'Zinc Oxide, Octinoxate, Niacinamide, Hyaluronic Acid, Lactic Acid',
          'price': 'Rp450.000 - Rp550.000',
          'texture': 'Lotion',
          'spf_level': 'SPF 46',
          'skin_type': 'Sensitif, Berjerawat',
          'image_url': 'eltamd_uv_clear.jpg',
          'rating': 4.9
        },
        
        // Untuk Anti Jerawat
        {
          'name': 'Paula\'s Choice Clear Oil-Free SPF 30',
          'category': 'untuk_anti_jerawat',
          'description': 'Formula ringan yang tidak membuat kulit berminyak atau memicu jerawat',
          'ingredients': 'Avobenzone, Octinoxate, Octisalate, Salicylic Acid',
          'price': 'Rp300.000 - Rp400.000',
          'texture': 'Gel',
          'spf_level': 'SPF 30',
          'skin_type': 'Berminyak, Berjerawat',
          'image_url': 'paulaschoice_clear.jpg',
          'rating': 4.6
        },
        {
          'name': 'Clinique Acne Solutions Oil-Free Face Sunscreen SPF 40',
          'category': 'untuk_anti_jerawat',
          'description': 'Tabir surya bebas minyak yang membantu mencegah jerawat baru',
          'ingredients': 'Ethylhexyl Methoxycinnamate, Zinc Oxide, Silica',
          'price': 'Rp350.000 - Rp450.000',
          'texture': 'Liquid',
          'spf_level': 'SPF 40',
          'skin_type': 'Berminyak, Berjerawat',
          'image_url': 'clinique_acne.jpg',
          'rating': 4.5
        },
        
        // Untuk Anti Aging
        {
          'name': 'Lancôme UV Expert Aqua Gel SPF 50 PA++++',
          'category': 'untuk_anti_aging',
          'description': 'Perlindungan terhadap UVA/UVB dan polusi, plus antioksidan untuk anti-aging',
          'ingredients': 'Mexoryl SX, Mexoryl XL, Vitamin E, Vitamin CG, Moringa Extract',
          'price': 'Rp600.000 - Rp800.000',
          'texture': 'Gel',
          'spf_level': 'SPF 50+ PA++++',
          'skin_type': 'Normal, Kombinasi',
          'image_url': 'lancome_uv_expert.jpg',
          'rating': 4.7
        },
        {
          'name': 'SkinCeuticals Physical Fusion UV Defense SPF 50',
          'category': 'untuk_anti_aging',
          'description': 'Perlindungan broad spectrum dengan teknologi color-infused untuk kulit cerah merata',
          'ingredients': 'Zinc Oxide, Titanium Dioxide, Artemia Salina, Translucent Color Spheres',
          'price': 'Rp700.000 - Rp900.000',
          'texture': 'Fluid',
          'spf_level': 'SPF 50',
          'skin_type': 'Normal, Aging, Semua jenis kulit',
          'image_url': 'skinceuticals_physical.jpg',
          'rating': 4.8
        },
        
        // Untuk White Cast / No White Cast
        {
          'name': 'Supergoop! Unseen Sunscreen SPF 40',
          'category': 'untuk_no_white_cast',
          'description': 'Sunscreen transparan, tidak meninggalkan white cast, cocok untuk semua skin tone',
          'ingredients': 'Avobenzone, Homosalate, Octisalate, Octocrylene, Red Algae',
          'price': 'Rp450.000 - Rp550.000',
          'texture': 'Gel',
          'spf_level': 'SPF 40',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'supergoop_unseen.jpg',
          'rating': 4.9
        },
        {
          'name': 'Shiseido Clear Sunscreen Stick SPF 50+',
          'category': 'untuk_no_white_cast',
          'description': 'Bentuk stick yang praktis, formula transparan tanpa white cast',
          'ingredients': 'Zinc Oxide, Octinoxate, WetForce Technology, SuperVeil-UV 360 Technology',
          'price': 'Rp350.000 - Rp450.000',
          'texture': 'Stick',
          'spf_level': 'SPF 50+',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'shiseido_clear_stick.jpg',
          'rating': 4.6
        },
        
        // Untuk Waterproof
        {
          'name': 'Anessa Perfect UV Sunscreen Skincare Milk SPF 50+ PA++++',
          'category': 'untuk_waterproof',
          'description': 'Sunscreen tahan air dan keringat dengan teknologi Aqua Booster',
          'ingredients': 'Zinc Oxide, Titanium Dioxide, Aqua Booster Technology, Hyaluronic Acid',
          'price': 'Rp400.000 - Rp500.000',
          'texture': 'Milk',
          'spf_level': 'SPF 50+ PA++++',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'anessa_perfect.jpg',
          'rating': 4.8
        },
        {
          'name': 'La Roche-Posay Anthelios Sport SPF 60',
          'category': 'untuk_waterproof',
          'description': 'Tahan air hingga 80 menit, ideal untuk beraktivitas outdoor atau berenang',
          'ingredients': 'Avobenzone, Homosalate, Octisalate, Cell-Ox Shield Technology',
          'price': 'Rp350.000 - Rp450.000',
          'texture': 'Cream',
          'spf_level': 'SPF 60',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'laroche_sport.jpg',
          'rating': 4.7
        },
        
        // Untuk Makeup Base
        {
          'name': 'Innisfree Tone Up No Sebum Sunscreen SPF 35 PA+++',
          'category': 'untuk_makeup_base',
          'description': 'Berfungsi sebagai primer makeup dan mengontrol minyak sekaligus',
          'ingredients': 'Ethylhexyl Methoxycinnamate, Jeju Green Tea Extract, Natural Minerals',
          'price': 'Rp200.000 - Rp250.000',
          'texture': 'Cream',
          'spf_level': 'SPF 35 PA+++',
          'skin_type': 'Berminyak, Kombinasi',
          'image_url': 'innisfree_tone_up.jpg',
          'rating': 4.5
        },
        {
          'name': 'Missha All Around Safe Block Soft Finish Sun Milk SPF 50+ PA+++',
          'category': 'untuk_makeup_base',
          'description': 'Sunscreen dengan finish matte, sempurna sebagai base makeup',
          'ingredients': 'Ethylhexyl Methoxycinnamate, Homosalate, Plant Extracts, Vitamin E',
          'price': 'Rp200.000 - Rp250.000',
          'texture': 'Milk',
          'spf_level': 'SPF 50+ PA+++',
          'skin_type': 'Berminyak, Normal',
          'image_url': 'missha_soft_finish.jpg',
          'rating': 4.6
        },
        
        // Untuk Wajah dan Tubuh
        {
          'name': 'Neutrogena Ultra Sheer Dry-Touch Sunscreen SPF 55',
          'category': 'untuk_wajah_dan_tubuh',
          'description': 'Nyaman digunakan untuk wajah dan tubuh, formula ringan dengan teknologi Dry-Touch',
          'ingredients': 'Avobenzone, Homosalate, Octisalate, Octocrylene, Oxybenzone',
          'price': 'Rp150.000 - Rp200.000',
          'texture': 'Lotion',
          'spf_level': 'SPF 55',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'neutrogena_ultra_sheer.jpg',
          'rating': 4.6
        },
        {
          'name': 'Banana Boat Light As Air SPF 50+ Faces',
          'category': 'untuk_wajah_dan_tubuh',
          'description': 'Ringan seperti udara, dapat digunakan untuk wajah dan tubuh',
          'ingredients': 'Homosalate, Octocrylene, Octisalate, Ensulizole, Avobenzone',
          'price': 'Rp100.000 - Rp150.000',
          'texture': 'Lotion',
          'spf_level': 'SPF 50+',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'banana_boat.jpg',
          'rating': 4.3
        },
      ];
      
      // Gunakan batch untuk performa lebih baik
      final Batch batch = db.batch();
      for (var product in products) {
        batch.insert('sunscreen_products', product);
      }
      
      await batch.commit(noResult: true);
      debugPrint('Sample sunscreen products added successfully');
      return true;
    } catch (e) {
      debugPrint('Error adding sample sunscreen products: $e');
      return false;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sunscreen_app.db');
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
    // Tabel untuk menyimpan data produk sunscreen
    await db.execute('''
    CREATE TABLE sunscreen_products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      description TEXT,
      ingredients TEXT,
      price TEXT,
      texture TEXT,
      spf_level TEXT,
      skin_type TEXT,
      image_url TEXT,
      rating REAL
    )
    ''');

    // Tabel untuk menyimpan jawaban user untuk sesi rekomendasi
    await db.execute('''
    CREATE TABLE user_answers_sunscreen (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      jenis_kulit TEXT,
      usia TEXT,
      jerawat TEXT,
      sensitifitas TEXT,
      kulit_kusam TEXT,
      paparan_sinar TEXT,
      aktivitas_outdoor TEXT,
      berenang TEXT,
      penggunaan_makeup TEXT,
      white_cast TEXT,
      budget TEXT,
      preferensi_tekstur TEXT,
      spf_preference TEXT,
      reapply TEXT,
      created_at TEXT
    )
    ''');
    
    // Tabel untuk menyimpan hasil rekomendasi
    await db.execute('''
    CREATE TABLE sunscreen_recommendation_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_answer_id INTEGER,
      product_type TEXT NOT NULL,
      top_category TEXT NOT NULL,
      match_percentage REAL,
      budget_range TEXT,
      created_at TEXT,
      FOREIGN KEY (user_answer_id) REFERENCES user_answers_sunscreen (id)
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
        await txn.delete('user_answers_sunscreen');
        
        // Simpan jawaban baru
        insertId = await txn.insert('user_answers_sunscreen', normalizedAnswers);
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
      
      final int insertId = await db.insert('sunscreen_recommendation_results', resultData);
      debugPrint('Hasil rekomendasi sunscreen berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan hasil rekomendasi sunscreen: $e');
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
          'sunscreen_products',
          where: 'category = ?',
          whereArgs: [category],
          orderBy: 'rating DESC'
        );
      } else {
        // Filter produk berdasarkan kategori dan budget
        results = await db.query(
          'sunscreen_products',
          where: 'category = ? AND price LIKE ?',
          whereArgs: [category, '%$budgetRange%'],
          orderBy: 'rating DESC'
        );
        
        // Jika tidak ada produk yang cocok dengan filter budget, tampilkan semua produk kategori
        if (results.isEmpty) {
          results = await db.query(
            'sunscreen_products',
            where: 'category = ?',
            whereArgs: [category],
            orderBy: 'rating DESC'
          );
        }
      }
      
      return results;
    } catch (e) {
      debugPrint('Error getting sunscreen products: $e');
      return [];
    }
  }

  // Fungsi untuk mendapatkan hasil rekomendasi terbaru
  Future<Map<String, dynamic>?> getLatestRecommendation() async {
    final db = await database;
    
    try {
      // Ambil hasil rekomendasi terbaru
      final List<Map<String, dynamic>> recommendationResults = await db.query(
        'sunscreen_recommendation_results',
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
      debugPrint('Error getting latest sunscreen recommendation: $e');
      return null;
    }
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}