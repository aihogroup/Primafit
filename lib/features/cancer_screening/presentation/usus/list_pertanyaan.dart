import 'package:flutter/cupertino.dart';

class KankerUsusQuestions {
  // Daftar pertanyaan gejala
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'riwayat_keluarga',
      'question': 'Apakah ada anggota keluarga inti (orang tua, saudara kandung, atau anak) yang pernah terdiagnosis kanker usus besar (kolorektal)?',
      'icon': CupertinoIcons.person_2_fill,
      'description': 'Riwayat kanker usus besar dalam keluarga meningkatkan risiko 2-3 kali lipat',
      'weight': 10, // Bobot: 10/10
    },
    {
      'id': 'pernah_kanker',
      'question': 'Apakah Anda pernah didiagnosis kanker usus besar sebelumnya atau memiliki riwayat polip usus?',
      'icon': CupertinoIcons.doc_text,
      'description': 'Riwayat polip usus atau kanker kolorektal sebelumnya meningkatkan risiko kanker usus besar baru',
      'weight': 10, // Bobot: 10/10
    },
    {
      'id': 'penyakit_ibd',
      'question': 'Apakah Anda pernah didiagnosis dengan penyakit radang usus (Inflammatory Bowel Disease) seperti Colitis Ulserativa atau penyakit Crohn?',
      'icon': CupertinoIcons.waveform_path,
      'description': 'Penyakit radang usus kronis meningkatkan risiko kanker kolorektal',
      'weight': 8, // Bobot: 8/10
    },
    {
      'id': 'usia_lebih_50',
      'question': 'Apakah usia Anda saat ini lebih dari 50 tahun?',
      'icon': CupertinoIcons.person_crop_circle,
      'description': 'Risiko kanker usus besar meningkat signifikan setelah usia 50 tahun',
      'weight': 7, // Bobot: 7/10
    },
    {
      'id': 'perubahan_bab',
      'question': 'Apakah Anda mengalami perubahan pola buang air besar (diare atau sembelit) yang berlangsung lebih dari 2 minggu?',
      'icon': CupertinoIcons.exclamationmark_circle,
      'description': 'Perubahan kebiasaan buang air besar yang persisten merupakan gejala umum kanker kolorektal',
      'weight': 9, // Bobot: 9/10
    },
    {
      'id': 'darah_feses',
      'question': 'Apakah Anda pernah menemukan darah dalam tinja/feses (berwarna merah atau hitam)?',
      'icon': CupertinoIcons.drop_fill,
      'description': 'Darah dalam tinja bisa menjadi tanda perdarahan pada saluran pencernaan',
      'weight': 12, // Bobot: 12/10 (gejala fisik lebih berbobot)
    },
    {
      'id': 'nyeri_perut',
      'question': 'Apakah Anda sering mengalami nyeri atau kram perut yang tidak kunjung membaik?',
      'icon': CupertinoIcons.gauge,
      'description': 'Nyeri perut berkepanjangan bisa mengindikasikan masalah pada usus',
      'weight': 8, // Bobot: 8/10
    },
    {
      'id': 'penurunan_berat',
      'question': 'Apakah Anda mengalami penurunan berat badan tanpa sebab yang jelas (lebih dari 5 kg dalam 6 bulan terakhir)?',
      'icon': CupertinoIcons.arrow_down_circle,
      'description': 'Penurunan berat badan tak disengaja bisa menjadi gejala kanker',
      'weight': 9, // Bobot: 9/10
    },
    {
      'id': 'kelelahan',
      'question': 'Apakah Anda mengalami kelelahan kronis meskipun dengan istirahat yang cukup?',
      'icon': CupertinoIcons.bed_double_fill,
      'description': 'Kelelahan persisten bisa mengindikasikan anemia akibat perdarahan internal',
      'weight': 6, // Bobot: 6/10
    },
    {
      'id': 'diet_daging_merah',
      'question': 'Apakah Anda sering mengkonsumsi daging merah atau daging olahan (lebih dari 3 kali seminggu)?',
      'icon': CupertinoIcons.cart_fill,
      'description': 'Konsumsi daging merah dan olahan tinggi berkaitan dengan peningkatan risiko kanker usus',
      'weight': 5, // Bobot: 5/10
    },
    {
      'id': 'obesitas',
      'question': 'Apakah Anda mengalami kelebihan berat badan signifikan atau obesitas?',
      'icon': CupertinoIcons.person_fill,
      'description': 'Obesitas meningkatkan risiko kanker usus besar dan jenis kanker lainnya',
      'weight': 5, // Bobot: 5/10
    },
    {
      'id': 'kurang_aktivitas',
      'question': 'Apakah Anda jarang melakukan aktivitas fisik (kurang dari 150 menit aktivitas sedang per minggu)?',
      'icon': CupertinoIcons.timer,
      'description': 'Gaya hidup sedentari meningkatkan risiko kanker kolorektal',
      'weight': 4, // Bobot: 4/10
    },
    {
      'id': 'merokok_alkohol',
      'question': 'Apakah Anda merokok atau mengkonsumsi alkohol secara rutin (lebih dari 1 gelas per hari)?',
      'icon': CupertinoIcons.smoke,
      'description': 'Merokok dan konsumsi alkohol berlebih meningkatkan risiko kanker kolorektal',
      'weight': 5, // Bobot: 5/10
    },
  ];

  // Filter pertanyaan yang aktif berdasarkan jawaban sebelumnya
  static List<Map<String, dynamic>> activeQuestions(Map<String, String> answers) {
    return questions.where((q) {
      final String questionId = q['id'];
      
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