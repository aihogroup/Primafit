import 'package:flutter/cupertino.dart';

class UmumQuestions {
  // Daftar pertanyaan gejala
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'hidung_tersumbat',
      'question': 'Apakah Anda mengalami hidung tersumbat atau berair dalam beberapa hari terakhir?',
      'icon': CupertinoIcons.person_fill,
      'description': 'Hidung tersumbat atau berair adalah gejala umum pada pilek dan alergi',
      'skipTo': 'batuk_kering', // Jika tidak, langsung ke pertanyaan batuk
    },
    {
      'id': 'batuk_kering',
      'question': 'Apakah Anda mengalami batuk kering atau berdahak?',
      'icon': CupertinoIcons.person_fill,
      'description': 'Batuk dapat menjadi gejala berbagai penyakit pernapasan',
      'skipTo': 'demam', // Jika tidak, langsung ke pertanyaan demam
    },
    {
      'id': 'batuk_berdahak',
      'question': 'Apakah batuk Anda mengeluarkan dahak?',
      'icon': CupertinoIcons.drop_fill,
      'description': 'Dahak adalah lendir kental yang dikeluarkan saat batuk',
      'conditional': 'batuk_kering',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'demam',
      'question': 'Apakah Anda merasakan badan panas atau demam?',
      'icon': CupertinoIcons.thermometer,
      'description': 'Demam adalah peningkatan suhu tubuh di atas normal, biasanya merupakan respons terhadap infeksi',
      'skipTo': 'sakit_kepala', // Jika tidak, langsung ke pertanyaan sakit kepala
    },
    {
      'id': 'sakit_kepala',
      'question': 'Apakah Anda sering merasa sakit kepala ringan atau berat?',
      'icon': CupertinoIcons.person_fill,
      'description': 'Sakit kepala bisa menjadi gejala dari berbagai kondisi kesehatan',
      'skipTo': 'sakit_kepala_berdenyut', // Jika tidak, langsung ke pertanyaan sakit kepala berdenyut
    },
    {
      'id': 'sakit_kepala_berdenyut',
      'question': 'Apakah Anda pernah merasakan sakit kepala berdenyut yang memburuk saat beraktivitas?',
      'icon': CupertinoIcons.waveform_path_ecg,
      'description': 'Sakit kepala berdenyut dapat menandakan migrain',
      'skipTo': 'diare', // Jika tidak, langsung ke pertanyaan diare
    },
    {
      'id': 'diare',
      'question': 'Apakah Anda mengalami buang air besar lebih dari tiga kali sehari dengan konsistensi cair?',
      'icon': CupertinoIcons.arrow_down_circle_fill,
      'description': 'Diare adalah gangguan pencernaan yang ditandai dengan buang air besar yang encer dan sering',
      'skipTo': 'perih_ulu_hati', // Jika tidak, langsung ke pertanyaan perih ulu hati
    },
    {
      'id': 'perih_ulu_hati',
      'question': 'Apakah Anda sering merasa perih di ulu hati terutama sebelum makan?',
      'icon': CupertinoIcons.heart_fill,
      'description': 'Nyeri ulu hati sebelum makan dapat menandakan maag',
      'skipTo': 'panas_dada', // Jika tidak, langsung ke pertanyaan panas dada
    },
    {
      'id': 'panas_dada',
      'question': 'Apakah Anda sering mengalami rasa panas di dada atau tenggorokan setelah makan?',
      'icon': CupertinoIcons.flame_fill,
      'description': 'Sensasi panas di dada atau tenggorokan bisa menandakan refluks asam lambung',
      'skipTo': 'nyeri_punggung', // Jika tidak, langsung ke pertanyaan nyeri punggung
    },
    {
      'id': 'nyeri_punggung',
      'question': 'Apakah Anda merasakan sakit atau pegal di bagian punggung bawah?',
      'icon': CupertinoIcons.person_2_fill,
      'description': 'Sakit punggung bawah bisa disebabkan oleh ketegangan otot atau masalah tulang belakang',
      'skipTo': 'alergi', // Jika tidak, langsung ke pertanyaan alergi
    },
    {
      'id': 'alergi',
      'question': 'Apakah Anda mengalami bersin, gatal hidung, atau ruam kulit setelah terpapar debu atau udara dingin?',
      'icon': CupertinoIcons.wind,
      'description': 'Gejala ini dapat menandakan reaksi alergi',
      'skipTo': 'ruam_alergi', // Jika tidak, langsung ke pertanyaan ruam alergi
    },
    {
      'id': 'ruam_alergi',
      'question': 'Apakah Anda mengalami ruam kulit saat reaksi alergi terjadi?',
      'icon': CupertinoIcons.bandage_fill,
      'description': 'Ruam kulit alergi biasanya gatal dan kemerahan',
      'skipTo': 'sulit_nafas', // Jika tidak, langsung ke pertanyaan sulit nafas
    },
    {
      'id': 'sulit_nafas',
      'question': 'Apakah Anda merasa sulit bernafas terutama saat malam atau setelah olahraga?',
      'icon': CupertinoIcons.wind_snow,
      'description': 'Sulit bernafas dan mengi dapat menjadi gejala asma',
      'skipTo': 'asma_malam', // Jika tidak, langsung ke pertanyaan asma malam
    },
    {
      'id': 'asma_malam',
      'question': 'Apakah gejala asma Anda lebih parah di malam hari?',
      'icon': CupertinoIcons.moon_fill,
      'description': 'Asma yang memburuk di malam hari adalah indikasi penting untuk diagnosis',
      'conditional': 'sulit_nafas',
      'requiredValue': ['Ya', 'Kadang'],
      'skipTo': 'asma_olahraga', // Jika tidak, langsung ke pertanyaan asma olahraga
    },
    {
      'id': 'asma_olahraga',
      'question': 'Apakah gejala asma Anda dipicu oleh aktivitas fisik?',
      'icon': CupertinoIcons.sportscourt_fill,
      'description': 'Asma yang dipicu oleh olahraga dikenal sebagai exercise-induced asthma',
      'conditional': 'sulit_nafas',
      'requiredValue': ['Ya', 'Kadang'],
      'skipTo': 'nyeri_kencing', // Jika tidak, langsung ke pertanyaan nyeri kencing
    },
    {
      'id': 'nyeri_kencing',
      'question': 'Apakah Anda merasa nyeri atau panas saat buang air kecil?',
      'icon': CupertinoIcons.drop_fill,
      'description': 'Nyeri atau sensasi terbakar saat buang air kecil bisa menandakan infeksi saluran kemih',
      'skipTo': 'sering_kencing', // Jika tidak, langsung ke pertanyaan sering kencing
    },
    {
      'id': 'sering_kencing',
      'question': 'Apakah Anda buang air kecil lebih sering dari biasanya?',
      'icon': CupertinoIcons.timer_fill,
      'description': 'Buang air kecil yang lebih sering adalah gejala umum infeksi saluran kemih',
      'skipTo': 'ruam_cacar', // Jika tidak, langsung ke pertanyaan ruam cacar
    },
    {
      'id': 'ruam_cacar',
      'question': 'Apakah Anda pernah mengalami munculnya ruam kemerahan yang berubah menjadi lenting berisi cairan?',
      'icon': CupertinoIcons.dot_radiowaves_right,
      'description': 'Ruam dan lenting berisi cairan adalah ciri khas cacar air',
      'skipTo': 'ruam_gatal', // Jika tidak, langsung ke pertanyaan ruam gatal
    },
    {
      'id': 'ruam_gatal',
      'question': 'Apakah ruam tersebut terasa sangat gatal?',
      'icon': CupertinoIcons.hand_raised_fill,
      'description': 'Rasa gatal yang intens adalah ciri khas cacar air',
      'conditional': 'ruam_cacar',
      'requiredValue': ['Ya', 'Kadang'],
      'skipTo': 'mata_merah', // Jika tidak, langsung ke pertanyaan mata merah
    },
    {
      'id': 'mata_merah',
      'question': 'Apakah mata Anda pernah memerah, berair, dan terasa gatal?',
      'icon': CupertinoIcons.eye_fill,
      'description': 'Mata merah, berair, dan gatal bisa menandakan konjungtivitis',
      'skipTo': 'tekanan_darah', // Jika tidak, langsung ke pertanyaan tekanan darah
    },
    {
      'id': 'tekanan_darah',
      'question': 'Apakah Anda pernah diberitahu bahwa tekanan darah Anda lebih tinggi dari normal?',
      'icon': CupertinoIcons.waveform_path,
      'description': 'Tekanan darah tinggi atau hipertensi sering tidak menimbulkan gejala',
      'skipTo': 'sakit_kepala_belakang', // Jika tidak, langsung ke pertanyaan sakit kepala belakang
    },
    {
      'id': 'sakit_kepala_belakang',
      'question': 'Apakah Anda mengalami sakit kepala di bagian belakang kepala terutama di pagi hari?',
      'icon': CupertinoIcons.person_fill,
      'description': 'Sakit kepala di bagian belakang kepala bisa menjadi gejala hipertensi',
      'skipTo': 'lemas', // Jika tidak, langsung ke pertanyaan lemas
    },
    {
      'id': 'lemas',
      'question': 'Apakah Anda sering merasa lemas, cepat lelah, atau pucat?',
      'icon': CupertinoIcons.battery_25,
      'description': 'Lemas, kelelahan, dan pucat adalah gejala umum anemia',
      'skipTo': 'pusing', // Jika tidak, langsung ke pertanyaan pusing
    },
    {
      'id': 'pusing',
      'question': 'Apakah Anda sering merasa pusing atau kepala berputar terutama saat berdiri?',
      'icon': CupertinoIcons.arrow_clockwise,
      'description': 'Pusing saat perubahan posisi bisa menjadi gejala anemia atau hipotensi',
      'skipTo': 'cemas', // Jika tidak, langsung ke pertanyaan cemas
    },
    {
      'id': 'cemas',
      'question': 'Apakah Anda merasa cemas, sulit tidur, atau mudah marah tanpa sebab yang jelas?',
      'icon': CupertinoIcons.exclamationmark_circle_fill,
      'description': 'Kecemasan, gangguan tidur, dan perubahan mood bisa menandakan stres',
      'skipTo': 'gejala_stres', // Jika tidak, langsung ke pertanyaan gejala stres
    },
    {
      'id': 'gejala_stres',
      'question': 'Apakah Anda mengalami gejala fisik seperti sakit kepala, nyeri otot, atau gangguan pencernaan ketika stres?',
      'icon': CupertinoIcons.bolt_fill,
      'description': 'Stres dapat memengaruhi tubuh secara fisik dengan berbagai cara',
      'skipTo': 'haus_berlebihan', // Jika tidak, langsung ke pertanyaan haus berlebihan
    },
    {
      'id': 'haus_berlebihan',
      'question': 'Apakah Anda sering merasa haus berlebihan dan sering buang air kecil?',
      'icon': CupertinoIcons.drop,
      'description': 'Rasa haus berlebihan dan sering buang air kecil bisa menjadi gejala diabetes',
      'skipTo': 'lapar_berlebihan', // Jika tidak, langsung ke pertanyaan lapar berlebihan
    },
    {
      'id': 'lapar_berlebihan',
      'question': 'Apakah Anda sering merasa lapar walaupun sudah makan?',
      'icon': CupertinoIcons.arrow_up_square_fill,
      'description': 'Rasa lapar berlebihan meskipun sudah makan bisa menjadi gejala diabetes',
      'skipTo': 'penurunan_bb', // Jika tidak, langsung ke pertanyaan penurunan berat badan
    },
    {
      'id': 'penurunan_bb',
      'question': 'Apakah berat badan Anda menurun tanpa sebab yang jelas dalam beberapa bulan terakhir?',
      'icon': CupertinoIcons.arrow_down_square_fill,
      'description': 'Penurunan berat badan tanpa sebab yang jelas perlu dievaluasi lebih lanjut',
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
  
  // Kelompokkan pertanyaan berdasarkan kategori untuk pengorganisasian
  static Map<String, List<Map<String, dynamic>>> getQuestionsByCategory() {
    return {
      'Gejala Pernapasan': questions.where((q) => 
        ['hidung_tersumbat', 'batuk_kering', 'batuk_berdahak', 'sulit_nafas', 'asma_malam', 'asma_olahraga'].contains(q['id'])).toList(),
      
      'Gejala Pencernaan': questions.where((q) => 
        ['diare', 'perih_ulu_hati', 'panas_dada'].contains(q['id'])).toList(),
      
      'Gejala Nyeri': questions.where((q) => 
        ['sakit_kepala', 'sakit_kepala_berdenyut', 'sakit_kepala_belakang', 'nyeri_punggung', 'nyeri_kencing'].contains(q['id'])).toList(),
      
      'Gejala Kulit dan Mata': questions.where((q) => 
        ['alergi', 'ruam_alergi', 'ruam_cacar', 'ruam_gatal', 'mata_merah'].contains(q['id'])).toList(),
      
      'Gejala Umum': questions.where((q) => 
        ['demam', 'lemas', 'pusing', 'tekanan_darah', 'cemas', 'gejala_stres', 'haus_berlebihan', 'lapar_berlebihan', 'penurunan_bb', 'sering_kencing'].contains(q['id'])).toList(),
    };
  }
}