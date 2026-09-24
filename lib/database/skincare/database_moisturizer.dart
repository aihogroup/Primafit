import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperMoisturizer {
  static final DatabaseHelperMoisturizer instance = DatabaseHelperMoisturizer._init();
  static Database? _database;

  DatabaseHelperMoisturizer._init();

  // Fungsi untuk menambahkan data sampel produk ke database
  Future<bool> addSampleProducts() async {
    try {
      final db = await database;
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM moisturizer_products'));
      if (count != null && count > 0) {
        debugPrint('Data produk moisturizer sudah ada, tidak perlu menambahkan sampel');
        return true;
      }
      
      // Contoh produk moisturizer untuk berbagai kategori
      List<Map<String, dynamic>> products = [
        // Untuk Kulit Berminyak
        {
          'name': 'Neutrogena Hydro Boost Water Gel',
          'category': 'untuk_kulit_berminyak',
          'description': 'Gel ringan berbahan dasar air yang memberikan hidrasi tanpa rasa lengket, cocok untuk kulit berminyak',
          'ingredients': 'Hyaluronic Acid, Glycerin, Dimethicone, Olive Extract',
          'price': 'Rp150.000 - Rp200.000',
          'texture': 'Gel',
          'with_spf': 'Tidak',
          'skin_type': 'Berminyak, Kombinasi',
          'image_url': 'neutrogena_hydroboost.jpg',
          'rating': 4.7
        },
        {
          'name': 'The Ordinary Natural Moisturizing Factors + HA',
          'category': 'untuk_kulit_berminyak',
          'description': 'Formula ringan tanpa minyak dengan asam amino, ceramide, dan hyaluronic acid untuk hidrasi tanpa menyumbat pori',
          'ingredients': 'Hyaluronic Acid, Amino Acids, Ceramides, Glycerin',
          'price': 'Rp120.000 - Rp150.000',
          'texture': 'Cream',
          'with_spf': 'Tidak',
          'skin_type': 'Berminyak, Normal',
          'image_url': 'ordinary_nmf.jpg',
          'rating': 4.5
        },
        
        // Untuk Kulit Kering
        {
          'name': 'CeraVe Moisturizing Cream',
          'category': 'untuk_kulit_kering',
          'description': 'Krim pelembab intensif dengan 3 ceramide dan hyaluronic acid untuk memulihkan skin barrier',
          'ingredients': 'Ceramides, Hyaluronic Acid, Glycerin, MVE Technology',
          'price': 'Rp200.000 - Rp250.000',
          'texture': 'Cream',
          'with_spf': 'Tidak',
          'skin_type': 'Kering, Normal',
          'image_url': 'cerave_moisturizing.jpg',
          'rating': 4.8
        },
        {
          'name': 'La Roche-Posay Lipikar Baume AP+M',
          'category': 'untuk_kulit_kering',
          'description': 'Balm pelembab intensif untuk kulit sangat kering, menenangkan dan mengurangi gatal',
          'ingredients': 'Shea Butter, Niacinamide, Glycerin, Thermal Spring Water',
          'price': 'Rp300.000 - Rp350.000',
          'texture': 'Balm',
          'with_spf': 'Tidak',
          'skin_type': 'Kering, Sensitif',
          'image_url': 'laroche_lipikar.jpg',
          'rating': 4.9
        },
        
        // Untuk Kulit Sensitif
        {
          'name': 'Avène Tolérance Extrême Cream',
          'category': 'untuk_kulit_sensitif',
          'description': 'Formula minimal dengan 7 bahan untuk menghidrasi dan menenangkan kulit sensitif',
          'ingredients': 'Avène Thermal Spring Water, Glycerin, Squalane',
          'price': 'Rp350.000 - Rp400.000',
          'texture': 'Cream',
          'with_spf': 'Tidak',
          'skin_type': 'Sensitif',
          'image_url': 'avene_tolerance.jpg',
          'rating': 4.7
        },
        {
          'name': 'Vanicream Moisturizing Skin Cream',
          'category': 'untuk_kulit_sensitif',
          'description': 'Krim pelembab bebas pewangi dan bahan iritan untuk kulit sensitif dan rawan alergi',
          'ingredients': 'Petrolatum, Sorbitol, White Petrolatum, Purified Water',
          'price': 'Rp200.000 - Rp250.000',
          'texture': 'Cream',
          'with_spf': 'Tidak',
          'skin_type': 'Sensitif, Alergi',
          'image_url': 'vanicream.jpg',
          'rating': 4.6
        },
        
        // Untuk Anti Jerawat
        {
          'name': 'La Roche-Posay Effaclar Mat',
          'category': 'untuk_anti_jerawat',
          'description': 'Moisturizer mattifying yang mengontrol minyak dan mengurangi ukuran pori',
          'ingredients': 'Sebulyse Technology, Lipo-Hydroxy Acid, Salicylic Acid, Glycerin',
          'price': 'Rp280.000 - Rp320.000',
          'texture': 'Gel',
          'with_spf': 'Tidak',
          'skin_type': 'Berminyak, Berjerawat',
          'image_url': 'laroche_effaclar.jpg',
          'rating': 4.6
        },
        {
          'name': 'Paula\'s Choice Clear Oil-Free Moisturizer',
          'category': 'untuk_anti_jerawat',
          'description': 'Moisturizer ringan dengan antioksidan untuk kulit berjerawat, tidak menyumbat pori',
          'ingredients': 'Niacinamide, Ceramides, Green Tea Extract, Hyaluronic Acid',
          'price': 'Rp300.000 - Rp350.000',
          'texture': 'Lotion',
          'with_spf': 'Tidak',
          'skin_type': 'Berminyak, Berjerawat',
          'image_url': 'paulaschoice_clear.jpg',
          'rating': 4.7
        },
        
        // Untuk Anti Aging
        {
          'name': 'Olay Regenerist Micro-Sculpting Cream',
          'category': 'untuk_anti_aging',
          'description': 'Krim anti-aging dengan peptida dan niacinamide untuk mengurangi kerutan dan meningkatkan elastisitas',
          'ingredients': 'Niacinamide (Vitamin B3), Peptides, Hyaluronic Acid, Vitamin E',
          'price': 'Rp250.000 - Rp300.000',
          'texture': 'Cream',
          'with_spf': 'Tidak',
          'skin_type': 'Normal, Kering, Mature',
          'image_url': 'olay_regenerist.jpg',
          'rating': 4.5
        },
        {
          'name': 'Lancôme Rénergie Lift Multi-Action Day Cream',
          'category': 'untuk_anti_aging',
          'description': 'Krim lifting dan mengencangkan kulit dengan SPF 15 untuk mengurangi garis halus dan kerutan',
          'ingredients': 'Linseed Extract, Hyaluronic Acid, Shea Butter, UV Filters',
          'price': 'Rp850.000 - Rp950.000',
          'texture': 'Cream',
          'with_spf': 'Ya, SPF 15',
          'skin_type': 'Normal, Kering, Mature',
          'image_url': 'lancome_renergie.jpg',
          'rating': 4.8
        },
        
        // Untuk Pencerah
        {
          'name': 'Dear, Klairs Freshly Juiced Vitamin Drop',
          'category': 'untuk_pencerah',
          'description': 'Serum pencerah dengan vitamin C 5% yang stabil, mencerahkan dan meratakan warna kulit',
          'ingredients': 'Vitamin C (Ascorbic Acid), Centella Asiatica Extract, Yuzu Extract',
          'price': 'Rp200.000 - Rp250.000',
          'texture': 'Serum',
          'with_spf': 'Tidak',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'klairs_vitamin.jpg',
          'rating': 4.6
        },
        {
          'name': 'Clinique Even Better Clinical Radical Dark Spot Corrector',
          'category': 'untuk_pencerah',
          'description': 'Serum untuk mengurangi noda hitam dan hiperpigmentasi, mencerahkan secara keseluruhan',
          'ingredients': 'Vitamin C, Salicylic Acid, Glucosamine, Yeast Extract',
          'price': 'Rp750.000 - Rp850.000',
          'texture': 'Serum',
          'with_spf': 'Tidak',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'clinique_even_better.jpg',
          'rating': 4.7
        },
        
        // Untuk Hidrasi Intensif
        {
          'name': 'Laneige Water Sleeping Mask',
          'category': 'untuk_hidrasi_intensif',
          'description': 'Masker tidur berbahan dasar air yang memberikan hidrasi sepanjang malam',
          'ingredients': 'Hydro Ionized Mineral Water, Ceramides, Evening Primrose Root Extract',
          'price': 'Rp350.000 - Rp400.000',
          'texture': 'Gel',
          'with_spf': 'Tidak',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'laneige_sleeping.jpg',
          'rating': 4.8
        },
        {
          'name': 'First Aid Beauty Ultra Repair Cream',
          'category': 'untuk_hidrasi_intensif',
          'description': 'Krim pelembab intensif untuk kulit sangat kering, aman untuk kondisi seperti eksim',
          'ingredients': 'Colloidal Oatmeal, Shea Butter, Ceramides, Allantoin',
          'price': 'Rp300.000 - Rp350.000',
          'texture': 'Cream',
          'with_spf': 'Tidak',
          'skin_type': 'Kering, Sensitif',
          'image_url': 'firstaid_ultrarepair.jpg',
          'rating': 4.9
        },
        
        // Untuk Kulit Kombinasi
        {
          'name': 'Clinique Dramatically Different Moisturizing Gel',
          'category': 'untuk_kulit_kombinasi',
          'description': 'Gel pelembab ringan yang menyeimbangkan area berminyak dan area kering pada kulit kombinasi',
          'ingredients': 'Hyaluronic Acid, Glycerin, Cucumber Extract, Barley Extract',
          'price': 'Rp350.000 - Rp400.000',
          'texture': 'Gel',
          'with_spf': 'Tidak',
          'skin_type': 'Kombinasi, Berminyak',
          'image_url': 'clinique_dramatically.jpg',
          'rating': 4.6
        },
        {
          'name': 'Kiehl\'s Ultra Facial Oil-Free Gel Cream',
          'category': 'untuk_kulit_kombinasi',
          'description': 'Krim gel bebas minyak yang ringan untuk hidrasi seimbang pada kulit kombinasi',
          'ingredients': 'Glycerin, Imperata Cylindrica Root Extract, Antarcticine, Cucumber Extract',
          'price': 'Rp400.000 - Rp450.000',
          'texture': 'Gel Cream',
          'with_spf': 'Tidak',
          'skin_type': 'Kombinasi, Berminyak',
          'image_url': 'kiehls_ultrafacial.jpg',
          'rating': 4.7
        },
        
        // Untuk Bahan Alami
        {
          'name': 'Herbivore Botanicals Pink Cloud Rosewater Moisture Cream',
          'category': 'untuk_bahan_alami',
          'description': 'Krim pelembab berbahan dasar air mawar dengan bahan-bahan alami dan organik',
          'ingredients': 'Rosewater, Aloe Vera, Kukui Oil, White Tea Extract',
          'price': 'Rp400.000 - Rp450.000',
          'texture': 'Cream',
          'with_spf': 'Tidak',
          'skin_type': 'Normal, Kering',
          'image_url': 'herbivore_pinkcloud.jpg',
          'rating': 4.5
        },
        {
          'name': 'COSRX Balancium Comfort Ceramide Cream',
          'category': 'untuk_bahan_alami',
          'description': 'Krim dengan ceramide alami dari tanaman dan centella asiatica untuk skin barrier yang sehat',
          'ingredients': 'Centella Asiatica Extract, Ceramides, Sunflower Seed Oil, Shea Butter',
          'price': 'Rp250.000 - Rp300.000',
          'texture': 'Cream',
          'with_spf': 'Tidak',
          'skin_type': 'Semua jenis kulit, Sensitif',
          'image_url': 'cosrx_balancium.jpg',
          'rating': 4.6
        },
      ];
      
      // Gunakan batch untuk performa lebih baik
      Batch batch = db.batch();
      for (var product in products) {
        batch.insert('moisturizer_products', product);
      }
      
      await batch.commit(noResult: true);
      debugPrint('Sample moisturizer products added successfully');
      return true;
    } catch (e) {
      debugPrint('Error adding sample moisturizer products: $e');
      return false;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('moisturizer_app.db');
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
    // Tabel untuk menyimpan data produk moisturizer
    await db.execute('''
    CREATE TABLE moisturizer_products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      description TEXT,
      ingredients TEXT,
      price TEXT,
      texture TEXT,
      with_spf TEXT,
      skin_type TEXT,
      image_url TEXT,
      rating REAL
    )
    ''');

    // Tabel untuk menyimpan jawaban user untuk sesi rekomendasi
    await db.execute('''
    CREATE TABLE user_answers_moisturizer (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      jenis_kulit TEXT,
      tingkat_hidrasi TEXT,
      usia TEXT,
      jerawat TEXT,
      sensitifitas TEXT,
      hiperpigmentasi TEXT,
      kulit_kusam TEXT,
      garis_halus TEXT,
      paparan_matahari TEXT,
      preferensi_tekstur TEXT,
      cuaca TEXT,
      waktu_penggunaan TEXT,
      budget TEXT,
      tambahan_spf TEXT,
      bahan_alami TEXT,
      created_at TEXT
    )
    ''');
    
    // Tabel untuk menyimpan hasil rekomendasi
    await db.execute('''
    CREATE TABLE moisturizer_recommendation_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_answer_id INTEGER,
      product_type TEXT NOT NULL,
      top_category TEXT NOT NULL,
      match_percentage REAL,
      budget_range TEXT,
      created_at TEXT,
      FOREIGN KEY (user_answer_id) REFERENCES user_answers_moisturizer (id)
    )
    ''');
  }

  // Fungsi untuk menyimpan jawaban user
  Future<int> saveUserAnswers(Map<String, dynamic> answers) async {
    final db = await database;
    
    try {
      // Normalisasi jawaban
      Map<String, dynamic> normalizedAnswers = {...answers};
      
      // Tambahkan timestamp
      normalizedAnswers['created_at'] = DateTime.now().toIso8601String();
      
      // Gunakan transaksi untuk operasi atomik
      int insertId = 0;
      await db.transaction((txn) async {
        // Hapus jawaban sebelumnya (opsional, tergantung kebutuhan aplikasi)
        await txn.delete('user_answers_moisturizer');
        
        // Simpan jawaban baru
        insertId = await txn.insert('user_answers_moisturizer', normalizedAnswers);
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
      Map<String, dynamic> resultData = {
        'user_answer_id': userAnswerId,
        'product_type': result['productType'],
        'top_category': result['topCategory'],
        'match_percentage': result['matchPercentage'],
        'budget_range': result['budgetRange'],
        'created_at': DateTime.now().toIso8601String(),
      };
      
      int insertId = await db.insert('moisturizer_recommendation_results', resultData);
      debugPrint('Hasil rekomendasi moisturizer berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan hasil rekomendasi moisturizer: $e');
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
          'moisturizer_products',
          where: 'category = ?',
          whereArgs: [category],
          orderBy: 'rating DESC'
        );
      } else {
        // Filter produk berdasarkan kategori dan budget
        results = await db.query(
          'moisturizer_products',
          where: 'category = ? AND price LIKE ?',
          whereArgs: [category, '%$budgetRange%'],
          orderBy: 'rating DESC'
        );
        
        // Jika tidak ada produk yang cocok dengan filter budget, tampilkan semua produk kategori
        if (results.isEmpty) {
          results = await db.query(
            'moisturizer_products',
            where: 'category = ?',
            whereArgs: [category],
            orderBy: 'rating DESC'
          );
        }
      }
      
      return results;
    } catch (e) {
      debugPrint('Error getting moisturizer products: $e');
      return [];
    }
  }

  // Fungsi untuk mendapatkan hasil rekomendasi terbaru
  Future<Map<String, dynamic>?> getLatestRecommendation() async {
    final db = await database;
    
    try {
      // Ambil hasil rekomendasi terbaru
      final List<Map<String, dynamic>> recommendationResults = await db.query(
        'moisturizer_recommendation_results',
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
      debugPrint('Error getting latest moisturizer recommendation: $e');
      return null;
    }
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}