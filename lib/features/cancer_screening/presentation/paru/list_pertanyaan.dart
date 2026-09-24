import 'package:flutter/cupertino.dart';

class KankerParuQuestions {
  // Daftar pertanyaan gejala
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'perokok_aktif',
      'question': 'Apakah Anda merupakan perokok aktif? (Merokok dalam kurun waktu 1 tahun terakhir)',
      'icon': CupertinoIcons.smoke,
      'description': 'Merokok aktif adalah faktor risiko utama kanker paru-paru',
      'weight': 10, // Bobot: 10/10
      // Add skipIfYes to skip bekas_perokok if this question is answered "Ya"
      'skipRelatedQuestions': ['bekas_perokok'],
    },
    {
      'id': 'perokok_pasif',
      'question': 'Apakah Anda merupakan perokok pasif? (Tidak merokok, namun terpapar asap rokok di rumah atau di tempat kerja)',
      'icon': CupertinoIcons.smoke_fill,
      'description': 'Paparan asap rokok lingkungan juga meningkatkan risiko kanker paru',
      'weight': 7, // Bobot: 7/10
    },
    {
      'id': 'bekas_perokok',
      'question': 'Apakah Anda merupakan bekas perokok? (Berhenti merokok sejak kurang dari 15 tahun yang lalu)',
      'icon': CupertinoIcons.nosign,
      'description': 'Risiko kanker paru masih ada pada mantan perokok terutama yang baru berhenti',
      'weight': 8, // Bobot: 8/10
    },
    {
      'id': 'riwayat_kanker',
      'question': 'Apakah Anda menderita kanker sebelumnya? (Pernah didiagnosis atau menderita kanker)',
      'icon': CupertinoIcons.doc_text,
      'description': 'Riwayat kanker sebelumnya meningkatkan risiko terkena kanker jenis lain',
      'weight': 9, // Bobot: 9/10
    },
    {
      'id': 'riwayat_keluarga',
      'question': 'Apakah ada keluarga (ayah/ibu/saudara kandung) yang sedang atau pernah menderita kanker? (Riwayat kanker dalam keluarga)',
      'icon': CupertinoIcons.person_2_fill,
      'description': 'Faktor genetik dapat meningkatkan risiko kanker paru-paru',
      'weight': 6, // Bobot: 6/10
    },
    {
      'id': 'paparan_karsinogen',
      'question': 'Apakah Anda sedang atau pernah bekerja di lingkungan yang terpapar zat pencetus kanker (karsinogen) yang tinggi selama lebih dari 5 tahun? (Bekerja sebagai buruh pabrik, tukang bangunan, pekerja di tambang, pekerja bengkel, sopir, dll.)',
      'icon': CupertinoIcons.exclamationmark_shield,
      'description': 'Paparan zat karsinogen di tempat kerja meningkatkan risiko kanker paru',
      'weight': 8, // Bobot: 8/10
    },
    {
      'id': 'polusi_tinggi',
      'question': 'Apakah Anda sedang atau pernah tinggal di lingkungan dengan tingkat polusi yang tinggi selama lebih dari 5 tahun? (Rumah di pinggir jalan raya, pemukiman dekat pabrik, dekat dengan pembuangan sampah)',
      'icon': CupertinoIcons.cloud_fill,
      'description': 'Paparan polusi udara jangka panjang meningkatkan risiko kanker paru',
      'weight': 7, // Bobot: 7/10
    },
    {
      'id': 'rumah_tidak_sehat',
      'question': 'Apakah rumah Anda tidak sehat? (Atap terbuat dari asbes, tidak ada ventilasi, lantai tanpa ubin)',
      'icon': CupertinoIcons.house_alt,
      'description': 'Kondisi rumah tidak sehat dapat meningkatkan paparan zat berbahaya',
      'weight': 6, // Bobot: 6/10
    },
    {
      'id': 'riwayat_penyakit_paru',
      'question': 'Apakah Anda sedang atau pernah mengidap penyakit tuberkulosis paru atau penyakit kronik paru lainnya? (Riwayat penyakit paru seperti TBC)',
      'icon': CupertinoIcons.person,
      'description': 'Riwayat penyakit paru kronis meningkatkan risiko kanker paru',
      'weight': 8, // Bobot: 8/10
    },
    {
      'id': 'gejala_respirasi',
      'question': 'Apakah Anda sedang mengalami gejala respirasi? (Batuk untuk jangka waktu yang lama, sesak nafas, nyeri dada)',
      'icon': CupertinoIcons.wind,
      'description': 'Gejala respirasi persisten bisa menjadi tanda kanker paru',
      'weight': 9, // Bobot: 9/10
    },
  ];

  // Filter pertanyaan yang aktif berdasarkan jawaban sebelumnya
  static List<Map<String, dynamic>> activeQuestions(Map<String, String> answers) {
    return questions.where((q) {
      final String questionId = q['id'];
      
      // Skip bekas_perokok question if user answered "Ya" to perokok_aktif
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
  
  // Hitung skor risiko berdasarkan jawaban
  static Map<String, dynamic> calculateRiskScore(Map<String, String> answers) {
    int totalScore = 0;
    int maxPossibleScore = 0;
    
    // Hitung skor berdasarkan jawaban dan bobot
    for (var question in questions) {
      final String id = question['id'];
      final int weight = question['weight'] ?? 0;
      
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
    }
    
    // Hitung persentase risiko
    final double riskPercentage = maxPossibleScore > 0 ? (totalScore / maxPossibleScore) * 100 : 0;
    
    // Tentukan kategori risiko sesuai dengan PenyakitParu.penyakitInfo di output_paru.dart
    String riskCategory;
    if (riskPercentage >= 80) {
      riskCategory = 'Risiko Tinggi';
    } else if (riskPercentage >= 50) {
      riskCategory = 'Risiko Sedang';
    } else if (riskPercentage >= 20) {
      riskCategory = 'Risiko Rendah';
    } else {
      riskCategory = 'Tidak Ada Risiko';
    }
    
    return {
      'score': totalScore,
      'maxScore': maxPossibleScore,
      'percentage': riskPercentage,
      'category': riskCategory,
    };
  }
}