import 'package:flutter/cupertino.dart';

class KulitQuestions {
  // Daftar pertanyaan gejala (15 pertanyaan utama saja)
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'gatal',
      'question': 'Apakah kulit anda terasa gatal?',
      'icon': CupertinoIcons.question,
      'description': 'Gatal adalah sensasi tidak nyaman yang menyebabkan keinginan untuk menggaruk kulit',
    },
    {
      'id': 'perubahan_warna',
      'question': 'Apakah ada perubahan warna pada kulit anda?',
      'icon': CupertinoIcons.question,
      'description': 'Perubahan warna kulit bisa berupa kemerahan, pemutihan, penghitaman, atau warna lainnya',
    },
    {
      'id': 'luka',
      'question': 'Apakah terdapat luka pada kulit anda?',
      'icon': CupertinoIcons.question,
      'description': 'Luka bisa berupa robekan, lecet, atau borok pada kulit',
    },
    {
      'id': 'kemerahan',
      'question': 'Apakah kulit anda mengalami kemerahan?',
      'icon': CupertinoIcons.question,
      'description': 'Kemerahan pada kulit bisa menandakan peradangan atau iritasi',
    },
    {
      'id': 'mengelupas',
      'question': 'Apakah kulit anda mengelupas?',
      'icon': CupertinoIcons.question,
      'description': 'Pengelupasan kulit adalah kondisi dimana lapisan luar kulit terkelupas',
    },
    {
      'id': 'kering',
      'question': 'Apakah kulit anda terasa kering?',
      'icon': CupertinoIcons.question,
      'description': 'Kulit kering memiliki tekstur kasar dan mungkin terasa kaku atau gatal',
    },
    {
      'id': 'kebas',
      'question': 'Apakah ada bagian kulit yang terasa kebas atau mati rasa?',
      'icon': CupertinoIcons.question,
      'description': 'Kebas adalah berkurangnya atau hilangnya sensasi pada kulit',
    },
    {
      'id': 'bengkak',
      'question': 'Apakah kulit anda mengalami pembengkakan?',
      'icon': CupertinoIcons.question,
      'description': 'Pembengkakan adalah penumpukan cairan di kulit dan jaringan di bawahnya',
    },
    {
      'id': 'benjolan',
      'question': 'Apakah terdapat benjolan pada kulit anda?',
      'icon': CupertinoIcons.question,
      'description': 'Benjolan adalah pertumbuhan atau tonjolan yang tidak normal pada kulit',
    },
    {
      'id': 'nyeri',
      'question': 'Apakah kulit anda terasa nyeri saat disentuh?',
      'icon': CupertinoIcons.question,
      'description': 'Nyeri pada kulit bisa mengindikasikan peradangan, infeksi, atau kerusakan saraf',
    },
    {
      'id': 'rambut_rontok',
      'question': 'Apakah anda mengalami kerontokan rambut?',
      'icon': CupertinoIcons.question,
      'description': 'Kerontokan rambut abnormal terjadi ketika jumlah rambut yang rontok lebih banyak dari biasanya',
    },
    {
      'id': 'sensitif',
      'question': 'Apakah kulit anda terasa lebih sensitif dari biasanya?',
      'icon': CupertinoIcons.question,
      'description': 'Kulit sensitif bereaksi lebih mudah terhadap produk, suhu, atau sentuhan',
    },
    {
      'id': 'bekas_luka',
      'question': 'Apakah terdapat bekas luka yang menonjol atau abnormal?',
      'icon': CupertinoIcons.question,
      'description': 'Bekas luka abnormal bisa berbentuk keloid atau jaringan parut hipertrofik',
    },
    {
      'id': 'infeksi_jamur',
      'question': 'Apakah ada tanda-tanda infeksi jamur pada kulit?',
      'icon': CupertinoIcons.question,
      'description': 'Infeksi jamur biasanya menyebabkan ruam merah, gatal, dan bersisik dengan batas yang jelas',
    },
    {
      'id': 'perubahan_sensasi',
      'question': 'Apakah anda mengalami perubahan sensasi pada kulit?',
      'icon': CupertinoIcons.question,
      'description': 'Perubahan sensasi seperti kesemutan, terbakar, atau mati rasa',
    },
  ];

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
  
  // Mendapatkan semua pertanyaan
  static List<Map<String, dynamic>> getAllQuestions() {
    return questions;
  }
  
  // Mendapatkan pertanyaan berdasarkan indeks
  static Map<String, dynamic> getQuestionByIndex(int index) {
    if (index >= 0 && index < questions.length) {
      return questions[index];
    }
    return {'id': '', 'question': 'Pertanyaan tidak ditemukan', 'icon': CupertinoIcons.question_circle, 'description': ''};
  }
  
  // Mendapatkan jumlah pertanyaan
  static int getQuestionCount() {
    return questions.length;
  }
}

