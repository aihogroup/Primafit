import 'package:flutter/cupertino.dart';

class MentalQuestions {
  // Daftar pertanyaan gejala kesehatan mental
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'perasaan_sedih',
      'question': 'Apakah Anda merasa sedih atau putus asa secara terus menerus?',
      'icon': CupertinoIcons.question,
      'description': 'Perasaan sedih yang menetap dan tidak membaik dalam waktu lama, meskipun situasi membaik',
      'skipTo': 'kehilangan_minat', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'sedih_berkelanjutan',
      'question': 'Apakah perasaan sedih ini bertahan lebih dari 2 minggu?',
      'icon': CupertinoIcons.question,
      'description': 'Durasi perasaan sedih yang berkelanjutan merupakan indikator penting',
      'conditional': 'perasaan_sedih',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'kehilangan_minat',
      'question': 'Apakah Anda kehilangan minat atau kesenangan dalam aktivitas yang biasa disukai?',
      'icon': CupertinoIcons.question,
      'description': 'Kehilangan ketertarikan pada aktivitas yang sebelumnya dinikmati merupakan ciri utama depresi',
      'skipTo': 'kecemasan_berlebihan', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'kehilangan_minat_durasi',
      'question': 'Apakah kehilangan minat ini berlangsung hampir setiap hari?',
      'icon': CupertinoIcons.question,
      'description': 'Frekuensi kehilangan minat penting untuk diagnosis',
      'conditional': 'kehilangan_minat',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'kecemasan_berlebihan',
      'question': 'Apakah Anda merasa cemas berlebihan atau ketakutan yang tidak rasional?',
      'icon': CupertinoIcons.question,
      'description': 'Perasaan cemas yang tidak proporsional terhadap situasi sebenarnya',
      'skipTo': 'serangan_panik', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'cemas_mengganggu',
      'question': 'Apakah kecemasan ini mengganggu aktivitas sehari-hari Anda?',
      'icon': CupertinoIcons.question,
      'description': 'Kecemasan yang memengaruhi fungsi normal kehidupan sehari-hari',
      'conditional': 'kecemasan_berlebihan',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'serangan_panik',
      'question': 'Apakah Anda pernah mengalami serangan panik berulang?',
      'icon': CupertinoIcons.question,
      'description': 'Serangan kecemasan mendadak dengan gejala fisik seperti jantung berdebar, sesak napas, dan ketakutan ekstrem',
      'skipTo': 'gangguan_tidur', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'gejala_fisik_panik',
      'question': 'Apakah serangan panik Anda disertai gejala fisik seperti jantung berdebar atau sesak napas?',
      'icon': CupertinoIcons.question,
      'description': 'Gejala fisik sering menyertai serangan panik dan dapat dirasakan sangat mengancam',
      'conditional': 'serangan_panik',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'gangguan_tidur',
      'question': 'Apakah Anda mengalami gangguan tidur seperti sulit tidur atau terlalu banyak tidur?',
      'icon': CupertinoIcons.question,
      'description': 'Gangguan tidur mencakup insomnia (sulit tidur) atau hipersomnia (tidur berlebihan)',
      'skipTo': 'mudah_marah', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'tipe_gangguan_tidur',
      'question': 'Apakah Anda lebih sering mengalami sulit tidur daripada terlalu banyak tidur?',
      'icon': CupertinoIcons.question,
      'description': 'Membedakan antara insomnia dan hipersomnia untuk diagnosis yang lebih spesifik',
      'conditional': 'gangguan_tidur',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'mudah_marah',
      'question': 'Apakah Anda merasa mudah marah atau mengalami emosi yang meledak-ledak?',
      'icon': CupertinoIcons.question,
      'description': 'Emosi yang sulit dikontrol dan reaksi berlebihan terhadap situasi kecil',
      'skipTo': 'sulit_konsentrasi', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'kontrol_emosi',
      'question': 'Apakah Anda merasa kesulitan mengontrol kemarahan tersebut?',
      'icon': CupertinoIcons.question,
      'description': 'Kesulitan mengendalikan respon emosional',
      'conditional': 'mudah_marah',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'sulit_konsentrasi',
      'question': 'Apakah Anda mengalami kesulitan berkonsentrasi atau mengambil keputusan?',
      'icon': CupertinoIcons.question,
      'description': 'Gangguan kognitif yang umum pada depresi, ADHD, atau gangguan mental lainnya',
      'skipTo': 'perubahan_nafsu_makan', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'konsentrasi_mengganggu',
      'question': 'Apakah masalah konsentrasi ini memengaruhi performa Anda di pekerjaan atau sekolah?',
      'icon': CupertinoIcons.question,
      'description': 'Dampak gangguan konsentrasi pada fungsi sehari-hari',
      'conditional': 'sulit_konsentrasi',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'perubahan_nafsu_makan',
      'question': 'Apakah Anda mengalami perubahan nafsu makan yang ekstrem?',
      'icon': CupertinoIcons.question,
      'description': 'Perubahan nafsu makan bisa meningkat drastis atau menurun hingga memengaruhi berat badan',
      'skipTo': 'pikiran_menyakiti_diri', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'nafsu_makan_meningkat',
      'question': 'Apakah nafsu makan Anda lebih banyak meningkat daripada menurun?',
      'icon': CupertinoIcons.question,
      'description': 'Membedakan antara hiperfagia (makan berlebih) dan hiporeksia (makan kurang)',
      'conditional': 'perubahan_nafsu_makan',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'pikiran_menyakiti_diri',
      'question': 'Apakah Anda memiliki pikiran untuk menyakiti diri sendiri atau bunuh diri?',
      'icon': CupertinoIcons.question,
      'description': 'Gejala darurat yang membutuhkan perhatian segera',
      'skipTo': 'perasaan_tidak_berharga', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'rencana_bunuh_diri',
      'question': 'Apakah Anda pernah memiliki rencana spesifik tentang bunuh diri?',
      'icon': CupertinoIcons.question,
      'description': 'Pertanyaan penting untuk menilai tingkat risiko',
      'conditional': 'pikiran_menyakiti_diri',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'perasaan_tidak_berharga',
      'question': 'Apakah Anda memiliki perasaan tidak berharga atau rasa bersalah yang berlebihan?',
      'icon': CupertinoIcons.question,
      'description': 'Merasa tidak berharga atau bersalah berlebihan bahkan untuk hal-hal kecil',
      'skipTo': 'menarik_diri', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'bersalah_persisten',
      'question': 'Apakah perasaan bersalah ini muncul hampir setiap hari?',
      'icon': CupertinoIcons.question,
      'description': 'Frekuensi dan keparahan rasa bersalah',
      'conditional': 'perasaan_tidak_berharga',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'menarik_diri',
      'question': 'Apakah Anda menarik diri dari lingkungan sosial atau keluarga?',
      'icon': CupertinoIcons.question,
      'description': 'Tidak ingin bertemu orang, mengisolasi diri dari lingkungan sosial',
      'skipTo': 'delusi', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'isolasi_sengaja',
      'question': 'Apakah Anda sengaja menghindari acara sosial yang sebelumnya Anda nikmati?',
      'icon': CupertinoIcons.question,
      'description': 'Penarikan diri yang disengaja dari aktivitas sosial',
      'conditional': 'menarik_diri',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'delusi',
      'question': 'Apakah Anda memiliki keyakinan yang tidak sesuai kenyataan (delusi)?',
      'icon': CupertinoIcons.question,
      'description': 'Keyakinan yang tidak masuk akal seperti merasa diawasi, diikuti, atau memiliki kekuatan khusus',
      'skipTo': 'halusinasi', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'tipe_delusi',
      'question': 'Apakah keyakinan tersebut berhubungan dengan merasa diawasi atau dikejar?',
      'icon': CupertinoIcons.question,
      'description': 'Delusi paranoid adalah jenis delusi yang paling umum',
      'conditional': 'delusi',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'halusinasi',
      'question': 'Apakah Anda pernah mendengar atau melihat sesuatu yang tidak nyata (halusinasi)?',
      'icon': CupertinoIcons.question,
      'description': 'Halusinasi bisa berupa pendengaran, penglihatan, atau sensasi lainnya',
      'skipTo': 'perubahan_suasana_hati', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'jenis_halusinasi',
      'question': 'Apakah halusinasi yang Anda alami lebih sering berupa suara daripada penglihatan?',
      'icon': CupertinoIcons.question,
      'description': 'Halusinasi auditorik lebih umum pada beberapa gangguan mental dibanding halusinasi visual',
      'conditional': 'halusinasi',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'perubahan_suasana_hati',
      'question': 'Apakah Anda mengalami perubahan suasana hati yang ekstrem (mood swing)?',
      'icon': CupertinoIcons.question,
      'description': 'Perubahan dari sangat senang ke sangat sedih dalam waktu cepat',
      'skipTo': 'perilaku_kompulsif', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'mood_swing_cepat',
      'question': 'Apakah perubahan suasana hati ini terjadi dengan sangat cepat, bahkan dalam satu hari?',
      'icon': CupertinoIcons.question,
      'description': 'Kecepatan perubahan mood dapat membantu diagnosis',
      'conditional': 'perubahan_suasana_hati',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'perilaku_kompulsif',
      'question': 'Apakah Anda memiliki perilaku kompulsif atau obsesi yang mengganggu?',
      'icon': CupertinoIcons.question,
      'description': 'Perilaku berulang seperti mencuci tangan berulang karena takut kuman (OCD)',
      'skipTo': 'kehilangan_motivasi', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'waktu_kompulsi',
      'question': 'Apakah perilaku kompulsif tersebut menghabiskan lebih dari satu jam per hari?',
      'icon': CupertinoIcons.question,
      'description': 'Waktu yang dihabiskan untuk kompulsi menunjukkan keparahan gangguan',
      'conditional': 'perilaku_kompulsif',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'kehilangan_motivasi',
      'question': 'Apakah Anda mengalami kehilangan motivasi atau energi secara drastis?',
      'icon': CupertinoIcons.question,
      'description': 'Kesulitan memulai atau menyelesaikan aktivitas harian biasa',
      'skipTo': 'takut_sosial', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'kehilangan_energi_fisik',
      'question': 'Apakah kehilangan energi ini memengaruhi kemampuan fisik Anda?',
      'icon': CupertinoIcons.question,
      'description': 'Membedakan antara kehilangan motivasi psikologis dan fisik',
      'conditional': 'kehilangan_motivasi',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'takut_sosial',
      'question': 'Apakah Anda merasa takut akan situasi sosial atau dinilai oleh orang lain?',
      'icon': CupertinoIcons.question,
      'description': 'Gejala fobia sosial atau gangguan kecemasan sosial',
      'skipTo': 'kecanduan', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'menghindari_sosial',
      'question': 'Apakah Anda selalu berusaha menghindari situasi sosial karena rasa takut ini?',
      'icon': CupertinoIcons.question,
      'description': 'Perilaku menghindar adalah ciri khas fobia sosial',
      'conditional': 'takut_sosial',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'kecanduan',
      'question': 'Apakah Anda memiliki kecanduan atau penggunaan zat yang mengganggu fungsi hidup?',
      'icon': CupertinoIcons.question,
      'description': 'Penggunaan berlebihan alkohol, narkoba, atau perilaku adiktif lain',
      'skipTo': 'masalah_identitas', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'dampak_kecanduan',
      'question': 'Apakah kecanduan tersebut mengganggu pekerjaan atau hubungan Anda?',
      'icon': CupertinoIcons.question,
      'description': 'Dampak kecanduan pada fungsi sosial dan okupasional',
      'conditional': 'kecanduan',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'masalah_identitas',
      'question': 'Apakah Anda mengalami masalah dengan identitas diri atau harga diri rendah?',
      'icon': CupertinoIcons.question,
      'description': 'Kebingungan tentang jati diri atau perasaan tidak berharga',
      'skipTo': 'perilaku_impulsif', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'perubahan_identitas',
      'question': 'Apakah perasaan tentang identitas diri Anda sering berubah-ubah?',
      'icon': CupertinoIcons.question,
      'description': 'Perubahan persepsi tentang diri sendiri yang sering',
      'conditional': 'masalah_identitas',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'perilaku_impulsif',
      'question': 'Apakah Anda memiliki perilaku impulsif atau berisiko tinggi?',
      'icon': CupertinoIcons.question,
      'description': 'Tindakan tanpa pertimbangan seperti mengemudi ugal-ugalan, seks bebas, belanja impulsif',
      'skipTo': 'disosiasi', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'menyesal_impulsif',
      'question': 'Apakah Anda sering menyesal setelah melakukan tindakan impulsif tersebut?',
      'icon': CupertinoIcons.question,
      'description': 'Penyesalan setelah bertindak impulsif umum dalam beberapa gangguan mental',
      'conditional': 'perilaku_impulsif',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'disosiasi',
      'question': 'Apakah Anda pernah mengalami disosiasi atau rasa seperti keluar dari tubuh sendiri?',
      'icon': CupertinoIcons.question,
      'description': 'Perasaan terpisah dari diri sendiri atau menjadi penonton terhadap diri sendiri',
      'skipTo': 'mimpi_buruk', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'disosiasi_sering',
      'question': 'Apakah pengalaman disosiasi tersebut terjadi cukup sering?',
      'icon': CupertinoIcons.question,
      'description': 'Frekuensi pengalaman disosiasi menunjukkan keparahan gejala',
      'conditional': 'disosiasi',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'mimpi_buruk',
      'question': 'Apakah Anda sering mengalami mimpi buruk atau kilas balik traumatis (flashback)?',
      'icon': CupertinoIcons.question,
      'description': 'Gangguan tidur dan kilas balik umum pada PTSD',
      'skipTo': 'ketergantungan_emosional', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'mimpi_trauma',
      'question': 'Apakah mimpi buruk tersebut berkaitan dengan peristiwa traumatis tertentu?',
      'icon': CupertinoIcons.question,
      'description': 'Keterkaitan mimpi buruk dengan trauma spesifik',
      'conditional': 'mimpi_buruk',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'ketergantungan_emosional',
      'question': 'Apakah Anda merasa sangat bergantung secara emosional pada orang lain?',
      'icon': CupertinoIcons.question,
      'description': 'Ketakutan ditinggalkan dan ketergantungan ekstrem',
      'skipTo': 'kesulitan_fungsi', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'takut_ditinggalkan',
      'question': 'Apakah Anda sangat takut ditinggalkan oleh orang yang Anda sayangi?',
      'icon': CupertinoIcons.question,
      'description': 'Ketakutan akan penolakan atau ditinggalkan sangat umum pada beberapa gangguan kepribadian',
      'conditional': 'ketergantungan_emosional',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'kesulitan_fungsi',
      'question': 'Apakah Anda mengalami kesulitan menjalankan fungsi sehari-hari (pekerjaan, sekolah, rumah)?',
      'icon': CupertinoIcons.question,
      'description': 'Penurunan performa atau ketidakteraturan dalam menjalani aktivitas rutin',
      'skipTo': 'gejala_somatik', // Jika tidak, langsung ke idPertanyaan berikutnya
    },
    {
      'id': 'bantuan_fungsi',
      'question': 'Apakah Anda membutuhkan bantuan orang lain untuk melakukan tugas sehari-hari?',
      'icon': CupertinoIcons.question,
      'description': 'Tingkat disfungsi dalam aktivitas harian',
      'conditional': 'kesulitan_fungsi',
      'requiredValue': ['Ya', 'Kadang'],
    },
    {
      'id': 'gejala_somatik',
      'question': 'Apakah Anda mengalami gejala fisik tanpa penyebab medis yang jelas?',
      'icon': CupertinoIcons.question,
      'description': 'Sakit perut, sakit kepala, atau gejala fisik lain akibat stres psikis',
    },
    {
      'id': 'intensitas_somatik',
      'question': 'Apakah gejala fisik tersebut terasa sangat mengganggu?',
      'icon': CupertinoIcons.question,
      'description': 'Intensitas gejala somatik dan dampaknya pada kualitas hidup',
      'conditional': 'gejala_somatik',
      'requiredValue': ['Ya', 'Kadang'],
    },
  ];

  // Filter pertanyaan yang aktif berdasarkan jawaban sebelumnya
  static List<Map<String, dynamic>> activeQuestions(Map<String, String> answers) {
    return questions.where((q) {
      // Cek apakah pertanyaan memiliki kondisi
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
  
  // Evaluasi kondisional untuk pertanyaan
  static bool shouldShowQuestion(String questionId, Map<String, String> answers) {
    final question = questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {},
    );
    
    if (question.isEmpty) return false;
    
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
  
  // Kelompokkan pertanyaan berdasarkan kategori
  static Map<String, List<Map<String, dynamic>>> getQuestionsByCategory() {
    return {
      'Gejala Suasana Hati': questions.where((q) => 
        ['perasaan_sedih', 'sedih_berkelanjutan', 'kehilangan_minat', 'kehilangan_minat_durasi', 
         'perubahan_suasana_hati', 'mood_swing_cepat', 'mudah_marah', 'kontrol_emosi'].contains(q['id'])).toList(),
      
      'Gejala Kecemasan': questions.where((q) => 
        ['kecemasan_berlebihan', 'cemas_mengganggu', 'serangan_panik', 'gejala_fisik_panik',
         'takut_sosial', 'menghindari_sosial', 'perilaku_kompulsif', 'waktu_kompulsi'].contains(q['id'])).toList(),
      
      'Gejala Kognitif': questions.where((q) => 
        ['sulit_konsentrasi', 'konsentrasi_mengganggu', 'kehilangan_motivasi', 'kehilangan_energi_fisik',
         'masalah_identitas', 'perubahan_identitas', 'perasaan_tidak_berharga', 'bersalah_persisten'].contains(q['id'])).toList(),
      
      'Gejala Psikotik': questions.where((q) => 
        ['delusi', 'tipe_delusi', 'halusinasi', 'jenis_halusinasi', 'disosiasi', 'disosiasi_sering'].contains(q['id'])).toList(),
      
      'Gangguan Perilaku': questions.where((q) => 
        ['perilaku_impulsif', 'menyesal_impulsif', 'menarik_diri', 'isolasi_sengaja', 
         'kecanduan', 'dampak_kecanduan', 'ketergantungan_emosional', 'takut_ditinggalkan'].contains(q['id'])).toList(),
      
      'Gejala Fisik': questions.where((q) => 
        ['gangguan_tidur', 'tipe_gangguan_tidur', 'perubahan_nafsu_makan', 'nafsu_makan_meningkat',
         'gejala_somatik', 'intensitas_somatik'].contains(q['id'])).toList(),
      
      'Gejala Traumatik': questions.where((q) => 
        ['mimpi_buruk', 'mimpi_trauma', 'pikiran_menyakiti_diri', 'rencana_bunuh_diri', 
         'kesulitan_fungsi', 'bantuan_fungsi'].contains(q['id'])).toList(),
    };
  }
}