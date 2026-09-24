import 'package:flutter/cupertino.dart';

class SerumQuestions {
  // Daftar pertanyaan untuk rekomendasi serum wajah
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'jenis_kulit',
      'question': 'Apa jenis kulit wajah Anda?',
      'icon': CupertinoIcons.person_crop_circle,
      'description': 'Jenis kulit menentukan kandungan serum yang cocok untuk Anda',
      'weight': 10, // Bobot: 10/10
      'options': ['Normal', 'Berminyak', 'Kering', 'Kombinasi', 'Sensitif'],
    },
    {
      'id': 'usia',
      'question': 'Berapa usia Anda saat ini?',
      'icon': CupertinoIcons.calendar,
      'description': 'Usia menentukan kebutuhan perawatan kulit yang berbeda',
      'weight': 9, // Bobot: 9/10
      'options': ['< 18 tahun', '18-25 tahun', '26-35 tahun', '36-45 tahun', '> 45 tahun'],
    },
    {
      'id': 'masalah_utama',
      'question': 'Apa masalah utama kulit yang ingin Anda atasi?',
      'icon': CupertinoIcons.exclamationmark_circle,
      'description': 'Fokus pada masalah utama membantu memilih serum dengan kandungan yang sesuai',
      'weight': 10, // Bobot: 10/10
      'options': ['Jerawat', 'Kulit kusam', 'Penuaan dini', 'Flek hitam/hiperpigmentasi', 'Kulit kering/dehidrasi'],
    },
    {
      'id': 'jerawat',
      'question': 'Apakah Anda memiliki masalah jerawat?',
      'icon': CupertinoIcons.bandage,
      'description': 'Masalah jerawat memerlukan kandungan antibakteri dan anti-inflamasi',
      'weight': 8, // Bobot: 8/10
      'options': ['Ya, banyak', 'Ya, sedikit', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'bekas_jerawat',
      'question': 'Apakah Anda memiliki bekas jerawat atau hiperpigmentasi?',
      'icon': CupertinoIcons.arrow_2_circlepath,
      'description': 'Bekas jerawat membutuhkan serum dengan kandungan mencerahkan dan meratakan',
      'weight': 7, // Bobot: 7/10
      'options': ['Ya, banyak', 'Ya, sedikit', 'Beberapa area', 'Sangat sedikit', 'Tidak ada'],
    },
    {
      'id': 'tekstur_kulit',
      'question': 'Bagaimana tekstur kulit wajah Anda?',
      'icon': CupertinoIcons.hand_raised,
      'description': 'Tekstur kulit memengaruhi jenis eksfoliasi yang dibutuhkan',
      'weight': 6, // Bobot: 6/10
      'options': ['Kasar/tidak rata', 'Bertekstur', 'Ada beberapa ketidakrataan', 'Cukup halus', 'Sangat halus'],
    },
    {
      'id': 'sensitivitas',
      'question': 'Seberapa sensitif kulit Anda terhadap produk skincare baru?',
      'icon': CupertinoIcons.exclamationmark_shield,
      'description': 'Kulit sensitif membutuhkan formula serum yang lebih lembut',
      'weight': 9, // Bobot: 9/10
      'options': ['Sangat sensitif', 'Cukup sensitif', 'Kadang sensitif', 'Jarang sensitif', 'Tidak sensitif'],
    },
    {
      'id': 'kulit_kusam',
      'question': 'Apakah kulit wajah Anda terlihat kusam?',
      'icon': CupertinoIcons.sun_max,
      'description': 'Kulit kusam membutuhkan serum dengan kandungan mencerahkan dan antioksidan',
      'weight': 7, // Bobot: 7/10
      'options': ['Ya, sangat kusam', 'Ya, cukup kusam', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'paparan_sinar',
      'question': 'Seberapa sering Anda terpapar sinar matahari?',
      'icon': CupertinoIcons.sun_haze,
      'description': 'Paparan matahari berlebih membutuhkan serum dengan antioksidan dan vitamin C',
      'weight': 6, // Bobot: 6/10
      'options': ['Sangat sering', 'Sering', 'Cukup sering', 'Jarang', 'Sangat jarang'],
    },
    {
      'id': 'keriput',
      'question': 'Apakah Anda memiliki kekhawatiran tentang kerutan atau tanda penuaan?',
      'icon': CupertinoIcons.waveform_path,
      'description': 'Tanda penuaan membutuhkan serum dengan kandungan anti-aging seperti retinol dan peptida',
      'weight': 8, // Bobot: 8/10
      'options': ['Ya, sangat khawatir', 'Ya, cukup khawatir', 'Mulai memikirkannya', 'Sedikit khawatir', 'Tidak khawatir'],
    },
    {
      'id': 'hidrasi',
      'question': 'Bagaimana tingkat kelembapan kulit Anda?',
      'icon': CupertinoIcons.drop,
      'description': 'Kulit dehidrasi membutuhkan serum dengan kandungan pelembap dan humektan',
      'weight': 8, // Bobot: 8/10
      'options': ['Sangat kering', 'Cukup kering', 'Normal', 'Cukup lembap', 'Sangat lembap'],
    },
    {
      'id': 'elastisitas',
      'question': 'Bagaimana elastisitas kulit wajah Anda?',
      'icon': CupertinoIcons.arrow_up_down,
      'description': 'Elastisitas kulit yang berkurang membutuhkan serum dengan peptida dan kolagen',
      'weight': 7, // Bobot: 7/10
      'options': ['Sangat kendur', 'Mulai kendur', 'Cukup elastis', 'Masih elastis', 'Sangat elastis'],
    },
    {
      'id': 'penggunaan_retinol',
      'question': 'Apakah Anda pernah menggunakan produk retinol sebelumnya?',
      'icon': CupertinoIcons.lab_flask,
      'description': 'Pengalaman dengan retinol menentukan konsentrasi yang cocok',
      'weight': 6, // Bobot: 6/10
      'options': ['Ya, rutin', 'Ya, sesekali', 'Pernah tapi berhenti', 'Belum pernah, tapi tertarik', 'Belum pernah dan tidak tertarik'],
    },
    {
      'id': 'budget',
      'question': 'Berapa budget Anda untuk serum wajah?',
      'icon': CupertinoIcons.money_dollar_circle,
      'description': 'Budget menentukan rentang produk yang akan direkomendasikan',
      'weight': 4, // Bobot: 4/10
      'options': ['< Rp100.000', 'Rp100.000 - Rp250.000', 'Rp250.000 - Rp500.000', 'Rp500.000 - Rp1.000.000', '> Rp1.000.000'],
    },
    {
      'id': 'preferensi_tekstur',
      'question': 'Tekstur serum apa yang Anda sukai?',
      'icon': CupertinoIcons.slider_horizontal_3,
      'description': 'Preferensi tekstur untuk kenyamanan penggunaan',
      'weight': 5, // Bobot: 5/10
      'options': ['Cair/ringan (watery)', 'Gel ringan', 'Gel kental', 'Serba oil', 'Tidak ada preferensi'],
    },
    {
      'id': 'bahan_alami',
      'question': 'Apakah Anda lebih menyukai produk dengan bahan-bahan alami?',
      'icon': CupertinoIcons.leaf_arrow_circlepath,
      'description': 'Preferensi terhadap kandungan bahan serum',
      'weight': 5, // Bobot: 5/10
      'options': ['Ya, harus alami', 'Lebih memilih alami', 'Netral', 'Tidak terlalu penting', 'Lebih suka scientifically-proven'],
    },
    {
      'id': 'rutinitas',
      'question': 'Berapa kali Anda ingin menggunakan serum dalam sehari?',
      'icon': CupertinoIcons.clock,
      'description': 'Frekuensi pemakaian mempengaruhi jenis serum yang direkomendasikan',
      'weight': 4, // Bobot: 4/10
      'options': ['Pagi dan malam', 'Hanya malam hari', 'Hanya pagi hari', 'Bergantian dengan produk lain', 'Tidak tentu'],
    },
  ];

  // Filter pertanyaan yang aktif berdasarkan jawaban sebelumnya
  static List<Map<String, dynamic>> activeQuestions(Map<String, String> answers) {
    return questions.where((q) {
      String questionId = q['id'];
      
      // Logic conditional untuk pertanyaan yang perlu dilewati
      bool shouldSkip = false;
      
      // Jika user memilih usia < 18 tahun, kita bisa skip pertanyaan tentang keriput dan elastisitas
      if ((questionId == 'keriput' || questionId == 'elastisitas') && 
          answers.containsKey('usia') && answers['usia'] == '< 18 tahun') {
        shouldSkip = true;
      }
      
      // Jika user tidak memiliki jerawat, kita bisa skip pertanyaan tentang bekas jerawat
      if (questionId == 'bekas_jerawat' && answers.containsKey('jerawat') && 
          answers['jerawat'] == 'Tidak pernah') {
        shouldSkip = true;
      }
      
      // Jika masalah utama bukan penuaan dini, kita bisa skip pertanyaan tentang penggunaan retinol
      if (questionId == 'penggunaan_retinol' && answers.containsKey('masalah_utama') && 
          answers['masalah_utama'] != 'Penuaan dini') {
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
    if ((questionId == 'keriput' || questionId == 'elastisitas') && 
        answers.containsKey('usia') && answers['usia'] == '< 18 tahun') {
      return false;
    }
    
    if (questionId == 'bekas_jerawat' && answers.containsKey('jerawat') && 
        answers['jerawat'] == 'Tidak pernah') {
      return false;
    }
    
    if (questionId == 'penggunaan_retinol' && answers.containsKey('masalah_utama') && 
        answers['masalah_utama'] != 'Penuaan dini') {
      return false;
    }
    
    return true;
  }
  
  // Hitung skor preferensi berdasarkan jawaban
  static Map<String, dynamic> calculateProductPreference(Map<String, String> answers) {
    // Inisialisasi skor untuk setiap kategori produk
    Map<String, double> categoryScores = {
      'untuk_anti_jerawat': 0,
      'untuk_kulit_kering': 0,
      'untuk_kulit_sensitif': 0,
      'untuk_anti_aging': 0,
      'untuk_pencerah': 0,
      'untuk_hidrasi': 0,
      'untuk_cerahkan_kulit': 0,
      'untuk_menenangkan': 0,
      'untuk_anti_oksidan': 0,
    };
    
    // Jenis Kulit
    if (answers.containsKey('jenis_kulit')) {
      switch (answers['jenis_kulit']) {
        case 'Berminyak':
          categoryScores.update('untuk_anti_jerawat', (v) => v + 5);
          break;
        case 'Kering':
          categoryScores.update('untuk_kulit_kering', (v) => v + 10);
          categoryScores.update('untuk_hidrasi', (v) => v + 8);
          break;
        case 'Sensitif':
          categoryScores.update('untuk_kulit_sensitif', (v) => v + 10);
          categoryScores.update('untuk_menenangkan', (v) => v + 7);
          break;
        case 'Kombinasi':
          categoryScores.update('untuk_anti_jerawat', (v) => v + 3);
          categoryScores.update('untuk_hidrasi', (v) => v + 3);
          break;
      }
    }

    // Usia
    if (answers.containsKey('usia')) {
      final usia = answers['usia'];
      if (usia == '36-45 tahun') {
        categoryScores.update('untuk_anti_aging', (v) => v + 8);
      } else if (usia == '> 45 tahun') {
        categoryScores.update('untuk_anti_aging', (v) => v + 10);
      } else if (usia == '26-35 tahun') {
        categoryScores.update('untuk_anti_aging', (v) => v + 5);
        categoryScores.update('untuk_anti_oksidan', (v) => v + 5);
      }
    }

    // Masalah Utama
    if (answers.containsKey('masalah_utama')) {
      switch (answers['masalah_utama']) {
        case 'Jerawat':
          categoryScores.update('untuk_anti_jerawat', (v) => v + 10);
          break;
        case 'Kulit kusam':
          categoryScores.update('untuk_pencerah', (v) => v + 10);
          categoryScores.update('untuk_cerahkan_kulit', (v) => v + 8);
          break;
        case 'Penuaan dini':
          categoryScores.update('untuk_anti_aging', (v) => v + 10);
          break;
        case 'Flek hitam/hiperpigmentasi':
          categoryScores.update('untuk_pencerah', (v) => v + 10);
          categoryScores.update('untuk_cerahkan_kulit', (v) => v + 9);
          break;
        case 'Kulit kering/dehidrasi':
          categoryScores.update('untuk_hidrasi', (v) => v + 10);
          categoryScores.update('untuk_kulit_kering', (v) => v + 8);
          break;
      }
    }

    // Jerawat
    if (answers.containsKey('jerawat')) {
      final jerawat = answers['jerawat'];
      if (jerawat == 'Ya, banyak') {
        categoryScores.update('untuk_anti_jerawat', (v) => v + 8);
      } else if (jerawat == 'Ya, sedikit' || jerawat == 'Kadang-kadang') {
        categoryScores.update('untuk_anti_jerawat', (v) => v + 5);
      }
    }

    // Bekas Jerawat
    if (answers.containsKey('bekas_jerawat')) {
      final bekasJerawat = answers['bekas_jerawat'];
      if (bekasJerawat == 'Ya, banyak' || bekasJerawat == 'Ya, sedikit') {
        categoryScores.update('untuk_pencerah', (v) => v + 7);
        categoryScores.update('untuk_cerahkan_kulit', (v) => v + 6);
      }
    }

    // Tekstur Kulit
    if (answers.containsKey('tekstur_kulit')) {
      final teksturKulit = answers['tekstur_kulit'];
      if (teksturKulit == 'Kasar/tidak rata' || teksturKulit == 'Bertekstur') {
        categoryScores.update('untuk_pencerah', (v) => v + 5);
      }
    }

    // Sensitivitas
    if (answers.containsKey('sensitivitas')) {
      final sensitivitas = answers['sensitivitas'];
      if (sensitivitas == 'Sangat sensitif' || sensitivitas == 'Cukup sensitif') {
        categoryScores.update('untuk_kulit_sensitif', (v) => v + 9);
        categoryScores.update('untuk_menenangkan', (v) => v + 7);
      }
    }

    // Kulit Kusam
    if (answers.containsKey('kulit_kusam')) {
      final kulitKusam = answers['kulit_kusam'];
      if (kulitKusam == 'Ya, sangat kusam' || kulitKusam == 'Ya, cukup kusam') {
        categoryScores.update('untuk_pencerah', (v) => v + 7);
        categoryScores.update('untuk_cerahkan_kulit', (v) => v + 7);
      }
    }

    // Paparan Sinar
    if (answers.containsKey('paparan_sinar')) {
      final paparanSinar = answers['paparan_sinar'];
      if (paparanSinar == 'Sangat sering' || paparanSinar == 'Sering') {
        categoryScores.update('untuk_anti_oksidan', (v) => v + 6);
        categoryScores.update('untuk_pencerah', (v) => v + 4);
      }
    }

    // Keriput
    if (answers.containsKey('keriput')) {
      final keriput = answers['keriput'];
      if (keriput == 'Ya, sangat khawatir' || keriput == 'Ya, cukup khawatir') {
        categoryScores.update('untuk_anti_aging', (v) => v + 8);
      } else if (keriput == 'Mulai memikirkannya') {
        categoryScores.update('untuk_anti_aging', (v) => v + 5);
      }
    }

    // Hidrasi
    if (answers.containsKey('hidrasi')) {
      final hidrasi = answers['hidrasi'];
      if (hidrasi == 'Sangat kering' || hidrasi == 'Cukup kering') {
        categoryScores.update('untuk_hidrasi', (v) => v + 8);
        categoryScores.update('untuk_kulit_kering', (v) => v + 7);
      }
    }

    // Elastisitas
    if (answers.containsKey('elastisitas')) {
      final elastisitas = answers['elastisitas'];
      if (elastisitas == 'Sangat kendur' || elastisitas == 'Mulai kendur') {
        categoryScores.update('untuk_anti_aging', (v) => v + 7);
      }
    }

    // Penggunaan Retinol
    if (answers.containsKey('penggunaan_retinol')) {
      final penggunaanRetinol = answers['penggunaan_retinol'];
      if (penggunaanRetinol == 'Ya, rutin' || penggunaanRetinol == 'Ya, sesekali') {
        categoryScores.update('untuk_anti_aging', (v) => v + 3);
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
      case 'untuk_anti_jerawat':
        productType = 'Serum Anti Jerawat';
        break;
      case 'untuk_kulit_kering':
        productType = 'Serum untuk Kulit Kering';
        break;
      case 'untuk_kulit_sensitif':
        productType = 'Serum untuk Kulit Sensitif';
        break;
      case 'untuk_anti_aging':
        productType = 'Serum Anti Aging';
        break;
      case 'untuk_pencerah':
        productType = 'Serum Pencerah';
        break;
      case 'untuk_hidrasi':
        productType = 'Serum Hidrasi';
        break;
      case 'untuk_cerahkan_kulit':
        productType = 'Serum untuk Cerahkan Kulit';
        break;
      case 'untuk_menenangkan':
        productType = 'Serum Menenangkan';
        break;
      case 'untuk_anti_oksidan':
        productType = 'Serum Antioksidan';
        break;
      default:
        productType = 'Serum Multi-Fungsi';
    }
    
    // Hitung persentase kecocokan
    double totalPossibleScore = 0;
    double userScore = 0;

    questions.forEach((question) {
      // Ubah dari cast (as double) menjadi konversi eksplisit
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