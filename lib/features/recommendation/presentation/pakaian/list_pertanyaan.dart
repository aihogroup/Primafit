import 'package:flutter/cupertino.dart';

class FashionQuestions {
  // Daftar pertanyaan untuk analisis rekomendasi fashion
  static final List<Map<String, dynamic>> questions = [
    {
      'id': 'gender',
      'question': 'Bagaimana Anda mengidentifikasi diri?',
      'icon': CupertinoIcons.person_alt,
      'description': 'Pilihan fashion dapat disesuaikan berdasarkan preferensi gender',
      'weight': 9,
      'options': ['Pria', 'Wanita', 'Non-binary/Gender Neutral'],
    },
    {
      'id': 'age_group',
      'question': 'Apa kategori usia Anda?',
      'icon': CupertinoIcons.chart_bar_alt_fill,
      'description': 'Usia dapat memengaruhi rekomendasi gaya yang sesuai',
      'weight': 7,
      'options': ['Remaja (13-19)', 'Dewasa Muda (20-29)', 'Dewasa (30-45)', 'Dewasa Paruh Baya (46-59)', 'Senior (60+)'],
    },
    {
      'id': 'style_preference',
      'question': 'Apa preferensi gaya fashion Anda secara umum?',
      'icon': CupertinoIcons.star,
      'description': 'Preferensi gaya dasar memengaruhi rekomendasi keseluruhan',
      'weight': 8,
      'options': ['Klasik/Timeless', 'Minimalis/Clean', 'Casual/Relaxed', 'Edgy/Street', 'Formal/Elegant', 'Bohemian/Artistic', 'Sporty/Athletic'],
    },
    {
      'id': 'event_type',
      'question': 'Untuk acara apa Anda mencari rekomendasi fashion?',
      'icon': CupertinoIcons.calendar_badge_plus,
      'description': 'Jenis acara menentukan tingkat formalitas pakaian',
      'weight': 10,
      'options': ['Formal (Acara Bisnis/Gala/Pernikahan)', 'Semi-Formal (Dinner/Pesta/Acara Sosial)', 'Smart Casual (Meeting/Kencan/Hangout)', 'Casual (Sehari-hari/Weekend)', 'Special Occasion (Event Budaya/Festival)'],
    },
    {
      'id': 'color_preference',
      'question': 'Apa kelompok warna yang Anda sukai atau cocok untuk Anda?',
      'icon': CupertinoIcons.color_filter,
      'description': 'Preferensi warna personal sangat penting dalam fashion',
      'weight': 8,
      'options': ['Warna Netral (Hitam, Putih, Abu-abu, Beige)', 'Warna Earth Tone (Cokelat, Olive, Terracotta)', 'Warna Pastel (Soft Pink, Baby Blue, Mint)', 'Warna Cerah (Merah, Kuning, Biru)', 'Jewel Tones (Emerald, Ruby, Sapphire)', 'Monokrom (Satu kelompok warna)', 'Mix and Match (Kombinasi Berbagai Warna)'],
    },
    {
      'id': 'body_type',
      'question': 'Bagaimana Anda mendeskripsikan bentuk tubuh Anda?',
      'icon': CupertinoIcons.person_crop_rectangle,
      'description': 'Bentuk tubuh membantu menemukan potongan yang paling flattering',
      'weight': 7,
      'options': ['Pria: Athletic/Inverted Triangle', 'Pria: Rectangle/Slim', 'Pria: Oval/Round', 'Wanita: Hourglass', 'Wanita: Pear/Triangle', 'Wanita: Apple/Round', 'Wanita: Rectangle/Athletic', 'Prefer Not to Specify'],
    },
    {
      'id': 'height',
      'question': 'Bagaimana tinggi badan Anda relatif terhadap rata-rata?',
      'icon': CupertinoIcons.arrow_up_arrow_down,
      'description': 'Tinggi badan memengaruhi proporsi dan panjang pakaian',
      'weight': 6,
      'options': ['Di bawah rata-rata', 'Rata-rata', 'Di atas rata-rata'],
    },
    {
      'id': 'preferred_fit',
      'question': 'Bagaimana fit pakaian yang Anda sukai?',
      'icon': CupertinoIcons.slider_horizontal_3,
      'description': 'Preferensi fit pakaian sangat personal dan memengaruhi kenyamanan',
      'weight': 7,
      'options': ['Slim/Fitted (Mengikuti bentuk tubuh)', 'Regular/Classic (Tidak terlalu ketat/longgar)', 'Relaxed/Loose (Longgar dan nyaman)', 'Oversized (Sangat longgar dengan look statement)', 'Mix of Different Fits'],
    },
    {
      'id': 'season',
      'question': 'Untuk musim apa Anda membutuhkan rekomendasi?',
      'icon': CupertinoIcons.sun_max,
      'description': 'Musim menentukan jenis dan bahan pakaian yang direkomendasikan',
      'weight': 9,
      'options': ['Tropis/Panas', 'Hujan', 'Dingin', 'Cuaca Bervariasi/Transisi'],
    },
    {
      'id': 'budget',
      'question': 'Bagaimana anggaran Anda untuk fashion?',
      'icon': CupertinoIcons.money_dollar_circle,
      'description': 'Budget membantu memberikan rekomendasi yang realistis',
      'weight': 6,
      'options': ['Budget (Affordable/Sale Items)', 'Mid-range (Mix high-street & premium)', 'Premium (Brand names & high quality)', 'Luxury (Designer & high-end)', 'Tidak ada batasan khusus'],
    },
    {
      'id': 'style_icons',
      'question': 'Siapa inspirasi gaya Anda (opsional)?',
      'icon': CupertinoIcons.person_2_square_stack,
      'description': 'Inspirasi membantu memahami arah gaya yang diinginkan',
      'weight': 5,
      'options': ['Selebriti/Public Figure', 'Influencer/Content Creator', 'Fashion Icon Klasik', 'Teman/Keluarga', 'Tidak Ada Inspirasi Khusus'],
    },
    {
      'id': 'fashion_challenges',
      'question': 'Apa tantangan fashion terbesar Anda saat ini?',
      'icon': CupertinoIcons.question_diamond,
      'description': 'Memahami tantangan membantu memberikan solusi yang tepat',
      'weight': 7,
      'options': ['Kesulitan mix & match pakaian', 'Tidak yakin dengan gaya yang cocok', 'Kesulitan berpakaian untuk bentuk tubuh', 'Tidak tahu tren fashion terkini', 'Sulit menemukan ukuran yang tepat', 'Bosan dengan gaya yang ada', 'Kesulitan berpakaian untuk acara tertentu'],
    },
  ];

