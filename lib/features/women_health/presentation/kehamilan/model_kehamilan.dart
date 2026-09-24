import 'package:flutter/material.dart';

class Pregnancy {
  int id;
  DateTime startDate; // Tanggal mulai kehamilan (HPHT/LMP)
  DateTime dueDate; // HPL/EDD (Hari Perkiraan Lahir)
  DateTime? birthDate; // Tanggal kelahiran (jika sudah lahir)
  int currentWeek; // Minggu kehamilan saat ini
  List<PregnancySymptom> symptoms; // Gejala yang dirasakan
  List<PregnancyCheckup> checkups; // Riwayat pemeriksaan
  List<PregnancyWeight> weightRecords; // Riwayat berat badan
  List<PregnancyNote> notes; // Catatan kehamilan
  bool isActive; // Status aktif/tidak
  
  Pregnancy({
    required this.id,
    required this.startDate,
    required this.dueDate,
    this.birthDate,
    required this.currentWeek,
    this.symptoms = const [],
    this.checkups = const [],
    this.weightRecords = const [],
    this.notes = const [],
    this.isActive = true,
  });
  
  // Konversi ke Map untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_date': startDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'birth_date': birthDate?.toIso8601String(),
      'current_week': currentWeek,
      'is_active': isActive ? 1 : 0,
    };
  }
  
  // Buat objek dari database
  factory Pregnancy.fromMap(Map<String, dynamic> map) {
    return Pregnancy(
      id: map['id'],
      startDate: DateTime.parse(map['start_date']),
      dueDate: DateTime.parse(map['due_date']),
      birthDate: map['birth_date'] != null ? DateTime.parse(map['birth_date']) : null,
      currentWeek: map['current_week'],
      isActive: map['is_active'] == 1,
    );
  }
  
  // Hitung usia kehamilan saat ini
  int calculateCurrentWeek() {
    final today = DateTime.now();
    final difference = today.difference(startDate).inDays;
    return (difference / 7).floor() + 1;
  }
  
  // Hitung trimester saat ini
  int get currentTrimester {
    if (currentWeek <= 13) {
      return 1;
    } else if (currentWeek <= 27) {
      return 2;
    } else {
      return 3;
    }
  }
  
  // Cek apakah tanggal tertentu dalam periode kehamilan
  bool isInPregnancyPeriod(DateTime date) {
    return date.isAfter(startDate.subtract(const Duration(days: 1))) && 
           date.isBefore(dueDate.add(const Duration(days: 1)));
  }
  
  // Mendapatkan minggu kehamilan untuk tanggal tertentu
  int getWeekForDate(DateTime date) {
    if (!isInPregnancyPeriod(date)) {
      return 0;
    }
    
    final difference = date.difference(startDate).inDays;
    return (difference / 7).floor() + 1;
  }
  
  // Mendapatkan ukuran bayi berdasarkan minggu kehamilan
  String getBabySize(int week) {
    switch (week) {
      case 1:
      case 2:
      case 3:
      case 4:
        return 'Biji poppy (0,4 mm)';
      case 5:
        return 'Biji sesame (3 mm)';
      case 6:
        return 'Biji lentil (6 mm)';
      case 7:
        return 'Blueberry (1,3 cm)';
      case 8:
        return 'Kacang polong (1,6 cm)';
      case 9:
        return 'Anggur (2,3 cm)';
      case 10:
        return 'Stroberi (3,1 cm)';
      case 11:
        return 'Jeruk kecil (4,1 cm)';
      case 12:
        return 'Jeruk besar (5,4 cm)';
      case 13:
        return 'Lemon (7,4 cm)';
      case 14:
        return 'Wortel (8,7 cm)';
      case 15:
        return 'Apel (10,1 cm)';
      case 16:
        return 'Alpukat (11,6 cm)';
      case 17:
        return 'Kaki tangan (12,7 cm)';
      case 18:
        return 'Paprika (14,2 cm)';
      case 19:
        return 'Tomat (15,3 cm)';
      case 20:
        return 'Pisang (16,5 cm)';
      case 21:
        return 'Wortel besar (26,7 cm)';
      case 22:
        return 'Terong (27,9 cm)';
      case 23:
        return 'Mangga (28,9 cm)';
      case 24:
        return 'Kembang kol (30 cm)';
      case 25:
        return 'Daun bawang (34,6 cm)';
      case 26:
        return 'Kubis (35,6 cm)';
      case 27:
        return 'Kacang polong besar (36,6 cm)';
      case 28:
        return 'Brokoli (37,6 cm)';
      case 29:
        return 'Buah naga (38,6 cm)';
      case 30:
        return 'Kubis (39,9 cm)';
      case 31:
        return 'Kelapa (41,1 cm)';
      case 32:
        return 'Kol (42,4 cm)';
      case 33:
        return 'Nanas (43,7 cm)';
      case 34:
        return 'Melon (45 cm)';
      case 35:
        return 'Pepaya (46,2 cm)';
      case 36:
        return 'Selada romaine (47,4 cm)';
      case 37:
        return 'Selada cos (48,6 cm)';
      case 38:
        return 'Labu kecil (49,8 cm)';
      case 39:
        return 'Semangka mini (50,7 cm)';
      case 40:
        return 'Semangka (51,2 cm)';
      default:
        return 'Ukuran tidak diketahui';
    }
  }
  
  // Mendapatkan berat bayi berdasarkan minggu kehamilan (dalam gram)
  double getBabyWeight(int week) {
    switch (week) {
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
        return 1.0;
      case 9:
        return 2.0;
      case 10:
        return 5.0;
      case 11:
        return 10.0;
      case 12:
        return 16.0;
      case 13:
        return 23.0;
      case 14:
        return 43.0;
      case 15:
        return 70.0;
      case 16:
        return 100.0;
      case 17:
        return 140.0;
      case 18:
        return 190.0;
      case 19:
        return 240.0;
      case 20:
        return 300.0;
      case 21:
        return 360.0;
      case 22:
        return 430.0;
      case 23:
        return 501.0;
      case 24:
        return 600.0;
      case 25:
        return 660.0;
      case 26:
        return 760.0;
      case 27:
        return 875.0;
      case 28:
        return 1000.0;
      case 29:
        return 1150.0;
      case 30:
        return 1300.0;
      case 31:
        return 1500.0;
      case 32:
        return 1700.0;
      case 33:
        return 1900.0;
      case 34:
        return 2150.0;
      case 35:
        return 2380.0;
      case 36:
        return 2620.0;
      case 37:
        return 2860.0;
      case 38:
        return 3080.0;
      case 39:
        return 3290.0;
      case 40:
        return 3500.0;
      default:
        return 0.0;
    }
  }
  
  // Mendapatkan perkembangan bayi berdasarkan minggu kehamilan
  String getBabyDevelopment(int week) {
    switch (week) {
      case 1:
      case 2:
        return 'Proses pembuahan dan perjalanan zigot ke rahim.';
      case 3:
        return 'Zigot berkembang menjadi blastokista dan menempel pada dinding rahim.';
      case 4:
        return 'Embrio mulai terbentuk. Plasenta dan kantung ketuban mulai berkembang.';
      case 5:
        return 'Tabung neural (cikal bakal otak dan sumsum tulang belakang) mulai terbentuk.';
      case 6:
        return 'Jantung mulai berdetak. Tunas tangan dan kaki mulai muncul.';
      case 7:
        return 'Mata, hidung, dan mulut mulai terbentuk. Otak berkembang pesat.';
      case 8:
        return 'Semua organ utama mulai terbentuk. Jari tangan dan kaki mulai terlihat.';
      case 9:
        return 'Embrio kini disebut janin. Genitalia mulai terbentuk. Dapat bergerak, namun belum terasa.';
      case 10:
        return 'Struktur wajah semakin jelas. Tulang mulai mengeras.';
      case 11:
        return 'Janin bisa cegukan, menghisap, dan menelan. Ginjal mulai memproduksi urin.';
      case 12:
        return 'Jari tangan dan kaki sudah lengkap dengan kuku. Janin bisa membuat ekspresi wajah.';
      case 13:
        return 'Tali pusat sudah terbentuk sempurna. Plasenta berfungsi penuh.';
      case 14:
        return 'Janin mulai melakukan gerakan pernapasan. Jenis kelamin sudah bisa ditentukan melalui USG.';
      case 15:
        return 'Kulit masih transparan. Rambut tipis mulai tumbuh.';
      case 16:
        return 'Kepala bisa bergerak. Ekspresi wajah seperti mengerutkan dahi sudah bisa dilakukan.';
      case 17:
        return 'Lapisan lemak mulai terbentuk. Gerakan semakin terkoordinasi.';
      case 18:
        return 'Ibu mungkin mulai merasakan gerakan janin. Telinga sudah bisa mendengar.';
      case 19:
        return 'Vernix caseosa (lapisan pelindung kulit) dan lanugo (rambut halus) menutupi tubuh.';
      case 20:
        return 'Janin mengalami refleks kejut. Irama tidur-bangun mulai terbentuk.';
      case 21:
        return 'Alis dan kelopak mata sudah terbentuk. Kuku jari tangan sudah lengkap.';
      case 22:
        return 'Gusi sudah memiliki pola gigi bayi. Keseimbangan mulai berkembang.';
      case 23:
        return 'Janin bisa mendengar suara dari luar rahim. Paru-paru berkembang untuk bernapas.';
      case 24:
        return 'Sidik jari terbentuk. Janin sering cegukan dan terasa seperti sentakan kecil.';
      case 25:
        return 'Janin merespon suara dan sentakan dari luar. Bisa membuka dan menutup mata.';
      case 26:
        return 'Otak berkembang pesat. Janin aktif bergerak, menendang, dan berputar.';
      case 27:
        return 'Sistem saraf semakin sempurna. Pola tidur-bangun semakin teratur.';
      case 28:
        return 'Janin bisa melihat cahaya yang masuk ke rahim. Paru-paru semakin matang.';
      case 29:
        return 'Tulang semakin keras. Otak mampu mengontrol suhu tubuh.';
      case 30:
        return 'Janin sering mengubah posisi. Lapisan lemak semakin banyak.';
      case 31:
        return 'Sistem kekebalan tubuh berkembang. Koordinasi tangan dan mulut sudah baik.';
      case 32:
        return 'Kuku jari kaki sudah lengkap. Tulang tengkorak masih lentur.';
      case 33:
        return 'Paru-paru hampir matang. Janin bisa berkedip sempurna.';
      case 34:
        return 'Kebanyakan sistem organ sudah matang. Janin mengambil posisi kepala di bawah.';
      case 35:
        return 'Ginjal sudah matang. Gerakan semakin terbatas karena ruang yang sempit.';
      case 36:
        return 'Lapisan lemak telah cukup. Janin siap untuk dilahirkan jika diperlukan.';
      case 37:
        return 'Janin dianggap cukup bulan. Sistem pencernaan siap untuk makanan.';
      case 38:
        return 'Sistem kekebalan terus berkembang. Janin terus mengambil antibodi dari ibu.';
      case 39:
        return 'Vernix dan lanugo mulai menghilang. Janin memiliki refleks kuat.';
      case 40:
        return 'Janin sudah siap lahir. Perkembangan telah sempurna.';
      default:
        return 'Informasi perkembangan tidak tersedia.';
    }
  }
  
  // Mendapatkan tips untuk ibu berdasarkan minggu kehamilan
  String getMotherTips(int week) {
    if (week >= 1 && week <= 13) {
      // Trimester 1
      return 'Konsumsi asam folat, istirahat cukup, hindari alkohol dan rokok, '
             'kurangi kafein, lakukan check-up rutin, dan atasi morning sickness '
             'dengan makan sedikit tapi sering.';
    } else if (week >= 14 && week <= 27) {
      // Trimester 2
      return 'Lakukan latihan Kegel, pilih pakaian yang nyaman, tidur miring ke kiri, '
             'konsumsi makanan tinggi zat besi dan kalsium, tetap aktif dengan olahraga '
             'ringan seperti berenang atau yoga untuk ibu hamil.';
    } else {
      // Trimester 3
      return 'Perhatikan gerakan janin, kenali tanda-tanda persalinan, siapkan perlengkapan '
             'bayi, tidur miring ke kiri, perhatikan tanda kontraksi palsu Braxton Hicks, '
             'dan jaga komunikasi dengan dokter atau bidan.';
    }
  }
}

