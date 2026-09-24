import 'package:flutter/cupertino.dart';

class NutritionQuestions {
  // Daftar pertanyaan untuk analisis kebutuhan nutrisi
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'usia',
      'question': 'Berapa usia Anda?',
      'icon': CupertinoIcons.person_alt,
      'description': 'Kebutuhan nutrisi berubah seiring pertambahan usia',
      'weight': 10, // Bobot: 10/10
      'options': ['Anak-anak (6-12 tahun)', 'Remaja (13-18 tahun)', 'Dewasa (19-50 tahun)', 'Dewasa senior (51-64 tahun)', 'Lansia (65+ tahun)'],
    },
    {
      'id': 'jenis_kelamin',
      'question': 'Apa jenis kelamin Anda?',
      'icon': CupertinoIcons.person_2,
      'description': 'Jenis kelamin memengaruhi kebutuhan kalori dan nutrisi spesifik',
      'weight': 9, // Bobot: 9/10
      'options': ['Laki-laki', 'Perempuan'],
    },
    {
      'id': 'tingkat_aktivitas',
      'question': 'Bagaimana tingkat aktivitas fisik Anda?',
      'icon': CupertinoIcons.flame,
      'description': 'Aktivitas fisik menentukan kebutuhan kalori harian',
      'weight': 9, // Bobot: 9/10
      'options': ['Sangat rendah (hampir tidak berolahraga)', 'Rendah (olahraga ringan 1-3 hari/minggu)', 'Sedang (olahraga moderat 3-5 hari/minggu)', 'Tinggi (olahraga intensif 6-7 hari/minggu)', 'Sangat tinggi (atlet/pekerja fisik berat)'],
    },
    {
      'id': 'berat_badan',
      'question': 'Berapa berat badan Anda? (kg)',
      'icon': CupertinoIcons.chart_bar,
      'description': 'Berat badan digunakan untuk menghitung BMI dan kebutuhan nutrisi',
      'weight': 8, // Bobot: 8/10
      'input_type': 'numeric',
    },
    {
      'id': 'tinggi_badan',
      'question': 'Berapa tinggi badan Anda? (cm)',
      'icon': CupertinoIcons.arrow_up_arrow_down,
      'description': 'Tinggi badan digunakan untuk menghitung BMI dan kebutuhan nutrisi',
      'weight': 8, // Bobot: 8/10
      'input_type': 'numeric',
    },
    {
      'id': 'waktu_makan_utama',
      'question': 'Pada waktu mana Anda biasanya makan dengan porsi terbanyak?',
      'icon': CupertinoIcons.clock,
      'description': 'Pola waktu makan memengaruhi rekomendasi distribusi nutrisi',
      'weight': 7, // Bobot: 7/10
      'options': ['Pagi hari', 'Siang hari', 'Malam hari', 'Tersebar merata sepanjang hari'],
    },
    {
      'id': 'alergi_makanan',
      'question': 'Apakah Anda memiliki alergi atau intoleransi makanan?',
      'icon': CupertinoIcons.exclamationmark_shield,
      'description': 'Informasi alergi penting untuk menyesuaikan rekomendasi menu',
      'weight': 10, // Bobot: 10/10
      'options': ['Tidak ada', 'Produk susu/laktosa', 'Kacang-kacangan', 'Gluten', 'Seafood/makanan laut', 'Telur', 'Lainnya (akan disesuaikan)'],
    },
    {
      'id': 'tujuan_diet',
      'question': 'Apa tujuan utama diet/pola makan Anda saat ini?',
      'icon': CupertinoIcons.arrow_branch,
      'description': 'Tujuan diet menentukan fokus nutrisi dan kalori yang direkomendasikan',
      'weight': 9, // Bobot: 9/10
      'options': ['Pemeliharaan berat badan', 'Penurunan berat badan', 'Penambahan berat badan/massa otot', 'Peningkatan energi/stamina', 'Kesehatan jangka panjang'],
    },
    {
      'id': 'kondisi_kesehatan',
      'question': 'Apakah Anda memiliki kondisi kesehatan yang memerlukan perhatian khusus?',
      'icon': CupertinoIcons.heart,
      'description': 'Kondisi kesehatan tertentu memerlukan penyesuaian dalam pola makan',
      'weight': 10, // Bobot: 10/10
      'options': ['Tidak ada', 'Diabetes', 'Hipertensi', 'Kolesterol tinggi', 'Penyakit jantung', 'Penyakit ginjal', 'Kehamilan/menyusui', 'Lainnya'],
    },
    {
      'id': 'preferensi_diet',
      'question': 'Apakah Anda memiliki preferensi pola makan khusus?',
      'icon': CupertinoIcons.leaf_arrow_circlepath,
      'description': 'Preferensi diet memengaruhi pilihan bahan makanan yang direkomendasikan',
      'weight': 8, // Bobot: 8/10
      'options': ['Tidak ada preferensi khusus', 'Vegetarian', 'Vegan', 'Pescatarian', 'Rendah karbohidrat', 'Tinggi protein', 'Bebas gluten', 'Paleo/whole food'],
    },
    {
      'id': 'waktu_persiapan',
      'question': 'Berapa banyak waktu yang bisa Anda luangkan untuk menyiapkan makanan?',
      'icon': CupertinoIcons.time,
      'description': 'Keterbatasan waktu perlu dipertimbangkan dalam rekomendasi menu',
      'weight': 6, // Bobot: 6/10
      'options': ['Minimal (<15 menit)', 'Sedikit (15-30 menit)', 'Sedang (30-60 menit)', 'Banyak (>60 menit)', 'Saya bisa meal prep di akhir pekan'],
    },
    {
      'id': 'anggaran',
      'question': 'Bagaimana anggaran Anda untuk makanan sehat?',
      'icon': CupertinoIcons.money_dollar,
      'description': 'Anggaran memengaruhi pilihan bahan makanan yang direkomendasikan',
      'weight': 6, // Bobot: 6/10
      'options': ['Sangat terbatas', 'Terbatas', 'Sedang', 'Fleksibel', 'Tidak terbatas'],
    },
  ];

  // Filter pertanyaan yang aktif berdasarkan jawaban sebelumnya
  static List<Map<String, dynamic>> activeQuestions(Map<String, String> answers) {
    return questions.where((q) {
      final String questionId = q['id'];
      
      // Logic conditional untuk pertanyaan yang perlu dilewati
      bool shouldSkip = false;
      
      // Contoh: Skip pertanyaan kehamilan jika pengguna laki-laki
      if (questionId == 'kehamilan' && answers.containsKey('jenis_kelamin') && 
          answers['jenis_kelamin'] == 'Laki-laki') {
        shouldSkip = true;
      }
      
      // Contoh: Skip pertanyaan kondisi kesehatan khusus jika usia anak-anak
      if (questionId == 'kondisi_kesehatan_khusus' && answers.containsKey('usia') && 
          answers['usia'] == 'Anak-anak (6-12 tahun)') {
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
    
    return question.containsKey('options') ? List<String>.from(question['options']) : [];
  }
  
  // Mendapatkan tipe input berdasarkan ID pertanyaan
  static String? getInputTypeForQuestion(String questionId) {
    final question = questions.firstWhere(
      (q) => q['id'] == questionId,
      orElse: () => {},
    );
    
    return question.containsKey('input_type') ? question['input_type'] as String : null;
  }
  
  // Evaluasi kondisional untuk pertanyaan
  static bool shouldShowQuestion(String questionId, Map<String, String> answers) {
    // Logic yang sama dengan activeQuestions
    if (questionId == 'kehamilan' && answers.containsKey('jenis_kelamin') && 
        answers['jenis_kelamin'] == 'Laki-laki') {
      return false;
    }
    
    return true;
  }
  
  // Hitung kebutuhan nutrisi berdasarkan jawaban
  static Map<String, dynamic> calculateNutritionNeeds(Map<String, dynamic> answers) {
    // Inisialisasi hasil
    final Map<String, dynamic> result = {
      'bmr': 0.0,
      'tdee': 0.0,
      'recommendedCalories': 0.0,
      'recommendedProtein': 0.0,
      'recommendedCarbs': 0.0,
      'recommendedFat': 0.0,
      'mainCategory': 'dewasa_aktif',
      'secondaryCategory': '',
    };
    
    try {
      // Parsing input numerik
      double beratBadan = 0;
      double tinggiBadan = 0;
      
      if (answers.containsKey('berat_badan') && answers['berat_badan'] != null) {
        if (answers['berat_badan'] is String) {
          beratBadan = double.tryParse(answers['berat_badan']) ?? 0.0;
        } else if (answers['berat_badan'] is num) {
          beratBadan = (answers['berat_badan'] as num).toDouble();
        }
      }
      
      if (answers.containsKey('tinggi_badan') && answers['tinggi_badan'] != null) {
        if (answers['tinggi_badan'] is String) {
          tinggiBadan = double.tryParse(answers['tinggi_badan']) ?? 0.0;
        } else if (answers['tinggi_badan'] is num) {
          tinggiBadan = (answers['tinggi_badan'] as num).toDouble();
        }
      }
      
      // Konversi tinggi badan dari cm ke m untuk BMI
      final double tinggiBadanMeter = tinggiBadan / 100;
      
      // Calculate BMI
      double bmi = 0;
      if (tinggiBadanMeter > 0) {
        bmi = beratBadan / (tinggiBadanMeter * tinggiBadanMeter);
      }
      
      // Get age category
      final String usia = answers['usia'] ?? 'Dewasa (19-50 tahun)';
      final String jenisKelamin = answers['jenis_kelamin'] ?? 'Laki-laki';
      final String tingkatAktivitas = answers['tingkat_aktivitas'] ?? 'Sedang (olahraga moderat 3-5 hari/minggu)';
      final String tujuanDiet = answers['tujuan_diet'] ?? 'Pemeliharaan berat badan';
      final String kondisiKesehatan = answers['kondisi_kesehatan'] ?? 'Tidak ada';
      
      // Calculate BMR using Mifflin-St Jeor Equation
      double bmr = 0;
      
      if (jenisKelamin == 'Laki-laki') {
        bmr = 10 * beratBadan + 6.25 * tinggiBadan - 5 * getEstimatedAgeValue(usia) + 5;
      } else {
        bmr = 10 * beratBadan + 6.25 * tinggiBadan - 5 * getEstimatedAgeValue(usia) - 161;
      }
      
      // Calculate TDEE (Total Daily Energy Expenditure)
      final double activityMultiplier = getActivityMultiplier(tingkatAktivitas);
      final double tdee = bmr * activityMultiplier;
      
      // Adjust calories based on goal
      final double recommendedCalories = adjustCaloriesForGoal(tdee, tujuanDiet);
      
      // Calculate macronutrients based on goal and health condition
      final Map<String, double> macros = calculateMacronutrients(
        recommendedCalories, 
        tujuanDiet, 
        kondisiKesehatan
      );
      
      // Determine main category for recommendations
      final String mainCategory = determineMainCategory(usia, kondisiKesehatan, answers);
      final String secondaryCategory = determineSecondaryCategory(tujuanDiet, answers);
      
      // Set result values
      result['bmr'] = bmr;
      result['tdee'] = tdee;
      result['bmi'] = bmi;
      result['recommendedCalories'] = recommendedCalories;
      result['recommendedProtein'] = macros['protein'] ?? 0.0;
      result['recommendedCarbs'] = macros['carbs'] ?? 0.0;
      result['recommendedFat'] = macros['fat'] ?? 0.0;
      result['mainCategory'] = mainCategory;
      result['secondaryCategory'] = secondaryCategory;
    } catch (e) {
      debugPrint('Error calculating nutrition needs: $e');
    }
    
    return result;
  }
  
  // Helper function to get estimated age value from age category
  static int getEstimatedAgeValue(String ageCategory) {
    switch (ageCategory) {
      case 'Anak-anak (6-12 tahun)':
        return 9; // midpoint
      case 'Remaja (13-18 tahun)':
        return 16; // midpoint
      case 'Dewasa (19-50 tahun)':
        return 35; // midpoint
      case 'Dewasa senior (51-64 tahun)':
        return 58; // midpoint
      case 'Lansia (65+ tahun)':
        return 70; // estimated
      default:
        return 35; // default to adult
    }
  }
  
  // Helper function to get activity multiplier
  static double getActivityMultiplier(String activityLevel) {
    switch (activityLevel) {
      case 'Sangat rendah (hampir tidak berolahraga)':
        return 1.2;
      case 'Rendah (olahraga ringan 1-3 hari/minggu)':
        return 1.375;
      case 'Sedang (olahraga moderat 3-5 hari/minggu)':
        return 1.55;
      case 'Tinggi (olahraga intensif 6-7 hari/minggu)':
        return 1.725;
      case 'Sangat tinggi (atlet/pekerja fisik berat)':
        return 1.9;
      default:
        return 1.55; // default to moderate
    }
  }
  
  // Helper function to adjust calories based on goal
  static double adjustCaloriesForGoal(double tdee, String goal) {
    switch (goal) {
      case 'Penurunan berat badan':
        return tdee * 0.8; // 20% caloric deficit
      case 'Penambahan berat badan/massa otot':
        return tdee * 1.15; // 15% caloric surplus
      case 'Pemeliharaan berat badan':
      case 'Kesehatan jangka panjang':
      case 'Peningkatan energi/stamina':
      default:
        return tdee; // maintenance
    }
  }
  
  // Helper function to calculate macronutrients
  static Map<String, double> calculateMacronutrients(
    double calories, 
    String goal, 
    String healthCondition
  ) {
    double proteinPercentage = 0.25; // default 25%
    double fatPercentage = 0.3; // default 30%
    double carbPercentage = 0.45; // default 45%
    
    // Adjust based on goal
    if (goal == 'Penambahan berat badan/massa otot') {
      proteinPercentage = 0.3; // 30%
      carbPercentage = 0.5; // 50%
      fatPercentage = 0.2; // 20%
    } else if (goal == 'Penurunan berat badan') {
      proteinPercentage = 0.35; // 35%
      carbPercentage = 0.35; // 35%
      fatPercentage = 0.3; // 30%
    }
    
    // Adjust for health conditions
    if (healthCondition == 'Diabetes') {
      carbPercentage = 0.35; // reduce carbs
      proteinPercentage = 0.3; // increase protein
      fatPercentage = 0.35; // healthy fats
    } else if (healthCondition == 'Kolesterol tinggi' || healthCondition == 'Penyakit jantung') {
      fatPercentage = 0.25; // reduce fat
      carbPercentage = 0.55; // increase complex carbs
      proteinPercentage = 0.2; // moderate protein
    }
    
    // Calculate grams
    final double proteinGrams = (calories * proteinPercentage) / 4; // 4 calories per gram
    final double carbGrams = (calories * carbPercentage) / 4; // 4 calories per gram
    final double fatGrams = (calories * fatPercentage) / 9; // 9 calories per gram
    
    return {
      'protein': proteinGrams,
      'carbs': carbGrams,
      'fat': fatGrams,
    };
  }
  
  // Helper function to determine main category for recommendations
  static String determineMainCategory(String ageCategory, String healthCondition, Map<String, dynamic> answers) {
    // Check health conditions first
    if (healthCondition == 'Diabetes') {
      return 'diabetes';
    } else if (healthCondition == 'Kehamilan/menyusui') {
      return 'hamil_trimester1'; // Default to first trimester if not specified
    }
    
    // Then check age groups
    switch (ageCategory) {
      case 'Anak-anak (6-12 tahun)':
        return 'anak_sekolah';
      case 'Remaja (13-18 tahun)':
        return 'remaja';
      case 'Dewasa (19-50 tahun)':
        // Check activity level for adults
        final String tingkatAktivitas = answers['tingkat_aktivitas'] ?? '';
        if (tingkatAktivitas.contains('Tinggi') || tingkatAktivitas.contains('Sangat tinggi')) {
          return 'dewasa_aktif';
        } else {
          return 'dewasa_aktif'; // Default to active adult
        }
      case 'Dewasa senior (51-64 tahun)':
        return 'dewasa_aktif'; // Seniors still active
      case 'Lansia (65+ tahun)':
        return 'dewasa_senior';
      default:
        return 'dewasa_aktif'; // Default category
    }
  }
  
  // Helper function to determine secondary category
  static String determineSecondaryCategory(String goal, Map<String, dynamic> answers) {
    final String preferensiDiet = answers['preferensi_diet'] ?? 'Tidak ada preferensi khusus';
    
    if (preferensiDiet == 'Vegetarian' || preferensiDiet == 'Vegan') {
      return 'plant_based';
    } else if (goal == 'Penurunan berat badan') {
      return 'weight_loss';
    } else if (goal == 'Penambahan berat badan/massa otot') {
      return 'muscle_gain';
    } else {
      return '';
    }
  }
}