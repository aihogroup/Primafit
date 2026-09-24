import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperToner {
  static final DatabaseHelperToner instance = DatabaseHelperToner._init();
  static Database? _database;

  DatabaseHelperToner._init();

  // Fungsi untuk menambahkan data sampel produk ke database
  Future<bool> addSampleProducts() async {
    try {
      final db = await database;
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM toner_products'));
      if (count != null && count > 0) {
        debugPrint('Data produk sudah ada, tidak perlu menambahkan sampel');
        return true;
      }
      
      // Contoh produk toner untuk berbagai kategori
      List<Map<String, dynamic>> products = [
        // Untuk Kulit Berminyak
        {
          'name': 'COSRX AHA/BHA Clarifying Treatment Toner',
          'category': 'untuk_kulit_berminyak',
          'description': 'Toner dengan asam AHA/BHA untuk mengontrol minyak, mengangkat sel kulit mati, dan mencerahkan kulit',
          'ingredients': 'Mineral Water, Salix Alba (Willow) Bark Water, Pyrus Malus (Apple) Fruit Water, Butylene Glycol, 1,2-Hexanediol, Sodium Lactate, Glycolic Acid, Betaine Salicylate',
          'price': 'Rp150.000 - Rp200.000',
          'volume': '150ml',
          'skin_type': 'Berminyak, Kombinasi',
          'image_url': 'cosrx_clarifying.jpg',
          'texture': 'Cair, ringan',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Tidak',
          'rating': 4.5
        },
        {
          'name': 'Benton Aloe BHA Skin Toner',
          'category': 'untuk_kulit_berminyak',
          'description': 'Toner dengan aloe vera dan 0.5% BHA untuk mengontrol produksi minyak berlebih secara lembut',
          'ingredients': 'Aloe Barbadensis Leaf Water, Glycerin, Sodium Hyaluronate, Snail Secretion Filtrate, Salicylic Acid',
          'price': 'Rp180.000 - Rp230.000',
          'volume': '200ml',
          'skin_type': 'Berminyak, Kombinasi, Berjerawat',
          'image_url': 'benton_aloe.jpg',
          'texture': 'Cair, hampir seperti air',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Tidak',
          'rating': 4.4
        },

        // Untuk Kulit Kering
        {
          'name': 'Laneige Cream Skin Refiner',
          'category': 'untuk_kulit_kering',
          'description': 'Toner-pelembap dengan white leaf tea water yang memberikan hidrasi intensif untuk kulit kering',
          'ingredients': 'White Leaf Tea Water, Butylene Glycol, Glycerin, Squalane, Cetyl Ethylhexanoate',
          'price': 'Rp300.000 - Rp350.000',
          'volume': '150ml',
          'skin_type': 'Kering, Normal',
          'image_url': 'laneige_cream_skin.jpg',
          'texture': 'Milky, kental',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Ya',
          'rating': 4.7
        },
        {
          'name': 'Klairs Supple Preparation Unscented Toner',
          'category': 'untuk_kulit_kering',
          'description': 'Toner tanpa pewangi dengan bahan pelembap yang memberikan hidrasi mendalam untuk kulit kering',
          'ingredients': 'Water, Butylene Glycol, Dimethyl Sulfone, Betaine, Caprylic/Capric Triglyceride, Natto Gum, Sodium Hyaluronate, Disodium EDTA, Centella Asiatica Extract',
          'price': 'Rp220.000 - Rp270.000',
          'volume': '180ml',
          'skin_type': 'Kering, Sensitif',
          'image_url': 'klairs_unscented.jpg',
          'texture': 'Cair, sedikit kental',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Tidak',
          'rating': 4.6
        },

        // Untuk Kulit Sensitif
        {
          'name': 'Avene Thermal Spring Water',
          'category': 'untuk_kulit_sensitif',
          'description': 'Air termal murni yang menenangkan dan mengurangi kemerahan pada kulit sensitif',
          'ingredients': 'Avene Thermal Spring Water',
          'price': 'Rp250.000 - Rp300.000',
          'volume': '300ml',
          'skin_type': 'Sensitif, Kemerahan',
          'image_url': 'avene_thermal.jpg',
          'texture': 'Cair seperti air',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Tidak',
          'rating': 4.5
        },
        {
          'name': 'Pyunkang Yul Essence Toner',
          'category': 'untuk_kulit_sensitif',
          'description': 'Toner dengan formula minimal (7 bahan) untuk menghidrasi dan menenangkan tanpa iritasi',
          'ingredients': 'Astragalus Membranaceus Root Extract, 1,2-Hexanediol, Butylene Glycol, Bis-PEG-18 Methyl Ether Dimethyl Silane, Hydroxyethylcellulose',
          'price': 'Rp180.000 - Rp230.000',
          'volume': '200ml',
          'skin_type': 'Sensitif, Kombinasi',
          'image_url': 'pyunkang_essence.jpg',
          'texture': 'Cair, sedikit kental',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Tidak',
          'rating': 4.6
        },

        // Untuk Eksfoliasi
        {
          'name': 'Some By Mi AHA BHA PHA 30 Days Miracle Toner',
          'category': 'untuk_eksfoliasi',
          'description': 'Toner eksfoliasi dengan 3 jenis asam dan ekstrak tea tree untuk sel kulit mati dan jerawat',
          'ingredients': 'Water, Tea Tree Leaf Water, Glycolic Acid, Lactic Acid, Salicylic Acid, Gluconolactone, Betaine Salicylate, Niacinamide',
          'price': 'Rp180.000 - Rp230.000',
          'volume': '150ml',
          'skin_type': 'Berjerawat, Berminyak, Kombinasi',
          'image_url': 'somebymi_miracle.jpg',
          'texture': 'Cair, sedikit lengket',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Ya',
          'rating': 4.7
        },
        {
          'name': 'The Ordinary Glycolic Acid 7% Toning Solution',
          'category': 'untuk_eksfoliasi',
          'description': 'Toner dengan konsentrasi glycolic acid 7% untuk eksfoliasi dan mencerahkan kulit',
          'ingredients': 'Aqua, Glycolic Acid, Aloe Barbadensis Leaf Water, Ginseng Root Extract, Tasmanian Pepperberry',
          'price': 'Rp170.000 - Rp220.000',
          'volume': '240ml',
          'skin_type': 'Normal, Kombinasi, Berminyak',
          'image_url': 'ordinary_glycolic.jpg',
          'texture': 'Cair',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Tidak',
          'rating': 4.5
        },

        // Untuk Pencerah
        {
          'name': 'Hada Labo Shirojyun Premium Whitening Lotion',
          'category': 'untuk_pencerah',
          'description': 'Toner dengan tranexamic acid dan vitamin C untuk mencerahkan dan mengatasi hiperpigmentasi',
          'ingredients': 'Water, Butylene Glycol, Glycerin, Disodium Succinate, Hydrolyzed Hyaluronic Acid, Tranexamic Acid, Vitamin C',
          'price': 'Rp200.000 - Rp250.000',
          'volume': '170ml',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'hadalabo_shirojyun.jpg',
          'texture': 'Cair, sedikit kental',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Tidak',
          'rating': 4.6
        },
        {
          'name': 'Melano CC Vitamin C Toner',
          'category': 'untuk_pencerah',
          'description': 'Toner dengan vitamin C dan ekstrak lemon untuk mencerahkan kulit dan memudarkan bekas jerawat',
          'ingredients': 'Water, Ethanol, Ascorbic Acid, Dipotassium Glycyrrhizate, Lemon Extract, Vitamin E',
          'price': 'Rp150.000 - Rp200.000',
          'volume': '170ml',
          'skin_type': 'Normal, Berminyak, Kombinasi',
          'image_url': 'melano_cc.jpg',
          'texture': 'Cair, seperti air',
          'contains_alcohol': 'Ya',
          'contains_fragrance': 'Ya',
          'rating': 4.3
        },

        // Untuk Hidrasi
        {
          'name': 'Hada Labo Gokujyun Premium Hyaluronic Acid Lotion',
          'category': 'untuk_hidrasi',
          'description': 'Toner dengan 5 jenis hyaluronic acid untuk hidrasi mendalam dan lapisan-lapisan kulit',
          'ingredients': 'Water, Butylene Glycol, Glycerin, PPG-10 Methyl Glucose Ether, Hydroxyethyl Urea, Sodium Acetylated Hyaluronate, Sodium Hyaluronate, Hydrolyzed Hyaluronic Acid',
          'price': 'Rp200.000 - Rp240.000',
          'volume': '170ml',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'hadalabo_premium.jpg',
          'texture': 'Kental, seperti serum tipis',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Tidak',
          'rating': 4.8
        },
        {
          'name': 'Isntree Hyaluronic Acid Toner Plus',
          'category': 'untuk_hidrasi',
          'description': 'Toner dengan 8 jenis hyaluronic acid, ceramide, dan centella asiatica untuk hidrasi maksimal',
          'ingredients': 'Water, Methylpropanediol, Butylene Glycol, Glycerin, Centella Asiatica Extract, Sodium Hyaluronate, Hydrolyzed Hyaluronic Acid, Ceramide NP',
          'price': 'Rp230.000 - Rp280.000',
          'volume': '200ml',
          'skin_type': 'Semua jenis kulit',
          'image_url': 'isntree_hyaluronic.jpg',
          'texture': 'Cair, sedikit kental',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Tidak',
          'rating': 4.7
        },

        // Untuk Menenangkan
        {
          'name': 'I\'m From Rice Toner',
          'category': 'untuk_menenangkan',
          'description': 'Toner berbahan dasar beras untuk menenangkan, mencerahkan, dan menutrisi kulit',
          'ingredients': 'Rice Extract (77.78%), Methylpropanediol, Triethylhexanoin, Hydrogenated Poly, Niacinamide',
          'price': 'Rp280.000 - Rp330.000',
          'volume': '150ml',
          'skin_type': 'Kering, Normal, Sensitif',
          'image_url': 'imfrom_rice.jpg',
          'texture': 'Cair, sedikit milky',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Ya',
          'rating': 4.6
        },
        {
          'name': 'Etude House Soon Jung pH 5.5 Relief Toner',
          'category': 'untuk_menenangkan',
          'description': 'Toner dengan pH seimbang dan panthenol untuk menenangkan dan menguatkan skin barrier',
          'ingredients': 'Water, Propanediol, Glycerin, Betaine, Panthenol, Madecassoside, Green Tea Extract',
          'price': 'Rp150.000 - Rp200.000',
          'volume': '180ml',
          'skin_type': 'Sensitif, Berjerawat, Semua jenis kulit',
          'image_url': 'etude_soonjung.jpg',
          'texture': 'Cair seperti air',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Tidak',
          'rating': 4.5
        },

        // Untuk Anti Aging
        {
          'name': 'Missha Time Revolution First Treatment Essence RX',
          'category': 'untuk_anti_aging',
          'description': 'Essence-toner dengan 97% fermented yeast extract untuk anti-aging dan memperbaiki tekstur kulit',
          'ingredients': 'Saccharomyces Ferment Filtrate, Bifida Ferment Lysate, Niacinamide, Adenosine, Hyaluronic Acid',
          'price': 'Rp350.000 - Rp450.000',
          'volume': '150ml',
          'skin_type': 'Semua jenis kulit, Aging',
          'image_url': 'missha_timerevolution.jpg',
          'texture': 'Cair seperti air',
          'contains_alcohol': 'Ya',
          'contains_fragrance': 'Tidak',
          'rating': 4.7
        },
        {
          'name': 'SK-II Facial Treatment Essence',
          'category': 'untuk_anti_aging',
          'description': 'Toner ikonik dengan PITERA™ untuk anti-aging, mencerahkan, dan memperbaiki tekstur kulit',
          'ingredients': 'Galactomyces Ferment Filtrate (PITERA™), Butylene Glycol, Pentylene Glycol, Water, Sodium Benzoate',
          'price': 'Rp1.200.000 - Rp1.500.000',
          'volume': '160ml',
          'skin_type': 'Semua jenis kulit, Aging',
          'image_url': 'skii_treatment.jpg',
          'texture': 'Cair seperti air',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Tidak',
          'rating': 4.6
        },

        // Untuk Skin Barrier
        {
          'name': 'Rovectin Skin Essentials Activating Treatment Lotion',
          'category': 'untuk_skin_barrier',
          'description': 'Toner untuk memperkuat skin barrier dengan 7 hyaluronic acid dan ekstrak honeysuckle',
          'ingredients': 'Water, Glycerin, Butylene Glycol, Caprylic/Capric Triglyceride, Lonicera Japonica (Honeysuckle) Flower Extract, Sodium Hyaluronate',
          'price': 'Rp250.000 - Rp300.000',
          'volume': '180ml',
          'skin_type': 'Sensitif, Kering, Iritasi, Semua jenis kulit',
          'image_url': 'rovectin_activating.jpg',
          'texture': 'Cair, sedikit kental',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Tidak',
          'rating': 4.5
        },
        {
          'name': 'Purito Centella Unscented Toner',
          'category': 'untuk_skin_barrier',
          'description': 'Toner tanpa pewangi dengan centella asiatica untuk menenangkan dan memperbaiki skin barrier',
          'ingredients': 'Water, Glycerin, Butylene Glycol, Centella Asiatica Extract, Ceramide NP, Panthenol, Madecassoside',
          'price': 'Rp200.000 - Rp250.000',
          'volume': '200ml',
          'skin_type': 'Sensitif, Kering, Berjerawat, Semua jenis kulit',
          'image_url': 'purito_centella.jpg',
          'texture': 'Cair, sedikit kental',
          'contains_alcohol': 'Tidak',
          'contains_fragrance': 'Tidak',
          'rating': 4.6
        },
      ];
      
      // Gunakan batch untuk performa lebih baik
      Batch batch = db.batch();
      for (var product in products) {
        batch.insert('toner_products', product);
      }
      
      await batch.commit(noResult: true);
      debugPrint('Sample toner products added successfully');
      return true;
    } catch (e) {
      debugPrint('Error adding sample toner products: $e');
      return false;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('toner_app.db');
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
    // Tabel untuk menyimpan data produk toner
    await db.execute('''
    CREATE TABLE toner_products (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      category TEXT NOT NULL,
      description TEXT,
      ingredients TEXT,
      price TEXT,
      volume TEXT,
      skin_type TEXT,
      image_url TEXT,
      texture TEXT,
      contains_alcohol TEXT,
      contains_fragrance TEXT,
      rating REAL
    )
    ''');

    // Tabel untuk menyimpan jawaban user untuk sesi rekomendasi
    await db.execute('''
    CREATE TABLE user_answers_toner (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      jenis_kulit TEXT,
      masalah_kulit TEXT,
      sensitifitas TEXT,
      iritasi_alkohol TEXT,
      iritasi_wewangian TEXT,
      eksfoliasi TEXT,
      hidrasi TEXT,
      brightening TEXT,
      jerawat TEXT,
      tekstur_preference TEXT,
      anti_aging TEXT,
      skin_barrier TEXT,
      budget TEXT,
      umur TEXT,
      created_at TEXT
    )
    ''');
    
    // Tabel untuk menyimpan hasil rekomendasi
    await db.execute('''
    CREATE TABLE toner_recommendation_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_answer_id INTEGER,
      product_type TEXT NOT NULL,
      top_category TEXT NOT NULL,
      match_percentage REAL,
      budget_range TEXT,
      created_at TEXT,
      FOREIGN KEY (user_answer_id) REFERENCES user_answers_toner (id)
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
        await txn.delete('user_answers_toner');
        
        // Simpan jawaban baru
        insertId = await txn.insert('user_answers_toner', normalizedAnswers);
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
      
      int insertId = await db.insert('toner_recommendation_results', resultData);
      debugPrint('Hasil rekomendasi toner berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan hasil rekomendasi toner: $e');
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
          'toner_products',
          where: 'category = ?',
          whereArgs: [category],
          orderBy: 'rating DESC'
        );
      } else {
        // Filter produk berdasarkan kategori dan budget
        results = await db.query(
          'toner_products',
          where: 'category = ? AND price LIKE ?',
          whereArgs: [category, '%$budgetRange%'],
          orderBy: 'rating DESC'
        );
        
        // Jika tidak ada produk yang cocok dengan filter budget, tampilkan semua produk kategori
        if (results.isEmpty) {
          results = await db.query(
            'toner_products',
            where: 'category = ?',
            whereArgs: [category],
            orderBy: 'rating DESC'
          );
        }
      }
      
      return results;
    } catch (e) {
      debugPrint('Error getting toner products: $e');
      return [];
    }
  }

  // Fungsi untuk mendapatkan hasil rekomendasi terbaru
  Future<Map<String, dynamic>?> getLatestRecommendation() async {
    final db = await database;
    
    try {
      // Ambil hasil rekomendasi terbaru
      final List<Map<String, dynamic>> recommendationResults = await db.query(
        'toner_recommendation_results',
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
      debugPrint('Error getting latest toner recommendation: $e');
      return null;
    }
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}