// Gejala kehamilan
class PregnancySymptom {
  int id;
  int pregnancyId;
  DateTime date;
  PregnancySymptomType type;
  int intensity; // 1-5 scale
  String notes;
  
  PregnancySymptom({
    required this.id,
    required this.pregnancyId,
    required this.date,
    required this.type,
    this.intensity = 3,
    this.notes = '',
  });
  
  // Konversi ke Map untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pregnancy_id': pregnancyId,
      'date': date.toIso8601String(),
      'type': type.index,
      'intensity': intensity,
      'notes': notes,
    };
  }
  
  // Buat objek dari database
  factory PregnancySymptom.fromMap(Map<String, dynamic> map) {
    return PregnancySymptom(
      id: map['id'],
      pregnancyId: map['pregnancy_id'],
      date: DateTime.parse(map['date']),
      type: PregnancySymptomType.values[map['type']],
      intensity: map['intensity'],
      notes: map['notes'],
    );
  }
}

// Enum untuk jenis gejala kehamilan
enum PregnancySymptomType {
  nausea,           // Mual
  vomiting,         // Muntah
  fatigue,          // Kelelahan
  heartburn,        // Mulas
  constipation,     // Sembelit
  backPain,         // Nyeri punggung
  headache,         // Sakit kepala
  legCramps,        // Kram kaki
  swelling,         // Bengkak
  insomnia,         // Susah tidur
  foodCravings,     // Ngidam
  frequentUrination, // Sering buang air kecil
  moodSwings,       // Perubahan mood
  dizziness,        // Pusing
  breastTenderness, // Nyeri payudara
  indigestion,      // Gangguan pencernaan
  bloating,         // Kembung
  vaginalDischarge, // Keputihan
  spotting,         // Bercak darah
  contractions,     // Kontraksi
  other,            // Lainnya
}