  /// Pertanyaan aktif berdasarkan jawaban sebelumnya.
  ///
  /// Opsi `body_type` difilter sesuai gender dengan mengembalikan *salinan*
  /// pertanyaan. Sebelumnya list statis [questions] dimutasi langsung, sehingga
  /// filter dari satu jawaban terbawa ke sesi berikutnya (mis. setelah memilih
  /// "Pria", opsi "Wanita" hilang permanen sampai aplikasi ditutup).
  static List<Map<String, dynamic>> activeQuestions(Map<String, String> answers) {
    final gender = answers['gender'];
    return questions.map((q) {
      if (q['id'] != 'body_type' || (gender != 'Pria' && gender != 'Wanita')) return q;
      final options = List<String>.from(q['options']);
      return {
        ...q,
        'options': options
            .where((option) => option.startsWith(gender!) || option == 'Prefer Not to Specify')
            .toList(),
      };
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
    if (questionId == 'body_type' && answers.containsKey('gender')) {
      // Pertanyaan masih ditampilkan, tetapi dengan opsi yang difilter
      return true;
    }
    
    return true;
  }
  
  // Hitung hasil analisis fashion berdasarkan jawaban
  static Map<String, dynamic> calculateFashionRecommendation(Map<String, dynamic> answers) {
    // Inisialisasi hasil
    final Map<String, dynamic> result = {
      'mainCategory': 'casual_neutral',
      'secondaryCategory': '',
      'colorPalette': 'Netral dan Earth Tones',
      'styleDirection': 'Smart Casual dengan Basic Pieces',
    };
    
    try {
      // Ekstrak jawaban user
      final String gender = answers['gender'] ?? 'Non-binary/Gender Neutral';
      final String eventType = answers['event_type'] ?? 'Casual (Sehari-hari/Weekend)';
      final String stylePreference = answers['style_preference'] ?? 'Casual/Relaxed';
      final String colorPreference = answers['color_preference'] ?? 'Warna Netral (Hitam, Putih, Abu-abu, Beige)';
      final String season = answers['season'] ?? 'Cuaca Bervariasi/Transisi';
      
      // Tentukan main category berdasarkan gender dan event type
      if (gender == 'Pria') {
        if (eventType.contains('Formal')) {
          result['mainCategory'] = 'formal_pria';
          result['styleDirection'] = 'Formal Elegant dengan Tailored Pieces';
        } else if (eventType.contains('Semi-Formal')) {
          result['mainCategory'] = 'semiformal_pria';
          result['styleDirection'] = 'Smart Casual dengan Structured Pieces';
        } else {
          result['mainCategory'] = 'casual_pria';
          result['styleDirection'] = 'Casual Comfortable dengan Personal Touch';
        }
      } else if (gender == 'Wanita') {
        if (eventType.contains('Formal')) {
          result['mainCategory'] = 'formal_wanita';
          result['styleDirection'] = 'Formal Elegant dengan Flattering Silhouettes';
        } else if (eventType.contains('Semi-Formal')) {
          result['mainCategory'] = 'semiformal_wanita';
          result['styleDirection'] = 'Smart Casual dengan Feminine Elements';
        } else {
          result['mainCategory'] = 'casual_wanita';
          result['styleDirection'] = 'Casual Chic dengan Statement Pieces';
        }
      } else {
        // Non-binary/Gender Neutral
        if (eventType.contains('Formal')) {
          result['mainCategory'] = 'formal_neutral';
          result['styleDirection'] = 'Structured Formal dengan Clean Lines';
        } else {
          result['mainCategory'] = 'casual_neutral';
          result['styleDirection'] = 'Modern Casual dengan Experimental Silhouettes';
        }
      }
      
      // Tentukan secondary category berdasarkan style preference
      if (stylePreference.contains('Edgy') || stylePreference.contains('Street')) {
        result['secondaryCategory'] = 'edgy_street';
      } else if (stylePreference.contains('Klasik') || stylePreference.contains('Timeless')) {
        result['secondaryCategory'] = 'classic_timeless';
      } else if (stylePreference.contains('Minimalis')) {
        result['secondaryCategory'] = 'minimalist_clean';
      } else if (stylePreference.contains('Bohemian') || stylePreference.contains('Artistic')) {
        result['secondaryCategory'] = 'bohemian_artistic';
      } else if (stylePreference.contains('Sporty') || stylePreference.contains('Athletic')) {
        result['secondaryCategory'] = 'sporty_athletic';
      }
      
      // Tentukan color palette berdasarkan preferensi warna
      if (colorPreference.contains('Netral')) {
        result['colorPalette'] = 'Netral (Hitam, Putih, Abu-abu, Beige)';
      } else if (colorPreference.contains('Earth Tone')) {
        result['colorPalette'] = 'Earth Tones (Cokelat, Olive, Terracotta)';
      } else if (colorPreference.contains('Pastel')) {
        result['colorPalette'] = 'Pastel (Soft Pink, Baby Blue, Mint)';
      } else if (colorPreference.contains('Cerah')) {
        result['colorPalette'] = 'Warna Cerah (Merah, Kuning, Biru)';
      } else if (colorPreference.contains('Jewel')) {
        result['colorPalette'] = 'Jewel Tones (Emerald, Ruby, Sapphire)';
      } else if (colorPreference.contains('Monokrom')) {
        result['colorPalette'] = 'Monokrom dengan Variasi Tekstur';
      } else {
        result['colorPalette'] = 'Mix and Match yang Harmonis';
      }
      
      // Sesuaikan style direction berdasarkan season
      if (season.contains('Tropis') || season.contains('Panas')) {
        result['styleDirection'] += ' dengan Material Breathable';
      } else if (season.contains('Hujan')) {
        result['styleDirection'] += ' dengan Weather-Resistant Pieces';
      } else if (season.contains('Dingin')) {
        result['styleDirection'] += ' dengan Strategic Layering';
      }
      
    } catch (e) {
      debugPrint('Error calculating fashion recommendation: $e');
    }
    
    return result;
  }
}