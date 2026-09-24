import 'package:flutter/cupertino.dart';

class KehangilanQuestions {
  // Daftar pertanyaan gejala kehamilan
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'terlambat_menstruasi',
      'question': 'Apakah siklus menstruasi Anda terlambat lebih dari 7 hari?',
      'icon': CupertinoIcons.calendar_badge_minus,
      'description': 'Keterlambatan menstruasi adalah tanda awal kehamilan yang umum',
      'weight': 12, // Bobot: 12/10 (tanda utama)
    },
    {
      'id': 'mual_muntah',
      'question': 'Apakah Anda mengalami mual atau muntah di pagi hari (morning sickness)?',
      'icon': CupertinoIcons.waveform,
      'description': 'Morning sickness sering dialami pada trimester pertama kehamilan',
      'weight': 8, // Bobot: 8/10
    },
    {
      'id': 'payudara_sensitif',
      'question': 'Apakah Anda merasa payudara menjadi lebih sensitif atau nyeri?',
      'icon': CupertinoIcons.exclamationmark_circle,
      'description': 'Perubahan hormon saat hamil dapat menyebabkan payudara menjadi sensitif',
      'weight': 7, // Bobot: 7/10
    },
    {
      'id': 'kelelahan',
      'question': 'Apakah Anda mengalami kelelahan yang tidak biasa?',
      'icon': CupertinoIcons.bed_double_fill,
      'description': 'Kelelahan ekstrem umum terjadi pada awal kehamilan',
      'weight': 6, // Bobot: 6/10
    },
    {
      'id': 'sering_buang_air',
      'question': 'Apakah Anda lebih sering buang air kecil dari biasanya?',
      'icon': CupertinoIcons.drop_fill,
      'description': 'Peningkatan frekuensi buang air kecil sering terjadi pada kehamilan',
      'weight': 5, // Bobot: 5/10
    },
    {
      'id': 'perubahan_selera',
      'question': 'Apakah Anda mengalami perubahan selera makan atau mengidam makanan tertentu?',
      'icon': CupertinoIcons.heart_fill,
      'description': 'Ngidam atau perubahan selera makan sering terjadi pada kehamilan',
      'weight': 4, // Bobot: 4/10
    },
    {
      'id': 'hubungan_intim',
      'question': 'Apakah Anda pernah melakukan hubungan intim tanpa perlindungan dalam 2 bulan terakhir?',
      'icon': CupertinoIcons.person_2_fill,
      'description': 'Hubungan intim tanpa kontrasepsi dapat menyebabkan kehamilan',
      'weight': 10, // Bobot: 10/10
    },
    {
      'id': 'pusing_sakit_kepala',
      'question': 'Apakah Anda sering mengalami pusing atau sakit kepala ringan?',
      'icon': CupertinoIcons.waveform_path,
      'description': 'Perubahan hormon dan volume darah dapat menyebabkan pusing',
      'weight': 4, // Bobot: 4/10
    },
    {
      'id': 'pembesaran_perut',
      'question': 'Apakah Anda mengalami pembesaran perut atau perasaan kembung yang tidak biasa?',
      'icon': CupertinoIcons.person_crop_circle,
      'description': 'Pembesaran perut bisa menjadi tanda kehamilan pada beberapa minggu awal',
      'weight': 5, // Bobot: 5/10
    },
    // {
    //   'id': 'uji_kehamilan',
    //   'question': 'Apakah Anda telah melakukan tes kehamilan dengan hasil positif?',
    //   'icon': CupertinoIcons.checkmark_shield_fill,
    //   'description': 'Tes kehamilan rumah umumnya cukup akurat setelah keterlambatan menstruasi',
    //   'weight': 15, // Bobot: 15/10 (tanda paling kuat)
    // },
    {
      'id': 'kram_perut',
      'question': 'Apakah Anda mengalami kram perut ringan yang mirip seperti saat menstruasi?',
      'icon': CupertinoIcons.waveform_path_ecg,
      'description': 'Kram ringan bisa terjadi saat embrio menempel pada dinding rahim',
      'weight': 5, // Bobot: 5/10
    },
    {
      'id': 'emosi_berubah',
      'question': 'Apakah Anda mengalami perubahan suasana hati (mood swing) yang tidak biasa?',
      'icon': CupertinoIcons.arrow_2_circlepath,
      'description': 'Fluktuasi hormon saat hamil dapat menyebabkan perubahan emosi',
      'weight': 4, // Bobot: 4/10
    },
  ];

  // Filter pertanyaan yang aktif berdasarkan jawaban sebelumnya
  static List<Map<String, dynamic>> activeQuestions(Map<String, String> answers) {
    return questions.where((q) {
      String questionId = q['id'];
      
      // Skip conditional logic untuk pertanyaan yang perlu dilewati
      bool shouldSkip = false;
      
      // Check if any question with skipRelatedQuestions that includes this question ID has been answered "Ya"
      for (var otherQuestion in questions) {
        if (otherQuestion.containsKey('skipRelatedQuestions') && 
            otherQuestion['skipRelatedQuestions'].contains(questionId) &&
            answers.containsKey(otherQuestion['id']) && 
            answers[otherQuestion['id']] == 'Ya') {
          shouldSkip = true;
          break;
        }
      }
      
      if (shouldSkip) {
        return false;
      }
      
      // Continue with original conditional logic
      if (!q.containsKey('conditional')) return true;
      
      String conditionalField = q['conditional'];
      List<String> requiredValues = List<String>.from(q['requiredValue']);
      
      // Cek apakah kondisi terpenuhi
      bool conditionalMet = answers.containsKey(conditionalField) && 
                          requiredValues.contains(answers[conditionalField]);
      
      // Cek apakah ada kondisi skip berdasarkan jawaban Ya pada pertanyaan lain
      if (q.containsKey('skipIfYes')) {
        String skipField = q['skipIfYes'];
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
  
  // Mendapatkan bobot pertanyaan
  static int getQuestionWeight(String questionId) {
    final question = questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {'weight': 0},
    );
    
    return question['weight'] as int;
  }
  
  // Evaluasi kondisional untuk pertanyaan
  static bool shouldShowQuestion(String questionId, Map<String, String> answers) {
    final question = questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {},
    );
    
    if (question.isEmpty) return false;
    
    // Check if this question should be skipped due to a related question's answer
    for (var otherQuestion in questions) {
      if (otherQuestion.containsKey('skipRelatedQuestions') && 
          otherQuestion['skipRelatedQuestions'].contains(questionId) &&
          answers.containsKey(otherQuestion['id']) && 
          answers[otherQuestion['id']] == 'Ya') {
        return false;
      }
    }
    
    if (!question.containsKey('conditional')) return true;
    
    String conditionalField = question['conditional'];
    List<String> requiredValues = List<String>.from(question['requiredValue']);
    
    bool conditionalMet = answers.containsKey(conditionalField) && 
                        requiredValues.contains(answers[conditionalField]);
    
    // Cek apakah ada kondisi skip berdasarkan jawaban Ya pada pertanyaan lain
    if (question.containsKey('skipIfYes')) {
      String skipField = question['skipIfYes'];
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
    int currentIndex = questions.indexWhere((q) => q['id'] == currentId);
    if (currentIndex == -1 || currentIndex >= questions.length - 1) return '';
    
    // Cari pertanyaan berikutnya yang seharusnya ditampilkan (yang memenuhi kondisi shouldShowQuestion)
    for (int i = currentIndex + 1; i < questions.length; i++) {
      if (shouldShowQuestion(questions[i]['id'], allAnswers)) {
        return questions[i]['id'];
      }
    }
    
    return '';
  }
  
  // Hitung skor risiko berdasarkan jawaban
  static Map<String, dynamic> calculatePregnancyScore(Map<String, String> answers) {
    int totalScore = 0;
    int maxPossibleScore = 0;
    
    // Hitung skor berdasarkan jawaban dan bobot
    questions.forEach((question) {
      String id = question['id'];
      int weight = question['weight'] ?? 0;
      
      // Jangan hitung skor untuk pertanyaan yang dilewati
      bool shouldSkip = false;
      for (var otherQuestion in questions) {
        if (otherQuestion.containsKey('skipRelatedQuestions') && 
            otherQuestion['skipRelatedQuestions'].contains(id) &&
            answers.containsKey(otherQuestion['id']) && 
            answers[otherQuestion['id']] == 'Ya') {
          shouldSkip = true;
          break;
        }
      }
      
      if (!shouldSkip) {
        maxPossibleScore += weight;
        
        if (answers.containsKey(id)) {
          if (answers[id] == 'Ya') {
            totalScore += weight;
          } else if (answers[id] == 'Mungkin') {
            totalScore += (weight / 2).round(); // Setengah bobot untuk jawaban "Mungkin"
          }
        }
      }
    });
    
    // Hitung persentase kemungkinan kehamilan
    double pregnancyPercentage = maxPossibleScore > 0 ? (totalScore / maxPossibleScore) * 100 : 0;
    
    // Tentukan kategori kehamilan
    String pregnancyCategory;
    if (pregnancyPercentage >= 80) {
      pregnancyCategory = 'Kemungkinan Besar Hamil';
    } else if (pregnancyPercentage >= 50) {
      pregnancyCategory = 'Kemungkinan Hamil';
    } else if (pregnancyPercentage >= 20) {
      pregnancyCategory = 'Kemungkinan Kecil Hamil';
    } else {
      pregnancyCategory = 'Kemungkinan Tidak Hamil';
    }
    
    return {
      'score': totalScore,
      'maxScore': maxPossibleScore,
      'percentage': pregnancyPercentage,
      'category': pregnancyCategory,
    };
  }
}