// Pemeriksaan kehamilan
class PregnancyCheckup {
  int id;
  int pregnancyId;
  DateTime date;
  CheckupType type;
  double weight; // Berat badan ibu (kg)
  double bpSystolic; // Tekanan darah sistolik
  double bpDiastolic; // Tekanan darah diastolik
  double fetalHeartRate; // Detak jantung janin (bpm)
  double fundusHeight; // Tinggi fundus (cm)
  String doctorNotes; // Catatan dokter
  String nextSteps; // Langkah selanjutnya
  List<String> medications; // Obat-obatan yang diresepkan
  
  PregnancyCheckup({
    required this.id,
    required this.pregnancyId,
    required this.date,
    required this.type,
    required this.weight,
    required this.bpSystolic,
    required this.bpDiastolic,
    this.fetalHeartRate = 0,
    this.fundusHeight = 0,
    this.doctorNotes = '',
    this.nextSteps = '',
    this.medications = const [],
  });
  
  // Konversi ke Map untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pregnancy_id': pregnancyId,
      'date': date.toIso8601String(),
      'type': type.index,
      'weight': weight,
      'bp_systolic': bpSystolic,
      'bp_diastolic': bpDiastolic,
      'fetal_heart_rate': fetalHeartRate,
      'fundus_height': fundusHeight,
      'doctor_notes': doctorNotes,
      'next_steps': nextSteps,
      'medications': medications.join(','),
    };
  }
  
  // Buat objek dari database
  factory PregnancyCheckup.fromMap(Map<String, dynamic> map) {
    return PregnancyCheckup(
      id: map['id'],
      pregnancyId: map['pregnancy_id'],
      date: DateTime.parse(map['date']),
      type: CheckupType.values[map['type']],
      weight: map['weight'],
      bpSystolic: map['bp_systolic'],
      bpDiastolic: map['bp_diastolic'],
      fetalHeartRate: map['fetal_heart_rate'],
      fundusHeight: map['fundus_height'],
      doctorNotes: map['doctor_notes'],
      nextSteps: map['next_steps'],
      medications: map['medications'] != null && map['medications'].isNotEmpty
          ? map['medications'].split(',')
          : [],
    );
  }
}

