class PenyakitUmum {
  // Map untuk informasi tambahan setiap penyakit
  static final Map<String, Map<String, String>> penyakitInfo = {
    'Anemia': {
      'description': 'Kondisi kekurangan sel darah merah atau hemoglobin yang sehat dalam darah.',
      'treatment': 'Suplemen zat besi, vitamin B12, atau asam folat, tergantung penyebabnya.',
      'icon': 'blood_drop',
    },
    'Asma': {
      'description': 'Kondisi kronis dimana saluran udara paru-paru menyempit dan membengkak, memproduksi lendir ekstra.',
      'treatment': 'Inhaler pengontrol dan pelega, hindari pemicu, rencana penanganan asma.',
      'icon': 'inhaler',
    },
    'Asam lambung naik / Maag': {
      'description': 'Kondisi dimana asam lambung naik ke kerongkongan, menyebabkan sensasi terbakar. Maag adalah peradangan pada lapisan lambung.',
      'treatment': 'Obat penghambat asam, antibiotik jika disebabkan bakteri, modifikasi pola makan.',
      'icon': 'acid_reflux',
    },
    'Batuk pilek': {
      'description': 'Infeksi saluran pernapasan atas yang umum, biasanya disebabkan oleh virus.',
      'treatment': 'Istirahat, minum banyak cairan, obat pereda gejala seperti dekongestan dan antihistamin.',
      'icon': 'lungs',
    },
    'Cacar air': {
      'description': 'Infeksi virus yang menyebabkan ruam gatal berisi cairan yang kemudian menjadi keropeng.',
      'treatment': 'Istirahat, obat pereda gatal, lotion calamine, dan antivirus dalam kasus tertentu.',
      'icon': 'rash',
    },
    'Demam berdarah dengue (DBD)': {
      'description': 'Penyakit yang disebabkan oleh virus dengue yang ditularkan melalui gigitan nyamuk Aedes aegypti.',
      'treatment': 'Rehidrasi, pemantauan trombosit, istirahat total, dan perawatan di rumah sakit untuk kasus parah.',
      'icon': 'virus',
    },
    'Demam tifoid (tipes)': {
      'description': 'Infeksi bakteri yang menyebar melalui makanan dan air yang terkontaminasi.',
      'treatment': 'Antibiotik, istirahat total, dan hidrasi yang cukup.',
      'icon': 'bacteria',
    },
    'Diare / Radang usus (gastroenteritis)': {
      'description': 'Gangguan pencernaan yang ditandai dengan buang air besar yang encer dan sering.',
      'treatment': 'Rehidrasi, makanan ringan, probiotik, dan obat antidiare dalam kasus tertentu.',
      'icon': 'stomach',
    },
    'Diabetes tipe 2 ringan': {
      'description': 'Kondisi dimana tubuh tidak menggunakan insulin dengan baik, menyebabkan kadar gula darah tinggi.',
      'treatment': 'Diet seimbang, olahraga teratur, pemantauan gula darah, dan kadang obat penurun gula darah oral.',
      'icon': 'glucose',
    },
    'Gagal ginjal ringan': {
      'description': 'Kondisi dimana ginjal mulai kehilangan kemampuannya untuk menyaring limbah dan cairan berlebih dari darah.',
      'treatment': 'Pengaturan diet, manajemen tekanan darah, dan pengobatan untuk memperlambat kerusakan ginjal.',
      'icon': 'kidney',
    },
    'Hepatitis A': {
      'description': 'Infeksi virus yang menyebabkan peradangan pada hati, disebarkan melalui makanan dan air yang terkontaminasi.',
      'treatment': 'Istirahat, menjaga hidrasi, menghindari alkohol, dan pemantauan fungsi hati.',
      'icon': 'liver',
    },
    'Hipertensi': {
      'description': 'Tekanan darah yang lebih tinggi dari normal secara persisten.',
      'treatment': 'Perubahan gaya hidup, diet rendah garam, olahraga teratur, dan obat penurun tekanan darah.',
      'icon': 'heart_rate',
    },
    'Hipotensi': {
      'description': 'Kondisi dimana tekanan darah lebih rendah dari normal.',
      'treatment': 'Asupan cairan yang cukup, penyesuaian diet, dan dalam kasus tertentu pengobatan.',
      'icon': 'heart_rate_low',
    },
    'Infeksi saluran kemih (ISK)': {
      'description': 'Infeksi pada bagian sistem kemih seperti kandung kemih, uretra, atau ginjal.',
      'treatment': 'Antibiotik, minum banyak cairan, dan pereda nyeri.',
      'icon': 'kidney',
    },
    'Infeksi saluran pernapasan atas': {
      'description': 'Infeksi pada hidung, sinus, tenggorokan yang biasanya disebabkan oleh virus.',
      'treatment': 'Istirahat, minum banyak cairan, obat pereda gejala, dan antibiotik jika ada infeksi bakteri sekunder.',
      'icon': 'lungs',
    },
    'Influenza': {
      'description': 'Infeksi virus yang menyerang sistem pernapasan (hidung, tenggorokan, dan paru-paru).',
      'treatment': 'Istirahat, minum banyak cairan, obat pereda nyeri dan demam, dan antivirus dalam kasus tertentu.',
      'icon': 'virus',
    },
    'Migrain / Sakit kepala berat': {
      'description': 'Sakit kepala parah yang sering disertai mual, muntah, dan sensitivitas terhadap cahaya dan suara.',
      'treatment': 'Obat pereda nyeri spesifik migrain, istirahat di ruang gelap dan tenang, terapi preventif.',
      'icon': 'head_pain',
    },
    'Pneumonia ringan (infeksi paru-paru)': {
      'description': 'Infeksi paru-paru yang menyebabkan kantung udara di paru-paru (alveoli) meradang dan terisi cairan.',
      'treatment': 'Antibiotik, istirahat cukup, cairan yang memadai, dan manajemen gejala.',
      'icon': 'waveform_path',
    },
    'Sinusitis akut': {
      'description': 'Peradangan pada sinus yang biasanya disebabkan oleh infeksi virus atau bakteri.',
      'treatment': 'Dekongestan, analgesia, irigasi saline, dan antibiotik jika disebabkan oleh bakteri.',
      'icon': 'sinus',
    },
    'Stres': {
      'description': 'Respons fisik dan emosional terhadap tekanan atau tuntutan.',
      'treatment': 'Teknik relaksasi, meditasi, olahraga, terapi bicara, dan dalam kasus tertentu obat penenang.',
      'icon': 'brain_waves',
    },
    'Vertigo': {
      'description': 'Sensasi pusing berputar atau perasaan bahwa lingkungan sekitar berputar.',
      'treatment': 'Tergantung penyebab, mungkin memerlukan maneuver reposisi, obat anti-vertigo, atau terapi rehabilitasi vestibular.',
      'icon': 'balance',
    },
    'Sehat': {
    'description': 'Kondisi tubuh yang berfungsi secara normal tanpa gejala atau gangguan kesehatan tertentu.',
    'treatment': 'Tidak memerlukan penanganan medis. Menjaga pola hidup sehat, olahraga rutin, makan bergizi, tidur cukup, dan mengelola stres penting untuk mempertahankan kesehatan.',
    'icon': 'wellness',
    },
    'Normal': {
    'description': 'Kondisi tubuh kemungkinan berada dalam batas normal. Tidak ditemukan kelainan atau gejala yang mengarah pada suatu penyakit khusus.',
    'treatment': 'Tidak diperlukan penanganan khusus. Disarankan tetap menjaga pola hidup sehat dan melakukan pemeriksaan rutin bila diperlukan.',
    'icon': 'check_circle',
    },
  };
}