// import 'package:flutter/cupertino.dart';

// class KulitQuestions {
//   // Daftar pertanyaan gejala
//   static final List<Map<String, dynamic>> questions = [
//     {
//       'id': 'gatal',
//       'question': 'Apakah kulit anda terasa gatal?',
//       'icon': CupertinoIcons.question,
//       'description': 'Gatal adalah sensasi tidak nyaman yang menyebabkan keinginan untuk menggaruk kulit',
//       'skipTo': 'perubahan_warna', // Jika tidak, langsung ke perubahan warna
//     },
//     {
//       'id': 'gatal_parah',
//       'question': 'Apakah rasa gatal cukup parah atau mengganggu aktivitas?',
//       'icon': CupertinoIcons.question,
//       'description': 'Gatal yang parah dapat mengganggu tidur dan aktivitas sehari-hari',
//       'conditional': 'gatal',
//       'requiredValue': ['Ya', 'Kadang'],
//     },
//     {
//       'id': 'gatal_malam',
//       'question': 'Apakah gatal lebih terasa di malam hari?',
//       'icon': CupertinoIcons.question,
//       'description': 'Gatal yang memburuk di malam hari bisa mengindikasikan kondisi tertentu seperti eksim atau scabies',
//       'conditional': 'gatal',
//       'requiredValue': ['Ya', 'Kadang'],
//     },
//     {
//       'id': 'perubahan_warna',
//       'question': 'Apakah ada perubahan warna pada kulit anda?',
//       'icon': CupertinoIcons.question,
//       'description': 'Perubahan warna kulit bisa berupa kemerahan, pemutihan, penghitaman, atau warna lainnya',
//       'skipTo': 'luka', // Jika tidak, langsung ke luka
//     },
//     {
//       'id': 'warna_lebih_terang',
//       'question': 'Apakah kulit berubah menjadi lebih terang dari kulit sekitarnya?',
//       'icon': CupertinoIcons.question,
//       'description': 'Perubahan warna menjadi lebih terang bisa mengindikasikan vitiligo atau infeksi jamur',
//       'conditional': 'perubahan_warna',
//       'requiredValue': ['Ya', 'Kadang'],
//     },
//     {
//       'id': 'warna_lebih_gelap',
//       'question': 'Apakah kulit berubah menjadi lebih gelap dari kulit sekitarnya?',
//       'icon': CupertinoIcons.question,
//       'description': 'Perubahan warna menjadi lebih gelap bisa terjadi karena hiperpigmentasi atau bekas luka',
//       'conditional': 'perubahan_warna',
//       'requiredValue': ['Ya', 'Kadang'],
//       'skipIfYes': 'warna_lebih_terang', // Hanya ditampilkan jika warna_lebih_terang tidak dijawab Ya
//     },
//     {
//       'id': 'luka',
//       'question': 'Apakah terdapat luka pada kulit anda?',
//       'icon': CupertinoIcons.question,
//       'description': 'Luka bisa berupa robekan, lecet, atau borok pada kulit',
//       'skipTo': 'kemerahan', // Jika tidak, langsung ke kemerahan
//     },
//     {
//       'id': 'luka_sulit_sembuh',
//       'question': 'Apakah luka sulit atau lambat sembuh?',
//       'icon': CupertinoIcons.question,
//       'description': 'Luka yang tidak sembuh dalam 3 minggu perlu mendapat perhatian medis',
//       'conditional': 'luka',
//       'requiredValue': ['Ya', 'Kadang'],
//     },
//     {
//       'id': 'kemerahan',
//       'question': 'Apakah kulit anda mengalami kemerahan?',
//       'icon': CupertinoIcons.question,
//       'description': 'Kemerahan pada kulit bisa menandakan peradangan atau iritasi',
//       'skipTo': 'mengelupas', // Jika tidak, langsung ke mengelupas
//     },
//     {
//       'id': 'kemerahan_menyebar',
//       'question': 'Apakah kemerahan cenderung menyebar atau meluas?',
//       'icon': CupertinoIcons.question,
//       'description': 'Kemerahan yang menyebar bisa mengindikasikan infeksi atau reaksi alergi',
//       'conditional': 'kemerahan',
//       'requiredValue': ['Ya', 'Kadang'],
//     },
//     {
//       'id': 'mengelupas',
//       'question': 'Apakah kulit anda mengelupas?',
//       'icon': CupertinoIcons.question,
//       'description': 'Pengelupasan kulit adalah kondisi dimana lapisan luar kulit terkelupas',
//       'skipTo': 'kering', // Jika tidak, langsung ke kering
//     },
//     {
//       'id': 'mengelupas_bersisik',
//       'question': 'Apakah pengelupasan disertai dengan sisik-sisik pada kulit?',
//       'icon': CupertinoIcons.question,
//       'description': 'Kulit bersisik sering terjadi pada psoriasis, eksim, atau infeksi jamur',
//       'conditional': 'mengelupas',
//       'requiredValue': ['Ya', 'Kadang'],
//     },
//     {
//       'id': 'kering',
//       'question': 'Apakah kulit anda terasa kering?',
//       'icon': CupertinoIcons.question,
//       'description': 'Kulit kering memiliki tekstur kasar dan mungkin terasa kaku atau gatal',
//       'skipTo': 'kebas', // Jika tidak, langsung ke kebas
//     },
//     {
//       'id': 'kering_retak',
//       'question': 'Apakah kulit kering sampai retak atau pecah-pecah?',
//       'icon': CupertinoIcons.question,
//       'description': 'Kulit yang sangat kering bisa menyebabkan retakan yang kadang terasa nyeri',
//       'conditional': 'kering',
//       'requiredValue': ['Ya', 'Kadang'],
//     },
//     {
//       'id': 'kebas',
//       'question': 'Apakah ada bagian kulit yang terasa kebas atau mati rasa?',
//       'icon': CupertinoIcons.question,
//       'description': 'Kebas adalah berkurangnya atau hilangnya sensasi pada kulit',
//       'skipTo': 'bengkak', // Jika tidak, langsung ke bengkak
//     },
//     {
//       'id': 'bengkak',
//       'question': 'Apakah kulit anda mengalami pembengkakan?',
//       'icon': CupertinoIcons.question,
//       'description': 'Pembengkakan adalah penumpukan cairan di kulit dan jaringan di bawahnya',
//       'skipTo': 'benjolan', // Jika tidak, langsung ke benjolan
//     },
//     {
//       'id': 'bengkak_nyeri',
//       'question': 'Apakah pembengkakan disertai nyeri?',
//       'icon': CupertinoIcons.question,
//       'description': 'Pembengkakan yang nyeri sering menandakan adanya peradangan atau infeksi',
//       'conditional': 'bengkak',
//       'requiredValue': ['Ya', 'Kadang'],
//     },
//     {
//       'id': 'benjolan',
//       'question': 'Apakah terdapat benjolan pada kulit anda?',
//       'icon': CupertinoIcons.question,
//       'description': 'Benjolan adalah pertumbuhan atau tonjolan yang tidak normal pada kulit',
//       'skipTo': 'nyeri', // Jika tidak, langsung ke nyeri
//     },
//     {
//       'id': 'benjolan_bertambah',
//       'question': 'Apakah benjolan bertambah ukuran atau jumlahnya?',
//       'icon': CupertinoIcons.question,
//       'description': 'Benjolan yang bertambah ukuran atau jumlah perlu diwaspadai dan diperiksa oleh dokter',
//       'conditional': 'benjolan',
//       'requiredValue': ['Ya', 'Kadang'],
//     },
//     {
//       'id': 'nyeri',
//       'question': 'Apakah kulit anda terasa nyeri saat disentuh?',
//       'icon': CupertinoIcons.question,
//       'description': 'Nyeri pada kulit bisa mengindikasikan peradangan, infeksi, atau kerusakan saraf',
//       'skipTo': 'rambut_rontok', // Jika tidak, langsung ke rambut_rontok
//     },
//     {
//       'id': 'nyeri_terbakar',
//       'question': 'Apakah nyeri terasa seperti terbakar?',
//       'icon': CupertinoIcons.question,
//       'description': 'Rasa nyeri seperti terbakar bisa mengindikasikan kerusakan saraf atau infeksi tertentu',
//       'conditional': 'nyeri',
//       'requiredValue': ['Ya', 'Kadang'],
//     },
//     {
//       'id': 'rambut_rontok',
//       'question': 'Apakah anda mengalami kerontokan rambut?',
//       'icon': CupertinoIcons.question,
//       'description': 'Kerontokan rambut abnormal terjadi ketika jumlah rambut yang rontok lebih banyak dari biasanya',
//       'skipTo': 'sensitif', // Jika tidak, langsung ke sensitif
//     },
//     {
//       'id': 'rontok_bercak',
//       'question': 'Apakah rambut rontok membentuk bercak-bercak?',
//       'icon': CupertinoIcons.question,
//       'description': 'Kerontokan rambut berbentuk bercak bisa mengindikasikan alopecia areata',
//       'conditional': 'rambut_rontok',
//       'requiredValue': ['Ya', 'Kadang'],
//     },
//     {
//       'id': 'sensitif',
//       'question': 'Apakah kulit anda terasa lebih sensitif dari biasanya?',
//       'icon': CupertinoIcons.question,
//       'description': 'Kulit sensitif bereaksi lebih mudah terhadap produk, suhu, atau sentuhan',
//       'skipTo': 'bekas_luka', // Jika tidak, langsung ke bekas_luka
//     },
//     {
//       'id': 'sensitif_matahari',
//       'question': 'Apakah kulit sangat sensitif terhadap sinar matahari?',
//       'icon': CupertinoIcons.question,
//       'description': 'Sensitivitas berlebihan terhadap matahari bisa terjadi pada lupus, fotosensitivitas, atau efek obat',
//       'conditional': 'sensitif',
//       'requiredValue': ['Ya', 'Kadang'],
//     },
//     {
//       'id': 'bekas_luka',
//       'question': 'Apakah terdapat bekas luka yang menonjol atau abnormal?',
//       'icon': CupertinoIcons.question,
//       'description': 'Bekas luka abnormal bisa berbentuk keloid atau jaringan parut hipertrofik',
//       'skipTo': 'infeksi_jamur', // Jika tidak, langsung ke infeksi_jamur
//     },
//     {
//       'id': 'bekas_luka_membesar',
//       'question': 'Apakah bekas luka cenderung membesar melebihi luka aslinya?',
//       'icon': CupertinoIcons.question,
//       'description': 'Bekas luka yang membesar melebihi luka asli bisa merupakan keloid',
//       'conditional': 'bekas_luka',
//       'requiredValue': ['Ya', 'Kadang'],
//     },
//     {
//       'id': 'infeksi_jamur',
//       'question': 'Apakah ada tanda-tanda infeksi jamur pada kulit?',
//       'icon': CupertinoIcons.question,
//       'description': 'Infeksi jamur biasanya menyebabkan ruam merah, gatal, dan bersisik dengan batas yang jelas',
//       'skipTo': 'perubahan_sensasi', // Jika tidak, langsung ke perubahan_sensasi
//     },
//     {
//       'id': 'jamur_menyebar',
//       'question': 'Apakah infeksi jamur cenderung menyebar atau kambuh?',
//       'icon': CupertinoIcons.question,
//       'description': 'Infeksi jamur yang menyebar atau kambuh mungkin memerlukan pengobatan yang lebih agresif',
//       'conditional': 'infeksi_jamur',
//       'requiredValue': ['Ya', 'Kadang'],
//     },
//     {
//       'id': 'perubahan_sensasi',
//       'question': 'Apakah anda mengalami perubahan sensasi pada kulit?',
//       'icon': CupertinoIcons.question,
//       'description': 'Perubahan sensasi seperti kesemutan, terbakar, atau mati rasa',
//     },
//     {
//       'id': 'sensasi_kesemutan',
//       'question': 'Apakah anda merasakan kesemutan atau seperti ditusuk jarum pada kulit?',
//       'icon': CupertinoIcons.question,
//       'description': 'Sensasi kesemutan bisa mengindikasikan masalah pada saraf atau iritasi',
//       'conditional': 'perubahan_sensasi',
//       'requiredValue': ['Ya', 'Kadang'],
//     },
//   ];

