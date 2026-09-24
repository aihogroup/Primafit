import 'package:flutter/material.dart';

class MenstrualCycle {
  int id;
  DateTime startDate;
  DateTime? endDate;
  int cycleLength; // Panjang siklus (dari awal periode ke awal periode berikutnya)
  int periodLength; // Panjang menstruasi
  List<MenstrualSymptom> symptoms;
  String notes;
  MoodType mood;

  MenstrualCycle({
    required this.id,
    required this.startDate,
    this.endDate,
    this.cycleLength = 28, // Default 28 hari
    this.periodLength = 5, // Default 5 hari
    this.symptoms = const [],
    this.notes = '',
    this.mood = MoodType.normal
  });

  // Konversi ke Map untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'cycle_length': cycleLength,
      'period_length': periodLength,
      'notes': notes,
      'mood': mood.index,
    };
  }

  // Buat objek dari database
  factory MenstrualCycle.fromMap(Map<String, dynamic> map) {
    return MenstrualCycle(
      id: map['id'],
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      cycleLength: map['cycle_length'],
      periodLength: map['period_length'],
      notes: map['notes'],
      mood: MoodType.values[map['mood']],
    );
  }

  // Cek apakah tanggal tertentu berada dalam periode menstruasi
  bool isInPeriod(DateTime date) {
    if (endDate == null) {
      // Jika endDate belum ditentukan, gunakan periodLength
      final predictedEndDate = startDate.add(Duration(days: periodLength - 1));
      return date.isAfter(startDate.subtract(const Duration(days: 1))) && 
             date.isBefore(predictedEndDate.add(const Duration(days: 1)));
    } else {
      return date.isAfter(startDate.subtract(const Duration(days: 1))) && 
             date.isBefore(endDate!.add(const Duration(days: 1)));
    }
  }

  // Cek apakah tanggal tertentu adalah periode subur (rata-rata 14 hari sebelum periode berikutnya)
  bool isFertile(DateTime date) {
    final nextPeriodStart = startDate.add(Duration(days: cycleLength));
    final fertileStart = nextPeriodStart.subtract(const Duration(days: 19)); // 5 hari sebelum ovulasi
    final fertileEnd = nextPeriodStart.subtract(const Duration(days: 10)); // 1 hari setelah ovulasi
    
    return date.isAfter(fertileStart.subtract(const Duration(days: 1))) && 
           date.isBefore(fertileEnd.add(const Duration(days: 1)));
  }

  // Cek apakah tanggal tertentu adalah ovulasi (rata-rata 14 hari sebelum periode berikutnya)
  bool isOvulation(DateTime date) {
    final nextPeriodStart = startDate.add(Duration(days: cycleLength));
    final ovulationDate = nextPeriodStart.subtract(const Duration(days: 14));
    
    return date.year == ovulationDate.year && 
           date.month == ovulationDate.month && 
           date.day == ovulationDate.day;
  }

  // Prediksi tanggal menstruasi berikutnya
  DateTime predictNextPeriod() {
    return startDate.add(Duration(days: cycleLength));
  }

  // Prediksi tanggal ovulasi berikutnya
  DateTime predictNextOvulation() {
    final nextPeriod = predictNextPeriod();
    return nextPeriod.subtract(const Duration(days: 14));
  }
}

// Gejala menstruasi
class MenstrualSymptom {
  int id;
  int cycleId;
  DateTime date;
  SymptomType type;
  int intensity; // 1-5 scale
  String notes;

  MenstrualSymptom({
    required this.id,
    required this.cycleId,
    required this.date,
    required this.type,
    this.intensity = 3,
    this.notes = '',
  });

  // Konversi ke Map untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cycle_id': cycleId,
      'date': date.toIso8601String(),
      'type': type.index,
      'intensity': intensity,
      'notes': notes,
    };
  }

  // Buat objek dari database
  factory MenstrualSymptom.fromMap(Map<String, dynamic> map) {
    return MenstrualSymptom(
      id: map['id'],
      cycleId: map['cycle_id'],
      date: DateTime.parse(map['date']),
      type: SymptomType.values[map['type']],
      intensity: map['intensity'],
      notes: map['notes'],
    );
  }
}

// Enum untuk jenis gejala
enum SymptomType {
  cramps,         // Kram perut
  headache,       // Sakit kepala
  backPain,       // Nyeri punggung
  bloating,       // Kembung
  breastTenderness, // Nyeri payudara
  acne,           // Jerawat
  fatigue,        // Kelelahan
  moodSwings,     // Perubahan mood
  nausea,         // Mual
  spotting,       // Bercak darah
  heavyBleeding,  // Pendarahan berat
  constipation,   // Sembelit
  diarrhea,       // Diare
  insomnia,       // Susah tidur
  cravings,       // Ngidam
  dizziness,      // Pusing
  other,          // Lainnya
}

// Enum untuk jenis mood
enum MoodType {
  happy,        // Bahagia
  energetic,    // Berenergi
  relaxed,      // Santai
  normal,       // Normal
  anxious,      // Cemas
  irritable,    // Mudah tersinggung
  sad,          // Sedih
  depressed,    // Depresi
  stressed,     // Stres
  overwhelmed,  // Kewalahan
}

