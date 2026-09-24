import 'package:flutter/cupertino.dart';

class SunscreenQuestions {
  // Daftar pertanyaan untuk rekomendasi sunscreen
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'jenis_kulit',
      'question': 'Apa jenis kulit wajah Anda?',
      'icon': CupertinoIcons.person_crop_circle,
      'description': 'Jenis kulit menentukan kandungan sunscreen yang cocok untuk Anda',
      'weight': 10, // Bobot: 10/10
      'options': ['Normal', 'Berminyak', 'Kering', 'Kombinasi', 'Sensitif'],
    },
    {
      'id': 'usia',
      'question': 'Berapa usia Anda saat ini?',
      'icon': CupertinoIcons.calendar,
      'description': 'Usia menentukan kebutuhan perlindungan UV dan anti-aging yang berbeda',
      'weight': 8, // Bobot: 8/10
      'options': ['< 18 tahun', '18-25 tahun', '26-35 tahun', '36-45 tahun', '> 45 tahun'],
    },
    {
      'id': 'jerawat',
      'question': 'Apakah Anda memiliki masalah jerawat?',
      'icon': CupertinoIcons.bandage,
      'description': 'Masalah jerawat memerlukan sunscreen non-comedogenic',
      'weight': 8, // Bobot: 8/10
      'options': ['Ya, banyak', 'Ya, sedikit', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'sensitifitas',
      'question': 'Seberapa sensitif kulit Anda terhadap produk baru?',
      'icon': CupertinoIcons.exclamationmark_circle,
      'description': 'Kulit sensitif membutuhkan formula sunscreen yang lebih lembut',
      'weight': 9, // Bobot: 9/10
      'options': ['Sangat sensitif', 'Cukup sensitif', 'Kadang sensitif', 'Jarang sensitif', 'Tidak sensitif'],
    },
    {
      'id': 'kulit_kusam',
      'question': 'Apakah kulit wajah Anda terlihat kusam?',
      'icon': CupertinoIcons.sun_max,
      'description': 'Kusam bisa disebabkan oleh efek sinar UV dan polusi',
      'weight': 6, // Bobot: 6/10
      'options': ['Ya, sangat kusam', 'Ya, cukup kusam', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'paparan_sinar',
      'question': 'Seberapa sering Anda terpapar sinar matahari?',
      'icon': CupertinoIcons.sun_haze,
      'description': 'Frekuensi paparan UV menentukan tingkat SPF yang dibutuhkan',
      'weight': 10, // Bobot: 10/10
      'options': ['Sangat sering', 'Sering', 'Cukup sering', 'Jarang', 'Sangat jarang'],
    },
    {
      'id': 'aktivitas_outdoor',
      'question': 'Apakah Anda sering beraktivitas di luar ruangan?',
      'icon': CupertinoIcons.person_2_fill,
      'description': 'Aktivitas outdoor membutuhkan sunscreen yang lebih tahan lama',
      'weight': 8, // Bobot: 8/10
      'options': ['Ya, sangat sering', 'Sering', 'Terkadang', 'Jarang', 'Hampir tidak pernah'],
    },
    {
      'id': 'berenang',
      'question': 'Apakah Anda berenang atau berkeringat banyak saat menggunakan sunscreen?',
      'icon': CupertinoIcons.drop_fill,
      'description': 'Berenang/berkeringat membutuhkan sunscreen waterproof',
      'weight': 7, // Bobot: 7/10
      'options': ['Ya, sangat sering', 'Sering', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'penggunaan_makeup',
      'question': 'Apakah Anda menggunakan makeup di atas sunscreen?',
      'icon': CupertinoIcons.wand_stars,
      'description': 'Penggunaan makeup memerlukan sunscreen yang bisa jadi base makeup',
      'weight': 6, // Bobot: 6/10
      'options': ['Ya, selalu', 'Sering', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'white_cast',
      'question': 'Apakah Anda terganggu dengan white cast (lapisan putih) pada sunscreen?',
      'icon': CupertinoIcons.eyedropper,
      'description': 'White cast kadang muncul pada sunscreen berbahan mineral',
      'weight': 7, // Bobot: 7/10
      'options': ['Ya, sangat terganggu', 'Cukup terganggu', 'Netral', 'Tidak terlalu masalah', 'Tidak masalah sama sekali'],
    },
    {
      'id': 'budget',
      'question': 'Berapa budget Anda untuk sunscreen?',
      'icon': CupertinoIcons.money_dollar_circle,
      'description': 'Budget menentukan rentang produk yang akan direkomendasikan',
      'weight': 4, // Bobot: 4/10
      'options': ['< Rp100.000', 'Rp100.000 - Rp200.000', 'Rp200.000 - Rp300.000', 'Rp300.000 - Rp500.000', '> Rp500.000'],
    },
    {
      'id': 'preferensi_tekstur',
      'question': 'Tekstur sunscreen apa yang Anda sukai?',
      'icon': CupertinoIcons.hand_raised,
      'description': 'Preferensi tekstur untuk kenyamanan penggunaan',
      'weight': 5, // Bobot: 5/10
      'options': ['Gel', 'Cream', 'Lotion', 'Essence', 'Milk/Fluid'],
    },
    {
      'id': 'spf_preference',
      'question': 'Anda lebih menyukai sunscreen dengan SPF level berapa?',
      'icon': CupertinoIcons.shield_lefthalf_fill,
      'description': 'SPF level menentukan tingkat perlindungan terhadap UVB',
      'weight': 7, // Bobot: 7/10
      'options': ['SPF 30', 'SPF 30-50', 'SPF 50+', 'PA+++ atau PA++++', 'Tidak ada preferensi'],
    },
    {
      'id': 'reapply',
      'question': 'Apakah Anda biasa mengaplikasikan ulang sunscreen sepanjang hari?',
      'icon': CupertinoIcons.refresh,
      'description': 'Frekuensi reapply mempengaruhi kebutuhan sunscreen Anda',
      'weight': 5, // Bobot: 5/10
      'options': ['Ya, setiap 2-3 jam', 'Ya, sekali tambahan', 'Hanya jika outdoor lama', 'Jarang', 'Tidak pernah'],
    },
  ];

  // Filter pertanyaan yang aktif berdasarkan jawaban sebelumnya
  static List<Map<String, dynamic>> activeQuestions(Map<String, String> answers) {
    return questions.where((q) {
      final String questionId = q['id'];
      
      // Logic conditional untuk pertanyaan yang perlu dilewati
      bool shouldSkip = false;
      
      // Jika user jarang/tidak pernah berenang, skip pertanyaan waterproof
      if (questionId == 'berenang' && answers.containsKey('aktivitas_outdoor') && 
          (answers['aktivitas_outdoor'] == 'Jarang' || answers['aktivitas_outdoor'] == 'Hampir tidak pernah')) {
        shouldSkip = true;
      }
      
      // Jika user tidak pakai makeup, skip pertanyaan makeup base
      if (questionId == 'penggunaan_makeup' && answers.containsKey('white_cast') && 
          answers['white_cast'] == 'Tidak masalah sama sekali') {
        shouldSkip = true;
      }
      
      if (shouldSkip) {
        return false;
      }
      
      return true;
    }).toList();
  }

  // Mendapatkan icon berdasarkan ID pertanyaan
  static IconData getIconForQuestion(String questionId) {
    final question = questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {'icon': CupertinoIcons.question_circle},
    );
    
    return question['icon'] as IconData;
  }

  // Mendapatkan deskripsi berdasarkan ID pertanyaan
  static String getDescriptionForQuestion(String questionId) {
    final question = questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {'description': 'Tidak ada deskripsi'},
    );
    
    return question['description'] as String;
  }
  
  // Mendapatkan pertanyaan berdasarkan ID
  static String getQuestionText(String questionId) {
    final question = questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {'question': 'Pertanyaan tidak ditemukan'},
    );
    
    return question['question'] as String;
  }
  
  // Mendapatkan bobot pertanyaan
  static int getQuestionWeight(String questionId) {
    final question = questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {'weight': 0},
    );
    
    return question['weight'] as int;
  }
  
  // Mendapatkan opsi jawaban berdasarkan ID pertanyaan
  static List<String> getOptionsForQuestion(String questionId) {
    final question = questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {'options': <String>[]},
    );
    
    return List<String>.from(question['options'] ?? []);
  }
  
  // Evaluasi kondisional untuk pertanyaan
  static bool shouldShowQuestion(String questionId, Map<String, String> answers) {
    // Logic yang sama dengan activeQuestions
    if (questionId == 'berenang' && answers.containsKey('aktivitas_outdoor') && 
        (answers['aktivitas_outdoor'] == 'Jarang' || answers['aktivitas_outdoor'] == 'Hampir tidak pernah')) {
      return false;
    }
    
    if (questionId == 'penggunaan_makeup' && answers.containsKey('white_cast') && 
        answers['white_cast'] == 'Tidak masalah sama sekali') {
      return false;
    }
    
    return true;
  }
  
  // Hitung skor preferensi berdasarkan jawaban
  static Map<String, dynamic> calculateProductPreference(Map<String, String> answers) {
    // Inisialisasi skor untuk setiap kategori produk
    final Map<String, double> categoryScores = {
      'untuk_kulit_berminyak': 0,
      'untuk_kulit_kering': 0,
      'untuk_kulit_sensitif': 0,
      'untuk_anti_jerawat': 0,
      'untuk_anti_aging': 0,
      'untuk_no_white_cast': 0,
      'untuk_waterproof': 0,
      'untuk_makeup_base': 0,
      'untuk_wajah_dan_tubuh': 0,
    };
    
    // Asumsi: categoryScores sudah ter-inisialisasi semua key-nya ke 0.
    if (answers.containsKey('jenis_kulit')) {
      switch (answers['jenis_kulit']) {
        case 'Berminyak':
          categoryScores.update('untuk_kulit_berminyak', (v) => v + 10);
          break;
        case 'Kering':
          categoryScores.update('untuk_kulit_kering', (v) => v + 10);
          break;
        case 'Sensitif':
          categoryScores.update('untuk_kulit_sensitif', (v) => v + 10);
          break;
        case 'Kombinasi':
          categoryScores.update('untuk_kulit_berminyak', (v) => v + 5);
          categoryScores.update('untuk_kulit_kering', (v) => v + 5);
          break;
      }
    }

    if (answers.containsKey('usia')) {
      final usia = answers['usia'];
      if (usia == '36-45 tahun' || usia == '> 45 tahun') {
        categoryScores.update('untuk_anti_aging', (v) => v + 8);
      }
    }

    if (answers.containsKey('jerawat')) {
      final jerawat = answers['jerawat'];
      if (jerawat == 'Ya, banyak' || jerawat == 'Ya, sedikit') {
        categoryScores.update('untuk_anti_jerawat', (v) => v + 8);
      }
    }

    if (answers.containsKey('sensitifitas')) {
      final s = answers['sensitifitas'];
      if (s == 'Sangat sensitif' || s == 'Cukup sensitif') {
        categoryScores.update('untuk_kulit_sensitif', (v) => v + 9);
      }
    }

    if (answers.containsKey('paparan_sinar')) {
      final p = answers['paparan_sinar'];
      if (p == 'Sangat sering' || p == 'Sering') {
        // Level SPF tinggi dan perlindungan lebih baik
        categoryScores.update('untuk_anti_aging', (v) => v + 5);
      }
    }

    if (answers.containsKey('aktivitas_outdoor')) {
      final a = answers['aktivitas_outdoor'];
      if (a == 'Ya, sangat sering' || a == 'Sering') {
        categoryScores.update('untuk_waterproof', (v) => v + 6);
        categoryScores.update('untuk_wajah_dan_tubuh', (v) => v + 4);
      }
    }

    if (answers.containsKey('berenang')) {
      final b = answers['berenang'];
      if (b == 'Ya, sangat sering' || b == 'Sering') {
        categoryScores.update('untuk_waterproof', (v) => v + 7);
      }
    }

    if (answers.containsKey('penggunaan_makeup')) {
      final m = answers['penggunaan_makeup'];
      if (m == 'Ya, selalu' || m == 'Sering') {
        categoryScores.update('untuk_makeup_base', (v) => v + 6);
      }
    }

    if (answers.containsKey('white_cast')) {
      final w = answers['white_cast'];
      if (w == 'Ya, sangat terganggu' || w == 'Cukup terganggu') {
        categoryScores.update('untuk_no_white_cast', (v) => v + 7);
      }
    }

    // Temukan kategori dengan skor tertinggi
    String topCategory = '';
    double maxScore = 0;
    
    categoryScores.forEach((category, score) {
      if (score > maxScore) {
        maxScore = score;
        topCategory = category;
      }
    });
    
    // Tentukan tipe produk berdasarkan kategori tertinggi
    String productType;
    switch (topCategory) {
      case 'untuk_kulit_berminyak':
        productType = 'Sunscreen untuk Kulit Berminyak';
        break;
      case 'untuk_kulit_kering':
        productType = 'Sunscreen untuk Kulit Kering';
        break;
      case 'untuk_kulit_sensitif':
        productType = 'Sunscreen untuk Kulit Sensitif';
        break;
      case 'untuk_anti_jerawat':
        productType = 'Sunscreen Anti Jerawat';
        break;
      case 'untuk_anti_aging':
        productType = 'Sunscreen Anti Aging';
        break;
      case 'untuk_no_white_cast':
        productType = 'Sunscreen Tanpa White Cast';
        break;
      case 'untuk_waterproof':
        productType = 'Sunscreen Waterproof';
        break;
      case 'untuk_makeup_base':
        productType = 'Sunscreen Base Makeup';
        break;
      case 'untuk_wajah_dan_tubuh':
        productType = 'Sunscreen Wajah dan Tubuh';
        break;
      default:
        productType = 'Sunscreen untuk Kulit Normal';
    }
    
    // Hitung persentase kecocokan
    double totalPossibleScore = 0;
    double userScore = 0;
    
    for (var question in questions) {
      // Perbaikan untuk mengatasi error: menggunakan toDouble() untuk konversi
      totalPossibleScore += (question['weight'] as int).toDouble();
    }
    
    // Skor pengguna berdasarkan kategori tertinggi
    userScore = maxScore;
    
    // Persentase kecocokan
    final double matchPercentage = (userScore / totalPossibleScore) * 100;
    
    // Gunakan budget untuk filter rekomendasi
    final String budgetRange = answers['budget'] ?? 'Semua harga';
    
    return {
      'productType': productType,
      'topCategory': topCategory,
      'matchPercentage': matchPercentage,
      'categoryScores': categoryScores,
      'budgetRange': budgetRange,
    };
  }
}