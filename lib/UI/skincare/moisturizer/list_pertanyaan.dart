import 'package:flutter/cupertino.dart';

class MoisturizerQuestions {
  // Daftar pertanyaan untuk rekomendasi moisturizer
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'jenis_kulit',
      'question': 'Apa jenis kulit wajah Anda?',
      'icon': CupertinoIcons.person_crop_circle,
      'description': 'Jenis kulit menentukan tekstur dan kandungan moisturizer yang cocok untuk Anda',
      'weight': 10, // Bobot: 10/10
      'options': ['Normal', 'Berminyak', 'Kering', 'Kombinasi', 'Sensitif'],
    },
    {
      'id': 'tingkat_hidrasi',
      'question': 'Seberapa kering kulit Anda saat ini?',
      'icon': CupertinoIcons.drop,
      'description': 'Tingkat kekeringan kulit menentukan kebutuhan hidrasi dari moisturizer',
      'weight': 9, // Bobot: 9/10
      'options': ['Sangat kering', 'Cukup kering', 'Normal', 'Cenderung berminyak', 'Sangat berminyak'],
    },
    {
      'id': 'usia',
      'question': 'Berapa usia Anda saat ini?',
      'icon': CupertinoIcons.calendar,
      'description': 'Usia menentukan kebutuhan anti-aging dan nutrisi kulit yang berbeda',
      'weight': 8, // Bobot: 8/10
      'options': ['< 18 tahun', '18-25 tahun', '26-35 tahun', '36-45 tahun', '> 45 tahun'],
    },
    {
      'id': 'jerawat',
      'question': 'Apakah Anda memiliki masalah jerawat?',
      'icon': CupertinoIcons.bandage,
      'description': 'Masalah jerawat memerlukan moisturizer non-comedogenic dengan bahan yang menenangkan',
      'weight': 8, // Bobot: 8/10
      'options': ['Ya, banyak', 'Ya, sedikit', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'sensitifitas',
      'question': 'Seberapa sensitif kulit Anda terhadap produk baru?',
      'icon': CupertinoIcons.exclamationmark_circle,
      'description': 'Kulit sensitif membutuhkan formula moisturizer yang lebih lembut dan tanpa pewangi',
      'weight': 9, // Bobot: 9/10
      'options': ['Sangat sensitif', 'Cukup sensitif', 'Kadang sensitif', 'Jarang sensitif', 'Tidak sensitif'],
    },
    {
      'id': 'hiperpigmentasi',
      'question': 'Apakah Anda memiliki masalah noda hitam atau hiperpigmentasi?',
      'icon': CupertinoIcons.doc_text_search,
      'description': 'Hiperpigmentasi membutuhkan moisturizer dengan kandungan pencerah kulit',
      'weight': 7, // Bobot: 7/10
      'options': ['Ya, banyak', 'Ya, sedikit', 'Mulai muncul', 'Hampir tidak ada', 'Tidak ada sama sekali'],
    },
    {
      'id': 'kulit_kusam',
      'question': 'Apakah kulit wajah Anda terlihat kusam?',
      'icon': CupertinoIcons.sun_max,
      'description': 'Kulit kusam membutuhkan moisturizer dengan kandungan vitamin dan brightening agent',
      'weight': 6, // Bobot: 6/10
      'options': ['Ya, sangat kusam', 'Ya, cukup kusam', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'garis_halus',
      'question': 'Apakah Anda memiliki garis halus atau kerutan?',
      'icon': CupertinoIcons.arrow_2_circlepath,
      'description': 'Garis halus membutuhkan moisturizer dengan kandungan anti-aging',
      'weight': 7, // Bobot: 7/10
      'options': ['Ya, terlihat jelas', 'Ya, mulai terlihat', 'Mulai muncul', 'Hampir tidak ada', 'Tidak ada sama sekali'],
    },
    {
      'id': 'paparan_matahari',
      'question': 'Seberapa sering Anda terpapar sinar matahari langsung?',
      'icon': CupertinoIcons.sun_haze,
      'description': 'Paparan UV tinggi membutuhkan moisturizer dengan antioksidan yang melindungi kulit',
      'weight': 7, // Bobot: 7/10
      'options': ['Sangat sering', 'Sering', 'Cukup sering', 'Jarang', 'Sangat jarang'],
    },
    {
      'id': 'preferensi_tekstur',
      'question': 'Tekstur moisturizer apa yang Anda sukai?',
      'icon': CupertinoIcons.hand_raised,
      'description': 'Preferensi tekstur untuk kenyamanan penggunaan sehari-hari',
      'weight': 6, // Bobot: 6/10
      'options': ['Gel ringan', 'Cream', 'Lotion', 'Water cream', 'Heavy cream'],
    },
    {
      'id': 'cuaca',
      'question': 'Bagaimana cuaca di tempat tinggal Anda saat ini?',
      'icon': CupertinoIcons.cloud_sun,
      'description': 'Cuaca mempengaruhi kebutuhan hidrasi dan jenis moisturizer yang sesuai',
      'weight': 5, // Bobot: 5/10
      'options': ['Sangat kering', 'Panas dan lembab', 'Dingin', 'Berubah-ubah', 'Sedang'],
    },
    {
      'id': 'waktu_penggunaan',
      'question': 'Kapan Anda berencana menggunakan moisturizer ini?',
      'icon': CupertinoIcons.clock,
      'description': 'Waktu penggunaan menentukan jenis formula yang dibutuhkan',
      'weight': 4, // Bobot: 4/10
      'options': ['Pagi hari', 'Malam hari', 'Pagi dan malam', 'Sepanjang hari', 'Situasional'],
    },
    {
      'id': 'budget',
      'question': 'Berapa budget Anda untuk moisturizer?',
      'icon': CupertinoIcons.money_dollar_circle,
      'description': 'Budget menentukan rentang produk yang akan direkomendasikan',
      'weight': 4, // Bobot: 4/10
      'options': ['< Rp100.000', 'Rp100.000 - Rp200.000', 'Rp200.000 - Rp300.000', 'Rp300.000 - Rp500.000', '> Rp500.000'],
    },
    {
      'id': 'tambahan_spf',
      'question': 'Apakah Anda ingin moisturizer yang mengandung SPF?',
      'icon': CupertinoIcons.shield_lefthalf_fill,
      'description': 'Moisturizer dengan SPF memberikan perlindungan tambahan dari sinar matahari',
      'weight': 5, // Bobot: 5/10
      'options': ['Ya, wajib', 'Ya, lebih baik ada', 'Tidak masalah', 'Lebih baik tidak ada', 'Tidak perlu'],
    },
    {
      'id': 'bahan_alami',
      'question': 'Apakah Anda lebih menyukai moisturizer dengan bahan alami?',
      'icon': CupertinoIcons.leaf_arrow_circlepath,
      'description': 'Preferensi terhadap produk dengan formula alami atau organik',
      'weight': 3, // Bobot: 3/10
      'options': ['Ya, sangat penting', 'Ya, lebih disukai', 'Tidak masalah', 'Tidak terlalu penting', 'Tidak penting sama sekali'],
    },
  ];

  // Filter pertanyaan yang aktif berdasarkan jawaban sebelumnya
  static List<Map<String, dynamic>> activeQuestions(Map<String, String> answers) {
    return questions.where((q) {
      String questionId = q['id'];
      
      // Logic conditional untuk pertanyaan yang perlu dilewati
      bool shouldSkip = false;
      
      // Jika user berusia < 25 tahun, skip pertanyaan garis halus
      if (questionId == 'garis_halus' && answers.containsKey('usia') && 
          (answers['usia'] == '< 18 tahun' || answers['usia'] == '18-25 tahun')) {
        shouldSkip = true;
      }
      
      // Jika user memiliki kulit sangat berminyak, skip pertanyaan tingkat hidrasi
      if (questionId == 'tingkat_hidrasi' && answers.containsKey('jenis_kulit') && 
          answers['jenis_kulit'] == 'Berminyak') {
        shouldSkip = true;
      }
      
      // Jika user tidak pernah terpapar sinar matahari, skip pertanyaan SPF
      if (questionId == 'tambahan_spf' && answers.containsKey('paparan_matahari') && 
          answers['paparan_matahari'] == 'Sangat jarang') {
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
    if (questionId == 'garis_halus' && answers.containsKey('usia') && 
        (answers['usia'] == '< 18 tahun' || answers['usia'] == '18-25 tahun')) {
      return false;
    }
    
    if (questionId == 'tingkat_hidrasi' && answers.containsKey('jenis_kulit') && 
        answers['jenis_kulit'] == 'Berminyak') {
      return false;
    }
    
    if (questionId == 'tambahan_spf' && answers.containsKey('paparan_matahari') && 
        answers['paparan_matahari'] == 'Sangat jarang') {
      return false;
    }
    
    return true;
  }
  
  // Hitung skor preferensi berdasarkan jawaban
  static Map<String, dynamic> calculateProductPreference(Map<String, String> answers) {
    // Inisialisasi skor untuk setiap kategori produk
    Map<String, double> categoryScores = {
      'untuk_kulit_berminyak': 0,
      'untuk_kulit_kering': 0,
      'untuk_kulit_sensitif': 0,
      'untuk_anti_jerawat': 0,
      'untuk_anti_aging': 0,
      'untuk_pencerah': 0,
      'untuk_hidrasi_intensif': 0,
      'untuk_kulit_kombinasi': 0,
      'untuk_bahan_alami': 0,
    };
    
    // Evaluasi jawaban dan kalkulasi skor kategori
    if (answers.containsKey('jenis_kulit')) {
      switch (answers['jenis_kulit']) {
        case 'Berminyak':
          categoryScores.update('untuk_kulit_berminyak', (v) => v + 10);
          break;
        case 'Kering':
          categoryScores.update('untuk_kulit_kering', (v) => v + 10);
          categoryScores.update('untuk_hidrasi_intensif', (v) => v + 5);
          break;
        case 'Sensitif':
          categoryScores.update('untuk_kulit_sensitif', (v) => v + 10);
          break;
        case 'Kombinasi':
          categoryScores.update('untuk_kulit_kombinasi', (v) => v + 10);
          break;
      }
    }

    if (answers.containsKey('tingkat_hidrasi')) {
      final hidrasi = answers['tingkat_hidrasi'];
      if (hidrasi == 'Sangat kering' || hidrasi == 'Cukup kering') {
        categoryScores.update('untuk_hidrasi_intensif', (v) => v + 9);
        categoryScores.update('untuk_kulit_kering', (v) => v + 6);
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
        categoryScores.update('untuk_kulit_berminyak', (v) => v + 3);
      }
    }

    if (answers.containsKey('sensitifitas')) {
      final s = answers['sensitifitas'];
      if (s == 'Sangat sensitif' || s == 'Cukup sensitif') {
        categoryScores.update('untuk_kulit_sensitif', (v) => v + 9);
      }
    }

    if (answers.containsKey('hiperpigmentasi')) {
      final h = answers['hiperpigmentasi'];
      if (h == 'Ya, banyak' || h == 'Ya, sedikit' || h == 'Mulai muncul') {
        categoryScores.update('untuk_pencerah', (v) => v + 7);
      }
    }

    if (answers.containsKey('kulit_kusam')) {
      final k = answers['kulit_kusam'];
      if (k == 'Ya, sangat kusam' || k == 'Ya, cukup kusam') {
        categoryScores.update('untuk_pencerah', (v) => v + 6);
      }
    }

    if (answers.containsKey('garis_halus')) {
      final g = answers['garis_halus'];
      if (g == 'Ya, terlihat jelas' || g == 'Ya, mulai terlihat' || g == 'Mulai muncul') {
        categoryScores.update('untuk_anti_aging', (v) => v + 7);
      }
    }

    if (answers.containsKey('paparan_matahari')) {
      final p = answers['paparan_matahari'];
      if (p == 'Sangat sering' || p == 'Sering') {
        // Perlu perlindungan tambahan
        categoryScores.update('untuk_pencerah', (v) => v + 3);
        categoryScores.update('untuk_anti_aging', (v) => v + 3);
      }
    }
    
    if (answers.containsKey('preferensi_tekstur')) {
      final t = answers['preferensi_tekstur'];
      if (t == 'Gel ringan' || t == 'Water cream') {
        categoryScores.update('untuk_kulit_berminyak', (v) => v + 4);
      } else if (t == 'Heavy cream') {
        categoryScores.update('untuk_kulit_kering', (v) => v + 4);
        categoryScores.update('untuk_hidrasi_intensif', (v) => v + 3);
      }
    }
    
    if (answers.containsKey('cuaca')) {
      final c = answers['cuaca'];
      if (c == 'Sangat kering' || c == 'Dingin') {
        categoryScores.update('untuk_hidrasi_intensif', (v) => v + 5);
      } else if (c == 'Panas dan lembab') {
        categoryScores.update('untuk_kulit_berminyak', (v) => v + 3);
      }
    }
    
    if (answers.containsKey('bahan_alami')) {
      final b = answers['bahan_alami'];
      if (b == 'Ya, sangat penting' || b == 'Ya, lebih disukai') {
        categoryScores.update('untuk_bahan_alami', (v) => v + 3);
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
        productType = 'Moisturizer untuk Kulit Berminyak';
        break;
      case 'untuk_kulit_kering':
        productType = 'Moisturizer untuk Kulit Kering';
        break;
      case 'untuk_kulit_sensitif':
        productType = 'Moisturizer untuk Kulit Sensitif';
        break;
      case 'untuk_anti_jerawat':
        productType = 'Moisturizer Anti Jerawat';
        break;
      case 'untuk_anti_aging':
        productType = 'Moisturizer Anti Aging';
        break;
      case 'untuk_pencerah':
        productType = 'Moisturizer Pencerah Wajah';
        break;
      case 'untuk_hidrasi_intensif':
        productType = 'Moisturizer Hidrasi Intensif';
        break;
      case 'untuk_kulit_kombinasi':
        productType = 'Moisturizer untuk Kulit Kombinasi';
        break;
      case 'untuk_bahan_alami':
        productType = 'Moisturizer dengan Bahan Alami';
        break;
      default:
        productType = 'Moisturizer untuk Kulit Normal';
    }
    
    // Hitung persentase kecocokan
    double totalPossibleScore = 0;
    double userScore = 0;
    
    questions.forEach((question) {
      // Perbaikan untuk mengatasi error: menggunakan toDouble() untuk konversi
      totalPossibleScore += (question['weight'] as int).toDouble();
    });
    
    // Skor pengguna berdasarkan kategori tertinggi
    userScore = maxScore;
    
    // Persentase kecocokan
    double matchPercentage = (userScore / totalPossibleScore) * 100;
    
    // Gunakan budget untuk filter rekomendasi
    String budgetRange = answers['budget'] ?? 'Semua harga';
    
    return {
      'productType': productType,
      'topCategory': topCategory,
      'matchPercentage': matchPercentage,
      'categoryScores': categoryScores,
      'budgetRange': budgetRange,
    };
  }
}