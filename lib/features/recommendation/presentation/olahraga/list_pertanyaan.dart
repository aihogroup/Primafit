import 'package:flutter/cupertino.dart';
import 'dart:math';

class ExerciseQuestions {
  // Daftar pertanyaan untuk analisis kebutuhan olahraga
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'usia',
      'question': 'Berapa usia Anda?',
      'icon': CupertinoIcons.person_alt,
      'description': 'Kebutuhan dan jenis olahraga berbeda sesuai usia',
      'weight': 10, // Bobot: 10/10
      'options': ['Anak-anak (6-12 tahun)', 'Remaja (13-18 tahun)', 'Dewasa (19-50 tahun)', 'Dewasa senior (51-64 tahun)', 'Lansia (65+ tahun)'],
    },
    {
      'id': 'jenis_kelamin',
      'question': 'Apa jenis kelamin Anda?',
      'icon': CupertinoIcons.person_2,
      'description': 'Jenis kelamin memengaruhi kebutuhan dan respons terhadap aktivitas fisik',
      'weight': 9, // Bobot: 9/10
      'options': ['Laki-laki', 'Perempuan'],
    },
    {
      'id': 'tingkat_aktivitas',
      'question': 'Bagaimana tingkat aktivitas fisik Anda saat ini?',
      'icon': CupertinoIcons.flame,
      'description': 'Aktivitas saat ini menentukan titik awal program olahraga',
      'weight': 9, // Bobot: 9/10
      'options': ['Sangat rendah (hampir tidak berolahraga)', 'Rendah (olahraga ringan 1-3 hari/minggu)', 'Sedang (olahraga moderat 3-5 hari/minggu)', 'Tinggi (olahraga intensif 6-7 hari/minggu)', 'Sangat tinggi (atlet/pekerja fisik berat)'],
    },
    {
      'id': 'berat_badan',
      'question': 'Berapa berat badan Anda? (kg)',
      'icon': CupertinoIcons.chart_bar,
      'description': 'Berat badan digunakan untuk menyesuaikan intensitas dan jenis olahraga',
      'weight': 8, // Bobot: 8/10
      'input_type': 'numeric',
    },
    {
      'id': 'tinggi_badan',
      'question': 'Berapa tinggi badan Anda? (cm)',
      'icon': CupertinoIcons.arrow_up_arrow_down,
      'description': 'Tinggi badan digunakan untuk menghitung BMI dan menyesuaikan rekomendasi',
      'weight': 8, // Bobot: 8/10
      'input_type': 'numeric',
    },
    {
      'id': 'waktu_tersedia',
      'question': 'Berapa banyak waktu yang bisa Anda luangkan untuk olahraga?',
      'icon': CupertinoIcons.clock,
      'description': 'Ketersediaan waktu menentukan durasi dan frekuensi latihan',
      'weight': 7, // Bobot: 7/10
      'options': ['Sangat sedikit (<15 menit/hari)', 'Sedikit (15-30 menit/hari)', 'Sedang (30-60 menit/hari)', 'Banyak (60-90 menit/hari)', 'Sangat banyak (>90 menit/hari)'],
    },
    {
      'id': 'kondisi_kesehatan',
      'question': 'Apakah Anda memiliki kondisi kesehatan yang perlu diperhatikan?',
      'icon': CupertinoIcons.heart,
      'description': 'Kondisi kesehatan tertentu memerlukan penyesuaian dalam aktivitas fisik',
      'weight': 10, // Bobot: 10/10
      'options': ['Tidak ada', 'Masalah jantung/kardiovaskular', 'Tekanan darah tinggi', 'Diabetes', 'Masalah sendi/tulang', 'Masalah pernapasan', 'Kehamilan/pascamelahirkan', 'Lainnya'],
    },
    {
      'id': 'tujuan_olahraga',
      'question': 'Apa tujuan utama Anda berolahraga?',
      'icon': CupertinoIcons.arrow_branch,
      'description': 'Tujuan olahraga menentukan jenis latihan dan intensitas yang direkomendasikan',
      'weight': 9, // Bobot: 9/10
      'options': ['Penurunan berat badan', 'Pemeliharaan kebugaran umum', 'Peningkatan massa otot', 'Peningkatan stamina/daya tahan', 'Kesehatan jantung', 'Relaksasi/Manajemen stres', 'Rehabilitasi/pemulihan cedera'],
    },
    {
      'id': 'preferensi_olahraga',
      'question': 'Aktivitas fisik apa yang Anda sukai?',
      'icon': CupertinoIcons.heart_fill,
      'description': 'Preferensi aktivitas meningkatkan kepatuhan jangka panjang',
      'weight': 7, // Bobot: 7/10
      'options': ['Kardio (lari, bersepeda, berenang)', 'Latihan beban/gym', 'Olahraga tim (basket, sepak bola)', 'Aktivitas di luar ruangan (hiking, kayaking)', 'Aktivitas fleksibilitas (yoga, pilates)', 'Aktivitas berbasis kelas (zumba, aerobik)', 'Tidak memiliki preferensi khusus'],
    },
    {
      'id': 'level_kebugaran',
      'question': 'Bagaimana tingkat kebugaran Anda saat ini?',
      'icon': CupertinoIcons.gauge,
      'description': 'Level kebugaran menentukan titik awal intensitas dan kompleksitas latihan',
      'weight': 8, // Bobot: 8/10
      'options': ['Pemula (baru mulai berolahraga)', 'Dasar (kadang-kadang berolahraga)', 'Menengah (rutin berolahraga 3-4x/minggu)', 'Mahir (rutin berolahraga 5+ kali/minggu)', 'Atlet (latihan terstruktur intensif)'],
    },
    {
      'id': 'akses_fasilitas',
      'question': 'Fasilitas olahraga apa yang Anda miliki akses?',
      'icon': CupertinoIcons.building_2_fill,
      'description': 'Akses fasilitas menentukan jenis latihan yang dapat dilakukan',
      'weight': 6, // Bobot: 6/10
      'options': ['Tidak ada/Hanya rumah', 'Gym/pusat kebugaran', 'Kolam renang', 'Taman/lintasan jogging', 'Lapangan olahraga', 'Studio yoga/pilates', 'Lengkap (akses ke berbagai fasilitas)'],
    },
    {
      'id': 'riwayat_cedera',
      'question': 'Apakah Anda memiliki riwayat cedera yang memengaruhi aktivitas fisik?',
      'icon': CupertinoIcons.bandage,
      'description': 'Riwayat cedera penting untuk menghindari aktivitas yang berpotensi berbahaya',
      'weight': 8, // Bobot: 8/10
      'options': ['Tidak ada', 'Cedera lutut', 'Cedera bahu', 'Cedera punggung/tulang belakang', 'Cedera pergelangan kaki', 'Cedera pinggul', 'Lainnya'],
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
  
  // Hitung kebutuhan olahraga berdasarkan jawaban
  static Map<String, dynamic> calculateExerciseNeeds(Map<String, dynamic> answers) {
    // Inisialisasi hasil
    final Map<String, dynamic> result = {
      'recommendedExerciseMinutes': 0,
      'recommendedFrequency': 0,
      'recommendedIntensity': '',
      'bmr': 0.0,
      'tdee': 0.0,
      'bmi': 0.0,
      'mainCategory': 'dewasa_aktif',
      'secondaryCategory': '',
      'recoveryTimeNeeded': 0,
      'targetHeartRate': {'min': 0, 'max': 0},
      'caloriesBurnEstimate': 0,
      'exerciseLevel': '',
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
      
      // Get basic info
      final String usia = answers['usia'] ?? 'Dewasa (19-50 tahun)';
      final String jenisKelamin = answers['jenis_kelamin'] ?? 'Laki-laki';
      final String tingkatAktivitas = answers['tingkat_aktivitas'] ?? 'Sedang (olahraga moderat 3-5 hari/minggu)';
      final String tujuanOlahraga = answers['tujuan_olahraga'] ?? 'Pemeliharaan kebugaran umum';
      final String kondisiKesehatan = answers['kondisi_kesehatan'] ?? 'Tidak ada';
      final String levelKebugaran = answers['level_kebugaran'] ?? 'Menengah (rutin berolahraga 3-4x/minggu)';
      final String waktuTersedia = answers['waktu_tersedia'] ?? 'Sedang (30-60 menit/hari)';
      
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
      
      // Calculate exercise parameters
      final int recommendedMinutes = calculateRecommendedExerciseMinutes(waktuTersedia, tujuanOlahraga, levelKebugaran, usia);
      final int recommendedFrequency = calculateRecommendedFrequency(tujuanOlahraga, levelKebugaran, usia);
      final String recommendedIntensity = calculateRecommendedIntensity(kondisiKesehatan, tujuanOlahraga, levelKebugaran, bmi, usia);
      final int recoveryTime = calculateRecoveryTime(usia, levelKebugaran, tujuanOlahraga);
      
      // Calculate target heart rate based on age
      final Map<String, int> targetHeartRate = calculateTargetHeartRate(getEstimatedAgeValue(usia), recommendedIntensity);
      
      // Estimate calories burned (rough estimate)
      final int caloriesBurnEstimate = estimateCaloriesBurn(beratBadan, recommendedMinutes, recommendedIntensity);
      
      // Determine exercise level
      final String exerciseLevel = determineExerciseLevel(levelKebugaran, tingkatAktivitas, bmi, usia);
      
      // Determine main category for recommendations
      final String mainCategory = determineMainCategory(usia, kondisiKesehatan, answers);
      final String secondaryCategory = determineSecondaryCategory(tujuanOlahraga, answers);
      
      // Set result values
      result['recommendedExerciseMinutes'] = recommendedMinutes;
      result['recommendedFrequency'] = recommendedFrequency;
      result['recommendedIntensity'] = recommendedIntensity;
      result['bmr'] = bmr;
      result['tdee'] = tdee;
      result['bmi'] = bmi;
      result['mainCategory'] = mainCategory;
      result['secondaryCategory'] = secondaryCategory;
      result['recoveryTimeNeeded'] = recoveryTime;
      result['targetHeartRate'] = targetHeartRate;
      result['caloriesBurnEstimate'] = caloriesBurnEstimate;
      result['exerciseLevel'] = exerciseLevel;
    } catch (e) {
      debugPrint('Error calculating exercise needs: $e');
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
  
  // Calculate recommended exercise minutes
  static int calculateRecommendedExerciseMinutes(String availableTime, String goal, String fitnessLevel, String ageCategory) {
    // Base minutes based on available time
    int baseMinutes = 0;
    switch (availableTime) {
      case 'Sangat sedikit (<15 menit/hari)':
        baseMinutes = 15;
        break;
      case 'Sedikit (15-30 menit/hari)':
        baseMinutes = 25;
        break;
      case 'Sedang (30-60 menit/hari)':
        baseMinutes = 45;
        break;
      case 'Banyak (60-90 menit/hari)':
        baseMinutes = 75;
        break;
      case 'Sangat banyak (>90 menit/hari)':
        baseMinutes = 100;
        break;
      default:
        baseMinutes = 30;
    }
    
    // Adjust based on goal
    double goalMultiplier = 1.0;
    switch (goal) {
      case 'Penurunan berat badan':
        goalMultiplier = 1.2;
        break;
      case 'Peningkatan massa otot':
        goalMultiplier = 1.1;
        break;
      case 'Peningkatan stamina/daya tahan':
        goalMultiplier = 1.3;
        break;
      case 'Kesehatan jantung':
        goalMultiplier = 1.1;
        break;
      case 'Relaksasi/Manajemen stres':
        goalMultiplier = 0.8;
        break;
      case 'Rehabilitasi/pemulihan cedera':
        goalMultiplier = 0.7;
        break;
      default:
        goalMultiplier = 1.0; // Pemeliharaan kebugaran umum
    }
    
    // Adjust based on fitness level
    double fitnessMultiplier = 1.0;
    switch (fitnessLevel) {
      case 'Pemula (baru mulai berolahraga)':
        fitnessMultiplier = 0.7;
        break;
      case 'Dasar (kadang-kadang berolahraga)':
        fitnessMultiplier = 0.9;
        break;
      case 'Menengah (rutin berolahraga 3-4x/minggu)':
        fitnessMultiplier = 1.0;
        break;
      case 'Mahir (rutin berolahraga 5+ kali/minggu)':
        fitnessMultiplier = 1.2;
        break;
      case 'Atlet (latihan terstruktur intensif)':
        fitnessMultiplier = 1.4;
        break;
      default:
        fitnessMultiplier = 1.0;
    }
    
    // Adjust for age
    double ageMultiplier = 1.0;
    switch (ageCategory) {
      case 'Anak-anak (6-12 tahun)':
        ageMultiplier = 0.8;
        break;
      case 'Remaja (13-18 tahun)':
        ageMultiplier = 1.1;
        break;
      case 'Dewasa (19-50 tahun)':
        ageMultiplier = 1.0;
        break;
      case 'Dewasa senior (51-64 tahun)':
        ageMultiplier = 0.9;
        break;
      case 'Lansia (65+ tahun)':
        ageMultiplier = 0.7;
        break;
      default:
        ageMultiplier = 1.0;
    }
    
    // Calculate final minutes (with minimum of 10 minutes per session)
    final int finalMinutes = max(10, (baseMinutes * goalMultiplier * fitnessMultiplier * ageMultiplier).round());
    
    // Cap at reasonable maximum based on available time
    switch (availableTime) {
      case 'Sangat sedikit (<15 menit/hari)':
        return min(finalMinutes, 15);
      case 'Sedikit (15-30 menit/hari)':
        return min(finalMinutes, 30);
      case 'Sedang (30-60 menit/hari)':
        return min(finalMinutes, 60);
      case 'Banyak (60-90 menit/hari)':
        return min(finalMinutes, 90);
      case 'Sangat banyak (>90 menit/hari)':
        return min(finalMinutes, 120);
      default:
        return finalMinutes;
    }
  }
  
  // Calculate recommended exercise frequency (days per week)
  static int calculateRecommendedFrequency(String goal, String fitnessLevel, String ageCategory) {
    // Base frequency based on goal
    int baseFrequency = 0;
    switch (goal) {
      case 'Penurunan berat badan':
        baseFrequency = 5;
        break;
      case 'Pemeliharaan kebugaran umum':
        baseFrequency = 4;
        break;
      case 'Peningkatan massa otot':
        baseFrequency = 4; // Typically with split routines
        break;
      case 'Peningkatan stamina/daya tahan':
        baseFrequency = 5;
        break;
      case 'Kesehatan jantung':
        baseFrequency = 5;
        break;
      case 'Relaksasi/Manajemen stres':
        baseFrequency = 3;
        break;
      case 'Rehabilitasi/pemulihan cedera':
        baseFrequency = 3;
        break;
      default:
        baseFrequency = 4;
    }
    
    // Adjust based on fitness level
    int fitnessAdjustment = 0;
    switch (fitnessLevel) {
      case 'Pemula (baru mulai berolahraga)':
        fitnessAdjustment = -1;
        break;
      case 'Dasar (kadang-kadang berolahraga)':
        fitnessAdjustment = 0;
        break;
      case 'Menengah (rutin berolahraga 3-4x/minggu)':
        fitnessAdjustment = 0;
        break;
      case 'Mahir (rutin berolahraga 5+ kali/minggu)':
        fitnessAdjustment = 1;
        break;
      case 'Atlet (latihan terstruktur intensif)':
        fitnessAdjustment = 2;
        break;
      default:
        fitnessAdjustment = 0;
    }
    
    // Adjust for age
    int ageAdjustment = 0;
    switch (ageCategory) {
      case 'Anak-anak (6-12 tahun)':
        ageAdjustment = 0;
        break;
      case 'Remaja (13-18 tahun)':
        ageAdjustment = 0;
        break;
      case 'Dewasa (19-50 tahun)':
        ageAdjustment = 0;
        break;
      case 'Dewasa senior (51-64 tahun)':
        ageAdjustment = -1;
        break;
      case 'Lansia (65+ tahun)':
        ageAdjustment = -1;
        break;
      default:
        ageAdjustment = 0;
    }
    
    // Calculate final frequency (min 2, max 7 days per week)
    return min(7, max(2, baseFrequency + fitnessAdjustment + ageAdjustment));
  }
  
  // Calculate recommended exercise intensity
  static String calculateRecommendedIntensity(String healthCondition, String goal, String fitnessLevel, double bmi, String ageCategory) {
    // Default intensity level
    String baseIntensity = 'Moderate';
    
    // Adjust based on goal
    switch (goal) {
      case 'Penurunan berat badan':
        baseIntensity = 'Moderate-to-High';
        break;
      case 'Pemeliharaan kebugaran umum':
        baseIntensity = 'Moderate';
        break;
      case 'Peningkatan massa otot':
        baseIntensity = 'High';
        break;
      case 'Peningkatan stamina/daya tahan':
        baseIntensity = 'Moderate-to-High';
        break;
      case 'Kesehatan jantung':
        baseIntensity = 'Moderate';
        break;
      case 'Relaksasi/Manajemen stres':
        baseIntensity = 'Low-to-Moderate';
        break;
      case 'Rehabilitasi/pemulihan cedera':
        baseIntensity = 'Low';
        break;
      default:
        baseIntensity = 'Moderate';
    }
    
    // Adjust based on fitness level
    String adjustedIntensity = baseIntensity;
    switch (fitnessLevel) {
      case 'Pemula (baru mulai berolahraga)':
        if (baseIntensity == 'High') {
          adjustedIntensity = 'Moderate';
        } else if (baseIntensity == 'Moderate-to-High') adjustedIntensity = 'Moderate';
        else if (baseIntensity == 'Moderate') adjustedIntensity = 'Low-to-Moderate';
        break;
      case 'Dasar (kadang-kadang berolahraga)':
        if (baseIntensity == 'High') adjustedIntensity = 'Moderate-to-High';
        break;
      case 'Atlet (latihan terstruktur intensif)':
        if (baseIntensity == 'Moderate') {
          adjustedIntensity = 'Moderate-to-High';
        } else if (baseIntensity == 'Moderate-to-High') adjustedIntensity = 'High';
        break;
      default:
        // Keep the base intensity for intermediate and advanced levels
    }
    
    // Health condition overrides
    if (healthCondition != 'Tidak ada') {
      switch (healthCondition) {
        case 'Masalah jantung/kardiovaskular':
          adjustedIntensity = 'Low-to-Moderate';
          break;
        case 'Tekanan darah tinggi':
          if (baseIntensity == 'High') {
            adjustedIntensity = 'Moderate';
          } else if (baseIntensity == 'Moderate-to-High') adjustedIntensity = 'Moderate';
          break;
        case 'Diabetes':
          if (baseIntensity == 'High') adjustedIntensity = 'Moderate-to-High';
          break;
        case 'Masalah sendi/tulang':
          if (baseIntensity == 'High' || baseIntensity == 'Moderate-to-High') {
            adjustedIntensity = 'Low-to-Moderate';
          }
          break;
        case 'Masalah pernapasan':
          if (baseIntensity == 'High') {
            adjustedIntensity = 'Moderate';
          } else if (baseIntensity == 'Moderate-to-High') adjustedIntensity = 'Moderate';
          break;
        case 'Kehamilan/pascamelahirkan':
          if (baseIntensity == 'High' || baseIntensity == 'Moderate-to-High') {
            adjustedIntensity = 'Moderate';
          }
          break;
        default:
          if (baseIntensity == 'High') adjustedIntensity = 'Moderate';
      }
    }
    
    // Age overrides (special consideration for elderly and children)
    if (ageCategory == 'Lansia (65+ tahun)') {
      if (adjustedIntensity == 'High' || adjustedIntensity == 'Moderate-to-High') {
        adjustedIntensity = 'Moderate';
      }
    }
    
    // BMI considerations
    if (bmi > 30) { // Obesity
      if (adjustedIntensity == 'High') adjustedIntensity = 'Moderate-to-High';
    }
    
    return adjustedIntensity;
  }
  
  // Calculate recovery time needed (in hours)
  static int calculateRecoveryTime(String ageCategory, String fitnessLevel, String goal) {
    // Base recovery hours
    int baseRecovery = 24; // 1 day
    
    // Adjust based on age
    switch (ageCategory) {
      case 'Anak-anak (6-12 tahun)':
        baseRecovery = 18;
        break;
      case 'Remaja (13-18 tahun)':
        baseRecovery = 20;
        break;
      case 'Dewasa (19-50 tahun)':
        baseRecovery = 24;
        break;
      case 'Dewasa senior (51-64 tahun)':
        baseRecovery = 36;
        break;
      case 'Lansia (65+ tahun)':
        baseRecovery = 48;
        break;
      default:
        baseRecovery = 24;
    }
    
    // Adjust based on fitness level
    int fitnessAdjustment = 0;
    switch (fitnessLevel) {
      case 'Pemula (baru mulai berolahraga)':
        fitnessAdjustment = 12;
        break;
      case 'Dasar (kadang-kadang berolahraga)':
        fitnessAdjustment = 6;
        break;
      case 'Menengah (rutin berolahraga 3-4x/minggu)':
        fitnessAdjustment = 0;
        break;
      case 'Mahir (rutin berolahraga 5+ kali/minggu)':
        fitnessAdjustment = -6;
        break;
      case 'Atlet (latihan terstruktur intensif)':
        fitnessAdjustment = -12;
        break;
      default:
        fitnessAdjustment = 0;
    }
    
    // Adjust based on goal
    int goalAdjustment = 0;
    switch (goal) {
      case 'Peningkatan massa otot':
        goalAdjustment = 12; // Muscle building requires more recovery
        break;
      case 'Rehabilitasi/pemulihan cedera':
        goalAdjustment = 24; // Injury recovery needs more time
        break;
      case 'Peningkatan stamina/daya tahan':
        goalAdjustment = -6; // Endurance training can be done more frequently
        break;
      default:
        goalAdjustment = 0;
    }
    
    // Calculate final recovery time (minimum 12 hours)
    return max(12, baseRecovery + fitnessAdjustment + goalAdjustment);
  }
  
  // Calculate target heart rate range
  static Map<String, int> calculateTargetHeartRate(int age, String intensity) {
    // Max heart rate (rough estimate)
    final int maxHeartRate = 220 - age;
    
    // Target heart rate ranges based on intensity
    int minRate = 0;
    int maxRate = 0;
    
    switch (intensity) {
      case 'Low':
        minRate = (maxHeartRate * 0.5).round();
        maxRate = (maxHeartRate * 0.6).round();
        break;
      case 'Low-to-Moderate':
        minRate = (maxHeartRate * 0.6).round();
        maxRate = (maxHeartRate * 0.7).round();
        break;
      case 'Moderate':
        minRate = (maxHeartRate * 0.7).round();
        maxRate = (maxHeartRate * 0.8).round();
        break;
      case 'Moderate-to-High':
        minRate = (maxHeartRate * 0.75).round();
        maxRate = (maxHeartRate * 0.85).round();
        break;
      case 'High':
        minRate = (maxHeartRate * 0.8).round();
        maxRate = (maxHeartRate * 0.9).round();
        break;
      default:
        minRate = (maxHeartRate * 0.7).round();
        maxRate = (maxHeartRate * 0.8).round();
    }
    
    return {'min': minRate, 'max': maxRate};
  }
  
  // Estimate calories burned during exercise
  static int estimateCaloriesBurn(double weightKg, int minutes, String intensity) {
    // MET values (Metabolic Equivalent of Task) approximation based on intensity
    double met = 0;
    switch (intensity) {
      case 'Low':
        met = 3.0;
        break;
      case 'Low-to-Moderate':
        met = 4.5;
        break;
      case 'Moderate':
        met = 6.0;
        break;
      case 'Moderate-to-High':
        met = 7.5;
        break;
      case 'High':
        met = 9.0;
        break;
      default:
        met = 6.0;
    }
    
    // Calories burned formula: MET × weight (kg) × time (hours)
    final double hours = minutes / 60;
    final int calories = (met * weightKg * hours).round();
    
    return calories;
  }
  
  // Determine exercise level
  static String determineExerciseLevel(String fitnessLevel, String activityLevel, double bmi, String ageCategory) {
    // Base level from fitness level
    String baseLevel = '';
    
    switch (fitnessLevel) {
      case 'Pemula (baru mulai berolahraga)':
        baseLevel = 'Beginner';
        break;
      case 'Dasar (kadang-kadang berolahraga)':
        baseLevel = 'Beginner-Intermediate';
        break;
      case 'Menengah (rutin berolahraga 3-4x/minggu)':
        baseLevel = 'Intermediate';
        break;
      case 'Mahir (rutin berolahraga 5+ kali/minggu)':
        baseLevel = 'Advanced';
        break;
      case 'Atlet (latihan terstruktur intensif)':
        baseLevel = 'Elite';
        break;
      default:
        baseLevel = 'Intermediate';
    }
    
    // Adjust for current activity level
    switch (activityLevel) {
      case 'Sangat rendah (hampir tidak berolahraga)':
        if (baseLevel == 'Intermediate' || baseLevel == 'Advanced') baseLevel = 'Beginner-Intermediate';
        break;
      case 'Sangat tinggi (atlet/pekerja fisik berat)':
        if (baseLevel == 'Beginner') baseLevel = 'Beginner-Intermediate';
        break;
      default:
        // No adjustment
    }
    
    // Adjust for age
    switch (ageCategory) {
      case 'Lansia (65+ tahun)':
        if (baseLevel == 'Advanced' || baseLevel == 'Elite') baseLevel = 'Intermediate';
        break;
      default:
        // No adjustment
    }
    
    // Adjust for BMI
    if (bmi > 30) {
      if (baseLevel == 'Advanced' || baseLevel == 'Elite') baseLevel = 'Intermediate';
    }
    
    return baseLevel;
  }
  
  // Helper function to determine main category for recommendations
  static String determineMainCategory(String ageCategory, String healthCondition, Map<String, dynamic> answers) {
    // Check health conditions first
    if (healthCondition == 'Masalah jantung/kardiovaskular' || healthCondition == 'Tekanan darah tinggi') {
      return 'kardio';
    } else if (healthCondition == 'Diabetes') {
      return 'diabetes';
    } else if (healthCondition == 'Masalah sendi/tulang') {
      return 'sendi';
    } else if (healthCondition == 'Kehamilan/pascamelahirkan') {
      return 'prenatal';
    }
    
    // Then check age groups
    switch (ageCategory) {
      case 'Anak-anak (6-12 tahun)':
        return 'anak';
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
        return 'dewasa_senior';
      case 'Lansia (65+ tahun)':
        return 'lansia';
      default:
        return 'dewasa_aktif'; // Default category
    }
  }
  
  // Helper function to determine secondary category
  static String determineSecondaryCategory(String goal, Map<String, dynamic> answers) {
    final String preferensiOlahraga = answers['preferensi_olahraga'] ?? 'Tidak memiliki preferensi khusus';
    
    if (preferensiOlahraga == 'Kardio (lari, bersepeda, berenang)') {
      return 'cardio_focus';
    } else if (preferensiOlahraga == 'Latihan beban/gym') {
      return 'strength_focus';
    } else if (goal == 'Penurunan berat badan') {
      return 'weight_loss';
    } else if (goal == 'Peningkatan massa otot') {
      return 'muscle_gain';
    } else if (goal == 'Peningkatan stamina/daya tahan') {
      return 'endurance';
    } else if (goal == 'Relaksasi/Manajemen stres') {
      return 'stress_management';
    } else {
      return '';
    }
  }
}