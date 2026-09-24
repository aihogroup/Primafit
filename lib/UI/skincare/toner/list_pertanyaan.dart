import 'package:flutter/cupertino.dart';

class TonerQuestions {
  // Daftar pertanyaan untuk rekomendasi toner
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'jenis_kulit',
      'question': 'Apa jenis kulit wajah Anda?',
      'icon': CupertinoIcons.person_crop_circle,
      'description': 'Jenis kulit menentukan kandungan toner yang cocok untuk Anda',
      'weight': 10, // Bobot: 10/10
      'options': ['Normal', 'Berminyak', 'Kering', 'Kombinasi', 'Sensitif'],
    },
    {
      'id': 'masalah_kulit',
      'question': 'Apa masalah kulit utama yang ingin Anda atasi?',
      'icon': CupertinoIcons.bandage,
      'description': 'Fokus utama dari toner yang Anda butuhkan',
      'weight': 9, // Bobot: 9/10
      'options': ['Kulit berminyak', 'Kulit kering', 'Kulit kusam', 'Tekstur tidak rata', 'Hiperpigmentasi'],
    },
    {
      'id': 'sensitifitas',
      'question': 'Seberapa sensitif kulit Anda?',
      'icon': CupertinoIcons.exclamationmark_circle,
      'description': 'Kulit sensitif membutuhkan formula toner yang lebih lembut',
      'weight': 8, // Bobot: 8/10
      'options': ['Sangat sensitif', 'Cukup sensitif', 'Kadang sensitif', 'Jarang sensitif', 'Tidak sensitif'],
    },
    {
      'id': 'iritasi_alkohol',
      'question': 'Apakah kulit Anda mudah teriritasi oleh alkohol dalam skincare?',
      'icon': CupertinoIcons.drop_fill,
      'description': 'Banyak toner mengandung alkohol yang bisa menyebabkan iritasi pada kulit tertentu',
      'weight': 7, // Bobot: 7/10
      'options': ['Ya, selalu', 'Sering', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'iritasi_wewangian',
      'question': 'Apakah kulit Anda bereaksi negatif terhadap produk dengan wewangian?',
      'icon': CupertinoIcons.scribble,
      'description': 'Fragrance sering menjadi pemicu iritasi pada kulit sensitif',
      'weight': 7, // Bobot: 7/10
      'options': ['Ya, selalu', 'Sering', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'eksfoliasi',
      'question': 'Apakah Anda membutuhkan toner dengan eksfoliasi?',
      'icon': CupertinoIcons.refresh_circled,
      'description': 'Toner eksfoliasi mengandung AHA/BHA untuk membantu mengangkat sel kulit mati',
      'weight': 8, // Bobot: 8/10
      'options': ['Ya, sangat butuh', 'Ya, cukup butuh', 'Netral', 'Tidak terlalu butuh', 'Tidak butuh'],
    },
    {
      'id': 'hidrasi',
      'question': 'Seberapa penting hidrasi dalam toner untuk Anda?',
      'icon': CupertinoIcons.drop,
      'description': 'Hidrasi membantu menjaga kelembapan dan kesehatan kulit',
      'weight': 8, // Bobot: 8/10
      'options': ['Sangat penting', 'Penting', 'Cukup penting', 'Tidak terlalu penting', 'Tidak penting'],
    },
    {
      'id': 'brightening',
      'question': 'Apakah Anda menginginkan efek pencerah dari toner?',
      'icon': CupertinoIcons.sun_max,
      'description': 'Toner pencerah biasanya mengandung vitamin C, niacinamide, atau arbutin',
      'weight': 7, // Bobot: 7/10
      'options': ['Ya, sangat ingin', 'Ya, cukup ingin', 'Netral', 'Tidak terlalu ingin', 'Tidak ingin'],
    },
    {
      'id': 'jerawat',
      'question': 'Apakah Anda memiliki masalah jerawat?',
      'icon': CupertinoIcons.bandage,
      'description': 'Toner untuk jerawat biasanya mengandung BHA, tea tree, atau zinc',
      'weight': 8, // Bobot: 8/10
      'options': ['Ya, banyak', 'Ya, sedikit', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'tekstur_preference',
      'question': 'Tekstur toner seperti apa yang Anda sukai?',
      'icon': CupertinoIcons.hand_raised,
      'description': 'Preferensi tekstur untuk kenyamanan penggunaan',
      'weight': 5, // Bobot: 5/10
      'options': ['Cair seperti air', 'Sedikit kental', 'Kental seperti essence', 'Milky/creamy', 'Tidak ada preferensi'],
    },
    {
      'id': 'anti_aging',
      'question': 'Apakah Anda mencari toner dengan manfaat anti-aging?',
      'icon': CupertinoIcons.arrow_2_circlepath,
      'description': 'Toner anti-aging biasanya mengandung peptide, adenosine, atau fermented ingredients',
      'weight': 7, // Bobot: 7/10
      'options': ['Ya, sangat penting', 'Ya, cukup penting', 'Netral', 'Tidak terlalu penting', 'Tidak penting'],
    },
    {
      'id': 'skin_barrier',
      'question': 'Apakah skin barrier Anda sedang rusak atau perlu diperkuat?',
      'icon': CupertinoIcons.shield_lefthalf_fill,
      'description': 'Tanda skin barrier rusak: kemerahan, sensasi terbakar, sensitif berlebih',
      'weight': 8, // Bobot: 8/10
      'options': ['Ya, sangat rusak', 'Ya, cukup rusak', 'Mungkin sedikit', 'Tidak yakin', 'Tidak rusak'],
    },
    {
      'id': 'budget',
      'question': 'Berapa budget Anda untuk toner?',
      'icon': CupertinoIcons.money_dollar_circle,
      'description': 'Budget menentukan rentang produk yang akan direkomendasikan',
      'weight': 4, // Bobot: 4/10
      'options': ['< Rp100.000', 'Rp100.000 - Rp200.000', 'Rp200.000 - Rp300.000', 'Rp300.000 - Rp500.000', '> Rp500.000'],
    },
    {
      'id': 'umur',
      'question': 'Berapa usia Anda saat ini?',
      'icon': CupertinoIcons.calendar,
      'description': 'Usia menentukan kebutuhan perawatan kulit yang berbeda',
      'weight': 6, // Bobot: 6/10
      'options': ['< 18 tahun', '18-25 tahun', '26-35 tahun', '36-45 tahun', '> 45 tahun'],
    },
  ];
  
  // Filter pertanyaan yang aktif berdasarkan jawaban sebelumnya
  static List<Map<String, dynamic>> activeQuestions(Map<String, String> answers) {
    return questions.where((q) {
      String questionId = q['id'];
      
      // Logic conditional untuk pertanyaan yang perlu dilewati
      bool shouldSkip = false;
      
      // Jika user tidak sensitif sama sekali, skip pertanyaan iritasi alkohol dan wewangian
      if ((questionId == 'iritasi_alkohol' || questionId == 'iritasi_wewangian') && 
          answers.containsKey('sensitifitas') && answers['sensitifitas'] == 'Tidak sensitif') {
        shouldSkip = true;
      }
      
      // Jika user tidak punya masalah jerawat, skip pertanyaan jerawat
      if (questionId == 'jerawat' && answers.containsKey('masalah_kulit') && 
          answers['masalah_kulit'] != 'Kulit berminyak') {
        shouldSkip = true;
      }
      
      // Jika user berusia dibawah 26 tahun, skip pertanyaan anti-aging
      if (questionId == 'anti_aging' && answers.containsKey('umur') && 
          (answers['umur'] == '< 18 tahun' || answers['umur'] == '18-25 tahun')) {
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
    if ((questionId == 'iritasi_alkohol' || questionId == 'iritasi_wewangian') && 
        answers.containsKey('sensitifitas') && answers['sensitifitas'] == 'Tidak sensitif') {
      return false;
    }
    
    if (questionId == 'jerawat' && answers.containsKey('masalah_kulit') && 
        answers['masalah_kulit'] != 'Kulit berminyak') {
      return false;
    }
    
    if (questionId == 'anti_aging' && answers.containsKey('umur') && 
        (answers['umur'] == '< 18 tahun' || answers['umur'] == '18-25 tahun')) {
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
      'untuk_eksfoliasi': 0,
      'untuk_pencerah': 0,
      'untuk_hidrasi': 0,
      'untuk_menenangkan': 0,
      'untuk_anti_aging': 0,
      'untuk_skin_barrier': 0,
    };
    
    // Evaluasi jawaban untuk jenis kulit
    if (answers.containsKey('jenis_kulit')) {
      switch (answers['jenis_kulit']) {
        case 'Berminyak':
          categoryScores.update('untuk_kulit_berminyak', (v) => v + 10);
          break;
        case 'Kering':
          categoryScores.update('untuk_kulit_kering', (v) => v + 10);
          categoryScores.update('untuk_hidrasi', (v) => v + 5);
          break;
        case 'Sensitif':
          categoryScores.update('untuk_kulit_sensitif', (v) => v + 10);
          categoryScores.update('untuk_menenangkan', (v) => v + 5);
          break;
        case 'Kombinasi':
          categoryScores.update('untuk_kulit_berminyak', (v) => v + 5);
          categoryScores.update('untuk_kulit_kering', (v) => v + 5);
          break;
      }
    }

    // Evaluasi masalah kulit utama
    if (answers.containsKey('masalah_kulit')) {
      switch (answers['masalah_kulit']) {
        case 'Kulit berminyak':
          categoryScores.update('untuk_kulit_berminyak', (v) => v + 9);
          break;
        case 'Kulit kering':
          categoryScores.update('untuk_kulit_kering', (v) => v + 9);
          categoryScores.update('untuk_hidrasi', (v) => v + 6);
          break;
        case 'Kulit kusam':
          categoryScores.update('untuk_pencerah', (v) => v + 9);
          break;
        case 'Tekstur tidak rata':
          categoryScores.update('untuk_eksfoliasi', (v) => v + 9);
          break;
        case 'Hiperpigmentasi':
          categoryScores.update('untuk_pencerah', (v) => v + 9);
          break;
      }
    }

    // Evaluasi sensitifitas
    if (answers.containsKey('sensitifitas')) {
      final s = answers['sensitifitas'];
      if (s == 'Sangat sensitif' || s == 'Cukup sensitif') {
        categoryScores.update('untuk_kulit_sensitif', (v) => v + 8);
        categoryScores.update('untuk_menenangkan', (v) => v + 6);
      }
    }

    // Evaluasi iritasi alkohol
    if (answers.containsKey('iritasi_alkohol')) {
      final a = answers['iritasi_alkohol'];
      if (a == 'Ya, selalu' || a == 'Sering') {
        categoryScores.update('untuk_kulit_sensitif', (v) => v + 5);
        categoryScores.update('untuk_skin_barrier', (v) => v + 3);
      }
    }

    // Evaluasi iritasi wewangian
    if (answers.containsKey('iritasi_wewangian')) {
      final w = answers['iritasi_wewangian'];
      if (w == 'Ya, selalu' || w == 'Sering') {
        categoryScores.update('untuk_kulit_sensitif', (v) => v + 5);
        categoryScores.update('untuk_skin_barrier', (v) => v + 3);
      }
    }

    // Evaluasi kebutuhan eksfoliasi
    if (answers.containsKey('eksfoliasi')) {
      final e = answers['eksfoliasi'];
      if (e == 'Ya, sangat butuh' || e == 'Ya, cukup butuh') {
        categoryScores.update('untuk_eksfoliasi', (v) => v + 8);
      }
    }

    // Evaluasi kebutuhan hidrasi
    if (answers.containsKey('hidrasi')) {
      final h = answers['hidrasi'];
      if (h == 'Sangat penting' || h == 'Penting') {
        categoryScores.update('untuk_hidrasi', (v) => v + 8);
        categoryScores.update('untuk_kulit_kering', (v) => v + 3);
      }
    }

    // Evaluasi kebutuhan brightening
    if (answers.containsKey('brightening')) {
      final b = answers['brightening'];
      if (b == 'Ya, sangat ingin' || b == 'Ya, cukup ingin') {
        categoryScores.update('untuk_pencerah', (v) => v + 7);
      }
    }

    // Evaluasi masalah jerawat
    if (answers.containsKey('jerawat')) {
      final j = answers['jerawat'];
      if (j == 'Ya, banyak' || j == 'Ya, sedikit') {
        categoryScores.update('untuk_kulit_berminyak', (v) => v + 5);
        categoryScores.update('untuk_eksfoliasi', (v) => v + 6);
      }
    }

    // Evaluasi kebutuhan anti-aging
    if (answers.containsKey('anti_aging')) {
      final a = answers['anti_aging'];
      if (a == 'Ya, sangat penting' || a == 'Ya, cukup penting') {
        categoryScores.update('untuk_anti_aging', (v) => v + 7);
      }
    }

    // Evaluasi kondisi skin barrier
    if (answers.containsKey('skin_barrier')) {
      final s = answers['skin_barrier'];
      if (s == 'Ya, sangat rusak' || s == 'Ya, cukup rusak') {
        categoryScores.update('untuk_skin_barrier', (v) => v + 8);
        categoryScores.update('untuk_menenangkan', (v) => v + 5);
      }
    }

    // Evaluasi umur untuk anti-aging
    if (answers.containsKey('umur')) {
      final umur = answers['umur'];
      if (umur == '36-45 tahun' || umur == '> 45 tahun') {
        categoryScores.update('untuk_anti_aging', (v) => v + 6);
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
        productType = 'Toner untuk Kulit Berminyak';
        break;
      case 'untuk_kulit_kering':
        productType = 'Toner untuk Kulit Kering';
        break;
      case 'untuk_kulit_sensitif':
        productType = 'Toner untuk Kulit Sensitif';
        break;
      case 'untuk_eksfoliasi':
        productType = 'Toner Eksfoliasi';
        break;
      case 'untuk_pencerah':
        productType = 'Toner Pencerah';
        break;
      case 'untuk_hidrasi':
        productType = 'Toner Hidrasi';
        break;
      case 'untuk_menenangkan':
        productType = 'Toner Menenangkan';
        break;
      case 'untuk_anti_aging':
        productType = 'Toner Anti-Aging';
        break;
      case 'untuk_skin_barrier':
        productType = 'Toner untuk Skin Barrier';
        break;
      default:
        productType = 'Toner untuk Kulit Normal';
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