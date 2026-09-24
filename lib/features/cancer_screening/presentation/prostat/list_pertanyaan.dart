import 'package:flutter/cupertino.dart';

class KankerProstatQuestions {
  // Daftar pertanyaan gejala
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'riwayat_keluarga',
      'question': 'Apakah ada anggota keluarga inti (ayah, saudara laki-laki) yang pernah terdiagnosis kanker prostat?',
      'icon': CupertinoIcons.person_2_fill,
      'description': 'Riwayat kanker prostat dalam keluarga meningkatkan risiko 2-3 kali lipat',
      'weight': 10, // Bobot: 10/10
    },
    {
      'id': 'usia_lebih_50',
      'question': 'Apakah usia Anda saat ini lebih dari 50 tahun?',
      'icon': CupertinoIcons.person_crop_circle,
      'description': 'Risiko kanker prostat meningkat signifikan setelah usia 50 tahun',
      'weight': 8, // Bobot: 8/10
    },
    {
      'id': 'kesulitan_buang_air',
      'question': 'Apakah Anda mengalami kesulitan untuk memulai buang air kecil?',
      'icon': CupertinoIcons.drop,
      'description': 'Kesulitan untuk memulai aliran urine adalah gejala umum masalah prostat',
      'weight': 9, // Bobot: 9/10
    },
    {
      'id': 'sering_buang_air',
      'question': 'Apakah Anda sering buang air kecil (lebih dari 8 kali dalam sehari)?',
      'icon': CupertinoIcons.clock,
      'description': 'Frekuensi buang air kecil yang meningkat dapat mengindikasikan masalah prostat',
      'weight': 7, // Bobot: 7/10
    },
    {
      'id': 'bangun_malam_kencing',
      'question': 'Apakah Anda sering terbangun di malam hari untuk buang air kecil (lebih dari 2 kali)?',
      'icon': CupertinoIcons.moon_fill,
      'description': 'Nokturia (bangun malam untuk kencing) adalah gejala umum pembesaran prostat',
      'weight': 7, // Bobot: 7/10
    },
    {
      'id': 'aliran_urine_lemah',
      'question': 'Apakah aliran urine Anda lemah atau terputus-putus?',
      'icon': CupertinoIcons.waveform,
      'description': 'Aliran urine yang lemah dapat menandakan adanya obstruksi pada saluran kemih',
      'weight': 8, // Bobot: 8/10
    },
    {
      'id': 'mengedan_kencing',
      'question': 'Apakah Anda perlu mengedan saat buang air kecil?',
      'icon': CupertinoIcons.arrow_down_circle,
      'description': 'Mengedan saat kencing menunjukkan adanya resistensi pada saluran kemih',
      'weight': 6, // Bobot: 6/10
    },
    {
      'id': 'urine_terputus',
      'question': 'Apakah aliran urine Anda sering terhenti tiba-tiba sebelum selesai?',
      'icon': CupertinoIcons.stop_fill,
      'description': 'Aliran urine yang terputus dapat disebabkan oleh obstruksi prostat',
      'weight': 6, // Bobot: 6/10
    },
    {
      'id': 'rasa_tidak_tuntas',
      'question': 'Apakah Anda sering merasa kandung kemih tidak kosong setelah buang air kecil?',
      'icon': CupertinoIcons.person,
      'description': 'Perasaan tidak tuntas saat kencing bisa menandakan masalah prostat',
      'weight': 5, // Bobot: 5/10
    },
    {
      'id': 'nyeri_saat_kencing',
      'question': 'Apakah Anda mengalami nyeri atau rasa terbakar saat buang air kecil?',
      'icon': CupertinoIcons.flame,
      'description': 'Nyeri saat kencing bisa mengindikasikan infeksi atau peradangan prostat',
      'weight': 8, // Bobot: 8/10
    },
    {
      'id': 'darah_urine',
      'question': 'Apakah Anda pernah melihat darah dalam urine?',
      'icon': CupertinoIcons.drop_fill,
      'description': 'Darah dalam urine (hematuria) adalah gejala yang perlu diwaspadai',
      'weight': 10, // Bobot: 10/10
    },
    {
      'id': 'darah_air_mani',
      'question': 'Apakah Anda pernah melihat darah dalam air mani (semen)?',
      'icon': CupertinoIcons.drop_triangle,
      'description': 'Darah dalam semen (hematospermia) bisa menjadi tanda kanker prostat',
      'weight': 10, // Bobot: 10/10
    },
    {
      'id': 'nyeri_panggul',
      'question': 'Apakah Anda mengalami nyeri atau ketidaknyamanan di area panggul?',
      'icon': CupertinoIcons.waveform_path,
      'description': 'Nyeri panggul dapat terjadi pada kanker prostat stadium lanjut',
      'weight': 9, // Bobot: 9/10
    },
    {
      'id': 'nyeri_punggung',
      'question': 'Apakah Anda mengalami nyeri punggung bagian bawah yang tidak hilang?',
      'icon': CupertinoIcons.waveform_path_ecg,
      'description': 'Nyeri punggung bawah bisa mengindikasikan penyebaran kanker ke tulang',
      'weight': 7, // Bobot: 7/10
    },
    {
      'id': 'disfungsi_ereksi',
      'question': 'Apakah Anda mengalami kesulitan untuk mendapatkan atau mempertahankan ereksi?',
      'icon': CupertinoIcons.arrow_up_arrow_down,
      'description': 'Disfungsi ereksi kadang terjadi pada pria dengan masalah prostat',
      'weight': 6, // Bobot: 6/10
    },
    {
      'id': 'penurunan_berat',
      'question': 'Apakah Anda mengalami penurunan berat badan tanpa sebab yang jelas (lebih dari 5 kg dalam 6 bulan terakhir)?',
      'icon': CupertinoIcons.arrow_down_circle,
      'description': 'Penurunan berat badan tak disengaja bisa menjadi gejala kanker stadium lanjut',
      'weight': 9, // Bobot: 9/10
    },
    {
      'id': 'ras_afrika',
      'question': 'Apakah Anda memiliki keturunan Afrika atau Afrika-Amerika?',
      'icon': CupertinoIcons.globe,
      'description': 'Pria keturunan Afrika memiliki risiko kanker prostat lebih tinggi',
      'weight': 4, // Bobot: 4/10
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