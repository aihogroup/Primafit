import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperNutrition {
  static final DatabaseHelperNutrition instance = DatabaseHelperNutrition._init();
  static Database? _database;

  DatabaseHelperNutrition._init();

  // Fungsi untuk menambahkan data rekomendasi menu makan sehat
  Future<bool> addHealthyMealRecommendations() async {
    try {
      final db = await database;
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM meal_recommendations'));
      if (count != null && count > 0) {
        debugPrint('Data rekomendasi menu makan sehat sudah ada');
        return true;
      }
      
      // Contoh rekomendasi menu makan sehat untuk berbagai kategori
      List<Map<String, dynamic>> recommendations = [
        // Menu untuk dewasa aktif (usia 19-50)
        {
          'category': 'dewasa_aktif',
          'breakfast_options': 'Oatmeal dengan buah-buahan segar dan kacang-kacangan; Smoothie protein dengan sayuran hijau; Telur orak-arik dengan sayuran dan roti gandum utuh.',
          'lunch_options': 'Bowl nasi merah dengan protein tanpa lemak, sayuran panggang, dan alpukat; Salad dengan protein, biji-bijian, dan vinaigrette; Wrap gandum utuh dengan hummus dan sayuran.',
          'dinner_options': 'Salmon panggang dengan quinoa dan sayuran panggang; Ayam panggang dengan ubi jalar dan brokoli; Bowl protein nabati dengan sayuran beragam warna.',
          'snack_options': 'Yogurt Yunani dengan buah dan madu; Kacang-kacangan dan buah kering; Smoothie protein pasca latihan; Apel dengan selai kacang.',
          'meal_planning_tips': 'Fokus pada protein berkualitas tinggi setelah berolahraga; Konsumsi karbohidrat kompleks sebagai sumber energi; Variasikan sumber protein; Pastikan mendapatkan lemak sehat dari sumber seperti alpukat, minyak zaitun, dan kacang-kacangan.',
          'nutritional_focus': 'Protein: 1.2-2.0g per kg berat badan; Karbohidrat: 3-7g per kg berat badan tergantung tingkat aktivitas; Lemak sehat: 20-35% dari total kalori; Serat: 25-35g per hari.',
          'hydration_tips': 'Minum 2.7-3.7 liter cairan sehari; Tambahkan 500-600ml untuk setiap jam berolahraga; Konsumsi elektrolit setelah latihan intens.',
          'portion_guidance': 'Protein: seukuran telapak tangan; Karbohidrat kompleks: seukuran kepalan tangan; Lemak sehat: seukuran ibu jari; Sayuran: sepuas mungkin, minimal setengah piring.',
          'timing_tips': 'Makan dalam 45 menit setelah latihan berat; Distribusikan protein secara merata sepanjang hari; Konsumsi karbohidrat kompleks 3-4 jam sebelum latihan berat.',
          'special_considerations': 'Pertimbangkan kebutuhan zat besi yang lebih tinggi bagi wanita; Fokus pada kalsium dan vitamin D untuk kesehatan tulang; Perhatikan tanda-tanda kekurangan elektrolit seperti kram otot.',
        },
        
        // Menu untuk dewasa senior (usia 65+)
        {
          'category': 'dewasa_senior',
          'breakfast_options': 'Oatmeal dengan buah lembut dan kacang-kacangan cincang; Smoothie kaya protein dan kalsium; Telur rebus dengan roti gandum utuh dan alpukat.',
          'lunch_options': 'Sup kaya serat dengan kacang-kacangan dan sayuran; Salad dengan protein lunak dan dressing kaya nutrisi; Ikan rebus dengan kentang tumbuk dan sayuran rebus.',
          'dinner_options': 'Casserole ayam dengan sayuran dan quinoa; Salmon kukus dengan asparagus dan ubi; Tofu lembut dengan saus dan nasi merah.',
          'snack_options': 'Yogurt Yunani dengan buah-buahan yang dihaluskan; Puding chia dengan buah; Smoothie kaya kalsium; Keju cottage dengan buah.',
          'meal_planning_tips': 'Utamakan makanan lunak jika ada masalah mengunyah; Variasikan warna makanan untuk memastikan beragam nutrisi; Pilih makanan kaya nutrisi dengan kalori yang memadai; Perhatikan porsi yang lebih kecil namun lebih sering.',
          'nutritional_focus': 'Protein: 1.0-1.5g per kg berat badan untuk menjaga massa otot; Kalsium dan Vitamin D untuk kesehatan tulang; Vitamin B12 dari sumber fortifikasi; Serat larut dan tidak larut: 21-30g per hari.',
          'hydration_tips': 'Target minimal 2 liter cairan sehari; Minum secara proaktif bahkan tanpa merasa haus; Perhatikan minuman elektrolit jika menggunakan diuretik.',
          'portion_guidance': 'Protein: seukuran telapak tangan; Karbohidrat kompleks: seukuran 1/3 piring; Sayuran beragam: seukuran 1/2 piring; Buah-buahan: 2-3 porsi sehari.',
          'timing_tips': 'Makan pagi dalam satu jam setelah bangun; Konsumsi makanan kaya protein setelah aktivitas fisik; Hindari makan berat 3 jam sebelum tidur.',
          'special_considerations': 'Monitoring kesehatan ginjal dengan dokter; Perhatikan interaksi makanan dengan obat-obatan; Fokus pada makanan anti-inflamasi; Konsumsi probiotik untuk kesehatan pencernaan.',
        },
        
        // Menu untuk anak usia sekolah (6-12 tahun)
        {
          'category': 'anak_sekolah',
          'breakfast_options': 'Pancake gandum utuh dengan buah dan yogurt; Oatmeal dengan buah-buahan dan madu; Telur orak-arik dengan roti gandum dan buah potong.',
          'lunch_options': 'Sandwich protein dengan sayuran dan buah; Pasta gandum utuh dengan saus tomat dan protein; Wrap dengan hummus, sayuran, dan protein nabati/hewani.',
          'dinner_options': 'Nugget ayam buatan sendiri dengan sayuran panggang; Nasi dengan gulai ayam/ikan dan sayuran; Pizza buatan sendiri dengan topping sayuran.',
          'snack_options': 'Yogurt dengan granola buatan sendiri; Smoothie buah dengan sayuran tersembunyi; Stik sayuran dengan hummus; Trail mix dengan kacang dan buah kering.',
          'meal_planning_tips': 'Libatkan anak dalam perencanaan dan persiapan makanan; Sajikan makanan dengan warna-warni menarik; Perkenalkan makanan baru secara bertahap; Batasi makanan olahan dan tinggi gula.',
          'nutritional_focus': 'Kalsium untuk pertumbuhan tulang; Zat besi untuk perkembangan kognitif; Protein untuk pertumbuhan; Omega-3 untuk perkembangan otak; Serat untuk kesehatan pencernaan.',
          'hydration_tips': 'Air putih sebagai minuman utama; Buat air infused dengan buah untuk variasi rasa; Batasi jus buah (maksimal 120ml/hari); Pastikan membawa botol air ke sekolah.',
          'portion_guidance': 'Gunakan ukuran kepalan tangan anak sebagai panduan porsi; Protein: seukuran telapak tangan; Sayuran: setidaknya 1/3 piring; Karbohidrat: 1/4 piring.',
          'timing_tips': 'Pastikan sarapan sebelum berangkat sekolah; Sediakan snack sehat untuk di sekolah; Tetapkan jadwal makan yang konsisten; Hindari makanan berat sebelum tidur.',
          'special_considerations': 'Perhatikan alergi dan intoleransi makanan; Pertimbangkan preferensi tekstur; Pantau perkembangan dan pertumbuhan dengan dokter; Kurangi makanan tinggi sodium dan pemanis buatan.',
        },
        
        // Menu untuk remaja (13-18 tahun)
        {
          'category': 'remaja',
          'breakfast_options': 'Smoothie bowl dengan buah, yogurt, dan granola; Overnight oats dengan buah dan kacang-kacangan; Roti gandum utuh dengan telur dan alpukat.',
          'lunch_options': 'Bowl protein dengan nasi, daging tanpa lemak, dan sayuran colorful; Wrap dengan protein, sayuran, dan saus sehat; Salad dengan protein dan dressing yogurt.',
          'dinner_options': 'Stir-fry dengan protein dan sayuran beragam warna; Pasta gandum utuh dengan saus bolognese dan sayuran tersembunyi; Bowl burrito dengan nasi, kacang hitam, dan topping sehat.',
          'snack_options': 'Yogurt tinggi protein dengan buah dan granola; Smoothie protein pasca latihan; Selai kacang dengan apel atau roti gandum; Energy balls buatan sendiri dari kurma dan kacang.',
          'meal_planning_tips': 'Siapkan makanan grab-and-go untuk jadwal sibuk; Libatkan remaja dalam perencanaan dan memasak; Persiapkan snack tinggi protein dan nutrisi; Pastikan ketersediaan makanan sehat di rumah.',
          'nutritional_focus': 'Kalsium: 1300mg/hari untuk pertumbuhan tulang; Zat besi: terutama untuk remaja putri (15mg/hari); Protein: 0.85g/kg berat badan untuk mendukung pertumbuhan; Zinc untuk perkembangan hormonal; Vitamin D untuk kesehatan tulang.',
          'hydration_tips': 'Target 2-3 liter air sehari; Tingkatkan konsumsi cairan saat berolahraga; Batasi minuman energi dan berkafein; Bawa botol air kemana-mana.',
          'portion_guidance': 'Protein: seukuran telapak tangan; Karbohidrat kompleks: seukuran kepalan tangan; Sayuran: minimal 1/2 piring; Buah-buahan: 2-4 porsi sehari.',
          'timing_tips': 'Jangan lewatkan sarapan meski terburu-buru; Rencanakan snack diantara kelas/aktivitas; Konsumsi nutrisi dalam 45 menit setelah olahraga; Hindari ngemil larut malam.',
          'special_considerations': 'Perhatikan body image dan hubungan dengan makanan; Dukungan nutrisi selama masa pubertas; Antisipasi lonjakan nafsu makan; Pantau pola makan yang ekstrem atau obsesif.',
        },
        
        // Menu untuk ibu hamil trimester pertama
        {
          'category': 'hamil_trimester1',
          'breakfast_options': 'Yogurt dengan buah dan granola kaya zat besi; Roti gandum utuh dengan telur rebus dan alpukat; Smoothie jahe anti mual dengan pisang dan protein nabati.',
          'lunch_options': 'Sup lentil dengan sayuran hijau; Salad dengan protein, kacang-kacangan, dan vinaigrette lemon; Sandwich gandum utuh dengan hummus dan sayuran.',
          'dinner_options': 'Salmon panggang kaya omega-3 dengan ubi jalar dan asparagus; Bowl quinoa dengan protein dan sayuran panggang; Pasta gandum utuh dengan saus tomat kaya vitamin C.',
          'snack_options': 'Cracker gandum utuh dengan keju; Kacang-kacangan dan buah kering; Apel dengan selai kacang; Yogurt dengan buah segar.',
          'meal_planning_tips': 'Makan porsi kecil tapi sering untuk mengatasi mual; Simpan cracker di samping tempat tidur untuk mual pagi hari; Pilih makanan dengan aroma minimal jika sensitif bau; Prioritaskan makanan yang dapat ditoleransi saat mual.',
          'nutritional_focus': 'Folat/asam folat: 600-800mcg/hari; Zat besi untuk mencegah anemia; B6 untuk mengurangi mual; Kalsium untuk perkembangan tulang janin; Protein tambahan 10g/hari.',
          'hydration_tips': 'Target 2-3 liter cairan sehari; Air jahe untuk mengatasi mual; Hindari kafein berlebihan (batasi <200mg/hari); Minum diantara waktu makan jika mual saat makan.',
          'portion_guidance': 'Fokus pada kualitas bukan kuantitas; Makan sekenyangnya saat nafsu makan baik; Tidak perlu menambah kalori pada trimester pertama; Prioritaskan makanan padat nutrisi.',
          'timing_tips': 'Makan makanan kecil segera setelah bangun tidur; Jangan biarkan perut kosong terlalu lama; Konsumsi snack protein sebelum tidur; Pisahkan waktu minum dan makan jika mengalami mual.',
          'special_considerations': 'Hindari daging/telur mentah/setengah matang; Batasi ikan tinggi merkuri; Hindari alkohol; Konsultasikan penggunaan herbal dengan dokter; Perhatikan keamanan pangan.',
        },
        
        // Menu untuk penderita diabetes tipe 2
        {
          'category': 'diabetes',
          'breakfast_options': 'Oatmeal dengan kacang-kacangan dan kayu manis (tanpa gula tambahan); Telur dengan sayuran dan alpukat; Yogurt Yunani dengan buah rendah indeks glikemik dan chia seeds.',
          'lunch_options': 'Salad protein dengan minyak zaitun dan cuka; Bowl quinoa dengan protein dan sayuran non-starchy; Sup kacang-kacangan dengan sayuran hijau.',
          'dinner_options': 'Ikan panggang dengan sayuran hijau dan lemon; Ayam panggang dengan sayuran panggang non-starchy; Tofu dengan stir-fry sayuran dan bumbu rempah.',
          'snack_options': 'Kacang-kacangan tanpa garam; Stik sayuran dengan hummus; Telur rebus; Edamame; Keju cottage dengan mentimun.',
          'meal_planning_tips': 'Perhatikan ukuran porsi karbohidrat; Distribusikan karbohidrat secara merata sepanjang hari; Pilih karbohidrat kompleks berserat tinggi; Selalu pasangkan karbohidrat dengan protein dan lemak sehat.',
          'nutritional_focus': 'Serat larut (dari oat, kacang-kacangan) untuk memperlambat penyerapan gula; Protein tanpa lemak jenuh; Lemak sehat dari ikan, kacang, dan minyak zaitun; Magnesium untuk sensitivitas insulin; Chromium untuk metabolisme glukosa.',
          'hydration_tips': 'Target 2-3 liter air sehari; Hindari minuman manis dan jus buah; Teh hijau tanpa gula untuk antioksidan; Perhatikan konsumsi alkohol (dapat menyebabkan hipoglikemia).',
          'portion_guidance': 'Karbohidrat: 1/4 piring; Protein: 1/4 piring; Sayuran non-starchy: 1/2 piring; Batasi buah menjadi 2-3 porsi kecil per hari; Ukur porsi dengan metode piring atau tangan.',
          'timing_tips': 'Makan pada interval waktu teratur; Hindari puasa berkepanjangan; Sesuaikan waktu makan dengan obat diabetes; Perhatikan efek makanan tertentu pada gula darah melalui monitoring.',
          'special_considerations': 'Monitor gula darah secara teratur; Perhatikan efek aktivitas fisik pada kebutuhan insulin; Pertimbangkan indeks glikemik dan beban glikemik makanan; Baca label makanan untuk total karbohidrat.',
        },
      ];
      
      // Gunakan batch untuk performa lebih baik
      Batch batch = db.batch();
      for (var rec in recommendations) {
        batch.insert('meal_recommendations', rec);
      }
      
      await batch.commit(noResult: true);
      debugPrint('Rekomendasi menu makan sehat berhasil ditambahkan');
      return true;
    } catch (e) {
      debugPrint('Error menambahkan rekomendasi menu makan sehat: $e');
      return false;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nutrition_app.db');
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
    // Tabel untuk menyimpan jawaban user untuk analisis kebutuhan nutrisi
    await db.execute('''
    CREATE TABLE user_answers_nutrition (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      usia TEXT,
      jenis_kelamin TEXT,
      tingkat_aktivitas TEXT,
      berat_badan REAL,
      tinggi_badan REAL,
      waktu_makan_utama TEXT,
      alergi_makanan TEXT,
      tujuan_diet TEXT,
      kondisi_kesehatan TEXT,
      preferensi_diet TEXT,
      waktu_persiapan TEXT,
      anggaran TEXT,
      created_at TEXT
    )
    ''');
    
    // Tabel untuk menyimpan hasil analisis kebutuhan nutrisi
    await db.execute('''
    CREATE TABLE nutrition_analysis_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_answer_id INTEGER,
      recommended_calories REAL,
      recommended_protein REAL,
      recommended_carbs REAL,
      recommended_fat REAL,
      main_category TEXT NOT NULL,
      secondary_category TEXT,
      bmr REAL,
      tdee REAL,
      created_at TEXT,
      FOREIGN KEY (user_answer_id) REFERENCES user_answers_nutrition (id)
    )
    ''');
    
    // Tabel untuk rekomendasi menu makanan berdasarkan kategori
    await db.execute('''
    CREATE TABLE meal_recommendations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category TEXT UNIQUE NOT NULL,
      breakfast_options TEXT,
      lunch_options TEXT,
      dinner_options TEXT,
      snack_options TEXT,
      meal_planning_tips TEXT,
      nutritional_focus TEXT,
      hydration_tips TEXT,
      portion_guidance TEXT,
      timing_tips TEXT,
      special_considerations TEXT
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
        insertId = await txn.insert('user_answers_nutrition', normalizedAnswers);
      });
      
      debugPrint('Jawaban user untuk analisis nutrisi berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan jawaban user analisis nutrisi: $e');
      rethrow;
    }
  }

  // Fungsi untuk menyimpan hasil analisis kebutuhan nutrisi
  Future<int> saveAnalysisResult(int userAnswerId, Map<String, dynamic> result) async {
    final db = await database;
    
    try {
      Map<String, dynamic> resultData = {
        'user_answer_id': userAnswerId,
        'recommended_calories': result['recommendedCalories'],
        'recommended_protein': result['recommendedProtein'],
        'recommended_carbs': result['recommendedCarbs'],
        'recommended_fat': result['recommendedFat'],
        'main_category': result['mainCategory'],
        'secondary_category': result['secondaryCategory'],
        'bmr': result['bmr'],
        'tdee': result['tdee'],
        'created_at': DateTime.now().toIso8601String(),
      };
      
      int insertId = await db.insert('nutrition_analysis_results', resultData);
      debugPrint('Hasil analisis kebutuhan nutrisi berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan hasil analisis kebutuhan nutrisi: $e');
      rethrow;
    }
  }

  // Fungsi untuk mendapatkan rekomendasi menu berdasarkan kategori
  Future<Map<String, dynamic>?> getRecommendationByCategory(String category) async {
    final db = await database;
    
    try {
      // Pastikan tabel rekomendasi tidak kosong
      await addHealthyMealRecommendations();
      
      final List<Map<String, dynamic>> results = await db.query(
        'meal_recommendations',
        where: 'category = ?',
        whereArgs: [category],
      );
      
      if (results.isEmpty) {
        // Jika tidak ditemukan rekomendasi spesifik, kembalikan rekomendasi untuk dewasa aktif
        return (await db.query(
          'meal_recommendations',
          where: 'category = ?',
          whereArgs: ['dewasa_aktif'],
        )).first;
      }
      
      return results.first;
    } catch (e) {
      debugPrint('Error mendapatkan rekomendasi menu makanan: $e');
      return null;
    }
  }

  // Fungsi untuk mendapatkan hasil analisis kebutuhan nutrisi terbaru
  Future<Map<String, dynamic>?> getLatestAnalysisResult() async {
    final db = await database;
    
    try {
      // Ambil hasil analisis kebutuhan nutrisi terbaru
      final List<Map<String, dynamic>> analysisResults = await db.query(
        'nutrition_analysis_results',
        orderBy: 'created_at DESC',
        limit: 1
      );
      
      if (analysisResults.isEmpty) {
        return null;
      }
      
      final analysis = analysisResults.first;
      final String mainCategory = analysis['main_category'];
      
      // Ambil rekomendasi menu berdasarkan kategori
      final recommendation = await getRecommendationByCategory(mainCategory);
      
      return {
        'analysis': analysis,
        'recommendation': recommendation,
      };
    } catch (e) {
      debugPrint('Error mendapatkan hasil analisis kebutuhan nutrisi terbaru: $e');
      return null;
    }
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}