// Enum untuk jenis pemeriksaan
enum CheckupType {
  regular,      // Pemeriksaan rutin
  ultrasound,   // USG
  bloodTest,    // Tes darah
  glucoseTest,  // Tes glukosa
  amniocentesis, // Amniosentesis
  cvs,          // Chorionic Villus Sampling
  nst,          // Non-Stress Test
  other,        // Lainnya
}

// Berat badan kehamilan
class PregnancyWeight {
  int id;
  int pregnancyId;
  DateTime date;
  double weight; // Berat dalam kg
  String notes;
  
  PregnancyWeight({
    required this.id,
    required this.pregnancyId,
    required this.date,
    required this.weight,
    this.notes = '',
  });
  
  // Konversi ke Map untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pregnancy_id': pregnancyId,
      'date': date.toIso8601String(),
      'weight': weight,
      'notes': notes,
    };
  }
  
  // Buat objek dari database
  factory PregnancyWeight.fromMap(Map<String, dynamic> map) {
    return PregnancyWeight(
      id: map['id'],
      pregnancyId: map['pregnancy_id'],
      date: DateTime.parse(map['date']),
      weight: map['weight'],
      notes: map['notes'],
    );
  }
}

// Catatan kehamilan
class PregnancyNote {
  int id;
  int pregnancyId;
  DateTime date;
  String title;
  String content;
  NoteType type;
  
