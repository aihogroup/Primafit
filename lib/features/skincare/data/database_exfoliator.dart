import 'package:primafit/core/database/local_db.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperExfoliator {
  static final DatabaseHelperExfoliator instance = DatabaseHelperExfoliator._init();
  static Database? _database;

  DatabaseHelperExfoliator._init();

  // Fungsi untuk menambahkan data sampel produk ke database
  Future<bool> addSampleProducts() async {
    try {
      final db = await database;
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM exfoliator_products'));
      if (count != null && count > 0) {
        debugPrint('Data produk sudah ada, tidak perlu menambahkan sampel');
        return true;
      }
      
      // Contoh produk exfoliator untuk berbagai kategori
      final List<Map<String, dynamic>> products = [
        // Untuk Kulit Berminyak
        {
          'name': 'Paula\'s Choice 2% BHA Liquid Exfoliant',
          'category': 'untuk_kulit_berminyak',
          'description': 'Exfoliant berbahan BHA yang efektif mengontrol minyak dan membersihkan pori-pori tersumbat',
          'ingredients': 'Salicylic Acid 2%, Green Tea Extract, Methylpropanediol, Camellia Oleifera Leaf Extract',
          'price': 'Rp350.000 - Rp450.000',
          'exfoliant_type': 'Chemical',
          'acid_type': 'BHA (Salicylic Acid)',
          'skin_type': 'Berminyak, Kombinasi, Berjerawat',
          'usage_frequency': '1-2 kali seminggu',
          'image_url': 'paulas_choice_bha.jpg',
          'rating': 4.8
        },
        {
          'name': 'The Ordinary Salicylic Acid 2% Solution',
          'category': 'untuk_kulit_berminyak',
          'description': 'Exfoliant berbahan BHA yang membantu mengatasi kulit berminyak dan mencegah timbulnya jerawat',
          'ingredients': 'Salicylic Acid 2%, Witch Hazel, Hexylene Glycol',
          'price': 'Rp150.000 - Rp200.000',
          'exfoliant_type': 'Chemical',
          'acid_type': 'BHA (Salicylic Acid)',
          'skin_type': 'Berminyak, Berjerawat',
          'usage_frequency': '1-2 kali seminggu',
          'image_url': 'ordinary_salicylic.jpg',
          'rating': 4.6
        },
        
        // Untuk Kulit Kering
        {
          'name': 'Laneige Soft Calming Peeling Gel',
          'category': 'untuk_kulit_kering',
          'description': 'Peeling gel lembut yang mengangkat sel kulit mati tanpa membuat kulit terasa kering',
          'ingredients': 'Papain Extract, Centella Asiatica Extract, Glycerin, Cellulose',
          'price': 'Rp250.000 - Rp300.000',
          'exfoliant_type': 'Physical',
          'acid_type': 'N/A',
          'skin_type': 'Kering, Normal',
          'usage_frequency': '1-2 kali seminggu',
          'image_url': 'laneige_peeling.jpg',
          'rating': 4.5
        },
        {
          'name': 'First Aid Beauty Facial Radiance Pads',
          'category': 'untuk_kulit_kering',
          'description': 'Pad exfoliasi lembut dengan konsentrasi AHA rendah, cocok untuk kulit sensitif dan kering',
          'ingredients': 'Glycolic Acid, Lactic Acid, Cucumber Extract, Licorice Root Extract',
          'price': 'Rp400.000 - Rp500.000',
          'exfoliant_type': 'Chemical',
          'acid_type': 'AHA (Glycolic Acid, Lactic Acid)',
          'skin_type': 'Kering, Sensitif',
          'usage_frequency': '2-3 kali seminggu',
          'image_url': 'fab_pads.jpg',
          'rating': 4.7
        },
        
        // Untuk Kulit Sensitif
        {
          'name': 'Krave Beauty Kale-Lalu-yAHA',
          'category': 'untuk_kulit_sensitif',
          'description': 'Exfoliant lembut dengan AHA 5.25%, ideal untuk kulit sensitif dan pemula dalam exfoliation',
          'ingredients': 'Glycolic Acid 5.25%, Aloe Barbadensis Leaf Water, Glycerin, Kale Extract, Spinach Extract',
          'price': 'Rp300.000 - Rp400.000',
          'exfoliant_type': 'Chemical',
          'acid_type': 'AHA (Glycolic Acid)',
          'skin_type': 'Sensitif, Normal, Pemula',
          'usage_frequency': '1-2 kali seminggu',
          'image_url': 'krave_aha.jpg',
          'rating': 4.8
        },
        {
          'name': 'Dermalogica Daily Microfoliant',
          'category': 'untuk_kulit_sensitif',
          'description': 'Exfoliant bubuk lembut berbasis rice enzyme yang menghaluskan dan mencerahkan kulit',
          'ingredients': 'Rice Bran, Papain, Salicylic Acid, Colloidal Oatmeal, White Tea',
          'price': 'Rp850.000 - Rp950.000',
          'exfoliant_type': 'Physical & Chemical',
          'acid_type': 'Enzymes (Papain), BHA (trace)',
          'skin_type': 'Sensitif, Normal, Kering',
          'usage_frequency': 'Setiap hari (pagi)',
          'image_url': 'dermalogica_microfoliant.jpg',
          'rating': 4.9
        },
        
        // Untuk Anti Jerawat
        {
          'name': 'COSRX BHA Blackhead Power Liquid',
          'category': 'untuk_anti_jerawat',
          'description': 'Exfoliant dengan BHA yang efektif mengangkat komedo dan mencegah jerawat',
          'ingredients': 'Betaine Salicylate 4%, Willow Bark Water, Niacinamide, Hyaluronic Acid',
          'price': 'Rp250.000 - Rp300.000',
          'exfoliant_type': 'Chemical',
          'acid_type': 'BHA (Betaine Salicylate)',
          'skin_type': 'Berminyak, Berjerawat, Kombinasi',
          'usage_frequency': '2-3 kali seminggu',
          'image_url': 'cosrx_bha.jpg',
          'rating': 4.7
        },
        {
          'name': 'Murad Acne Clarifying Exfoliator',
          'category': 'untuk_anti_jerawat',
          'description': 'Scrub exfoliator dengan BHA untuk kulit berjerawat, mengandung partikel lembut dari jojoba beads',
          'ingredients': 'Salicylic Acid 1%, Jojoba Beads, Witch Hazel, Green Tea Extract',
          'price': 'Rp500.000 - Rp600.000',
          'exfoliant_type': 'Physical & Chemical',
          'acid_type': 'BHA (Salicylic Acid)',
          'skin_type': 'Berjerawat, Berminyak',
          'usage_frequency': '2-3 kali seminggu',
          'image_url': 'murad_exfoliator.jpg',
          'rating': 4.6
        },
        
        // Untuk Anti Aging
        {
          'name': 'Sunday Riley Good Genes Lactic Acid Treatment',
          'category': 'untuk_anti_aging',
          'description': 'Serum exfoliating dengan lactic acid yang mengurangi garis halus dan meningkatkan kecerahan kulit',
          'ingredients': 'Lactic Acid, Licorice Root Extract, Lemongrass Extract, Arnica Extract, Aloe Barbadensis Leaf Extract',
          'price': 'Rp1.200.000 - Rp1.500.000',
          'exfoliant_type': 'Chemical',
          'acid_type': 'AHA (Lactic Acid)',
          'skin_type': 'Kering, Normal, Aging',
          'usage_frequency': '3-4 kali seminggu',
          'image_url': 'sunday_riley.jpg',
          'rating': 4.9
        },
        {
          'name': 'Drunk Elephant T.L.C. Framboos Glycolic Night Serum',
          'category': 'untuk_anti_aging',
          'description': 'Serum malam dengan kombinasi AHA dan BHA untuk mengatasi garis halus dan tekstur kulit',
          'ingredients': 'Glycolic Acid, Salicylic Acid, Lactic Acid, Tartaric Acid, Citric Acid, Raspberry Extract',
          'price': 'Rp1.300.000 - Rp1.600.000',
          'exfoliant_type': 'Chemical',
          'acid_type': 'AHA/BHA Blend',
          'skin_type': 'Normal, Kombinasi, Aging',
          'usage_frequency': '2-3 kali seminggu',
          'image_url': 'drunk_elephant.jpg',
          'rating': 4.8
        },
        
        // Untuk Kulit Kusam
        {
          'name': 'Pixi Glow Tonic',
          'category': 'untuk_kulit_kusam',
          'description': 'Toner exfoliating dengan glycolic acid 5% yang mencerahkan dan menghaluskan kulit kusam',
          'ingredients': 'Glycolic Acid 5%, Aloe Vera, Ginseng, Witch Hazel, Horse Chestnut Extract',
          'price': 'Rp200.000 - Rp300.000',
          'exfoliant_type': 'Chemical',
          'acid_type': 'AHA (Glycolic Acid)',
          'skin_type': 'Normal, Kusam, Kombinasi',
          'usage_frequency': '1-2 kali sehari',
          'image_url': 'pixi_glow.jpg',
          'rating': 4.7
        },
        {
          'name': 'Tatcha The Rice Polish: Classic',
          'category': 'untuk_kulit_kusam',
          'description': 'Exfoliant bubuk dengan rice enzyme yang mengangkat sel kulit mati dan memberikan kilau alami',
          'ingredients': 'Rice Powder, Papaya Enzyme, Green Tea Extract, Rice Bran, Silk Protein',
          'price': 'Rp850.000 - Rp1.000.000',
          'exfoliant_type': 'Physical & Enzymatic',
          'acid_type': 'Enzymes (Papain)',
          'skin_type': 'Normal, Kusam',
          'usage_frequency': 'Setiap hari',
          'image_url': 'tatcha_rice.jpg',
          'rating': 4.8
        },
        
        // Untuk Kulit Kombinasi
        {
          'name': 'Glossier Solution',
          'category': 'untuk_kulit_kombinasi',
          'description': 'Exfoliating skin perfector dengan campuran AHA, BHA, dan PHA yang cocok untuk kulit kombinasi',
          'ingredients': 'AHA 7% (Lactic + Glycolic Acids), BHA 1% (Salicylic Acid), PHA (Gluconolactone), Aloe, Glycerin',
          'price': 'Rp350.000 - Rp450.000',
          'exfoliant_type': 'Chemical',
          'acid_type': 'AHA/BHA/PHA Blend',
          'skin_type': 'Kombinasi, Normal',
          'usage_frequency': '3-4 kali seminggu',
          'image_url': 'glossier_solution.jpg',
          'rating': 4.6
        },
        {
          'name': 'Boscia Exfoliating Peel Gel',
          'category': 'untuk_kulit_kombinasi',
          'description': 'Peel gel yang lembut mengangkat sel kulit mati tanpa mengiritasi bagian kulit yang sensitif',
          'ingredients': 'Multi-Fruit Enzymes, Pomegranate Extract, Jojoba Leaf, Botanical Extracts',
          'price': 'Rp400.000 - Rp500.000',
          'exfoliant_type': 'Physical & Enzymatic',
          'acid_type': 'Enzymes (Fruit)',
          'skin_type': 'Kombinasi, Sensitif',
          'usage_frequency': '1-2 kali seminggu',
          'image_url': 'boscia_peel.jpg',
          'rating': 4.5
        },
        
        // Untuk Penggunaan Harian
        {
          'name': 'Neogen Bio-Peel Gauze Peeling Wine',
          'category': 'untuk_penggunaan_harian',
          'description': 'Pad exfoliasi dengan sisi fisik dan kimia yang terendam dalam ekstrak anggur dan AHA',
          'ingredients': 'Glycolic Acid, Lactic Acid, Wine Extract, Resveratrol, Rosemary Extract',
          'price': 'Rp300.000 - Rp400.000',
          'exfoliant_type': 'Physical & Chemical',
          'acid_type': 'AHA (Glycolic Acid, Lactic Acid)',
          'skin_type': 'Normal, Kombinasi',
          'usage_frequency': 'Setiap hari (malam)',
          'image_url': 'neogen_wine.jpg',
          'rating': 4.7
        },
        {
          'name': 'Cure Natural Aqua Gel',
          'category': 'untuk_penggunaan_harian',
          'description': 'Exfoliant gel sangat lembut yang populer di Jepang, aman untuk penggunaan sehari-hari',
          'ingredients': 'Activated Hydrogen Water, Glycerin, Aloe Extract, Gingko Extract',
          'price': 'Rp350.000 - Rp450.000',
          'exfoliant_type': 'Physical',
          'acid_type': 'N/A',
          'skin_type': 'Semua jenis kulit',
          'usage_frequency': 'Setiap hari',
          'image_url': 'cure_aqua.jpg',
          'rating': 4.8
        },
        
        // Untuk Penggunaan Mingguan
        {
          'name': 'The Ordinary AHA 30% + BHA 2% Peeling Solution',
          'category': 'untuk_penggunaan_mingguan',
          'description': 'Peeling solution konsentrasi tinggi untuk hasil exfoliasi intensif, hanya untuk penggunaan mingguan',
          'ingredients': 'Glycolic Acid, Lactic Acid, Tartaric Acid, Citric Acid, Salicylic Acid 2%, Hyaluronic Acid',
          'price': 'Rp150.000 - Rp200.000',
          'exfoliant_type': 'Chemical',
          'acid_type': 'AHA/BHA Blend (High Concentration)',
          'skin_type': 'Normal, Berminyak, Tidak Sensitif',
          'usage_frequency': 'Sekali seminggu maksimal',
          'image_url': 'ordinary_aha_bha.jpg',
          'rating': 4.7
        },
        {
          'name': 'Dr. Dennis Gross Alpha Beta Universal Daily Peel',
          'category': 'untuk_penggunaan_mingguan',
          'description': 'Peeling pad dua langkah dengan AHA dan BHA, formulasi profesional untuk perawatan mingguan',
          'ingredients': 'Glycolic Acid, Lactic Acid, Malic Acid, Citric Acid, Salicylic Acid, Retinol, Green Tea Extract',
          'price': 'Rp850.000 - Rp1.000.000',
          'exfoliant_type': 'Chemical',
          'acid_type': 'AHA/BHA Blend',
          'skin_type': 'Normal, Kombinasi, Berminyak',
          'usage_frequency': '1-2 kali seminggu',
          'image_url': 'drdennisgross_peel.jpg',
          'rating': 4.9
        },
      ];
      
      // Gunakan batch untuk performa lebih baik
      final Batch batch = db.batch();
      for (var product in products) {
        batch.insert('exfoliator_products', product);
      }
      
      await batch.commit(noResult: true);
      debugPrint('Sample exfoliator products added successfully');
      return true;
    } catch (e) {
      debugPrint('Error adding sample exfoliator products: $e');
      return false;
    }
  }

  Future<Database> get database async {
    if (_database?.isOpen ?? false) return _database!;
    _database = await _initDB('exfoliator_app.db');
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
    // Tabel untuk menyimpan data produk exfoliator
    await db.execute('''
    CREATE TABLE exfoliator_products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      description TEXT,
      ingredients TEXT,
      price TEXT,
      exfoliant_type TEXT,
      acid_type TEXT,
      skin_type TEXT,
      usage_frequency TEXT,
      image_url TEXT,
      rating REAL
    )
    ''');

    // Tabel untuk menyimpan jawaban user untuk sesi rekomendasi
    await db.execute('''
    CREATE TABLE user_answers_exfoliator (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      jenis_kulit TEXT,
      usia TEXT,
      jerawat TEXT,
      sensitifitas TEXT,
      kulit_kusam TEXT,
      exfoliating_experience TEXT,
      masalah_tekstur TEXT,
      kulit_mengelupas TEXT,
      penggunaan_makeup TEXT,
      frekuensi_exfoliasi TEXT,
      budget TEXT,
      preferensi_tipe TEXT,
      hasil_diinginkan TEXT,
      created_at TEXT
    )
    ''');
    
    // Tabel untuk menyimpan hasil rekomendasi
    await db.execute('''
    CREATE TABLE exfoliator_recommendation_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_answer_id INTEGER,
      product_type TEXT NOT NULL,
      top_category TEXT NOT NULL,
      match_percentage REAL,
      budget_range TEXT,
      created_at TEXT,
      FOREIGN KEY (user_answer_id) REFERENCES user_answers_exfoliator (id)
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
        await txn.delete('user_answers_exfoliator');
        
        // Simpan jawaban baru
        insertId = await txn.insert('user_answers_exfoliator', normalizedAnswers);
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
      
      final int insertId = await db.insert('exfoliator_recommendation_results', resultData);
      debugPrint('Hasil rekomendasi exfoliator berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan hasil rekomendasi exfoliator: $e');
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
          'exfoliator_products',
          where: 'category = ?',
          whereArgs: [category],
          orderBy: 'rating DESC'
        );
      } else {
        // Filter produk berdasarkan kategori dan budget
        results = await db.query(
          'exfoliator_products',
          where: 'category = ? AND price LIKE ?',
          whereArgs: [category, '%$budgetRange%'],
          orderBy: 'rating DESC'
        );
        
        // Jika tidak ada produk yang cocok dengan filter budget, tampilkan semua produk kategori
        if (results.isEmpty) {
          results = await db.query(
            'exfoliator_products',
            where: 'category = ?',
            whereArgs: [category],
            orderBy: 'rating DESC'
          );
        }
      }
      
      return results;
    } catch (e) {
      debugPrint('Error getting exfoliator products: $e');
      return [];
    }
  }

  // Fungsi untuk mendapatkan hasil rekomendasi terbaru
  Future<Map<String, dynamic>?> getLatestRecommendation() async {
    final db = await database;
    
    try {
      // Ambil hasil rekomendasi terbaru
      final List<Map<String, dynamic>> recommendationResults = await db.query(
        'exfoliator_recommendation_results',
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
      debugPrint('Error getting latest exfoliator recommendation: $e');
      return null;
    }
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}