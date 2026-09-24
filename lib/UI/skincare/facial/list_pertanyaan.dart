import 'package:flutter/cupertino.dart';

class FacialWashQuestions {
  // Daftar pertanyaan untuk rekomendasi facial wash
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'jenis_kulit',
      'question': 'Apa jenis kulit wajah Anda?',
      'icon': CupertinoIcons.person_crop_circle,
      'description': 'Jenis kulit menentukan kandungan facial wash yang cocok untuk Anda',
      'weight': 10, // Bobot: 10/10
      'options': ['Normal', 'Berminyak', 'Kering', 'Kombinasi', 'Sensitif'],
    },
    {
      'id': 'usia',
      'question': 'Berapa usia Anda saat ini?',
      'icon': CupertinoIcons.calendar,
      'description': 'Usia menentukan kebutuhan perawatan kulit yang berbeda',
      'weight': 8, // Bobot: 8/10
      'options': ['< 18 tahun', '18-25 tahun', '26-35 tahun', '36-45 tahun', '> 45 tahun'],
    },
    {
      'id': 'jerawat',
      'question': 'Apakah Anda memiliki masalah jerawat?',
      'icon': CupertinoIcons.bandage,
      'description': 'Masalah jerawat memerlukan kandungan antibakteri',
      'weight': 9, // Bobot: 9/10
      'options': ['Ya, banyak', 'Ya, sedikit', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'komedo',
      'question': 'Apakah Anda memiliki masalah komedo?',
      'icon': CupertinoIcons.doc_text,
      'description': 'Komedo membutuhkan facial wash dengan kemampuan mengangkat sel kulit mati',
      'weight': 7, // Bobot: 7/10
      'options': ['Ya, banyak', 'Ya, sedikit', 'Kadang-kadang', 'Jarang', 'Tidak ada'],
    },
    {
      'id': 'bekas_jerawat',
      'question': 'Apakah Anda memiliki bekas jerawat atau hiperpigmentasi?',
      'icon': CupertinoIcons.arrow_2_circlepath,
      'description': 'Bekas jerawat membutuhkan facial wash dengan kandungan mencerahkan',
      'weight': 6, // Bobot: 6/10
      'options': ['Ya, banyak', 'Ya, sedikit', 'Beberapa area', 'Sangat sedikit', 'Tidak ada'],
    },
    {
      'id': 'pori_besar',
      'question': 'Apakah Anda memiliki pori-pori besar?',
      'icon': CupertinoIcons.circle_grid_3x3,
      'description': 'Pori-pori besar membutuhkan facial wash yang mampu mengecilkan pori',
      'weight': 6, // Bobot: 6/10
      'options': ['Ya, sangat jelas', 'Ya, cukup terlihat', 'Hanya di area T', 'Tidak begitu terlihat', 'Tidak ada'],
    },
    {
      'id': 'sensitifitas',
      'question': 'Seberapa sensitif kulit Anda terhadap produk skincare baru?',
      'icon': CupertinoIcons.exclamationmark_circle,
      'description': 'Kulit sensitif membutuhkan formula facial wash yang lebih lembut',
      'weight': 9, // Bobot: 9/10
      'options': ['Sangat sensitif', 'Cukup sensitif', 'Kadang sensitif', 'Jarang sensitif', 'Tidak sensitif'],
    },
    {
      'id': 'kulit_kusam',
      'question': 'Apakah kulit wajah Anda terlihat kusam?',
      'icon': CupertinoIcons.sun_max,
      'description': 'Kulit kusam membutuhkan facial wash dengan kandungan mencerahkan',
      'weight': 7, // Bobot: 7/10
      'options': ['Ya, sangat kusam', 'Ya, cukup kusam', 'Kadang-kadang', 'Jarang', 'Tidak pernah'],
    },
    {
      'id': 'paparan_sinar',
      'question': 'Seberapa sering Anda terpapar sinar matahari?',
      'icon': CupertinoIcons.sun_haze,
      'description': 'Paparan matahari berlebih membutuhkan facial wash dengan antioksidan',
      'weight': 6, // Bobot: 6/10
      'options': ['Sangat sering', 'Sering', 'Cukup sering', 'Jarang', 'Sangat jarang'],
    },
    {
      'id': 'keriput',
      'question': 'Apakah Anda memiliki kekhawatiran tentang kerutan atau tanda penuaan?',
      'icon': CupertinoIcons.waveform_path,
      'description': 'Tanda penuaan membutuhkan facial wash dengan kandungan anti-aging',
      'weight': 7, // Bobot: 7/10
      'options': ['Ya, sangat khawatir', 'Ya, cukup khawatir', 'Mulai memikirkannya', 'Sedikit khawatir', 'Tidak khawatir'],
    },
    {
      'id': 'efek_makeup',
      'question': 'Seberapa sering Anda menggunakan makeup?',
      'icon': CupertinoIcons.wand_stars,
      'description': 'Penggunaan makeup sering memerlukan facial wash dengan kemampuan membersihkan lebih baik',
      'weight': 8, // Bobot: 8/10
      'options': ['Setiap hari, tebal', 'Setiap hari, tipis', 'Beberapa kali seminggu', 'Hanya acara tertentu', 'Jarang/tidak pernah'],
    },
    {
      'id': 'cuci_wajah',
      'question': 'Berapa kali Anda mencuci wajah dalam sehari?',
      'icon': CupertinoIcons.drop,
      'description': 'Frekuensi mencuci wajah memengaruhi jenis facial wash yang cocok',
      'weight': 5, // Bobot: 5/10
      'options': ['Lebih dari 3 kali', '3 kali', '2 kali', '1 kali', 'Tidak teratur'],
    },
    {
      'id': 'budget',
      'question': 'Berapa budget Anda untuk facial wash?',
      'icon': CupertinoIcons.money_dollar_circle,
      'description': 'Budget menentukan rentang produk yang akan direkomendasikan',
      'weight': 4, // Bobot: 4/10
      'options': ['< Rp50.000', 'Rp50.000 - Rp100.000', 'Rp100.000 - Rp200.000', 'Rp200.000 - Rp300.000', '> Rp300.000'],
    },
    {
      'id': 'preferensi_tekstur',
      'question': 'Tekstur facial wash apa yang Anda sukai?',
      'icon': CupertinoIcons.hand_raised,
      'description': 'Preferensi tekstur untuk kenyamanan penggunaan',
      'weight': 5, // Bobot: 5/10
      'options': ['Gel', 'Foam', 'Cream', 'Oil', 'Micellar/Water Based'],
    },
    {
      'id': 'bahan_alami',
      'question': 'Apakah Anda lebih menyukai produk dengan bahan-bahan alami?',
      'icon': CupertinoIcons.leaf_arrow_circlepath,
      'description': 'Preferensi terhadap kandungan bahan facial wash',
      'weight': 5, // Bobot: 5/10
      'options': ['Ya, harus alami', 'Lebih memilih alami', 'Netral', 'Tidak terlalu penting', 'Lebih suka scientifically-proven'],
    },
    {
      'id': 'aroma',
      'question': 'Apakah Anda memiliki preferensi aroma pada facial wash?',
      'icon': CupertinoIcons.wind,
      'description': 'Preferensi aroma untuk kenyamanan penggunaan',
      'weight': 3, // Bobot: 3/10
      'options': ['Tanpa wewangian', 'Aroma ringan', 'Aroma herbal/natural', 'Aroma segar', 'Tidak ada preferensi'],
    },
  ];

  // Filter pertanyaan yang aktif berdasarkan jawaban sebelumnya
  static List<Map<String, dynamic>> activeQuestions(Map<String, String> answers) {
    return questions.where((q) {
      String questionId = q['id'];
      
      // Logic conditional untuk pertanyaan yang perlu dilewati
      bool shouldSkip = false;
      
      // Contoh: Jika user memilih kulit normal dan usia <18, kita bisa skip pertanyaan tentang keriput
      if (questionId == 'keriput' && answers.containsKey('usia') && 
          (answers['usia'] == '< 18 tahun' || answers['usia'] == '18-25 tahun')) {
        shouldSkip = true;
      }
      
      // Jika user tidak memiliki jerawat, kita bisa skip pertanyaan tentang bekas jerawat
      if (questionId == 'bekas_jerawat' && answers.containsKey('jerawat') && 
          answers['jerawat'] == 'Tidak pernah') {
        shouldSkip = true;
      }
      
      if (shouldSkip) {
        return false;
      }
      
      return true;
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
  
  // Mendapatkan opsi jawaban berdasarkan ID pertanyaan
  static List<String> getOptionsForQuestion(String questionId) {
    final question = questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {'options': <String>[]},
    );
    
    return List<String>.from(question['options'] ?? []);
  }
  
  // Evaluasi kondisional untuk pertanyaan
  static bool shouldShowQuestion(String questionId, Map<String, String> answers) {
    // Logic yang sama dengan activeQuestions
    if (questionId == 'keriput' && answers.containsKey('usia') && 
        (answers['usia'] == '< 18 tahun' || answers['usia'] == '18-25 tahun')) {
      return false;
    }
    
    if (questionId == 'bekas_jerawat' && answers.containsKey('jerawat') && 
        answers['jerawat'] == 'Tidak pernah') {
      return false;
    }
    
    return true;
  }
  
  // Hitung skor preferensi berdasarkan jawaban
  static Map<String, dynamic> calculateProductPreference(Map<String, String> answers) {
    // Mengimplementasikan logika untuk menentukan produk facial wash yang cocok
    
    // Bobot untuk setiap jenis jawaban dalam skala 0-4
    // Contoh: untuk jenis_kulit, ['Normal', 'Berminyak', 'Kering', 'Kombinasi', 'Sensitif']
    // Normal = 0, Berminyak = 1, Kering = 2, Kombinasi = 3, Sensitif = 4
    
    // Inisialisasi skor untuk setiap kategori produk
    Map<String, double> categoryScores = {
      'untuk_kulit_berminyak': 0,
      'untuk_kulit_kering': 0,
      'untuk_kulit_sensitif': 0,
      'untuk_anti_jerawat': 0,
      'untuk_pencerah': 0,
      'untuk_anti_aging': 0,
      'untuk_pori_besar': 0,
      'untuk_pembersih_mendalam': 0,
    };
    
    // Asumsi: categoryScores sudah ter-inisialisasi semua key-nya ke 0.
if (answers.containsKey('jenis_kulit')) {
  switch (answers['jenis_kulit']) {
    case 'Berminyak':
      categoryScores.update('untuk_kulit_berminyak', (v) => v + 10);
      categoryScores.update('untuk_pori_besar',      (v) => v + 5);
      break;
    case 'Kering':
      categoryScores.update('untuk_kulit_kering',   (v) => v + 10);
      break;
    case 'Sensitif':
      categoryScores.update('untuk_kulit_sensitif', (v) => v + 10);
      break;
    case 'Kombinasi':
      categoryScores.update('untuk_kulit_berminyak',(v) => v + 5);
      categoryScores.update('untuk_kulit_kering',   (v) => v + 5);
      break;
  }
}

if (answers.containsKey('usia')) {
  final usia = answers['usia'];
  if (usia == '36-45 tahun' || usia == '> 45 tahun') {
    categoryScores.update('untuk_anti_aging', (v) => v + 8);
  }
}

if (answers.containsKey('jerawat')) {
  final jerawat = answers['jerawat'];
  final inc = jerawat == 'Ya, banyak' ? 9 : 6;
  categoryScores.update('untuk_anti_jerawat', (v) => v + inc);
}

if (answers.containsKey('komedo')) {
  final komedo = answers['komedo']!;
  if (komedo.startsWith('Ya,')) {
    categoryScores.update('untuk_pembersih_mendalam', (v) => v + 7);
    categoryScores.update('untuk_pori_besar',        (v) => v + 5);
  }
}

if (answers.containsKey('bekas_jerawat')) {
  categoryScores.update('untuk_pencerah', (v) => v + 6);
}

if (answers.containsKey('pori_besar')) {
  switch (answers['pori_besar']) {
    case 'Ya, sangat jelas':
    case 'Ya, cukup terlihat':
      categoryScores.update('untuk_pori_besar', (v) => v + 6);
      break;
    case 'Hanya di area T':
      categoryScores.update('untuk_pori_besar', (v) => v + 3);
      break;
  }
}

if (answers.containsKey('sensitifitas')) {
  final s = answers['sensitifitas'];
  if (s == 'Sangat sensitif' || s == 'Cukup sensitif') {
    categoryScores.update('untuk_kulit_sensitif', (v) => v + 9);
  }
}

if (answers.containsKey('kulit_kusam')) {
  final k = answers['kulit_kusam'];
  if (k == 'Ya, sangat kusam' || k == 'Ya, cukup kusam') {
    categoryScores.update('untuk_pencerah', (v) => v + 7);
  }
}

if (answers.containsKey('paparan_sinar')) {
  final p = answers['paparan_sinar'];
  if (p == 'Sangat sering' || p == 'Sering') {
    categoryScores.update('untuk_pencerah', (v) => v + 4);
  }
}

if (answers.containsKey('keriput')) {
  final k = answers['keriput'];
  if (k == 'Ya, sangat khawatir' || k == 'Ya, cukup khawatir') {
    categoryScores.update('untuk_anti_aging', (v) => v + 7);
  }
}

if (answers.containsKey('efek_makeup')) {
  final e = answers['efek_makeup']!;
  if (e.startsWith('Setiap hari,')) {
    categoryScores.update('untuk_pembersih_mendalam', (v) => v + 8);
  }
}

    
    // Temukan kategori dengan skor tertinggi
    String topCategory = '';
    double maxScore = 0;
    
    categoryScores.forEach((category, score) {
      if (score > maxScore) {
        maxScore = score;
        topCategory = category;
      }
    });
    
    // Tentukan tipe produk berdasarkan kategori tertinggi
    String productType;
    switch (topCategory) {
      case 'untuk_kulit_berminyak':
        productType = 'Facial Wash untuk Kulit Berminyak';
        break;
      case 'untuk_kulit_kering':
        productType = 'Facial Wash untuk Kulit Kering';
        break;
      case 'untuk_kulit_sensitif':
        productType = 'Facial Wash untuk Kulit Sensitif';
        break;
      case 'untuk_anti_jerawat':
        productType = 'Facial Wash Anti Jerawat';
        break;
      case 'untuk_pencerah':
        productType = 'Facial Wash Pencerah';
        break;
      case 'untuk_anti_aging':
        productType = 'Facial Wash Anti Aging';
        break;
      case 'untuk_pori_besar':
        productType = 'Facial Wash untuk Pori Besar';
        break;
      case 'untuk_pembersih_mendalam':
        productType = 'Facial Wash Pembersih Mendalam';
        break;
      default:
        productType = 'Facial Wash untuk Kulit Normal';
    }
    
    // Hitung persentase kecocokan
    double totalPossibleScore = 0;
    double userScore = 0;

    questions.forEach((question) {
      // Ubah dari cast (as double) menjadi konversi eksplisit
      totalPossibleScore += (question['weight'] as int).toDouble();
    });

    // Skor pengguna berdasarkan kategori tertinggi
    userScore = maxScore;

    // Persentase kecocokan
    double matchPercentage = (userScore / totalPossibleScore) * 100;
    
    // Gunakan budget untuk filter rekomendasi
    String budgetRange = answers['budget'] ?? 'Semua harga';
    
    return {
      'productType': productType,
      'topCategory': topCategory,
      'matchPercentage': matchPercentage,
      'categoryScores': categoryScores,
      'budgetRange': budgetRange,
    };
  }
}