//   // Filter pertanyaan yang aktif berdasarkan jawaban sebelumnya
//   static List<Map<String, dynamic>> activeQuestions(Map<String, String> answers) {
//     return questions.where((q) {
//       // Cek apakah pertanyaan memiliki kondisi
//       if (!q.containsKey('conditional')) return true;
      
//       String conditionalField = q['conditional'];
//       List<String> requiredValues = List<String>.from(q['requiredValue']);
      
//       // Cek apakah kondisi terpenuhi
//       bool conditionalMet = answers.containsKey(conditionalField) && 
//                           requiredValues.contains(answers[conditionalField]);
      
//       // Cek apakah ada kondisi skip berdasarkan jawaban Ya pada pertanyaan lain
//       if (q.containsKey('skipIfYes')) {
//         String skipField = q['skipIfYes'];
//         return conditionalMet && (!answers.containsKey(skipField) || answers[skipField] != 'Ya');
//       }
      
//       return conditionalMet;
//     }).toList();
//   }

//   // Mendapatkan icon berdasarkan ID pertanyaan
//   static IconData getIconForQuestion(String questionId) {
//     final question = questions.firstWhere(
//       (q) => q['id'] == questionId,
//       orElse: () => {'icon': CupertinoIcons.question_circle},
//     );
    
//     return question['icon'] as IconData;
//   }

//   // Mendapatkan deskripsi berdasarkan ID pertanyaan
//   static String getDescriptionForQuestion(String questionId) {
//     final question = questions.firstWhere(
//       (q) => q['id'] == questionId,
//       orElse: () => {'description': 'Tidak ada deskripsi'},
//     );
    
//     return question['description'] as String;
//   }
  
//   // Mendapatkan pertanyaan berdasarkan ID
//   static String getQuestionText(String questionId) {
//     final question = questions.firstWhere(
//       (q) => q['id'] == questionId,
//       orElse: () => {'question': 'Pertanyaan tidak ditemukan'},
//     );
    
//     return question['question'] as String;
//   }
// }