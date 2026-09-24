import 'package:flutter/cupertino.dart';

class PencernaanQuestions {
  // Daftar pertanyaan gejala penyakit pencernaan
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'nyeri_perut',
      'question': 'Apakah anda mengalami nyeri perut?',
      'icon': CupertinoIcons.question,
      'description': 'Rasa sakit atau tidak nyaman di area perut',
      'skipTo': 'kembung', // Jika tidak, langsung ke kembung
    },
    {
      'id': 'kembung',
      'question': 'Apakah anda merasa kembung atau perut terasa penuh?',
      'icon': CupertinoIcons.question,
      'description': 'Rasa penuh atau tekanan di perut (distensi abdominal)',
      'skipTo': 'mual', // Jika tidak, langsung ke mual
    },
    {
      'id': 'mual',
      'question': 'Apakah anda mengalami mual?',
      'icon': CupertinoIcons.question,
      'description': 'Perasaan ingin muntah, sering dikaitkan dengan gangguan lambung',
      'skipTo': 'muntah', // Jika tidak, langsung ke muntah
    },
    {
      'id': 'muntah',
      'question': 'Apakah anda muntah?',
      'icon': CupertinoIcons.question,
      'description': 'Mengeluarkan isi lambung melalui mulut',
      'skipTo': 'diare', // Jika tidak, langsung ke diare
    },
    {
      'id': 'diare',
      'question': 'Apakah anda mengalami diare?',
      'icon': CupertinoIcons.question,
      'description': 'Frekuensi buang air besar meningkat dan konsistensi feses cair',
      'skipTo': 'konstipasi', // Jika tidak, langsung ke konstipasi
    },
    {
      'id': 'konstipasi',
      'question': 'Apakah anda mengalami konstipasi (sembelit)?',
      'icon': CupertinoIcons.question,
      'description': 'Buang air besar kurang dari 3 kali per minggu atau sulit dikeluarkan',
      'skipTo': 'perubahan_bab', // Jika tidak, langsung ke perubahan pola bab
    },
    {
      'id': 'perubahan_bab',
      'question': 'Apakah anda mengalami perubahan pola buang air besar?',
      'icon': CupertinoIcons.question,
      'description': 'Perubahan frekuensi, konsistensi, atau bentuk feses',
      'skipTo': 'feses_berdarah', // Jika tidak, langsung ke feses berdarah
    },
    {
      'id': 'feses_berdarah',
      'question': 'Apakah anda menemukan darah pada feses?',
      'icon': CupertinoIcons.question,
      'description': 'Darah pada feses dapat menunjukkan perdarahan saluran cerna',
      'skipTo': 'nyeri_bab', // Jika tidak, langsung ke nyeri bab
    },
    {
      'id': 'nyeri_bab',
      'question': 'Apakah anda merasakan nyeri saat buang air besar?',
      'icon': CupertinoIcons.question,
      'description': 'Nyeri saat defekasi (tenesmus) dan sensasi tidak tuntas',
      'skipTo': 'penurunan_nafsu_makan', // Jika tidak, langsung ke penurunan nafsu makan
    },
    {
      'id': 'penurunan_nafsu_makan',
      'question': 'Apakah anda mengalami penurunan nafsu makan?',
      'icon': CupertinoIcons.question,
      'description': 'Berkurangnya keinginan untuk makan (anoreksia)',
      'skipTo': 'penurunan_bb', // Jika tidak, langsung ke penurunan bb
    },
    {
      'id': 'penurunan_bb',
      'question': 'Apakah anda mengalami penurunan berat badan tanpa sebab yang jelas?',
      'icon': CupertinoIcons.question,
      'description': 'Penurunan berat badan tanpa diet atau olahraga',
      'skipTo': 'heartburn', // Jika tidak, langsung ke heartburn
    },
    {
      'id': 'heartburn',
      'question': 'Apakah anda merasakan sensasi terbakar di dada (heartburn)?',
      'icon': CupertinoIcons.question,
      'description': 'Tanda khas refluks gastroesofageal (GERD)',
      'skipTo': 'regurgitasi', // Jika tidak, langsung ke regurgitasi
    },
    {
      'id': 'regurgitasi',
      'question': 'Apakah anda mengalami regurgitasi (makanan kembali ke kerongkongan atau mulut)?',
      'icon': CupertinoIcons.question,
      'description': 'Kembalinya makanan dari lambung ke kerongkongan atau mulut',
      'skipTo': 'sulit_menelan', // Jika tidak, langsung ke sulit menelan
    },
    {
      'id': 'sulit_menelan',
      'question': 'Apakah anda mengalami kesulitan menelan (disfagia)?',
      'icon': CupertinoIcons.question,
      'description': 'Kesulitan menelan baik terhadap makanan padat maupun cair',
      'skipTo': 'nyeri_menelan', // Jika tidak, langsung ke nyeri menelan
    },
    {
      'id': 'nyeri_menelan',
      'question': 'Apakah anda merasakan nyeri saat menelan (odynophagia)?',
      'icon': CupertinoIcons.question,
      'description': 'Nyeri saat menelan mengindikasikan iritasi atau peradangan esofagus',
      'skipTo': 'rasa_pahit_mulut', // Jika tidak, langsung ke rasa pahit mulut
    },
    {
      'id': 'rasa_pahit_mulut',
      'question': 'Apakah anda merasakan rasa pahit atau asam di mulut?',
      'icon': CupertinoIcons.question,
      'description': 'Terkait dengan refluks asam lambung',
      'skipTo': 'kenyang_cepat', // Jika tidak, langsung ke kenyang cepat
    },
    {
      'id': 'kenyang_cepat',
      'question': 'Apakah anda merasa cepat kenyang saat makan (early satiety)?',
      'icon': CupertinoIcons.question,
      'description': 'Rasa kenyang meskipun baru makan sedikit',
      'skipTo': 'kentut_berlebihan', // Jika tidak, langsung ke kentut berlebihan
    },
    {
      'id': 'kentut_berlebihan',
      'question': 'Apakah anda mengalami kentut berlebihan (flatulensi)?',
      'icon': CupertinoIcons.question,
      'description': 'Bisa berkaitan dengan fermentasi makanan di usus',
      'skipTo': 'kulit_kuning', // Jika tidak, langsung ke kulit kuning
    },
    {
      'id': 'kulit_kuning',
      'question': 'Apakah kulit dan mata anda menguning (ikterus)?',
      'icon': CupertinoIcons.question,
      'description': 'Menandakan gangguan hati atau saluran empedu',
      'skipTo': 'gatal_tubuh', // Jika tidak, langsung ke gatal tubuh
    },
    {
      'id': 'gatal_tubuh',
      'question': 'Apakah anda mengalami gatal seluruh tubuh tanpa ruam (pruritus)?',
      'icon': CupertinoIcons.question,
      'description': 'Kadang terkait dengan kolestasis intrahepatik',
      'skipTo': 'urin_gelap', // Jika tidak, langsung ke urin gelap
    },
    {
      'id': 'urin_gelap',
      'question': 'Apakah urin anda berwarna gelap?',
      'icon': CupertinoIcons.question,
      'description': 'Tanda awal gangguan hati atau empedu',
      'skipTo': 'feses_pucat', // Jika tidak, langsung ke feses pucat
    },
    {
      'id': 'feses_pucat',
      'question': 'Apakah feses anda berwarna pucat atau seperti dempul?',
      'icon': CupertinoIcons.question,
      'description': 'Indikasi obstruksi saluran empedu',
      'skipTo': 'demam', // Jika tidak, langsung ke demam
    },
    {
      'id': 'demam',
      'question': 'Apakah anda mengalami demam?',
      'icon': CupertinoIcons.question,
      'description': 'Menyertai infeksi atau inflamasi pada saluran cerna',
      'skipTo': 'gejala_anemia', // Jika tidak, langsung ke gejala anemia
    },
    {
      'id': 'gejala_anemia',
      'question': 'Apakah anda mengalami gejala anemia (lemas, pucat, pusing)?',
      'icon': CupertinoIcons.question,
      'description': 'Bisa terjadi akibat perdarahan saluran cerna kronis',
      'skipTo': 'perut_berdebar', // Jika tidak, langsung ke perut berdebar
    },
    {
      'id': 'perut_berdebar',
      'question': 'Apakah perut anda terasa berdebar atau bunyi usus berlebihan (borborygmi)?',
      'icon': CupertinoIcons.question,
      'description': 'Tanda hiperaktivitas motilitas usus atau obstruksi',
    },
  ];

  // Filter pertanyaan yang aktif berdasarkan jawaban sebelumnya
  static List<Map<String, dynamic>> activeQuestions(Map<String, String> answers) {
    return questions.where((q) {
      // Cek apakah pertanyaan memiliki kondisi
      if (!q.containsKey('conditional')) return true;
      
      final String conditionalField = q['conditional'];
      final List<String> requiredValues = List<String>.from(q['requiredValue']);
      
      // Cek apakah kondisi terpenuhi
      final bool conditionalMet = answers.containsKey(conditionalField) && 
                          requiredValues.contains(answers[conditionalField]);
      
      // Cek apakah ada kondisi skip berdasarkan jawaban Ya pada pertanyaan lain
      if (q.containsKey('skipIfYes')) {
        final String skipField = q['skipIfYes'];
        return conditionalMet && (!answers.containsKey(skipField) || answers[skipField] != 'Ya');
      }
      
      return conditionalMet;
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
  
  // Mendapatkan opsi jawaban jika tersedia
  static List<String>? getOptionsForQuestion(String questionId) {
    final question = questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {},
    );
    
    if (question.isEmpty || !question.containsKey('options')) return null;
    
    return List<String>.from(question['options']);
  }
  
  // Evaluasi kondisional untuk pertanyaan
  static bool shouldShowQuestion(String questionId, Map<String, String> answers) {
    final question = questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {},
    );
    
    if (question.isEmpty) return false;
    
    if (!question.containsKey('conditional')) return true;
    
    final String conditionalField = question['conditional'];
    final List<String> requiredValues = List<String>.from(question['requiredValue']);
    
    final bool conditionalMet = answers.containsKey(conditionalField) && 
                        requiredValues.contains(answers[conditionalField]);
    
    // Cek apakah ada kondisi skip berdasarkan jawaban Ya pada pertanyaan lain
    if (question.containsKey('skipIfYes')) {
      final String skipField = question['skipIfYes'];
      return conditionalMet && (!answers.containsKey(skipField) || answers[skipField] != 'Ya');
    }
    
    return conditionalMet;
  }
  
  // Dapatkan ID pertanyaan berikutnya berdasarkan logic skipTo
  static String getNextQuestionId(String currentId, String answer, Map<String, String> allAnswers) {
    final currentQuestion = questions.firstWhere(
      (q) => q['id'] == currentId,
      orElse: () => {},
    );
    
    if (currentQuestion.isEmpty) return '';
    
    // Jika jawaban "Tidak" dan ada skipTo, maka lompat ke pertanyaan yang ditentukan
    if (answer == 'Tidak' && currentQuestion.containsKey('skipTo')) {
      return currentQuestion['skipTo'];
    }
    
    // Jika jawaban "Ya" dan ada skipToIfYes, maka lompat ke pertanyaan yang ditentukan
    if (answer == 'Ya' && currentQuestion.containsKey('skipToIfYes')) {
      return currentQuestion['skipToIfYes'];
    }
    
    // Jika tidak ada kondisi skip atau kondisi tidak terpenuhi, cari pertanyaan berikutnya secara berurutan
    final int currentIndex = questions.indexWhere((q) => q['id'] == currentId);
    if (currentIndex == -1 || currentIndex >= questions.length - 1) return '';
    
    // Cari pertanyaan berikutnya yang seharusnya ditampilkan (yang memenuhi kondisi shouldShowQuestion)
    for (int i = currentIndex + 1; i < questions.length; i++) {
      if (shouldShowQuestion(questions[i]['id'], allAnswers)) {
        return questions[i]['id'];
      }
    }
    
    return '';
  }
  
  // Kelompokkan pertanyaan berdasarkan kategori
  static Map<String, List<Map<String, dynamic>>> getQuestionsByCategory() {
    return {
      'Gejala Perut': questions.where((q) => 
        ['nyeri_perut', 'nyeri_lokasi', 'nyeri_perut_intensitas', 'nyeri_perut_durasi', 
        'kembung', 'kembung_durasi', 'perut_berdebar'].contains(q['id'])).toList(),
      
      'Gejala Umum Pencernaan': questions.where((q) => 
        ['mual', 'mual_frekuensi', 'muntah', 'muntah_warna', 'muntah_frekuensi',
        'penurunan_nafsu_makan', 'penurunan_bb', 'jumlah_penurunan_bb',
        'demam', 'tingkat_demam', 'gejala_anemia'].contains(q['id'])).toList(),
      
      'Gejala Buang Air Besar': questions.where((q) => 
        ['diare', 'diare_frekuensi', 'diare_durasi', 'konstipasi', 'konstipasi_durasi',
        'perubahan_bab', 'perubahan_bentuk', 'feses_berdarah', 'warna_darah_feses',
        'nyeri_bab', 'feses_pucat'].contains(q['id'])).toList(),
      
      'Gejala Refluks': questions.where((q) => 
        ['heartburn', 'heartburn_frekuensi', 'regurgitasi', 'rasa_pahit_mulut'].contains(q['id'])).toList(),
      
      'Gejala Menelan': questions.where((q) => 
        ['sulit_menelan', 'jenis_sulit_menelan', 'nyeri_menelan'].contains(q['id'])).toList(),
      
      'Gejala Hepatobilier': questions.where((q) => 
        ['kulit_kuning', 'gatal_tubuh', 'urin_gelap'].contains(q['id'])).toList(),
      
      'Gejala Lainnya': questions.where((q) => 
        ['kenyang_cepat', 'kentut_berlebihan'].contains(q['id'])).toList(),
    };
  }
}