// Extension untuk tampilan yang bisa dibaca manusia
extension SymptomTypeExtension on SymptomType {
  String get displayName {
    switch (this) {
      case SymptomType.cramps:
        return 'Kram Perut';
      case SymptomType.headache:
        return 'Sakit Kepala';
      case SymptomType.backPain:
        return 'Nyeri Punggung';
      case SymptomType.bloating:
        return 'Kembung';
      case SymptomType.breastTenderness:
        return 'Nyeri Payudara';
      case SymptomType.acne:
        return 'Jerawat';
      case SymptomType.fatigue:
        return 'Kelelahan';
      case SymptomType.moodSwings:
        return 'Perubahan Mood';
      case SymptomType.nausea:
        return 'Mual';
      case SymptomType.spotting:
        return 'Bercak Darah';
      case SymptomType.heavyBleeding:
        return 'Pendarahan Berat';
      case SymptomType.constipation:
        return 'Sembelit';
      case SymptomType.diarrhea:
        return 'Diare';
      case SymptomType.insomnia:
        return 'Susah Tidur';
      case SymptomType.cravings:
        return 'Ngidam';
      case SymptomType.dizziness:
        return 'Pusing';
      case SymptomType.other:
        return 'Lainnya';
    }
  }

  IconData get icon {
    switch (this) {
      case SymptomType.cramps:
        return Icons.health_and_safety;
      case SymptomType.headache:
        return Icons.sentiment_very_dissatisfied;
      case SymptomType.backPain:
        return Icons.accessibility;
      case SymptomType.bloating:
        return Icons.bubble_chart;
      case SymptomType.breastTenderness:
        return Icons.female;
      case SymptomType.acne:
        return Icons.face;
      case SymptomType.fatigue:
        return Icons.battery_alert;
      case SymptomType.moodSwings:
        return Icons.mood_bad;
      case SymptomType.nausea:
        return Icons.sick;
      case SymptomType.spotting:
        return Icons.opacity;
      case SymptomType.heavyBleeding:
        return Icons.whatshot;
      case SymptomType.constipation:
        return Icons.do_not_disturb;
      case SymptomType.diarrhea:
        return Icons.waves;
      case SymptomType.insomnia:
        return Icons.nightlight_round;
      case SymptomType.cravings:
        return Icons.restaurant;
      case SymptomType.dizziness:
        return Icons.sync_problem;
      case SymptomType.other:
        return Icons.help_outline;
    }
  }
}

// Extension untuk tampilan mood
extension MoodTypeExtension on MoodType {
  String get displayName {
    switch (this) {
      case MoodType.happy:
        return 'Bahagia';
      case MoodType.energetic:
        return 'Berenergi';
      case MoodType.relaxed:
        return 'Santai';
      case MoodType.normal:
        return 'Normal';
      case MoodType.anxious:
        return 'Cemas';
      case MoodType.irritable:
        return 'Mudah Tersinggung';
      case MoodType.sad:
        return 'Sedih';
      case MoodType.depressed:
        return 'Depresi';
      case MoodType.stressed:
        return 'Stres';
      case MoodType.overwhelmed:
        return 'Kewalahan';
    }
  }

  IconData get icon {
    switch (this) {
      case MoodType.happy:
        return Icons.sentiment_very_satisfied;
      case MoodType.energetic:
        return Icons.flash_on;
      case MoodType.relaxed:
        return Icons.spa;
      case MoodType.normal:
        return Icons.sentiment_satisfied;
      case MoodType.anxious:
        return Icons.psychology;
      case MoodType.irritable:
        return Icons.sentiment_very_dissatisfied;
      case MoodType.sad:
        return Icons.sentiment_dissatisfied;
      case MoodType.depressed:
        return Icons.cloud;
      case MoodType.stressed:
        return Icons.warning;
      case MoodType.overwhelmed:
        return Icons.highlight_off;
    }
  }

  Color get color {
    switch (this) {
      case MoodType.happy:
        return Colors.amber;
      case MoodType.energetic:
        return Colors.orange;
      case MoodType.relaxed:
        return Colors.lightBlue;
      case MoodType.normal:
        return Colors.green;
      case MoodType.anxious:
        return Colors.deepPurple;
      case MoodType.irritable:
        return Colors.red;
      case MoodType.sad:
        return Colors.indigo;
      case MoodType.depressed:
        return Colors.grey;
      case MoodType.stressed:
        return Colors.deepOrange;
      case MoodType.overwhelmed:
        return Colors.brown;
    }
  }
}

// Fase siklus
enum CyclePhase {
  menstruation,
  follicular,
  ovulation,
  luteal
}

// Extension untuk tampilan fase siklus
extension CyclePhaseExtension on CyclePhase {
  String get displayName {
    switch (this) {
      case CyclePhase.menstruation:
        return 'Menstruasi';
      case CyclePhase.follicular:
        return 'Fase Folikuler';
      case CyclePhase.ovulation:
        return 'Ovulasi';
      case CyclePhase.luteal:
        return 'Fase Luteal';
    }
  }
  
  String get description {
    switch (this) {
      case CyclePhase.menstruation:
        return 'Pelepasan lapisan dinding rahim. Durasi: 3-7 hari.';
      case CyclePhase.follicular:
        return 'Pertumbuhan folikel di ovarium. Durasi: sekitar 7-10 hari.';
      case CyclePhase.ovulation:
        return 'Pelepasan sel telur. Durasi: sekitar 1-2 hari.';
      case CyclePhase.luteal:
        return 'Pembentukan corpus luteum. Durasi: sekitar 14 hari.';
    }
  }
  
  Color get color {
    switch (this) {
      case CyclePhase.menstruation:
        return Colors.red;
      case CyclePhase.follicular:
        return Colors.green;
      case CyclePhase.ovulation:
        return Colors.amber;
      case CyclePhase.luteal:
        return Colors.purple;
    }
  }
  
  IconData get icon {
    switch (this) {
      case CyclePhase.menstruation:
        return Icons.opacity;
      case CyclePhase.follicular:
        return Icons.eco;
      case CyclePhase.ovulation:
        return Icons.egg;
      case CyclePhase.luteal:
        return Icons.change_circle;
    }
  }
}