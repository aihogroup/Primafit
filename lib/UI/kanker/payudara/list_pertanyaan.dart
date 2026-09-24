import 'package:flutter/cupertino.dart';

class KankerPayudaraQuestions {
  // Daftar pertanyaan gejala
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'riwayat_keluarga',
      'question': 'Apakah ada anggota keluarga inti (ibu, saudara perempuan, atau anak perempuan) yang pernah terdiagnosis kanker payudara?',
      'icon': CupertinoIcons.person_2_fill,
      'description': 'Riwayat kanker payudara dalam keluarga meningkatkan risiko 2-3 kali lipat',
      'weight': 10, // Bobot: 10/10
    },
    {
      'id': 'pernah_kanker',
      'question': 'Apakah Anda pernah didiagnosis kanker payudara sebelumnya atau memiliki riwayat tumor jinak payudara?',
      'icon': CupertinoIcons.doc_text,
      'description': 'Riwayat penyakit payudara sebelumnya dapat meningkatkan risiko kanker payudara baru',
      'weight': 10, // Bobot: 10/10
    },
    {
      'id': 'menstruasi_dini',
      'question': 'Apakah Anda mengalami menstruasi pertama (menarche) sebelum usia 12 tahun?',
      'icon': CupertinoIcons.calendar,
      'description': 'Menstruasi dini berarti paparan estrogen yang lebih lama dalam hidup',
      'weight': 6, // Bobot: 6/10
    },
    {
      'id': 'menopause_terlambat',
      'question': 'Apakah Anda mengalami menopause setelah usia 55 tahun?',
      'icon': CupertinoIcons.calendar_badge_plus,
      'description': 'Menopause yang terlambat berarti paparan estrogen yang lebih lama dalam hidup',
      'weight': 6, // Bobot: 6/10
    },
    {
      'id': 'usia_lebih_50',
      'question': 'Apakah usia Anda saat ini lebih dari 50 tahun?',
      'icon': CupertinoIcons.person_crop_circle,
      'description': 'Risiko kanker payudara meningkat seiring bertambahnya usia',
      'weight': 5, // Bobot: 5/10
    },
    {
      'id': 'tidak_menyusui',
      'question': 'Jika Anda pernah melahirkan, apakah Anda tidak pernah menyusui atau menyusui kurang dari 1 tahun total untuk semua kelahiran?',
      'icon': CupertinoIcons.person_2,
      'description': 'Menyusui berfungsi sebagai faktor pelindung terhadap kanker payudara',
      'weight': 4, // Bobot: 4/10
    },
    {
      'id': 'terapi_hormon',
      'question': 'Apakah Anda menggunakan atau pernah menggunakan terapi penggantian hormon (HRT) yang mengandung estrogen dan progesteron selama lebih dari 5 tahun?',
      'icon': CupertinoIcons.capsule_fill,
      'description': 'Penggunaan HRT jangka panjang dapat meningkatkan risiko kanker payudara',
      'weight': 7, // Bobot: 7/10
    },
    {
      'id': 'obesitas',
      'question': 'Apakah Anda mengalami kelebihan berat badan signifikan atau obesitas?',
      'icon': CupertinoIcons.person_fill,
      'description': 'Obesitas meningkatkan risiko kanker payudara, terutama setelah menopause',
      'weight': 5, // Bobot: 5/10
    },
    {
      'id': 'alkohol',
      'question': 'Apakah Anda mengonsumsi alkohol secara rutin (lebih dari 1 gelas per hari)?',
      'icon': CupertinoIcons.person,
      'description': 'Konsumsi alkohol berkaitan dengan peningkatan risiko kanker payudara',
      'weight': 4, // Bobot: 4/10
    },
    {
      'id': 'radiasi',
      'question': 'Apakah Anda pernah menjalani terapi radiasi di area dada, misalnya untuk pengobatan kanker lain?',
      'icon': CupertinoIcons.rays,
      'description': 'Paparan radiasi di area dada meningkatkan risiko kanker payudara',
      'weight': 6, // Bobot: 6/10
    },
    {
      'id': 'benjolan',
      'question': 'Apakah Anda menemukan benjolan atau penebalan di payudara yang tidak biasa atau perubahan pada kulit payudara?',
      'icon': CupertinoIcons.exclamationmark_circle,
      'description': 'Benjolan atau perubahan pada payudara bisa menjadi tanda awal kanker payudara',
      'weight': 12, // Bobot: 12/10 (gejala fisik lebih berbobot)
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
  static Map<String, dynamic> calculateRiskScore(Map<String, String> answers) {
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
    
    // Hitung persentase risiko
    double riskPercentage = maxPossibleScore > 0 ? (totalScore / maxPossibleScore) * 100 : 0;
    
    // Tentukan kategori risiko
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