  PregnancyNote({
    required this.id,
    required this.pregnancyId,
    required this.date,
    required this.title,
    required this.content,
    this.type = NoteType.general,
  });
  
  // Konversi ke Map untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pregnancy_id': pregnancyId,
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
      'type': type.index,
    };
  }
  
  // Buat objek dari database
  factory PregnancyNote.fromMap(Map<String, dynamic> map) {
    return PregnancyNote(
      id: map['id'],
      pregnancyId: map['pregnancy_id'],
      date: DateTime.parse(map['date']),
      title: map['title'],
      content: map['content'],
      type: NoteType.values[map['type']],
    );
  }
}

// Enum untuk jenis catatan
enum NoteType {
  general,      // Umum
  appointment,  // Janji temu
  diary,        // Diari
  question,     // Pertanyaan untuk dokter
  milestone,    // Pencapaian penting
  babyNames,    // Nama bayi
  other,        // Lainnya
}

// Extension untuk tampilan yang bisa dibaca manusia
extension PregnancySymptomTypeExtension on PregnancySymptomType {
  String get displayName {
    switch (this) {
      case PregnancySymptomType.nausea:
        return 'Mual';
      case PregnancySymptomType.vomiting:
        return 'Muntah';
      case PregnancySymptomType.fatigue:
        return 'Kelelahan';
      case PregnancySymptomType.heartburn:
        return 'Mulas';
      case PregnancySymptomType.constipation:
        return 'Sembelit';
      case PregnancySymptomType.backPain:
        return 'Nyeri Punggung';
      case PregnancySymptomType.headache:
        return 'Sakit Kepala';
      case PregnancySymptomType.legCramps:
        return 'Kram Kaki';
      case PregnancySymptomType.swelling:
        return 'Bengkak';
      case PregnancySymptomType.insomnia:
        return 'Susah Tidur';
      case PregnancySymptomType.foodCravings:
        return 'Ngidam';
      case PregnancySymptomType.frequentUrination:
        return 'Sering BAK';
      case PregnancySymptomType.moodSwings:
        return 'Perubahan Mood';
      case PregnancySymptomType.dizziness:
        return 'Pusing';
      case PregnancySymptomType.breastTenderness:
        return 'Nyeri Payudara';
      case PregnancySymptomType.indigestion:
        return 'Gangguan Pencernaan';
      case PregnancySymptomType.bloating:
        return 'Kembung';
      case PregnancySymptomType.vaginalDischarge:
        return 'Keputihan';
      case PregnancySymptomType.spotting:
        return 'Bercak Darah';
      case PregnancySymptomType.contractions:
        return 'Kontraksi';
      case PregnancySymptomType.other:
        return 'Gejala Lainnya';
    }
  }

