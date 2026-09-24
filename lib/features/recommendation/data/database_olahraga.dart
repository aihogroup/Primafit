import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperExercise {
  static final DatabaseHelperExercise instance = DatabaseHelperExercise._init();
  static Database? _database;

  DatabaseHelperExercise._init();

  // Fungsi untuk menambahkan data rekomendasi program olahraga
  Future<bool> addExerciseRecommendations() async {
    try {
      final db = await database;
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM exercise_recommendations'));
      if (count != null && count > 0) {
        debugPrint('Data rekomendasi program olahraga sudah ada');
        return true;
      }
      
      // Contoh rekomendasi program olahraga untuk berbagai kategori
      final List<Map<String, dynamic>> recommendations = [
        // Program untuk dewasa aktif (usia 19-50)
        {
          'category': 'dewasa_aktif',
          'title': 'Dewasa Aktif',
          'description': 'Program olahraga untuk dewasa usia 19-50 tahun dengan level aktivitas sedang hingga tinggi.',
          'cardio_program': 'Lari 30-45 menit (3x/minggu); Bersepeda 45-60 menit (2x/minggu); HIIT 20 menit (1x/minggu).',
          'strength_program': 'Latihan beban 45-60 menit (3-4x/minggu) dengan fokus pada kelompok otot utama; Circuit training 30 menit (1-2x/minggu).',
          'flexibility_program': 'Stretching dinamis 10 menit sebelum latihan; Stretching statis 10-15 menit setelah latihan; Yoga/pilates 45-60 menit (1x/minggu).',
          'sample_weekly_plan': 'Senin: Upper body strength + cardio ringan; Selasa: Kardio (lari/bersepeda); Rabu: Lower body strength; Kamis: HIIT atau cardio interval; Jumat: Full body strength; Sabtu: Aktivitas rekreasi atau yoga; Minggu: Istirahat aktif.',
          'warm_up_tips': 'Lakukan pemanasan dinamis 5-10 menit; Tingkatkan detak jantung secara bertahap; Fokus pada mobilitas sendi yang akan digunakan dalam latihan utama.',
          'recovery_focus': 'Waktu istirahat 48 jam untuk kelompok otot yang sama; Tidur 7-8 jam per malam; Konsumsi protein dalam 30 menit setelah latihan beban.',
          'intensity_guidance': 'Kardio: 70-85% detak jantung maksimal; Kekuatan: 70-85% dari 1RM untuk pertumbuhan otot, 8-12 repetisi per set.',
          'progression_tips': 'Tingkatkan beban 5-10% setiap 2-3 minggu; Variasikan latihan kardio dengan interval; Catat kemajuan untuk memantau perkembangan.',
          'special_considerations': 'Sesuaikan intensitas berdasarkan kemampuan recovery; Pertimbangkan stres pekerjaan dalam menjadwalkan latihan berat; Prioritaskan konsistensi di atas intensitas.',
        },
        
        // Program untuk dewasa senior (usia 51-64)
        {
          'category': 'dewasa_senior',
          'title': 'Dewasa Senior',
          'description': 'Program olahraga untuk dewasa usia 51-64 tahun dengan fokus pada kesehatan jangka panjang dan pemeliharaan fungsi tubuh.',
          'cardio_program': 'Jalan cepat 30-40 menit (3-4x/minggu); Bersepeda kecepatan rendah-sedang 30-45 menit (2-3x/minggu); Berenang 30 menit (1-2x/minggu).',
          'strength_program': 'Latihan kekuatan intensitas sedang 30-45 menit (2-3x/minggu) dengan fokus pada keseimbangan dan stabilitas; Band exercises untuk kelompok otot besar (2x/minggu).',
          'flexibility_program': 'Stretching 15-20 menit setiap hari; Yoga/tai chi 45-60 menit (2x/minggu) untuk keseimbangan dan fleksibilitas.',
          'sample_weekly_plan': 'Senin: Jalan cepat + latihan kekuatan dasar; Selasa: Yoga/tai chi; Rabu: Bersepeda + latihan keseimbangan; Kamis: Latihan kekuatan & stabilitas; Jumat: Berenang/aqua aerobik; Sabtu: Jalan cepat & stretching; Minggu: Istirahat aktif/stretching ringan.',
          'warm_up_tips': 'Pemanasan lebih lama (10-15 menit); Fokus pada mobilitas sendi secara menyeluruh; Tingkatkan intensitas sangat bertahap.',
          'recovery_focus': 'Waktu pemulihan 48-72 jam untuk kelompok otot yang sama; Prioritaskan kualitas tidur; Penuhi kebutuhan protein dan kalsium untuk kesehatan otot dan tulang.',
          'intensity_guidance': 'Kardio: 60-75% detak jantung maksimal; Kekuatan: 60-70% dari 1RM, 10-15 repetisi per set dengan fokus pada teknik.',
          'progression_tips': 'Tingkatkan intensitas secara bertahap (5% setiap 3-4 minggu); Fokus pada peningkatan daya tahan sebelum kekuatan; Selalu prioritaskan teknik dan pencegahan cedera.',
          'special_considerations': 'Perhatikan tanda-tanda kelelahan berlebih; Hindari gerakan yang memberikan tekanan tinggi pada sendi; Konsultasikan dengan dokter terutama jika memiliki kondisi kesehatan kronis.',
        },
        
        // Program untuk lansia (usia 65+)
        {
          'category': 'lansia',
          'title': 'Lansia',
          'description': 'Program olahraga untuk lansia usia 65+ tahun dengan fokus pada kemandirian, keseimbangan, dan pencegahan jatuh.',
          'cardio_program': 'Jalan santai 20-30 menit (3-5x/minggu); Bersepeda statis 15-25 menit (2-3x/minggu); Aktivitas di air 20-30 menit (1-2x/minggu).',
          'strength_program': 'Latihan kekuatan dengan beban ringan/resistance band 20-30 menit (2-3x/minggu); Latihan dengan kursi untuk penguatan kaki dan core (3x/minggu).',
          'flexibility_program': 'Stretching lembut 10-15 menit setiap hari; Tai chi/yoga untuk lansia 30-45 menit (2-3x/minggu); Latihan keseimbangan 10 menit setiap hari.',
          'sample_weekly_plan': 'Senin: Jalan santai + latihan keseimbangan; Selasa: Latihan kekuatan dengan kursi; Rabu: Tai chi/yoga lansia; Kamis: Bersepeda statis + stretching; Jumat: Latihan kekuatan ringan; Sabtu: Aqua aerobik/aktivitas air; Minggu: Istirahat aktif (jalan santai pendek).',
          'warm_up_tips': 'Pemanasan sangat penting, minimal 10-15 menit; Gerakan lembut dan bertahap; Fokus pada pernapasan dan aliran darah ke ekstremitas.',
          'recovery_focus': 'Istirahat memadai (24-48 jam) antara sesi kekuatan; Perhatikan tanda-tanda overtraining; Hindari aktivitas dengan risiko jatuh saat lelah.',
          'intensity_guidance': 'Kardio: 50-70% detak jantung maksimal, bisa memonitor dengan metode bicara (masih bisa bicara saat berolahraga); Kekuatan: 40-60% dari 1RM, 12-15 repetisi dengan teknik sempurna.',
          'progression_tips': 'Prioritaskan konsistensi daripada peningkatan intensitas; Tambah durasi sebelum intensitas; Tambah jumlah repetisi sebelum beban.',
          'special_considerations': 'Fokus pada pencegahan jatuh dan peningkatan keseimbangan; Hindari gerakan membungkuk/memutar berlebihan; Selalu melakukan aktivitas dengan pendamping jika memiliki risiko jatuh.',
        },
        
        // Program untuk remaja (13-18 tahun)
        {
          'category': 'remaja',
          'title': 'Remaja',
          'description': 'Program olahraga untuk remaja usia 13-18 tahun dengan fokus pada perkembangan keterampilan dasar dan kebiasaan sehat.',
          'cardio_program': 'Olahraga tim (sepak bola, basket) 45-60 menit (2-3x/minggu); Lari interval 20-30 menit (2x/minggu); Berenang atau aktivitas rekreasi 45-60 menit (1-2x/minggu).',
          'strength_program': 'Latihan bodyweight/kalistenik 30-45 menit (2-3x/minggu); Latihan beban dengan supervisi untuk remaja 16+ tahun (2x/minggu); Circuit training 30 menit (1x/minggu).',
          'flexibility_program': 'Stretching dinamis 10-15 menit sebelum aktivitas; Yoga/pilates remaja 45 menit (1x/minggu); Mobilitas sendi 10 menit setelah aktivitas.',
          'sample_weekly_plan': 'Senin: Olahraga tim + latihan kekuatan bodyweight; Selasa: Lari interval atau kardio; Rabu: Latihan kekuatan penuh dengan fokus teknik; Kamis: Aktivitas rekreasi atau olahraga tim; Jumat: Circuit training; Sabtu: Aktivitas outdoor atau berenang; Minggu: Istirahat aktif atau yoga.',
          'warm_up_tips': 'Pemanasan dinamis 10 menit; Gerakan fungsional yang menyiapkan tubuh untuk aktivitas utama; Hindari stretching statis sebelum aktivitas.',
          'recovery_focus': 'Tidur 8-10 jam per malam sangat penting; Penuhi kebutuhan kalori dan nutrisi untuk pertumbuhan; Istirahat 48 jam untuk kelompok otot yang sama pada latihan beban.',
          'intensity_guidance': 'Kardio: bervariasi dari intensitas sedang hingga tinggi dengan interval; Kekuatan: fokus pada teknik dan kontrol gerakan sebelum menambah beban.',
          'progression_tips': 'Kembangkan keterampilan fundamental sebelum spesialisasi; Tingkatkan kompleksitas gerakan secara bertahap; Catat kemajuan untuk motivasi.',
          'special_considerations': 'Hindari spesialisasi dini pada satu olahraga; Prioritaskan variasi aktivitas untuk perkembangan menyeluruh; Perhatikan lonjakan pertumbuhan yang dapat memengaruhi koordinasi.',
        },
        
        // Program untuk anak-anak (6-12 tahun)
        {
          'category': 'anak',
          'title': 'Anak-anak',
          'description': 'Program aktivitas fisik untuk anak usia 6-12 tahun dengan fokus pada kesenangan, keterampilan motorik, dan sosialisasi.',
          'cardio_program': 'Bermain aktif 60+ menit per hari (setiap hari); Olahraga tim/permainan terstruktur 45-60 menit (2-3x/minggu); Aktivitas berjalan/bersepeda 30 menit (3-4x/minggu).',
          'strength_program': 'Aktivitas bermain yang melibatkan memanjat, mendorong, menarik (sepanjang minggu); Latihan bodyweight dalam bentuk permainan 20-30 menit (2-3x/minggu); Latihan ketangkasan dan keseimbangan 15-20 menit (3x/minggu).',
          'flexibility_program': 'Gerakan-gerakan seperti dalam yoga/senam yang dibuat menyenangkan 15-20 menit (2-3x/minggu); Permainan yang melibatkan stretching 10 menit (3-4x/minggu).',
          'sample_weekly_plan': 'Setiap hari: Minimal 60 menit bermain aktif; 2-3x/minggu: Aktivitas terstruktur (olahraga tim, kelas); 2x/minggu: Aktivitas koordinasi dan keseimbangan; Libatkan berbagai elemen keterampilan motorik sepanjang minggu.',
          'warm_up_tips': 'Buat pemanasan dalam bentuk permainan; Fokus pada gerakan dasar seperti berlari, melompat, dan melempar; Tingkatkan antusiasme dan kesenangan.',
          'recovery_focus': 'Tidur 9-11 jam per malam; Istirahat aktif dengan aktivitas intensitas rendah; Variasikan jenis aktivitas untuk menghindari penggunaan otot yang sama secara berlebihan.',
          'intensity_guidance': 'Fokus pada kesenangan dan partisipasi daripada intensitas; Dorong anak untuk beristirahat saat lelah dan minum cukup air; Aktivitas harus bervariasi antara intensitas rendah hingga tinggi sepanjang hari.',
          'progression_tips': 'Kembangkan keterampilan fundamental (berlari, melompat, melempar); Tingkatkan kompleksitas permainan secara bertahap; Beri pengalaman pada berbagai jenis aktivitas.',
          'special_considerations': 'Selalu prioritaskan kesenangan dan sikap positif terhadap aktivitas fisik; Hindari spesialisasi olahraga terlalu dini; Sesuaikan aktivitas dengan perkembangan individual anak.',
        },
        
        // Program untuk kardio (fokus kesehatan jantung)
        {
          'category': 'kardio',
          'title': 'Kesehatan Kardiovaskular',
          'description': 'Program olahraga untuk meningkatkan dan menjaga kesehatan jantung dan pembuluh darah.',
          'cardio_program': 'Jalan cepat 30-45 menit (4-5x/minggu); Bersepeda intensitas rendah-sedang 30-40 menit (2-3x/minggu); Berenang atau aqua aerobik 30 menit (1-2x/minggu).',
          'strength_program': 'Latihan circuit intensitas rendah 20-30 menit (2x/minggu); Latihan resistance band 20 menit (2x/minggu); Latihan bodyweight dengan banyak repetisi dan intensitas rendah.',
          'flexibility_program': 'Stretching ringan 10-15 menit setiap hari; Yoga/tai chi 30-45 menit (2x/minggu) untuk manajemen stres dan fleksibilitas.',
          'sample_weekly_plan': 'Senin: Jalan cepat 30-45 menit; Selasa: Circuit training ringan + stretching; Rabu: Bersepeda atau aktivitas kardio pilihan; Kamis: Yoga/tai chi; Jumat: Jalan cepat + latihan resistance band; Sabtu: Berenang atau aqua aerobik; Minggu: Aktivitas rekreasi intensitas rendah.',
          'warm_up_tips': 'Pemanasan kardiovaskular bertahap 10-15 menit; Mulai dengan intensitas sangat rendah dan tingkatkan secara bertahap; Monitor detak jantung selama pemanasan.',
          'recovery_focus': 'Istirahat aktif dengan jalan santai; Manajemen stres melalui meditasi/pernapasan; Prioritaskan tidur berkualitas untuk pemulihan jantung.',
          'intensity_guidance': 'Kardio: 50-70% detak jantung maksimal (bisa menggunakan RPE 3-5 dari skala 10); Kekuatan: intensitas rendah, 12-15 repetisi, fokus pada pernapasan dan teknik.',
          'progression_tips': 'Tingkatkan durasi sebelum intensitas; Tambah 5-10% durasi setiap 2-3 minggu; Tambahkan variasi sebelum meningkatkan intensitas.',
          'special_considerations': 'Monitor gejala seperti nyeri dada, sesak napas berlebihan, atau pusing; Gunakan alat monitor detak jantung jika memungkinkan; Konsultasikan dengan dokter sebelum meningkatkan intensitas; Perhatikan obat-obatan yang memengaruhi detak jantung.',
        },
        
        // Program untuk diabetes
        {
          'category': 'diabetes',
          'title': 'Manajemen Diabetes',
          'description': 'Program olahraga untuk membantu mengontrol kadar gula darah dan meningkatkan sensitivitas insulin.',
          'cardio_program': 'Jalan cepat 30 menit (5-7x/minggu); Bersepeda intensitas sedang 20-30 menit (3x/minggu); Interval training ringan 15-20 menit (1-2x/minggu).',
          'strength_program': 'Latihan resistensi untuk kelompok otot besar 30 menit (2-3x/minggu); Circuit training intensitas sedang 20-30 menit (1-2x/minggu).',
          'flexibility_program': 'Stretching 10-15 menit setiap hari; Yoga 30-45 menit (2x/minggu) untuk manajemen stres dan fleksibilitas.',
          'sample_weekly_plan': 'Senin: Jalan cepat + latihan kekuatan; Selasa: Bersepeda statis; Rabu: Latihan kekuatan kelompok otot berbeda; Kamis: Interval training ringan; Jumat: Circuit training; Sabtu: Yoga; Minggu: Jalan cepat atau aktivitas rekreasi ringan.',
          'warm_up_tips': 'Pemanasan 10-15 menit dengan fokus pada aliran darah ke ekstremitas; Cek kadar gula darah sebelum, kadang selama, dan setelah olahraga; Siapkan sumber karbohidrat cepat (jus, permen) jika terjadi hipoglikemia.',
          'recovery_focus': 'Monitor kadar gula darah pasca latihan; Istirahat aktif dengan stretching dan mobilitas; Konsumsi protein dan karbohidrat kompleks pasca latihan.',
          'intensity_guidance': 'Kardio: 50-70% detak jantung maksimal, dapat bicara tapi tidak bernyanyi saat berolahraga; Kekuatan: intensitas sedang, 10-15 repetisi, dengan kontrol pernapasan.',
          'progression_tips': 'Tambah durasi secara bertahap 5-10% setiap 2 minggu; Konsisten lebih penting daripada intensitas; Sesuaikan program berdasarkan pembacaan gula darah.',
          'special_considerations': 'Selalu bawa meter gula darah dan sumber karbohidrat cepat; Gunakan alas kaki yang tepat dan periksa kaki secara rutin; Hindari olahraga saat kadar gula sangat tinggi (>250 mg/dL dengan ketosis) atau sangat rendah; Berolahraga di waktu yang sama setiap hari untuk membantu mengontrol insulin.',
        },
        
        // Program untuk masalah sendi/tulang
        {
          'category': 'sendi',
          'title': 'Kesehatan Sendi & Tulang',
          'description': 'Program olahraga untuk orang dengan masalah sendi atau tulang, fokus pada aktivitas low-impact dan penguatan.',
          'cardio_program': 'Berenang atau aqua fitness 30-45 menit (3x/minggu); Bersepeda statis dengan resistensi rendah 20-30 menit (2-3x/minggu); Jalan santai di permukaan rata 15-30 menit (3-4x/minggu).',
          'strength_program': 'Latihan penguatan otot sekitar sendi yang bermasalah 15-20 menit (3x/minggu); Latihan stabilitas core 15 menit (3-4x/minggu); Latihan resistance band intensitas rendah (2-3x/minggu).',
          'flexibility_program': 'Stretching lembut 10-15 menit setiap hari; Yoga atau pilates modifikasi 30-45 menit (2x/minggu); Latihan ROM (range of motion) 10 menit setiap hari.',
          'sample_weekly_plan': 'Senin: Aqua fitness + stretching; Selasa: Latihan penguatan ringan + core; Rabu: Bersepeda statis + ROM exercises; Kamis: Yoga modifikasi; Jumat: Latihan penguatan + core; Sabtu: Aktivitas di air atau jalan santai; Minggu: Stretching dan mobilitas.',
          'warm_up_tips': 'Pemanasan sangat penting, minimal 10-15 menit; Fokus pada peningkatan suhu sendi secara bertahap; Gunakan gerakan ROM tanpa beban sebelum aktivitas utama.',
          'recovery_focus': 'Aplikasi dingin jika ada tanda peradangan pasca latihan; Istirahat adekuat antara sesi latihan (48-72 jam untuk area yang sama); Pertimbangkan suplemen glukosamin/kondroitin sesuai anjuran dokter.',
          'intensity_guidance': 'Semua aktivitas harus bebas nyeri; Mulai dengan 40-50% kapasitas dan tingkatkan secara sangat bertahap; Gunakan skala nyeri 0-10, hentikan jika melebihi 3/10.',
          'progression_tips': 'Tingkatkan durasi dan repetisi sebelum intensitas; Tambah 5% volume setiap 1-2 minggu jika tidak ada peningkatan nyeri; Catat respons tubuh untuk penyesuaian program.',
          'special_considerations': 'Hindari aktivitas high-impact dan gerakan ekstrem; Modifikasi gerakan sesuai kebutuhan; Gunakan penyangga atau alat bantu jika dianjurkan; Konsultasi rutin dengan fisioterapis atau dokter ortopedi.',
        },
        
        // Program untuk ibu hamil
        {
          'category': 'prenatal',
          'title': 'Ibu Hamil & Pasca Melahirkan',
          'description': 'Program olahraga yang aman untuk ibu hamil dan pasca melahirkan dengan fokus pada kenyamanan dan kesehatan.',
          'cardio_program': 'Jalan 20-30 menit (4-5x/minggu); Berenang atau aqua aerobik khusus ibu hamil 30 menit (2-3x/minggu); Bersepeda statis dengan posisi nyaman 15-20 menit (2x/minggu).',
          'strength_program': 'Latihan kegel dan penguatan dasar panggul 10 menit (setiap hari); Latihan stabilitas core modifikasi 15 menit (3x/minggu); Resistance band untuk lengan dan kaki 15 menit (2x/minggu).',
          'flexibility_program': 'Prenatal yoga 30-45 menit (2-3x/minggu); Stretching lembut fokus pada area punggung dan pinggul 10-15 menit (setiap hari).',
          'sample_weekly_plan': 'Senin: Jalan santai + latihan penguatan ringan; Selasa: Prenatal yoga; Rabu: Aqua aerobik atau berenang; Kamis: Latihan dasar panggul + core; Jumat: Bersepeda statis atau jalan; Sabtu: Prenatal yoga; Minggu: Istirahat aktif dengan stretching ringan.',
          'warm_up_tips': 'Pemanasan lembut 10 menit; Fokus pada pernapasan dan mobilitas; Hindari gerakan tiba-tiba atau posisi terlentang setelah trimester pertama.',
          'recovery_focus': 'Tidur menyamping dengan bantal di antara lutut; Perhatikan postur saat istirahat; Jaga hidrasi yang baik sebelum, selama dan setelah aktivitas.',
          'intensity_guidance': 'Gunakan "talk test" - harus bisa berbicara dengan nyaman saat beraktivitas; Jaga intensitas rendah-sedang (40-60% kapasitas); Perhatikan tanda-tanda untuk berhenti (pusing, nyeri, kontraksi).',
          'progression_tips': 'Sesuaikan aktivitas dengan perkembangan kehamilan; Kurangi durasi dan intensitas seiring bertambahnya usia kehamilan; Fokus pada konsistensi, bukan peningkatan.',
          'special_considerations': 'Hindari posisi terlentang dan telungkup setelah trimester pertama; Hindari olahraga dengan risiko jatuh atau benturan; Gunakan pakaian dan alas kaki yang tepat; Konsultasikan program dengan dokter kandungan; Pasca melahirkan: mulai kembali secara sangat bertahap setelah mendapat izin dokter.',
        },
      ];
      
      // Gunakan batch untuk performa lebih baik
      final Batch batch = db.batch();
      for (var rec in recommendations) {
        batch.insert('exercise_recommendations', rec);
      }
      
      await batch.commit(noResult: true);
      debugPrint('Rekomendasi program olahraga berhasil ditambahkan');
      return true;
    } catch (e) {
      debugPrint('Error menambahkan rekomendasi program olahraga: $e');
      return false;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('exercise_app.db');
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
    // Tabel untuk menyimpan jawaban user untuk analisis kebutuhan olahraga
    await db.execute('''
    CREATE TABLE user_answers_exercise (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      usia TEXT,
      jenis_kelamin TEXT,
      tingkat_aktivitas TEXT,
      berat_badan REAL,
      tinggi_badan REAL,
      waktu_tersedia TEXT,
      kondisi_kesehatan TEXT,
      tujuan_olahraga TEXT,
      preferensi_olahraga TEXT,
      level_kebugaran TEXT,
      akses_fasilitas TEXT,
      riwayat_cedera TEXT,
      created_at TEXT
    )
    ''');
    
    // Tabel untuk menyimpan hasil analisis kebutuhan olahraga
    await db.execute('''
    CREATE TABLE exercise_analysis_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_answer_id INTEGER,
      recommended_exercise_minutes INTEGER,
      recommended_frequency INTEGER,
      recommended_intensity TEXT,
      bmr REAL,
      tdee REAL,
      bmi REAL,
      main_category TEXT NOT NULL,
      secondary_category TEXT,
      recovery_time_needed INTEGER,
      target_heart_rate_min INTEGER,
      target_heart_rate_max INTEGER,
      calories_burn_estimate INTEGER,
      exercise_level TEXT,
      created_at TEXT,
      FOREIGN KEY (user_answer_id) REFERENCES user_answers_exercise (id)
    )
    ''');
    
    // Tabel untuk rekomendasi program olahraga berdasarkan kategori
    await db.execute('''
    CREATE TABLE exercise_recommendations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category TEXT UNIQUE NOT NULL,
      title TEXT,
      description TEXT,
      cardio_program TEXT,
      strength_program TEXT,
      flexibility_program TEXT,
      sample_weekly_plan TEXT,
      warm_up_tips TEXT,
      recovery_focus TEXT,
      intensity_guidance TEXT,
      progression_tips TEXT,
      special_considerations TEXT
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
        // Simpan jawaban baru
        insertId = await txn.insert('user_answers_exercise', normalizedAnswers);
      });
      
      debugPrint('Jawaban user untuk analisis olahraga berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan jawaban user analisis olahraga: $e');
      rethrow;
    }
  }

  // Fungsi untuk menyimpan hasil analisis kebutuhan olahraga
  Future<int> saveAnalysisResult(int userAnswerId, Map<String, dynamic> result) async {
    final db = await database;
    
    try {
      final Map<String, dynamic> resultData = {
        'user_answer_id': userAnswerId,
        'recommended_exercise_minutes': result['recommendedExerciseMinutes'],
        'recommended_frequency': result['recommendedFrequency'],
        'recommended_intensity': result['recommendedIntensity'],
        'bmr': result['bmr'],
        'tdee': result['tdee'],
        'bmi': result['bmi'],
        'main_category': result['mainCategory'],
        'secondary_category': result['secondaryCategory'],
        'recovery_time_needed': result['recoveryTimeNeeded'],
        'target_heart_rate_min': result['targetHeartRate']['min'],
        'target_heart_rate_max': result['targetHeartRate']['max'],
        'calories_burn_estimate': result['caloriesBurnEstimate'],
        'exercise_level': result['exerciseLevel'],
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final int insertId = await db.insert('exercise_analysis_results', resultData);
      debugPrint('Hasil analisis kebutuhan olahraga berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan hasil analisis kebutuhan olahraga: $e');
      rethrow;
    }
  }

  // Fungsi untuk mendapatkan rekomendasi program berdasarkan kategori
  Future<Map<String, dynamic>?> getRecommendationByCategory(String category) async {
    final db = await database;
    
    try {
      // Pastikan tabel rekomendasi tidak kosong
      await addExerciseRecommendations();
      
      final List<Map<String, dynamic>> results = await db.query(
        'exercise_recommendations',
        where: 'category = ?',
        whereArgs: [category],
      );
      
      if (results.isEmpty) {
        // Jika tidak ditemukan rekomendasi spesifik, kembalikan rekomendasi untuk dewasa aktif
        return (await db.query(
          'exercise_recommendations',
          where: 'category = ?',
          whereArgs: ['dewasa_aktif'],
        )).first;
      }
      
      return results.first;
    } catch (e) {
      debugPrint('Error mendapatkan rekomendasi program olahraga: $e');
      return null;
    }
  }

  // Fungsi untuk mendapatkan hasil analisis kebutuhan olahraga terbaru
  Future<Map<String, dynamic>?> getLatestAnalysisResult() async {
    final db = await database;
    
    try {
      // Ambil hasil analisis kebutuhan olahraga terbaru
      final List<Map<String, dynamic>> analysisResults = await db.query(
        'exercise_analysis_results',
        orderBy: 'created_at DESC',
        limit: 1
      );
      
      if (analysisResults.isEmpty) {
        return null;
      }
      
      final analysis = analysisResults.first;
      final String mainCategory = analysis['main_category'];
      
      // Ambil rekomendasi program berdasarkan kategori
      final recommendation = await getRecommendationByCategory(mainCategory);
      
      // Rekonstruksi target heart rate
      final Map<String, int> targetHeartRate = {
        'min': analysis['target_heart_rate_min'],
        'max': analysis['target_heart_rate_max']
      };
      
      // Tambahkan target heart rate ke analisis
      final finalAnalysis = {...analysis};
      finalAnalysis['targetHeartRate'] = targetHeartRate;
      
      return {
        'analysis': finalAnalysis,
        'recommendation': recommendation,
      };
    } catch (e) {
      debugPrint('Error mendapatkan hasil analisis kebutuhan olahraga terbaru: $e');
      return null;
    }
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}