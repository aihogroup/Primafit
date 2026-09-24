import 'package:flutter/cupertino.dart';

class KankerRahimQuestions {
  // Daftar pertanyaan gejala
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'riwayat_keluarga',
      'question': 'Apakah ada anggota keluarga inti (orang tua, saudara kandung, atau anak) yang pernah terdiagnosis kanker rahim atau kanker endometrium?',
      'icon': CupertinoIcons.person_2_fill,
      'description': 'Riwayat kanker rahim dalam keluarga meningkatkan risiko 2-3 kali lipat',
      'weight': 10, // Bobot: 10/10
    },
    {
      'id': 'pernah_kanker',
      'question': 'Apakah Anda pernah didiagnosis kanker payudara, kanker ovarium, atau kanker usus besar sebelumnya?',
      'icon': CupertinoIcons.doc_text,
      'description': 'Riwayat kanker jenis tertentu meningkatkan risiko kanker rahim',
      'weight': 10, // Bobot: 10/10
    },
    {
      'id': 'usia_lebih_50',
      'question': 'Apakah usia Anda saat ini lebih dari 50 tahun?',
      'icon': CupertinoIcons.person_crop_circle,
      'description': 'Risiko kanker rahim meningkat signifikan setelah usia 50 tahun',
      'weight': 7, // Bobot: 7/10
    },
    {
      'id': 'perdarahan_abnormal',
      'question': 'Apakah Anda mengalami perdarahan di luar masa menstruasi atau perdarahan setelah menopause?',
      'icon': CupertinoIcons.drop_fill,
      'description': 'Perdarahan abnormal atau pasca menopause adalah gejala utama kanker rahim',
      'weight': 12, // Bobot: 12/10 (gejala fisik utama)
    },
    {
      'id': 'nyeri_panggul',
      'question': 'Apakah Anda mengalami nyeri di area panggul yang tidak berhubungan dengan menstruasi?',
      'icon': CupertinoIcons.waveform_path,
      'description': 'Nyeri panggul dapat menjadi tanda kanker rahim stadium lanjut',
      'weight': 8, // Bobot: 8/10
    },
    {
      'id': 'nyeri_saat_berhubungan',
      'question': 'Apakah Anda mengalami nyeri saat berhubungan seksual?',
      'icon': CupertinoIcons.exclamationmark_circle,
      'description': 'Nyeri saat berhubungan seksual bisa menjadi tanda perubahan pada rahim',
      'weight': 7, // Bobot: 7/10
    },
    {
      'id': 'keputihan_abnormal',
      'question': 'Apakah Anda mengalami keputihan berbau atau berwarna tidak normal (kekuningan, kehijauan, atau berdarah)?',
      'icon': CupertinoIcons.bandage,
      'description': 'Keputihan abnormal bisa mengindikasikan infeksi atau kondisi serius pada rahim',
      'weight': 9, // Bobot: 9/10
    },
    {
      'id': 'penurunan_berat',
      'question': 'Apakah Anda mengalami penurunan berat badan tanpa sebab yang jelas (lebih dari 5 kg dalam 6 bulan terakhir)?',
      'icon': CupertinoIcons.arrow_down_circle,
      'description': 'Penurunan berat badan tak disengaja bisa menjadi gejala kanker stadium lanjut',
      'weight': 9, // Bobot: 9/10
    },
    {
      'id': 'kelelahan',
      'question': 'Apakah Anda mengalami kelelahan ekstrem yang tidak membaik dengan istirahat?',
      'icon': CupertinoIcons.bed_double_fill,
      'description': 'Kelelahan persisten bisa mengindikasikan anemia akibat perdarahan internal',
      'weight': 6, // Bobot: 6/10
    },
    {
      'id': 'obesitas',
      'question': 'Apakah Anda memiliki indeks massa tubuh (IMT) di atas 30 atau mengalami obesitas?',
      'icon': CupertinoIcons.person_fill,
      'description': 'Obesitas meningkatkan risiko kanker rahim karena peningkatan estrogen',
      'weight': 5, // Bobot: 5/10
    },
    {
      'id': 'diabetes',
      'question': 'Apakah Anda menderita diabetes?',
      'icon': CupertinoIcons.gauge,
      'description': 'Diabetes tipe 2 meningkatkan risiko kanker rahim hingga 2 kali lipat',
      'weight': 5, // Bobot: 5/10
    },
    {
      'id': 'tidak_memiliki_anak',
      'question': 'Apakah Anda tidak pernah melahirkan anak (nulipara)?',
      'icon': CupertinoIcons.person_badge_minus,
      'description': 'Tidak pernah melahirkan meningkatkan paparan estrogen seumur hidup',
      'weight': 4, // Bobot: 4/10
    },
    {
      'id': 'menstruasi_dini',
      'question': 'Apakah Anda mulai menstruasi pada usia sangat muda (sebelum 12 tahun)?',
      'icon': CupertinoIcons.calendar_badge_minus,
      'description': 'Menstruasi dini meningkatkan paparan estrogen seumur hidup',
      'weight': 4, // Bobot: 4/10
    },
    {
      'id': 'menopause_terlambat',
      'question': 'Apakah Anda mengalami menopause pada usia lanjut (setelah 55 tahun) atau belum menopause di atas usia tersebut?',
      'icon': CupertinoIcons.calendar_badge_plus,
      'description': 'Menopause terlambat meningkatkan paparan estrogen seumur hidup',
      'weight': 4, // Bobot: 4/10
    },
    {
      'id': 'terapi_tamoxifen',
      'question': 'Apakah Anda sedang atau pernah menjalani terapi Tamoxifen untuk kanker payudara?',
      'icon': CupertinoIcons.capsule,
      'description': 'Pengobatan Tamoxifen untuk kanker payudara meningkatkan risiko kanker rahim',
      'weight': 8, // Bobot: 8/10
    },
    {
      'id': 'terapi_hormon',
      'question': 'Apakah Anda menggunakan terapi penggantian hormon (HRT) dengan estrogen tanpa progesteron?',
      'icon': CupertinoIcons.person,
      'description': 'HRT dengan estrogen saja dapat meningkatkan risiko kanker rahim',
      'weight': 7, // Bobot: 7/10
    },
    {
      'id': 'pcos',
      'question': 'Apakah Anda didiagnosis dengan Sindrom Ovarium Polikistik (PCOS)?',
      'icon': CupertinoIcons.waveform_circle,
      'description': 'PCOS meningkatkan risiko karena ketidakseimbangan hormonal',
      'weight': 6, // Bobot: 6/10
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