  IconData get icon {
    switch (this) {
      case PregnancySymptomType.nausea:
        return Icons.sick;
      case PregnancySymptomType.vomiting:
        return Icons.sick_outlined;
      case PregnancySymptomType.fatigue:
        return Icons.battery_alert;
      case PregnancySymptomType.heartburn:
        return Icons.local_fire_department;
      case PregnancySymptomType.constipation:
        return Icons.do_not_disturb;
      case PregnancySymptomType.backPain:
        return Icons.airline_seat_legroom_reduced;
      case PregnancySymptomType.headache:
        return Icons.sentiment_very_dissatisfied;
      case PregnancySymptomType.legCramps:
        return Icons.accessibility;
      case PregnancySymptomType.swelling:
        return Icons.bubble_chart;
      case PregnancySymptomType.insomnia:
        return Icons.nightlight_round;
      case PregnancySymptomType.foodCravings:
        return Icons.restaurant;
      case PregnancySymptomType.frequentUrination:
        return Icons.wc;
      case PregnancySymptomType.moodSwings:
        return Icons.mood_bad;
      case PregnancySymptomType.dizziness:
        return Icons.sync_problem;
      case PregnancySymptomType.breastTenderness:
        return Icons.pregnant_woman;
      case PregnancySymptomType.indigestion:
        return Icons.sick;
      case PregnancySymptomType.bloating:
        return Icons.bubble_chart;
      case PregnancySymptomType.vaginalDischarge:
        return Icons.opacity;
      case PregnancySymptomType.spotting:
        return Icons.opacity_outlined;
      case PregnancySymptomType.contractions:
        return Icons.waves;
      case PregnancySymptomType.other:
        return Icons.help_outline;
    }
  }
}

// Extension untuk tampilan tipe pemeriksaan
extension CheckupTypeExtension on CheckupType {
  String get displayName {
    switch (this) {
      case CheckupType.regular:
        return 'Pemeriksaan Rutin';
      case CheckupType.ultrasound:
        return 'USG';
      case CheckupType.bloodTest:
        return 'Tes Darah';
      case CheckupType.glucoseTest:
        return 'Tes Glukosa';
      case CheckupType.amniocentesis:
        return 'Amniosentesis';
      case CheckupType.cvs:
        return 'CVS';
      case CheckupType.nst:
        return 'Non-Stress Test';
      case CheckupType.other:
        return 'Lainnya';
    }
  }
  
  IconData get icon {
    switch (this) {
      case CheckupType.regular:
        return Icons.medical_services;
      case CheckupType.ultrasound:
        return Icons.scanner;
      case CheckupType.bloodTest:
        return Icons.opacity;
      case CheckupType.glucoseTest:
        return Icons.science;
      case CheckupType.amniocentesis:
        return Icons.colorize;
      case CheckupType.cvs:
        return Icons.biotech;
      case CheckupType.nst:
        return Icons.monitor_heart;
      case CheckupType.other:
        return Icons.more_horiz;
    }
  }
}

// Extension untuk tampilan tipe catatan
extension NoteTypeExtension on NoteType {
  String get displayName {
    switch (this) {
      case NoteType.general:
        return 'Umum';
      case NoteType.appointment:
        return 'Janji Temu';
      case NoteType.diary:
        return 'Diari';
      case NoteType.question:
        return 'Pertanyaan untuk Dokter';
      case NoteType.milestone:
        return 'Pencapaian Penting';
      case NoteType.babyNames:
        return 'Nama Bayi';
      case NoteType.other:
        return 'Lainnya';
    }
  }
  
  IconData get icon {
    switch (this) {
      case NoteType.general:
        return Icons.note;
      case NoteType.appointment:
        return Icons.calendar_today;
      case NoteType.diary:
        return Icons.book;
      case NoteType.question:
        return Icons.help;
      case NoteType.milestone:
        return Icons.emoji_events;
      case NoteType.babyNames:
        return Icons.child_care;
      case NoteType.other:
        return Icons.more_horiz;
    }
  }
  
  Color get color {
    switch (this) {
      case NoteType.general:
        return Colors.blue;
      case NoteType.appointment:
        return Colors.green;
      case NoteType.diary:
        return Colors.purple;
      case NoteType.question:
        return Colors.orange;
      case NoteType.milestone:
        return Colors.amber;
      case NoteType.babyNames:
        return Colors.pink;
      case NoteType.other:
        return Colors.grey;
    }
  }
}