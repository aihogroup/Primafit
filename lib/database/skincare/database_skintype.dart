import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperSkinType {
  static final DatabaseHelperSkinType instance = DatabaseHelperSkinType._init();
  static Database? _database;

  DatabaseHelperSkinType._init();

  // Fungsi untuk menambahkan data rekomendasi skincare berdasarkan jenis kulit
  Future<bool> addSkinTypeRecommendations() async {
    try {
      final db = await database;
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM skin_type_recommendations'));
      if (count != null && count > 0) {
        debugPrint('Data rekomendasi skincare jenis kulit sudah ada');
        return true;
      }
      
      // Contoh rekomendasi perawatan kulit untuk berbagai jenis kulit
      List<Map<String, dynamic>> recommendations = [
        // Kulit Berminyak
        {
          'skin_type': 'berminyak',
          'cleanser_tip': 'Gunakan pembersih berbasis gel dengan kandungan salicylic acid atau benzoyl peroxide untuk mengontrol produksi minyak dan mencegah penyumbatan pori.',
          'toner_tip': 'Pilih toner berbahan dasar air dengan BHA/AHA untuk mengontrol minyak dan menyempurnakan tampilan pori.',
          'moisturizer_tip': 'Gunakan pelembab ringan berbasis air atau gel. Hindari produk berbasis minyak atau terlalu creamy.',
          'sunscreen_tip': 'Pilih sunscreen berbasis gel atau cair dengan formula oil-free dan non-comedogenic.',
          'exfoliation_tip': 'Exfoliasi 2-3 kali seminggu dengan produk berbahan BHA seperti salicylic acid untuk membersihkan pori dan mengontrol minyak.',
          'routine_am': 'Pembersih > Toner > Serum > Pelembab > Sunscreen',
          'routine_pm': 'Pembersih > Toner > Treatment (niacinamide/salicylic acid) > Pelembab ringan',
          'ingredients_to_look': 'Niacinamide, Salicylic Acid, Zinc PCA, Tea Tree Oil, Hyaluronic Acid ringan',
          'ingredients_to_avoid': 'Minyak berat, Petroleum, Lanolin, Alkohol berlebih',
          'extra_tips': 'Gunakan masker clay 1-2 kali seminggu untuk menyerap kelebihan minyak. Hindari produk berminyak. Pilih formula bebas minyak.'
        },
        
        // Kulit Kering
        {
          'skin_type': 'kering',
          'cleanser_tip': 'Gunakan pembersih creamy atau berbasis minyak yang lembut, tanpa bahan foaming yang dapat mengeringkan kulit.',
          'toner_tip': 'Pilih toner hydrating tanpa alkohol dengan kandungan ceramide, glycerin, atau hyaluronic acid.',
          'moisturizer_tip': 'Gunakan pelembab kaya dengan kandungan minyak baik, ceramides, atau butter alami. Cream lebih direkomendasikan daripada lotion.',
          'sunscreen_tip': 'Pilih sunscreen creamy atau moisturizing dengan kandungan hyaluronic acid, ceramide, atau vitamin E.',
          'exfoliation_tip': 'Exfoliasi maksimal 1-2 kali seminggu dengan produk berbahan AHA seperti lactic acid atau glycolic acid untuk menghilangkan sel kulit mati.',
          'routine_am': 'Pembersih lembut > Toner hydrating > Serum (hyaluronic acid) > Pelembab kaya > Sunscreen',
          'routine_pm': 'Pembersih > Toner > Treatment (retinol jika diperlukan) > Serum > Pelembab kaya > Minyak wajah (opsional)',
          'ingredients_to_look': 'Hyaluronic Acid, Ceramides, Glycerin, Squalane, Shea Butter, Aloe Vera, Urea',
          'ingredients_to_avoid': 'Alkohol tinggi (SD Alcohol, Denatured), Parfum berlebih, Menthol',
          'extra_tips': 'Gunakan masker sheet hydrating 1-2 kali seminggu. Pertimbangkan humidifier untuk lingkungan kering. Minum cukup air untuk hidrasi dari dalam.'
        },
        
        // Kulit Normal
        {
          'skin_type': 'normal',
          'cleanser_tip': 'Gunakan pembersih dengan pH seimbang yang tidak terlalu stripping atau terlalu berminyak.',
          'toner_tip': 'Pilih toner tanpa alkohol yang menyegarkan dan memberikan hidrasi tambahan.',
          'moisturizer_tip': 'Gunakan pelembab dengan tekstur seimbang (tidak terlalu berat atau terlalu ringan) untuk menjaga kelembapan optimal.',
          'sunscreen_tip': 'Pilih sunscreen dengan tekstur yang nyaman, dapat berupa lotion, gel-cream, atau essence sesuai preferensi.',
          'exfoliation_tip': 'Exfoliasi 1-2 kali seminggu dengan produk AHA/BHA ringan untuk menjaga tekstur kulit tetap halus.',
          'routine_am': 'Pembersih > Toner > Serum antioksidan > Pelembab > Sunscreen',
          'routine_pm': 'Pembersih > Toner > Treatment (sesuai kebutuhan) > Pelembab',
          'ingredients_to_look': 'Vitamin C, Peptides, Niacinamide, Ceramides, Antioksidan, Hyaluronic Acid',
          'ingredients_to_avoid': 'Bahan yang terlalu agresif yang bisa mengganggu keseimbangan kulit',
          'extra_tips': 'Kulit normal umumnya lebih toleran terhadap berbagai produk, tetapi tetap perhatikan perubahan cuaca dan lingkungan yang mungkin memengaruhi keseimbangan kulit.'
        },
        
        // Kulit Kombinasi
        {
          'skin_type': 'kombinasi',
          'cleanser_tip': 'Gunakan pembersih gel ringan yang dapat membersihkan area berminyak tanpa mengeringkan area kering.',
          'toner_tip': 'Pertimbangkan untuk menggunakan toner berbeda untuk area berbeda atau pilih toner balancing yang cocok untuk semua area.',
          'moisturizer_tip': 'Gunakan pelembab gel atau lotion ringan di area T-zone, dan pelembab lebih kaya di area kering jika diperlukan.',
          'sunscreen_tip': 'Pilih sunscreen dengan tekstur seimbang, atau gunakan yang ringan di T-zone dan lebih hydrating di area kering.',
          'exfoliation_tip': 'Exfoliasi 2 kali seminggu, dengan fokus pada area T-zone. Gunakan chemical exfoliant dengan kombinasi AHA dan BHA.',
          'routine_am': 'Pembersih > Toner > Serum ringan > Pelembab (disesuaikan per area jika perlu) > Sunscreen',
          'routine_pm': 'Pembersih > Toner > Treatment (berbeda per area jika perlu) > Pelembab (disesuaikan per area)',
          'ingredients_to_look': 'Niacinamide, Hyaluronic Acid, Tea Tree (untuk area berminyak), Peptides, Ceramides ringan',
          'ingredients_to_avoid': 'Minyak berat di seluruh wajah, formula yang terlalu stripping',
          'extra_tips': 'Pendekatan multi-masking bisa efektif: gunakan clay mask di T-zone dan hydrating mask di area kering. Perhatikan kebutuhan berbeda setiap area wajah.'
        },
        
        // Kulit Sensitif
        {
          'skin_type': 'sensitif',
          'cleanser_tip': 'Gunakan pembersih sangat lembut, tanpa pewangi, tanpa SLS, berbahan dasar krim atau susu.',
          'toner_tip': 'Pilih toner tanpa alkohol yang menenangkan dan bebas pewangi, dengan bahan seperti chamomile atau calendula.',
          'moisturizer_tip': 'Gunakan pelembab hypoallergenic dengan bahan minimal, pilih yang mengandung ceramide untuk memperkuat skin barrier.',
          'sunscreen_tip': 'Pilih sunscreen mineral (zinc oxide, titanium dioxide) yang dirancang untuk kulit sensitif, bebas pewangi dan alkohol.',
          'exfoliation_tip': 'Exfoliasi sangat jarang (1 kali per 1-2 minggu) dengan PHA yang sangat lembut, atau hindari exfoliasi jika kulit sangat sensitif.',
          'routine_am': 'Pembersih lembut > Toner menenangkan (opsional) > Pelembab > Sunscreen mineral',
          'routine_pm': 'Pembersih lembut > Serum menenangkan > Pelembab perbaikan barrier',
          'ingredients_to_look': 'Centella Asiatica, Oat Extract, Allantoin, Panthenol, Madecassoside, Ceramides, Hyaluronic Acid',
          'ingredients_to_avoid': 'Alkohol, Pewangi, Essential Oil, AHA/BHA tinggi, Retinol konsentrasi tinggi, Sulfat, Menthol',
          'extra_tips': 'Selalu lakukan patch test pada produk baru. Hindari produk dengan banyak bahan. Pilih formula minimal dengan fokus pada penguatan skin barrier.'
        },
      ];
      
      // Gunakan batch untuk performa lebih baik
      Batch batch = db.batch();
      for (var rec in recommendations) {
        batch.insert('skin_type_recommendations', rec);
      }
      
      await batch.commit(noResult: true);
      debugPrint('Rekomendasi skincare berdasarkan jenis kulit berhasil ditambahkan');
      return true;
    } catch (e) {
      debugPrint('Error menambahkan rekomendasi skincare jenis kulit: $e');
      return false;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('skintype_app.db');
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
    // Tabel untuk menyimpan jawaban user untuk analisis jenis kulit
    await db.execute('''
    CREATE TABLE user_answers_skintype (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      wajah_setelah_cuci TEXT,
      ukuran_pori TEXT,
      kilap_wajah TEXT,
      tekstur_kulit TEXT,
      kecenderungan_jerawat TEXT,
      reaksi_produk TEXT,
      sensasi_ketarik TEXT,
      kemerahan_kulit TEXT,
      tipe_makeup TEXT,
      area_kering TEXT,
      perubahan_musim TEXT,
      pola_tidur TEXT,
      created_at TEXT
    )
    ''');
    
    // Tabel untuk menyimpan hasil analisis jenis kulit
    await db.execute('''
    CREATE TABLE skin_type_analysis_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_answer_id INTEGER,
      primary_skin_type TEXT NOT NULL,
      secondary_skin_type TEXT NOT NULL,
      tendency_level TEXT NOT NULL,
      match_percentage REAL,
      top_skin_type TEXT NOT NULL,
      created_at TEXT,
      FOREIGN KEY (user_answer_id) REFERENCES user_answers_skintype (id)
    )
    ''');
    
    // Tabel untuk rekomendasi skincare berdasarkan jenis kulit
    await db.execute('''
    CREATE TABLE skin_type_recommendations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      skin_type TEXT UNIQUE NOT NULL,
      cleanser_tip TEXT,
      toner_tip TEXT,
      moisturizer_tip TEXT,
      sunscreen_tip TEXT,
      exfoliation_tip TEXT,
      routine_am TEXT,
      routine_pm TEXT,
      ingredients_to_look TEXT,
      ingredients_to_avoid TEXT,
      extra_tips TEXT
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
        // Simpan jawaban baru
        insertId = await txn.insert('user_answers_skintype', normalizedAnswers);
      });
      
      debugPrint('Jawaban user untuk analisis kulit berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan jawaban user analisis kulit: $e');
      rethrow;
    }
  }

  // Fungsi untuk menyimpan hasil analisis jenis kulit
  Future<int> saveAnalysisResult(int userAnswerId, Map<String, dynamic> result) async {
    final db = await database;
    
    try {
      Map<String, dynamic> resultData = {
        'user_answer_id': userAnswerId,
        'primary_skin_type': result['primarySkinType'],
        'secondary_skin_type': result['secondarySkinType'],
        'tendency_level': result['tendencyLevel'],
        'match_percentage': result['matchPercentage'],
        'top_skin_type': result['topSkinType'],
        'created_at': DateTime.now().toIso8601String(),
      };
      
      int insertId = await db.insert('skin_type_analysis_results', resultData);
      debugPrint('Hasil analisis jenis kulit berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan hasil analisis jenis kulit: $e');
      rethrow;
    }
  }

  // Fungsi untuk mendapatkan rekomendasi skincare berdasarkan jenis kulit
  Future<Map<String, dynamic>?> getRecommendationBySkinType(String skinType) async {
    final db = await database;
    
    try {
      // Pastikan tabel rekomendasi tidak kosong
      await addSkinTypeRecommendations();
      
      final List<Map<String, dynamic>> results = await db.query(
        'skin_type_recommendations',
        where: 'skin_type = ?',
        whereArgs: [skinType],
      );
      
      if (results.isEmpty) {
        // Jika tidak ditemukan rekomendasi spesifik, kembalikan rekomendasi untuk kulit normal
        return (await db.query(
          'skin_type_recommendations',
          where: 'skin_type = ?',
          whereArgs: ['normal'],
        )).first;
      }
      
      return results.first;
    } catch (e) {
      debugPrint('Error mendapatkan rekomendasi skincare: $e');
      return null;
    }
  }

  // Fungsi untuk mendapatkan hasil analisis jenis kulit terbaru
  Future<Map<String, dynamic>?> getLatestAnalysisResult() async {
    final db = await database;
    
    try {
      // Ambil hasil analisis jenis kulit terbaru
      final List<Map<String, dynamic>> analysisResults = await db.query(
        'skin_type_analysis_results',
        orderBy: 'created_at DESC',
        limit: 1
      );
      
      if (analysisResults.isEmpty) {
        return null;
      }
      
      final analysis = analysisResults.first;
      final String topSkinType = analysis['top_skin_type'];
      
      // Ambil rekomendasi skincare berdasarkan jenis kulit
      final recommendation = await getRecommendationBySkinType(topSkinType);
      
      return {
        'analysis': analysis,
        'recommendation': recommendation,
      };
    } catch (e) {
      debugPrint('Error mendapatkan hasil analisis jenis kulit terbaru: $e');
      return null;
    }
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}