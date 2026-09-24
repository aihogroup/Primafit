import 'package:flutter/cupertino.dart';

class ExfoliatorQuestions {
  // Daftar pertanyaan untuk rekomendasi exfoliator
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'jenis_kulit',
      'question': 'Apa jenis kulit wajah Anda?',
      'icon': CupertinoIcons.person_crop_circle,
      'description': 'Jenis kulit menentukan kandungan exfoliator yang cocok untuk Anda',
      'weight': 10, // Bobot: 10/10
      'options': ['Normal', 'Berminyak', 'Kering', 'Kombinasi', 'Sensitif'],
    },
    {
      'id': 'usia',
      'question': 'Berapa usia Anda saat ini?',
      'icon': CupertinoIcons.calendar,
      'description': 'Usia menentukan kebutuhan exfoliasi yang berbeda',
      'weight': 7, // Bobot: 7/10
      'options': ['< 18 tahun', '18-25 tahun', '26-35 tahun', '36-45 tahun', '> 45 tahun'],
    },
    {
      'id': 'jerawat',
      'question': 'Apakah Anda memiliki masalah jerawat?',
      'icon': CupertinoIcons.bandage,
      'description': 'Masalah jerawat memerlukan exfoliator dengan kandungan khusus seperti BHA',
      'weight': 8, // Bobot: 8/10
      'options': ['Ya, banyak', 'Ya, sedikit', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'sensitifitas',
      'question': 'Seberapa sensitif kulit Anda terhadap produk baru?',
      'icon': CupertinoIcons.exclamationmark_circle,
      'description': 'Kulit sensitif membutuhkan formula exfoliator yang lebih lembut',
      'weight': 9, // Bobot: 9/10
      'options': ['Sangat sensitif', 'Cukup sensitif', 'Kadang sensitif', 'Jarang sensitif', 'Tidak sensitif'],
    },
    {
      'id': 'kulit_kusam',
      'question': 'Apakah kulit wajah Anda terlihat kusam?',
      'icon': CupertinoIcons.sun_max,
      'description': 'Exfoliator dengan AHA dapat membantu mengangkat sel kulit mati dan mengurangi kusam',
      'weight': 8, // Bobot: 8/10
      'options': ['Ya, sangat kusam', 'Ya, cukup kusam', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'exfoliating_experience',
      'question': 'Apa pengalaman Anda dengan produk exfoliating?',
      'icon': CupertinoIcons.star,
      'description': 'Ini membantu menentukan kekuatan produk yang sesuai untuk Anda',
      'weight': 8, // Bobot: 8/10
      'options': ['Pemula total', 'Pernah menggunakan beberapa kali', 'Pengguna rutin', 'Berpengalaman', 'Ahli skincare'],
    },
    {
      'id': 'masalah_tekstur',
      'question': 'Apakah Anda memiliki masalah tekstur kulit?',
      'icon': CupertinoIcons.waveform_path,
      'description': 'Tekstur tidak rata, bintik hitam, atau scar memerlukan jenis exfoliasi tertentu',
      'weight': 7, // Bobot: 7/10
      'options': ['Ya, sangat mengganggu', 'Ya, cukup mengganggu', 'Beberapa area saja', 'Sedikit', 'Tidak ada'],
    },
    {
      'id': 'kulit_mengelupas',
      'question': 'Apakah kulit Anda sering mengelupas atau kering bersisik?',
      'icon': CupertinoIcons.drop_fill,
      'description': 'Pengelupasan menunjukkan tingkat kelembaban dan kebutuhan exfoliasi',
      'weight': 7, // Bobot: 7/10
      'options': ['Ya, sangat sering', 'Sering', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'penggunaan_makeup',
      'question': 'Apakah Anda menggunakan makeup secara rutin?',
      'icon': CupertinoIcons.wand_stars,
      'description': 'Penggunaan makeup rutin memerlukan exfoliasi yang tepat untuk membersihkan pori-pori',
      'weight': 5, // Bobot: 5/10
      'options': ['Ya, setiap hari', 'Sering (4-6 kali seminggu)', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'frekuensi_exfoliasi',
      'question': 'Seberapa sering Anda ingin menggunakan exfoliator?',
      'icon': CupertinoIcons.refresh,
      'description': 'Frekuensi penggunaan akan menentukan jenis dan kekuatan exfoliator',
      'weight': 8, // Bobot: 8/10
      'options': ['Setiap hari', '2-3 kali seminggu', 'Seminggu sekali', 'Dua minggu sekali', 'Sebulan sekali'],
    },
    {
      'id': 'budget',
      'question': 'Berapa budget Anda untuk exfoliator?',
      'icon': CupertinoIcons.money_dollar_circle,
      'description': 'Budget menentukan rentang produk yang akan direkomendasikan',
      'weight': 4, // Bobot: 4/10
      'options': ['< Rp100.000', 'Rp100.000 - Rp200.000', 'Rp200.000 - Rp500.000', 'Rp500.000 - Rp1.000.000', '> Rp1.000.000'],
    },
    {
      'id': 'preferensi_tipe',
      'question': 'Tipe exfoliator apa yang Anda sukai?',
      'icon': CupertinoIcons.hand_raised,
      'description': 'Exfoliator dibagi menjadi tipe fisik (scrub), kimia (AHA/BHA), atau kombinasi',
      'weight': 9, // Bobot: 9/10
      'options': ['Chemical (AHA/BHA)', 'Physical (Scrub/Bubuk)', 'Kombinasi keduanya', 'Enzymatic', 'Tidak ada preferensi'],
    },
    {
      'id': 'hasil_diinginkan',
      'question': 'Hasil apa yang paling Anda harapkan dari exfoliator?',
      'icon': CupertinoIcons.lightbulb,
      'description': 'Hasil yang diinginkan menentukan bahan aktif yang dibutuhkan',
      'weight': 8, // Bobot: 8/10
      'options': ['Kulit lebih cerah', 'Mengurangi jerawat', 'Menyamarkan tekstur', 'Anti aging', 'Pori-pori lebih bersih'],
    },
  ];

  // Filter pertanyaan yang aktif berdasarkan jawaban sebelumnya
  static List<Map<String, dynamic>> activeQuestions(Map<String, String> answers) {
    return questions.where((q) {
      final String questionId = q['id'];
      
      // Logic conditional untuk pertanyaan yang perlu dilewati
      // bool shouldSkip = false;
      
      // Jika user sangat sensitif, skip pertanyaan preferensi_tipe exfoliator fisik
      if (questionId == 'preferensi_tipe' && answers.containsKey('sensitifitas') && 
          answers['sensitifitas'] == 'Sangat sensitif') {
        // Kita tidak skip pertanyaan tapi akan memfilter opsi yang tersedia
        // Ini akan dihandle di getOptionsForQuestion
      }
      
      // Jika user pemula total, berikan rekomendasi yang lebih aman
      if (questionId == 'frekuensi_exfoliasi' && answers.containsKey('exfoliating_experience') && 
          answers['exfoliating_experience'] == 'Pemula total') {
        // Tidak skip tapi akan batasi frekuensi penggunaan
      }
      
      // if (shouldSkip) {
      //   return false;
      // }
      
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
  
  // Mendapatkan opsi jawaban berdasarkan ID pertanyaan (dengan logic filter)
  static List<String> getOptionsForQuestion(String questionId, {Map<String, String>? answers}) {
    final question = questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {'options': <String>[]},
    );
    
    List<String> options = List<String>.from(question['options'] ?? []);
    
    // Jika sudah ada jawaban, filter opsi berdasarkan jawaban sebelumnya
    if (answers != null) {
      // Contoh logic filtering:
      // Untuk kulit sensitif, batasi pilihan tipe exfoliator
      if (questionId == 'preferensi_tipe' && 
          answers.containsKey('sensitifitas') && 
          answers['sensitifitas'] == 'Sangat sensitif') {
        // Filter out physical exfoliators for very sensitive skin
        options = options.where((option) => 
          !option.contains('Physical') && !option.contains('Kombinasi')
        ).toList();
      }
      
      // Untuk pemula, batasi frekuensi exfoliasi
      if (questionId == 'frekuensi_exfoliasi' && 
          answers.containsKey('exfoliating_experience') && 
          answers['exfoliating_experience'] == 'Pemula total') {
        // Remove daily options for beginners
        options = options.where((option) => 
          !option.contains('Setiap hari') && !option.contains('2-3 kali seminggu')
        ).toList();
      }
    }
    
    return options;
  }
  
  // Evaluasi kondisional untuk pertanyaan
  static bool shouldShowQuestion(String questionId, Map<String, String> answers) {
    // Logic yang sama dengan activeQuestions
    return true; // Semua pertanyaan ditampilkan, tapi opsi mungkin difilter
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
      'untuk_kulit_kusam': 0,
      'untuk_kulit_kombinasi': 0,
      'untuk_penggunaan_harian': 0,
      'untuk_penggunaan_mingguan': 0,
    };
    
    // Jenis kulit
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
          categoryScores.update('untuk_kulit_kombinasi', (v) => v + 10);
          break;
      }
    }

    // Usia
    if (answers.containsKey('usia')) {
      final usia = answers['usia'];
      if (usia == '36-45 tahun' || usia == '> 45 tahun') {
        categoryScores.update('untuk_anti_aging', (v) => v + 7);
      }
    }

    // Jerawat
    if (answers.containsKey('jerawat')) {
      final jerawat = answers['jerawat'];
      if (jerawat == 'Ya, banyak' || jerawat == 'Ya, sedikit') {
        categoryScores.update('untuk_anti_jerawat', (v) => v + 8);
        categoryScores.update('untuk_kulit_berminyak', (v) => v + 4);
      }
    }

    // Sensitifitas
    if (answers.containsKey('sensitifitas')) {
      final s = answers['sensitifitas'];
      if (s == 'Sangat sensitif' || s == 'Cukup sensitif') {
        categoryScores.update('untuk_kulit_sensitif', (v) => v + 9);
      }
    }

    // Kulit kusam
    if (answers.containsKey('kulit_kusam')) {
      final k = answers['kulit_kusam'];
      if (k == 'Ya, sangat kusam' || k == 'Ya, cukup kusam') {
        categoryScores.update('untuk_kulit_kusam', (v) => v + 8);
      }
    }

    // Pengalaman exfoliating
    if (answers.containsKey('exfoliating_experience')) {
      final exp = answers['exfoliating_experience'];
      if (exp == 'Pemula total' || exp == 'Pernah menggunakan beberapa kali') {
        // Untuk pemula, lebih baik produk yang lebih lembut
        categoryScores.update('untuk_kulit_sensitif', (v) => v + 5);
        categoryScores.update('untuk_penggunaan_mingguan', (v) => v + 6);
      } else if (exp == 'Ahli skincare' || exp == 'Berpengalaman') {
        // Untuk yang berpengalaman, bisa produk yang lebih kuat
        categoryScores.update('untuk_penggunaan_harian', (v) => v + 6);
      }
    }

    // Masalah tekstur
    if (answers.containsKey('masalah_tekstur')) {
      final mt = answers['masalah_tekstur'];
      if (mt == 'Ya, sangat mengganggu' || mt == 'Ya, cukup mengganggu') {
        categoryScores.update('untuk_kulit_kusam', (v) => v + 6);
        categoryScores.update('untuk_anti_aging', (v) => v + 4);
      }
    }

    // Kulit mengelupas
    if (answers.containsKey('kulit_mengelupas')) {
      final km = answers['kulit_mengelupas'];
      if (km == 'Ya, sangat sering' || km == 'Sering') {
        categoryScores.update('untuk_kulit_kering', (v) => v + 7);
      }
    }

    // Penggunaan makeup
    if (answers.containsKey('penggunaan_makeup')) {
      final pm = answers['penggunaan_makeup'];
      if (pm == 'Ya, setiap hari' || pm == 'Sering (4-6 kali seminggu)') {
        categoryScores.update('untuk_penggunaan_harian', (v) => v + 5);
      }
    }

    // Frekuensi exfoliasi
    if (answers.containsKey('frekuensi_exfoliasi')) {
      final fe = answers['frekuensi_exfoliasi'];
      if (fe == 'Setiap hari' || fe == '2-3 kali seminggu') {
        categoryScores.update('untuk_penggunaan_harian', (v) => v + 8);
      } else if (fe == 'Seminggu sekali' || fe == 'Dua minggu sekali' || fe == 'Sebulan sekali') {
        categoryScores.update('untuk_penggunaan_mingguan', (v) => v + 8);
      }
    }

    // Preferensi tipe
    if (answers.containsKey('preferensi_tipe')) {
      // Preferensi tipe mempengaruhi produk yang akan direkomendasikan
      // tapi tidak spesifik ke kategori tertentu
    }

    // Hasil yang diinginkan
    if (answers.containsKey('hasil_diinginkan')) {
      final hasil = answers['hasil_diinginkan'];
      switch (hasil) {
        case 'Kulit lebih cerah':
          categoryScores.update('untuk_kulit_kusam', (v) => v + 8);
          break;
        case 'Mengurangi jerawat':
          categoryScores.update('untuk_anti_jerawat', (v) => v + 8);
          break;
        case 'Menyamarkan tekstur':
          categoryScores.update('untuk_kulit_kusam', (v) => v + 7);
          break;
        case 'Anti aging':
          categoryScores.update('untuk_anti_aging', (v) => v + 8);
          break;
        case 'Pori-pori lebih bersih':
          categoryScores.update('untuk_kulit_berminyak', (v) => v + 7);
          break;
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
        productType = 'Exfoliator untuk Kulit Berminyak';
        break;
      case 'untuk_kulit_kering':
        productType = 'Exfoliator untuk Kulit Kering';
        break;
      case 'untuk_kulit_sensitif':
        productType = 'Exfoliator untuk Kulit Sensitif';
        break;
      case 'untuk_anti_jerawat':
        productType = 'Exfoliator Anti Jerawat';
        break;
      case 'untuk_anti_aging':
        productType = 'Exfoliator Anti Aging';
        break;
      case 'untuk_kulit_kusam':
        productType = 'Exfoliator untuk Kulit Kusam';
        break;
      case 'untuk_kulit_kombinasi':
        productType = 'Exfoliator untuk Kulit Kombinasi';
        break;
      case 'untuk_penggunaan_harian':
        productType = 'Exfoliator untuk Penggunaan Harian';
        break;
      case 'untuk_penggunaan_mingguan':
        productType = 'Exfoliator untuk Penggunaan Mingguan';
        break;
      default:
        productType = 'Exfoliator untuk Kulit Normal';
    }
    
    // Hitung persentase kecocokan
    double totalPossibleScore = 0;
    double userScore = 0;
    
    for (var question in questions) {
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