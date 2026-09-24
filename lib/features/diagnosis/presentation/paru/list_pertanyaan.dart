import 'package:flutter/cupertino.dart';

class ParuQuestions {
  // Daftar pertanyaan gejala
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'batuk',
      'question': 'Apakah anda batuk?',
      'icon': CupertinoIcons.question,
      'description': 'Batuk merupakan gejala umum pada penyakit paru-paru',
      'skipTo': 'sesak_nafas', // Jika tidak, langsung ke idPertanyaan 7
    },
    {
      'id': 'batuk_berdahak',
      'question': 'Apakah batuk berdahak?',
      'icon': CupertinoIcons.question,
      'description': 'Dahak adalah lendir kental yang dikeluarkan saat batuk',
      'conditional': 'batuk',
      'requiredValue': ['Ya', 'Kadang'],
      'skipTo': 'batuk_berdarah', // Jika tidak, langsung ke idPertanyaan 5
    },
    {
      'id': 'dahak_kuning',
      'question': 'Apakah dahak berwarna kuning?',
      'icon': CupertinoIcons.question,
      'description': 'Warna dahak dapat menunjukkan jenis infeksi',
      'conditional': 'batuk_berdahak',
      'requiredValue': ['Ya', 'Kadang'],
      'skipTo': 'batuk_berdarah', // Jika iya, langsung ke idPertanyaan 5
    },
    {
      'id': 'dahak_hijau',
      'question': 'Apakah dahak berwarna hijau?',
      'icon': CupertinoIcons.question,
      'description': 'Dahak hijau sering menandakan infeksi bakteri',
      'conditional': 'batuk_berdahak',
      'requiredValue': ['Ya', 'Kadang'],
      'skipIfYes': 'dahak_kuning', // Hanya ditampilkan jika dahak_kuning tidak dijawab Ya
    },
    {
      'id': 'batuk_berdarah',
      'question': 'Apakah batuk berdarah? (hemoptisis)',
      'icon': CupertinoIcons.question,
      'description': 'Batuk yang mengeluarkan darah',
      'conditional': 'batuk',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'batuk_kronis',
      'question': 'Apakah batuk anda cukup lama? (kronis)',
      'icon': CupertinoIcons.question,
      'description': 'Batuk yang berlangsung lebih dari 8 minggu dianggap kronis',
      'conditional': 'batuk',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'sesak_nafas',
      'question': 'Apakah anda sesak nafas? (dispnea)',
      'icon': CupertinoIcons.question,
      'description': 'Kesulitan bernapas atau sesak napas',
      'skipTo': 'nyeri_dada', // Jika tidak, langsung ke idPertanyaan 10
    },
    {
      'id': 'sesak_saat_istirahat',
      'question': 'Apakah sesak tetap muncul saat aktivitas ringan atau saat istirahat?',
      'icon': CupertinoIcons.question,
      'description': 'Sesak napas bahkan pada saat istirahat menunjukkan kondisi yang lebih serius',
      'conditional': 'sesak_nafas',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'sesak_saat_berbaring',
      'question': 'Apakah sesak nafas memburuk saat malam atau saat berbaring?',
      'icon': CupertinoIcons.question,
      'description': 'Kondisi ini disebut orthopnea, sering terjadi pada gangguan jantung',
      'conditional': 'sesak_nafas',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'nyeri_dada',
      'question': 'Apakah dada anda terasa nyeri?',
      'icon': CupertinoIcons.question,
      'description': 'Rasa nyeri atau tidak nyaman di area dada',
      'skipTo': 'bunyi_nafas', // Jika tidak, langsung ke idPertanyaan 12
    },
    {
      'id': 'nyeri_pleuritik',
      'question': 'Apakah nyeri terasa tajam saat bernapas dalam atau batuk?',
      'icon': CupertinoIcons.question,
      'description': 'Pleuritik adalah nyeri tajam yang memburuk saat bernapas atau batuk',
      'conditional': 'nyeri_dada',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'bunyi_nafas',
      'question': 'Apakah anda merasakan bunyi pada setiap tarikan nafas?',
      'icon': CupertinoIcons.question,
      'description': 'Bunyi napas abnormal bisa menunjukkan kondisi tertentu',
      'skipTo': 'penurunan_bb_drastis', // Jika tidak, langsung ke idPertanyaan 15
    },
    {
      'id': 'bunyi_mengi',
      'question': 'Apakah bunyi seperti siulan?',
      'icon': CupertinoIcons.question,
      'description': 'Wheezing/mengi adalah suara siulan saat bernapas yang disebabkan oleh penyempitan saluran napas',
      'conditional': 'bunyi_nafas',
      'requiredValue': ['Ya', 'Kadang'],
      'skipTo': 'penurunan_bb_drastis', // Jika iya, langsung ke idPertanyaan 15
    },
    {
      'id': 'bunyi_ronchi',
      'question': 'Apakah bunyi seperti dengkuran? (ronchi: suara dengkuran karena penyumbatan saluran nafas)',
      'icon': CupertinoIcons.question,
      'description': 'Ronchi adalah suara dengkuran saat bernapas yang disebabkan oleh penyumbatan saluran napas',
      'conditional': 'bunyi_nafas',
      'requiredValue': ['Ya', 'Kadang'],
      'skipIfYes': 'bunyi_mengi', // Hanya ditampilkan jika bunyi_mengi tidak dijawab Ya
    },
    {
      'id': 'penurunan_bb_drastis',
      'question': 'Apakah anda mengalami penurunan berat badan drastis?',
      'icon': CupertinoIcons.question,
      'description': 'Penurunan berat badan yang tidak disengaja dalam waktu singkat',
    },
    {
      'id': 'demam',
      'question': 'Apakah anda demam?',
      'icon': CupertinoIcons.question,
      'description': 'Suhu tubuh meningkat di atas normal',
      'skipTo': 'kelelahan_berkepanjangan', // Jika tidak, langsung ke idPertanyaan 19
    },
    {
      'id': 'demam_pola',
      'question': 'Apakah demam anda memilki pola tertentu? (misal saat malam saja)',
      'icon': CupertinoIcons.question,
      'description': 'Pola demam dapat membantu menentukan penyebab penyakit',
      'conditional': 'demam',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'keringat_malam',
      'question': 'Apakah berkeringat tanpa sebab di malam hari?',
      'icon': CupertinoIcons.question,
      'description': 'Keringat malam dapat menandakan infeksi serius seperti tuberkulosis',
      'conditional': 'demam',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'kelelahan_berkepanjangan',
      'question': 'Apakah anda mengalami kelelahan berkepanjangan?',
      'icon': CupertinoIcons.question,
      'description': 'Merasa lemah dan lelah yang tidak membaik dengan istirahat',
    },
    {
      'id': 'sianosis',
      'question': 'Apakah bibir atau ujung jari anda sedikit membiru/gelap?',
      'icon': CupertinoIcons.question,
      'description': 'Kondisi ini disebut sianosis dan menunjukkan kekurangan oksigen dalam darah',
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
  
  // Kelompokkan pertanyaan berdasarkan kategori (untuk pengembangan lebih lanjut)
  static Map<String, List<Map<String, dynamic>>> getQuestionsByCategory() {
    return {
      'Gejala Pernapasan': questions.where((q) => 
        ['batuk', 'batuk_berdahak', 'dahak_kuning', 'dahak_hijau', 'batuk_berdarah', 'batuk_kronis', 'sesak_nafas', 'sesak_saat_istirahat', 'sesak_saat_berbaring', 'bunyi_nafas', 'bunyi_mengi', 'bunyi_ronchi', 'sianosis'].contains(q['id'])).toList(),
      'Gejala Nyeri': questions.where((q) => 
        ['nyeri_dada', 'nyeri_pleuritik'].contains(q['id'])).toList(),
      'Gejala Umum': questions.where((q) => 
        ['demam', 'demam_pola', 'keringat_malam', 'penurunan_bb_drastis', 'kelelahan_berkepanjangan'].contains(q['id'])).toList(),
    };
  }
}