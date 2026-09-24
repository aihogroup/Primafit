import 'package:flutter/cupertino.dart';

class SkinTypeQuestions {
  // Daftar pertanyaan untuk analisis jenis kulit
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'wajah_setelah_cuci',
      'question': 'Bagaimana kondisi wajah Anda 1 jam setelah mencuci muka?',
      'icon': CupertinoIcons.person,
      'description': 'Kondisi wajah setelah dibersihkan dapat menunjukkan tingkat produksi minyak kulit',
      'weight': 10, // Bobot: 10/10
      'options': ['Sangat berminyak di seluruh wajah', 'Berminyak di T-zone, normal di area lain', 'Normal tanpa minyak berlebih', 'Terasa kencang/tertarik', 'Sangat kering dan mengelupas'],
    },
    {
      'id': 'ukuran_pori',
      'question': 'Bagaimana ukuran pori-pori di wajah Anda?',
      'icon': CupertinoIcons.circle_grid_3x3,
      'description': 'Ukuran pori dapat mengindikasikan jenis kulit dan produksi minyak',
      'weight': 8, // Bobot: 8/10
      'options': ['Besar dan terlihat jelas', 'Sedang, terutama di T-zone', 'Normal, tidak terlalu terlihat', 'Kecil dan hampir tidak terlihat', 'Bervariasi di area berbeda'],
    },
    {
      'id': 'kilap_wajah',
      'question': 'Seberapa cepat wajah Anda terlihat mengkilap/berminyak?',
      'icon': CupertinoIcons.sun_max,
      'description': 'Kecepatan munculnya kilap menunjukkan tingkat produksi sebum',
      'weight': 9, // Bobot: 9/10
      'options': ['Sangat cepat (1-2 jam)', 'Cukup cepat (3-4 jam)', 'Sedang (5-6 jam)', 'Lama (setelah 7+ jam)', 'Hampir tidak pernah mengkilap'],
    },
    {
      'id': 'tekstur_kulit',
      'question': 'Bagaimana tekstur kulit wajah Anda?',
      'icon': CupertinoIcons.hand_raised,
      'description': 'Tekstur kulit memberikan petunjuk tentang hidrasi dan kesehatan kulit',
      'weight': 8, // Bobot: 8/10
      'options': ['Halus dan berminyak', 'Halus di beberapa area, kasar di area lain', 'Halus dan normal', 'Sedikit kasar dan kering', 'Sangat kasar dan bersisik'],
    },
    {
      'id': 'kecenderungan_jerawat',
      'question': 'Bagaimana kecenderungan jerawat pada kulit Anda?',
      'icon': CupertinoIcons.bandage,
      'description': 'Frekuensi jerawat dapat berhubungan dengan jenis kulit dan produksi minyak',
      'weight': 7, // Bobot: 7/10
      'options': ['Sangat sering berjerawat', 'Sering berjerawat di T-zone', 'Kadang-kadang berjerawat', 'Jarang berjerawat', 'Hampir tidak pernah berjerawat'],
    },
    {
      'id': 'reaksi_produk',
      'question': 'Bagaimana reaksi kulit Anda terhadap produk skincare baru?',
      'icon': CupertinoIcons.exclamationmark_circle,
      'description': 'Reaksi kulit terhadap produk baru dapat menunjukkan tingkat sensitivitas',
      'weight': 9, // Bobot: 9/10
      'options': ['Sangat mudah bereaksi/iritasi', 'Cukup sering bereaksi/iritasi', 'Kadang bereaksi pada produk tertentu', 'Jarang bereaksi/iritasi', 'Hampir tidak pernah bereaksi/iritasi'],
    },
    {
      'id': 'sensasi_ketarik',
      'question': 'Apakah kulit Anda sering terasa ketarik/kencang?',
      'icon': CupertinoIcons.arrow_right_arrow_left,
      'description': 'Sensasi ketarik menandakan kulit kekurangan hidrasi',
      'weight': 8, // Bobot: 8/10
      'options': ['Tidak pernah terasa ketarik', 'Jarang terasa ketarik', 'Kadang terasa ketarik', 'Sering terasa ketarik', 'Selalu terasa ketarik'],
    },
    {
      'id': 'kemerahan_kulit',
      'question': 'Apakah kulit wajah Anda mudah memerah?',
      'icon': CupertinoIcons.flame,
      'description': 'Kemerahan pada kulit dapat mengindikasikan sensitivitas atau kondisi kulit tertentu',
      'weight': 7, // Bobot: 7/10
      'options': ['Sangat mudah memerah', 'Cukup mudah memerah', 'Kadang-kadang memerah', 'Jarang memerah', 'Hampir tidak pernah memerah'],
    },
    {
      'id': 'tipe_makeup',
      'question': 'Jenis foundation/makeup apa yang paling cocok untuk Anda?',
      'icon': CupertinoIcons.wand_stars,
      'description': 'Jenis makeup yang cocok dapat mencerminkan kebutuhan dan jenis kulit',
      'weight': 6, // Bobot: 6/10
      'options': ['Matte/oil control', 'Semi-matte', 'Natural finish', 'Dewy/radiant', 'Hydrating/moisturizing'],
    },
    {
      'id': 'area_kering',
      'question': 'Apakah ada area kering/mengelupas di wajah Anda?',
      'icon': CupertinoIcons.waveform_path,
      'description': 'Area kering dapat menunjukkan kulit dehidrasi atau kombinasi',
      'weight': 8, // Bobot: 8/10
      'options': ['Tidak ada area kering', 'Sedikit area kering', 'Area kering di pipi saja', 'Banyak area kering', 'Seluruh wajah terasa kering'],
    },
    {
      'id': 'perubahan_musim',
      'question': 'Bagaimana kulit Anda bereaksi terhadap perubahan musim?',
      'icon': CupertinoIcons.cloud_sun,
      'description': 'Perubahan kondisi kulit berdasarkan musim dapat memberikan informasi tambahan',
      'weight': 6, // Bobot: 6/10
      'options': ['Lebih berminyak di semua musim', 'Lebih berminyak saat panas, normal saat dingin', 'Relatif tidak berubah', 'Lebih kering saat dingin, normal saat panas', 'Selalu cenderung kering di semua musim'],
    },
    {
      'id': 'pola_tidur',
      'question': 'Bagaimana pola tidur Anda?',
      'icon': CupertinoIcons.moon_zzz,
      'description': 'Pola tidur dapat memengaruhi kesehatan dan regenerasi kulit',
      'weight': 5, // Bobot: 5/10
      'options': ['Sangat kurang (<5 jam)', 'Kurang (5-6 jam)', 'Cukup (6-7 jam)', 'Baik (7-8 jam)', 'Sangat baik (>8 jam)'],
    },
  ];

  // Filter pertanyaan yang aktif berdasarkan jawaban sebelumnya
  static List<Map<String, dynamic>> activeQuestions(Map<String, String> answers) {
    return questions.where((q) {
      final String questionId = q['id'];
      
      // Logic conditional untuk pertanyaan yang perlu dilewati
      bool shouldSkip = false;
      
      // Contoh: Skip pertanyaan tipe makeup jika tidak relevan
      if (questionId == 'tipe_makeup' && answers.containsKey('kecenderungan_jerawat') && 
          answers['kecenderungan_jerawat'] == 'Sangat sering berjerawat') {
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
    if (questionId == 'tipe_makeup' && answers.containsKey('kecenderungan_jerawat') && 
        answers['kecenderungan_jerawat'] == 'Sangat sering berjerawat') {
      return false;
    }
    
    return true;
  }
  
  // Hitung skor analisis jenis kulit berdasarkan jawaban
  static Map<String, dynamic> calculateSkinType(Map<String, String> answers) {
    // Inisialisasi skor untuk setiap jenis kulit
    final Map<String, double> skinTypeScores = {
      'berminyak': 0,
      'normal': 0,
      'kering': 0, 
      'kombinasi': 0,
      'sensitif': 0,
    };
    
    // Evaluasi jawaban dan hitung skor
    if (answers.containsKey('wajah_setelah_cuci')) {
      switch (answers['wajah_setelah_cuci']) {
        case 'Sangat berminyak di seluruh wajah':
          skinTypeScores.update('berminyak', (v) => v + 10);
          break;
        case 'Berminyak di T-zone, normal di area lain':
          skinTypeScores.update('kombinasi', (v) => v + 10);
          break;
        case 'Normal tanpa minyak berlebih':
          skinTypeScores.update('normal', (v) => v + 10);
          break;
        case 'Terasa kencang/tertarik':
          skinTypeScores.update('kering', (v) => v + 8);
          skinTypeScores.update('sensitif', (v) => v + 2);
          break;
        case 'Sangat kering dan mengelupas':
          skinTypeScores.update('kering', (v) => v + 10);
          break;
      }
    }

    if (answers.containsKey('ukuran_pori')) {
      switch (answers['ukuran_pori']) {
        case 'Besar dan terlihat jelas':
          skinTypeScores.update('berminyak', (v) => v + 8);
          break;
        case 'Sedang, terutama di T-zone':
          skinTypeScores.update('kombinasi', (v) => v + 8);
          break;
        case 'Normal, tidak terlalu terlihat':
          skinTypeScores.update('normal', (v) => v + 8);
          break;
        case 'Kecil dan hampir tidak terlihat':
          skinTypeScores.update('kering', (v) => v + 8);
          break;
        case 'Bervariasi di area berbeda':
          skinTypeScores.update('kombinasi', (v) => v + 8);
          break;
      }
    }

    if (answers.containsKey('kilap_wajah')) {
      switch (answers['kilap_wajah']) {
        case 'Sangat cepat (1-2 jam)':
          skinTypeScores.update('berminyak', (v) => v + 9);
          break;
        case 'Cukup cepat (3-4 jam)':
          skinTypeScores.update('berminyak', (v) => v + 6);
          skinTypeScores.update('kombinasi', (v) => v + 3);
          break;
        case 'Sedang (5-6 jam)':
          skinTypeScores.update('normal', (v) => v + 6);
          skinTypeScores.update('kombinasi', (v) => v + 3);
          break;
        case 'Lama (setelah 7+ jam)':
          skinTypeScores.update('normal', (v) => v + 6);
          skinTypeScores.update('kering', (v) => v + 3);
          break;
        case 'Hampir tidak pernah mengkilap':
          skinTypeScores.update('kering', (v) => v + 9);
          break;
      }
    }

    if (answers.containsKey('tekstur_kulit')) {
      switch (answers['tekstur_kulit']) {
        case 'Halus dan berminyak':
          skinTypeScores.update('berminyak', (v) => v + 8);
          break;
        case 'Halus di beberapa area, kasar di area lain':
          skinTypeScores.update('kombinasi', (v) => v + 8);
          break;
        case 'Halus dan normal':
          skinTypeScores.update('normal', (v) => v + 8);
          break;
        case 'Sedikit kasar dan kering':
          skinTypeScores.update('kering', (v) => v + 8);
          break;
        case 'Sangat kasar dan bersisik':
          skinTypeScores.update('kering', (v) => v + 6);
          skinTypeScores.update('sensitif', (v) => v + 2);
          break;
      }
    }

    if (answers.containsKey('kecenderungan_jerawat')) {
      switch (answers['kecenderungan_jerawat']) {
        case 'Sangat sering berjerawat':
          skinTypeScores.update('berminyak', (v) => v + 5);
          skinTypeScores.update('sensitif', (v) => v + 2);
          break;
        case 'Sering berjerawat di T-zone':
          skinTypeScores.update('kombinasi', (v) => v + 7);
          break;
        case 'Kadang-kadang berjerawat':
          skinTypeScores.update('normal', (v) => v + 4);
          skinTypeScores.update('kombinasi', (v) => v + 3);
          break;
        case 'Jarang berjerawat':
          skinTypeScores.update('normal', (v) => v + 6);
          skinTypeScores.update('kering', (v) => v + 1);
          break;
        case 'Hampir tidak pernah berjerawat':
          skinTypeScores.update('kering', (v) => v + 7);
          break;
      }
    }

    if (answers.containsKey('reaksi_produk')) {
      switch (answers['reaksi_produk']) {
        case 'Sangat mudah bereaksi/iritasi':
          skinTypeScores.update('sensitif', (v) => v + 9);
          break;
        case 'Cukup sering bereaksi/iritasi':
          skinTypeScores.update('sensitif', (v) => v + 7);
          break;
        case 'Kadang bereaksi pada produk tertentu':
          skinTypeScores.update('sensitif', (v) => v + 4);
          skinTypeScores.update('normal', (v) => v + 2);
          break;
        case 'Jarang bereaksi/iritasi':
          skinTypeScores.update('normal', (v) => v + 5);
          break;
        case 'Hampir tidak pernah bereaksi/iritasi':
          skinTypeScores.update('normal', (v) => v + 7);
          break;
      }
    }

    if (answers.containsKey('sensasi_ketarik')) {
      switch (answers['sensasi_ketarik']) {
        case 'Tidak pernah terasa ketarik':
          skinTypeScores.update('berminyak', (v) => v + 7);
          skinTypeScores.update('normal', (v) => v + 1);
          break;
        case 'Jarang terasa ketarik':
          skinTypeScores.update('normal', (v) => v + 6);
          skinTypeScores.update('berminyak', (v) => v + 2);
          break;
        case 'Kadang terasa ketarik':
          skinTypeScores.update('kombinasi', (v) => v + 5);
          skinTypeScores.update('normal', (v) => v + 3);
          break;
        case 'Sering terasa ketarik':
          skinTypeScores.update('kering', (v) => v + 6);
          skinTypeScores.update('sensitif', (v) => v + 2);
          break;
        case 'Selalu terasa ketarik':
          skinTypeScores.update('kering', (v) => v + 8);
          break;
      }
    }

    if (answers.containsKey('kemerahan_kulit')) {
      switch (answers['kemerahan_kulit']) {
        case 'Sangat mudah memerah':
          skinTypeScores.update('sensitif', (v) => v + 7);
          break;
        case 'Cukup mudah memerah':
          skinTypeScores.update('sensitif', (v) => v + 5);
          skinTypeScores.update('kering', (v) => v + 2);
          break;
        case 'Kadang-kadang memerah':
          skinTypeScores.update('sensitif', (v) => v + 3);
          skinTypeScores.update('normal', (v) => v + 2);
          break;
        case 'Jarang memerah':
          skinTypeScores.update('normal', (v) => v + 4);
          break;
        case 'Hampir tidak pernah memerah':
          skinTypeScores.update('normal', (v) => v + 4);
          skinTypeScores.update('berminyak', (v) => v + 3);
          break;
      }
    }

    if (answers.containsKey('tipe_makeup')) {
      switch (answers['tipe_makeup']) {
        case 'Matte/oil control':
          skinTypeScores.update('berminyak', (v) => v + 6);
          break;
        case 'Semi-matte':
          skinTypeScores.update('kombinasi', (v) => v + 6);
          break;
        case 'Natural finish':
          skinTypeScores.update('normal', (v) => v + 6);
          break;
        case 'Dewy/radiant':
          skinTypeScores.update('normal', (v) => v + 3);
          skinTypeScores.update('kering', (v) => v + 3);
          break;
        case 'Hydrating/moisturizing':
          skinTypeScores.update('kering', (v) => v + 6);
          break;
      }
    }

    if (answers.containsKey('area_kering')) {
      switch (answers['area_kering']) {
        case 'Tidak ada area kering':
          skinTypeScores.update('berminyak', (v) => v + 7);
          skinTypeScores.update('normal', (v) => v + 1);
          break;
        case 'Sedikit area kering':
          skinTypeScores.update('normal', (v) => v + 5);
          skinTypeScores.update('kombinasi', (v) => v + 3);
          break;
        case 'Area kering di pipi saja':
          skinTypeScores.update('kombinasi', (v) => v + 8);
          break;
        case 'Banyak area kering':
          skinTypeScores.update('kering', (v) => v + 7);
          skinTypeScores.update('sensitif', (v) => v + 1);
          break;
        case 'Seluruh wajah terasa kering':
          skinTypeScores.update('kering', (v) => v + 8);
          break;
      }
    }

    if (answers.containsKey('perubahan_musim')) {
      switch (answers['perubahan_musim']) {
        case 'Lebih berminyak di semua musim':
          skinTypeScores.update('berminyak', (v) => v + 6);
          break;
        case 'Lebih berminyak saat panas, normal saat dingin':
          skinTypeScores.update('kombinasi', (v) => v + 6);
          break;
        case 'Relatif tidak berubah':
          skinTypeScores.update('normal', (v) => v + 6);
          break;
        case 'Lebih kering saat dingin, normal saat panas':
          skinTypeScores.update('kering', (v) => v + 3);
          skinTypeScores.update('normal', (v) => v + 3);
          break;
        case 'Selalu cenderung kering di semua musim':
          skinTypeScores.update('kering', (v) => v + 6);
          break;
      }
    }

    // Temukan jenis kulit dengan skor tertinggi
    String topSkinType = '';
    String secondarySkinType = '';
    double maxScore = 0;
    double secondMaxScore = 0;
    
    skinTypeScores.forEach((skinType, score) {
      if (score > maxScore) {
        secondMaxScore = maxScore;
        secondarySkinType = topSkinType;
        maxScore = score;
        topSkinType = skinType;
      } else if (score > secondMaxScore) {
        secondMaxScore = score;
        secondarySkinType = skinType;
      }
    });
    
    // Tentukan kategori utama dan sekunder
    String primarySkinType;
    switch (topSkinType) {
      case 'berminyak':
        primarySkinType = 'Kulit Berminyak';
        break;
      case 'normal':
        primarySkinType = 'Kulit Normal';
        break;
      case 'kering':
        primarySkinType = 'Kulit Kering';
        break;
      case 'kombinasi':
        primarySkinType = 'Kulit Kombinasi';
        break;
      case 'sensitif':
        primarySkinType = 'Kulit Sensitif';
        break;
      default:
        primarySkinType = 'Kulit Normal';
    }
    
    String secondarySkinTypeText;
    switch (secondarySkinType) {
      case 'berminyak':
        secondarySkinTypeText = 'berminyak';
        break;
      case 'normal':
        secondarySkinTypeText = 'normal';
        break;
      case 'kering':
        secondarySkinTypeText = 'kering';
        break;
      case 'kombinasi':
        secondarySkinTypeText = 'kombinasi';
        break;
      case 'sensitif':
        secondarySkinTypeText = 'sensitif';
        break;
      default:
        secondarySkinTypeText = 'normal';
    }
    
    // Hitung persentase kecocokan
    double totalPossibleScore = 0;
    double userScore = 0;
    
    for (var question in questions) {
      totalPossibleScore += (question['weight'] as int).toDouble();
    }
    
    // Skor pengguna berdasarkan jenis kulit tertinggi
    userScore = maxScore;
    
    // Persentase kecocokan
    final double matchPercentage = (userScore / totalPossibleScore) * 100;
    
    // Perbedaan antara skor utama dan sekunder untuk menentukan tingkat kecenderungan
    final double scoreDifference = maxScore - secondMaxScore;
    String tendencyLevel;
    
    if (scoreDifference > 15) {
      tendencyLevel = 'sangat kuat';
    } else if (scoreDifference > 10) {
      tendencyLevel = 'kuat';
    } else if (scoreDifference > 5) {
      tendencyLevel = 'moderat';
    } else {
      tendencyLevel = 'ringan';
    }
    
    return {
      'primarySkinType': primarySkinType,
      'secondarySkinType': secondarySkinTypeText,
      'tendencyLevel': tendencyLevel,
      'matchPercentage': matchPercentage,
      'skinTypeScores': skinTypeScores,
      'topSkinType': topSkinType,
    };
  }
}