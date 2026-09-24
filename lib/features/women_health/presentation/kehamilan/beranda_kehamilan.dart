import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:primafit/features/women_health/presentation/kehamilan/model_kehamilan.dart';
import 'package:primafit/features/women_health/data/database_kehamilan.dart';
import 'package:primafit/features/women_health/presentation/kehamilan/tambah_kehamilan.dart';
import 'package:primafit/features/women_health/presentation/kehamilan/tambah_gejala_kehamilan.dart';
import 'package:primafit/features/women_health/presentation/kehamilan/tambah_pemeriksaan.dart';
import 'package:primafit/features/women_health/presentation/kehamilan/tambah_berat_badan.dart';
import 'package:primafit/features/women_health/presentation/kehamilan/tambah_catatan.dart';
import 'package:primafit/features/women_health/presentation/kehamilan/statistik_kehamilan.dart';
import 'package:primafit/features/women_health/presentation/kehamilan/pengaturan_kehamilan.dart';
import 'package:primafit/features/women_health/presentation/kehamilan/info_perkembangan.dart';
import 'package:primafit/features/women_health/presentation/kehamilan/penghitung_tendangan.dart';

class PregnancyTrackerHomePage extends StatefulWidget {
  const PregnancyTrackerHomePage({super.key});

  @override
  _PregnancyTrackerHomePageState createState() => _PregnancyTrackerHomePageState();
}

class _PregnancyTrackerHomePageState extends State<PregnancyTrackerHomePage> with SingleTickerProviderStateMixin {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;

  late TabController _tabController;
  
  Pregnancy? _activePregnancy;
  bool _isLoading = true;
  
  Map<DateTime, List<PregnancySymptom>> _symptoms = {};
  Map<DateTime, List<PregnancyCheckup>> _checkups = {};
  Map<DateTime, List<PregnancyWeight>> _weights = {};
  Map<DateTime, List<PregnancyNote>> _notes = {};
  
  final DateFormat _dateFormat = DateFormat('d MMMM yyyy');
  
  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _tabController = TabController(length: 2, vsync: this);
    
    _loadPregnancyData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPregnancyData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load active pregnancy
      final activePregnancy = await DatabaseHelperPregnancy.instance.getActivePregnancy();
      
      // If there is an active pregnancy, update current week
      if (activePregnancy != null) {
        // Calculate current week based on start date and today
        final currentWeek = activePregnancy.calculateCurrentWeek();
        
        // If current week has changed, update it in database
        if (currentWeek != activePregnancy.currentWeek) {
          await DatabaseHelperPregnancy.instance.updateCurrentWeek(
            activePregnancy.id, 
            currentWeek
          );
          activePregnancy.currentWeek = currentWeek;
        }
        
        // Prepare event maps for calendar
        _prepareEventMaps(activePregnancy);
      }
      
      if (mounted) {
        setState(() {
          _activePregnancy = activePregnancy;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading pregnancy data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _prepareEventMaps(Pregnancy pregnancy) {
    // Clear previous data
    _symptoms = {};
    _checkups = {};
    _weights = {};
    _notes = {};
    
    // Map symptoms by date
    for (var symptom in pregnancy.symptoms) {
      final dateOnly = DateTime(
        symptom.date.year, 
        symptom.date.month, 
        symptom.date.day
      );
      
      if (_symptoms.containsKey(dateOnly)) {
        _symptoms[dateOnly]!.add(symptom);
      } else {
        _symptoms[dateOnly] = [symptom];
      }
    }
    
    // Map checkups by date
    for (var checkup in pregnancy.checkups) {
      final dateOnly = DateTime(
        checkup.date.year, 
        checkup.date.month, 
        checkup.date.day
      );
      
      if (_checkups.containsKey(dateOnly)) {
        _checkups[dateOnly]!.add(checkup);
      } else {
        _checkups[dateOnly] = [checkup];
      }
    }
    
    // Map weights by date
    for (var weight in pregnancy.weightRecords) {
      final dateOnly = DateTime(
        weight.date.year, 
        weight.date.month, 
        weight.date.day
      );
      
      if (_weights.containsKey(dateOnly)) {
        _weights[dateOnly]!.add(weight);
      } else {
        _weights[dateOnly] = [weight];
      }
    }
    
    // Map notes by date
    for (var note in pregnancy.notes) {
      final dateOnly = DateTime(
        note.date.year, 
        note.date.month, 
        note.date.day
      );
      
      if (_notes.containsKey(dateOnly)) {
        _notes[dateOnly]!.add(note);
      } else {
        _notes[dateOnly] = [note];
      }
    }
  }
  
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }
  
  // Get the color for the event marker on the calendar
  Color _getEventColor(DateTime date) {
    // Get date without time
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    // Check if date has a checkup (highest priority)
    if (_checkups.containsKey(dateOnly) && _checkups[dateOnly]!.isNotEmpty) {
      return const Color(0xFF4CAF50); // Green for checkups
    }
    
    // Check if date has symptoms
    if (_symptoms.containsKey(dateOnly) && _symptoms[dateOnly]!.isNotEmpty) {
      return const Color(0xFFF44336); // Red for symptoms
    }
    
    // Check if date has weight record
    if (_weights.containsKey(dateOnly) && _weights[dateOnly]!.isNotEmpty) {
      return const Color(0xFF2196F3); // Blue for weights
    }
    
    // Check if date has notes
    if (_notes.containsKey(dateOnly) && _notes[dateOnly]!.isNotEmpty) {
      return const Color(0xFFFF9800); // Orange for notes
    }
    
    return Colors.transparent;
  }
  
  
  
  // Build the calendar UI
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: _onDaySelected,
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        todayDecoration: const BoxDecoration(
          color: Color(0xFFE9458D),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.teal.shade300,
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: Colors.teal,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          final color = _getEventColor(date);
          if (color == Colors.transparent) return const SizedBox.shrink();
          
          return Positioned(
            bottom: 1,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
          );
        },
        // Add custom styling for pregnancy weeks
        defaultBuilder: (context, day, focusedDay) {
          Color? cellColor;
          String? weekText;
          
          if (_activePregnancy != null && _activePregnancy!.isInPregnancyPeriod(day)) {
            // Get pregnancy week for this day
            final weekNumber = _activePregnancy!.getWeekForDate(day);
            
            if (weekNumber > 0) {
              if (day.weekday == DateTime.monday) {
                weekText = 'W$weekNumber';
              }
              
              // Color based on trimester
              if (weekNumber <= 13) {
                cellColor = Colors.lightBlue.withValues(alpha: 0.1); // First trimester
              } else if (weekNumber <= 27) {
                cellColor = Colors.teal.withValues(alpha: 0.1); // Second trimester
              } else {
                cellColor = Colors.indigo.withValues(alpha: 0.1); // Third trimester
              }
            }
          }
          
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cellColor,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      color: cellColor != null ? Colors.black87 : null,
                    ),
                  ),
                ),
                if (weekText != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        weekText,
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // Build the selected day details UI
  Widget _buildSelectedDayDetails() {
    final dateString = _dateFormat.format(_selectedDay);
    
    // Check if selected day is in pregnancy period
    bool isInPregnancy = false;
    int weekNumber = 0;
    
    if (_activePregnancy != null) {
      isInPregnancy = _activePregnancy!.isInPregnancyPeriod(_selectedDay);
      weekNumber = _activePregnancy!.getWeekForDate(_selectedDay);
    }
    
    // Get events for the selected day
    final dateOnly = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final List<PregnancySymptom> daySymptoms = _symptoms[dateOnly] ?? [];
    final List<PregnancyCheckup> dayCheckups = _checkups[dateOnly] ?? [];
    final List<PregnancyWeight> dayWeights = _weights[dateOnly] ?? [];
    final List<PregnancyNote> dayNotes = _notes[dateOnly] ?? [];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected date
          Row(
            children: [
              Icon(
                CupertinoIcons.calendar,
                size: 18,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                dateString,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Pregnancy week information
          if (isInPregnancy) 
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.heart_fill,
                          color: Colors.teal.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Minggu Kehamilan $weekNumber',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ukuran janin: ${_activePregnancy!.getBabySize(weekNumber)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Berat janin: ${_activePregnancy!.getBabyWeight(weekNumber)} gram',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DevelopmentInfoPage(weekNumber: weekNumber),
                        ),
                      );
                    },
                    icon: const Icon(CupertinoIcons.info_circle, size: 16),
                    label: const Text('Lihat Info Lengkap'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal.shade600,
                      minimumSize: const Size(double.infinity, 36),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (_activePregnancy != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Tanggal ini di luar masa kehamilan Anda',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          
          const SizedBox(height: 20),
          
          // Events for this day
          // 1. Checkups
          if (dayCheckups.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Pemeriksaan:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    if (_activePregnancy != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCheckupPage(
                            pregnancyId: _activePregnancy!.id,
                            selectedDate: _selectedDay,
                          ),
                        ),
                      );
                      // Reload data after adding
                      _loadPregnancyData();
                    }
                  },
                  icon: const Icon(CupertinoIcons.plus_circle, size: 16),
                  label: const Text('Tambah'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dayCheckups.length,
              itemBuilder: (context, index) {
                final checkup = dayCheckups[index];
                return _buildCheckupItem(checkup);
              },
            ),
          ],
          
          // 2. Symptoms
          if (daySymptoms.isNotEmpty || isInPregnancy) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Gejala:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    if (_activePregnancy != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPregnancySymptomPage(
                            pregnancyId: _activePregnancy!.id,
                            selectedDate: _selectedDay,
                          ),
                        ),
                      );
                      // Reload data after adding
                      _loadPregnancyData();
                    }
                  },
                  icon: const Icon(CupertinoIcons.plus_circle, size: 16),
                  label: const Text('Tambah'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFF44336),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            daySymptoms.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Belum ada gejala tercatat untuk tanggal ini',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: daySymptoms.length,
                  itemBuilder: (context, index) {
                    final symptom = daySymptoms[index];
                    return _buildSymptomItem(symptom);
                  },
                ),
          ],
          
          // 3. Weight Records
          if (dayWeights.isNotEmpty || isInPregnancy) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Berat Badan:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    if (_activePregnancy != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddWeightPage(
                            pregnancyId: _activePregnancy!.id,
                            selectedDate: _selectedDay,
                          ),
                        ),
                      );
                      // Reload data after adding
                      _loadPregnancyData();
                    }
                  },
                  icon: const Icon(CupertinoIcons.plus_circle, size: 16),
                  label: const Text('Tambah'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            dayWeights.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Belum ada catatan berat badan untuk tanggal ini',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dayWeights.length,
                  itemBuilder: (context, index) {
                    final weight = dayWeights[index];
                    return _buildWeightItem(weight);
                  },
                ),
          ],
          
          // 4. Notes
          if (dayNotes.isNotEmpty || isInPregnancy) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Catatan:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    if (_activePregnancy != null) {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddNotePage(
                            pregnancyId: _activePregnancy!.id,
                            selectedDate: _selectedDay,
                          ),
                        ),
                      );
                      // Reload data after adding
                      _loadPregnancyData();
                    }
                  },
                  icon: const Icon(CupertinoIcons.plus_circle, size: 16),
                  label: const Text('Tambah'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF9800),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            dayNotes.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Belum ada catatan untuk tanggal ini',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dayNotes.length,
                  itemBuilder: (context, index) {
                    final note = dayNotes[index];
                    return _buildNoteItem(note);
                  },
                ),
          ],
          
          if (!isInPregnancy && _activePregnancy == null) ...[
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.heart,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum Ada Data Kehamilan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan kehamilan baru untuk mulai memantau',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddPregnancyPage(),
                        ),
                      );
                      // Reload data after adding
                      _loadPregnancyData();
                    },
                    icon: const Icon(CupertinoIcons.add),
                    label: const Text('Tambah Kehamilan'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFFE9458D),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildCheckupItem(PregnancyCheckup checkup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  checkup.type.icon,
                  size: 16,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  checkup.type.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  // Show confirmation dialog
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus Pemeriksaan'),
                      content: const Text('Apakah Anda yakin ingin menghapus data pemeriksaan ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                  
                  if (shouldDelete == true) {
                    await DatabaseHelperPregnancy.instance.deleteCheckup(checkup.id);
                    _loadPregnancyData(); // Reload data
                  }
                },
                icon: Icon(
                  CupertinoIcons.delete,
                  size: 16,
                  color: Colors.red.shade300,
                ),
                splashRadius: 20,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Berat: ${checkup.weight} kg',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Tekanan darah: ${checkup.bpSystolic}/${checkup.bpDiastolic}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                
                if (checkup.fetalHeartRate > 0)
                  Text(
                    'Detak jantung janin: ${checkup.fetalHeartRate} bpm',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                
                if (checkup.fundusHeight > 0)
                  Text(
                    'Tinggi fundus: ${checkup.fundusHeight} cm',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                
                if (checkup.doctorNotes.isNotEmpty)
                  Text(
                    'Catatan dokter: ${checkup.doctorNotes}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSymptomItem(PregnancySymptom symptom) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              symptom.type.icon,
              size: 16,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symptom.type.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (symptom.notes.isNotEmpty)
                  Text(
                    symptom.notes,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
              ],
            ),
          ),
          // Intensity indicator
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < symptom.intensity 
                    ? CupertinoIcons.circle_fill 
                    : CupertinoIcons.circle,
                size: 8,
                color: index < symptom.intensity 
                    ? Colors.red.shade700 
                    : Colors.red.shade200,
              );
            }),
          ),
          // Delete button
          IconButton(
            onPressed: () async {
              // Show confirmation dialog
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Gejala'),
                  content: const Text('Apakah Anda yakin ingin menghapus gejala ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
              
              if (shouldDelete == true) {
                await DatabaseHelperPregnancy.instance.deleteSymptom(symptom.id);
                _loadPregnancyData(); // Reload data
              }
            },
            icon: Icon(
              CupertinoIcons.delete,
              size: 16,
              color: Colors.red.shade300,
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeightItem(PregnancyWeight weight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.monitor_weight,
              size: 16,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weight.weight} kg',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (weight.notes.isNotEmpty)
                  Text(
                    weight.notes,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
              ],
            ),
          ),
          // Delete button
          IconButton(
            onPressed: () async {
              // Show confirmation dialog
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Catatan Berat'),
                  content: const Text('Apakah Anda yakin ingin menghapus catatan berat badan ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
              
              if (shouldDelete == true) {
                await DatabaseHelperPregnancy.instance.deleteWeight(weight.id);
                _loadPregnancyData(); // Reload data
              }
            },
            icon: Icon(
              CupertinoIcons.delete,
              size: 16,
              color: Colors.red.shade300,
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoteItem(PregnancyNote note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  note.type.icon,
                  size: 16,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  note.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: note.type.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  note.type.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: note.type.color,
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  // Show confirmation dialog
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus Catatan'),
                      content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                  
                  if (shouldDelete == true) {
                    await DatabaseHelperPregnancy.instance.deleteNote(note.id);
                    _loadPregnancyData(); // Reload data
                  }
                },
                icon: Icon(
                  CupertinoIcons.delete,
                  size: 16,
                  color: Colors.red.shade300,
                ),
                splashRadius: 20,
              ),
            ],
          ),
          
          if (note.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                note.content,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
  
  // Build the overview UI
  Widget _buildOverview() {
    if (_activePregnancy == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.heart,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Data Kehamilan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Tambahkan kehamilan baru untuk mulai memantau perkembangan janin dan kesehatan ibu',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddPregnancyPage(),
                  ),
                );
                // Reload data after adding
                _loadPregnancyData();
              },
              icon: const Icon(CupertinoIcons.add),
              label: const Text('Tambah Kehamilan'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFFE9458D),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Calculate days until due date
    final today = DateTime.now();
    final daysUntilDue = _activePregnancy!.dueDate.difference(today).inDays;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pregnancy Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE9458D), Color(0xFF4A8799)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE9458D).withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.heart_fill,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minggu ke-${_activePregnancy!.currentWeek}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _activePregnancy!.currentWeek <= 13 
                            ? 'Trimester 1' 
                            : (_activePregnancy!.currentWeek <= 27 
                                ? 'Trimester 2' 
                                : 'Trimester 3'),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Pregnancy progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HPHT: ${_dateFormat.format(_activePregnancy!.startDate)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      Text(
                        'HPL: ${_dateFormat.format(_activePregnancy!.dueDate)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _activePregnancy!.currentWeek / 40,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    daysUntilDue > 0
                        ? '$daysUntilDue hari menuju persalinan'
                        : 'Sudah melewati HPL',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Baby development info
        Text(
          'Perkembangan Janin',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baby icon or illustration
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.child_friendly,
                      size: 30,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minggu ${_activePregnancy!.currentWeek}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ukuran: ${_activePregnancy!.getBabySize(_activePregnancy!.currentWeek)}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          'Berat: ${_activePregnancy!.getBabyWeight(_activePregnancy!.currentWeek)} gram',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Perkembangan:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _activePregnancy!.getBabyDevelopment(_activePregnancy!.currentWeek),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DevelopmentInfoPage(
                        weekNumber: _activePregnancy!.currentWeek,
                      ),
                    ),
                  );
                },
                icon: const Icon(CupertinoIcons.info_circle, size: 16),
                label: const Text('Lihat Info Lengkap'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal.shade600,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Mom Tips
        Text(
          'Tips untuk Ibu',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.lightbulb_fill,
                      size: 18,
                      color: Colors.pink.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rekomendasi Trimester ${_activePregnancy!.currentTrimester}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _activePregnancy!.getMotherTips(_activePregnancy!.currentWeek),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Recent Records
        Text(
          'Aktivitas Terbaru',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Combine all recent events and sort by date
        _buildRecentActivities(),
        
        const SizedBox(height: 24),
        
        // Quick Action Buttons
        Text(
          'Aksi Cepat',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: CupertinoIcons.heart_circle_fill,
                label: 'Hitung Tendangan Bayi',
                color: Colors.red.shade400,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KickCounterPage(
                        pregnancyId: _activePregnancy!.id,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: CupertinoIcons.graph_circle_fill,
                label: 'Lihat Statistik',
                color: Colors.blue.shade400,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PregnancyStatisticsPage(
                        pregnancyId: _activePregnancy!.id,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: CupertinoIcons.bandage_fill,
                label: 'Catat Gejala',
                color: Colors.purple.shade400,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPregnancySymptomPage(
                        pregnancyId: _activePregnancy!.id,
                        selectedDate: DateTime.now(),
                      ),
                    ),
                  );
                  _loadPregnancyData(); // Reload data
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: CupertinoIcons.doc_text_fill,
                label: 'Tambah Catatan',
                color: Colors.orange.shade400,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddNotePage(
                        pregnancyId: _activePregnancy!.id,
                        selectedDate: DateTime.now(),
                      ),
                    ),
                  );
                  _loadPregnancyData(); // Reload data
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 32),
      ],
    );
  }
  
  Widget _buildRecentActivities() {
    // Create a combined list of all recent events
    final List<Map<String, dynamic>> allEvents = [];
    
    // Add symptoms
    for (var symptom in _activePregnancy!.symptoms) {
      allEvents.add({
        'type': 'symptom',
        'date': symptom.date,
        'data': symptom,
      });
    }
    
    // Add checkups
    for (var checkup in _activePregnancy!.checkups) {
      allEvents.add({
        'type': 'checkup',
        'date': checkup.date,
        'data': checkup,
      });
    }
    
    // Add weights
    for (var weight in _activePregnancy!.weightRecords) {
      allEvents.add({
        'type': 'weight',
        'date': weight.date,
        'data': weight,
      });
    }
    
    // Add notes
    for (var note in _activePregnancy!.notes) {
      allEvents.add({
        'type': 'note',
        'date': note.date,
        'data': note,
      });
    }
    
    // Sort by date (descending)
    allEvents.sort((a, b) => b['date'].compareTo(a['date']));
    
    // Take only the 5 most recent events
    final recentEvents = allEvents.take(5).toList();
    
    if (recentEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Belum ada aktivitas tercatat',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: recentEvents.map((event) {
          final date = event['date'] as DateTime;
          final formattedDate = _dateFormat.format(date);
          
          switch (event['type']) {
            case 'symptom':
              final symptom = event['data'] as PregnancySymptom;
              return _buildRecentActivityItem(
                icon: symptom.type.icon,
                color: Colors.red.shade400,
                title: 'Gejala: ${symptom.type.displayName}',
                subtitle: 'Intensitas: ${symptom.intensity}',
                date: formattedDate,
              );
              
            case 'checkup':
              final checkup = event['data'] as PregnancyCheckup;
              return _buildRecentActivityItem(
                icon: checkup.type.icon,
                color: Colors.green.shade400,
                title: 'Pemeriksaan: ${checkup.type.displayName}',
                subtitle: 'Berat: ${checkup.weight} kg',
                date: formattedDate,
              );
              
            case 'weight':
              final weight = event['data'] as PregnancyWeight;
              return _buildRecentActivityItem(
                icon: Icons.monitor_weight,
                color: Colors.blue.shade400,
                title: 'Berat Badan: ${weight.weight} kg',
                subtitle: weight.notes.isEmpty ? 'Tidak ada catatan' : weight.notes,
                date: formattedDate,
              );
              
            case 'note':
              final note = event['data'] as PregnancyNote;
              return _buildRecentActivityItem(
                icon: note.type.icon,
                color: Colors.orange.shade400,
                title: note.title,
                subtitle: note.content.length > 50 
                    ? '${note.content.substring(0, 50)}...' 
                    : note.content,
                date: formattedDate,
              );
              
            default:
              return const SizedBox.shrink();
          }
        }).toList(),
      ),
    );
  }
  
  Widget _buildRecentActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9458D),
        elevation: 0,
        title: Text(
          'Pemantauan Kehamilan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Settings
          IconButton(
            icon: const Icon(CupertinoIcons.settings, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PregnancySettingsPage(),
                ),
              );
              // Reload data after potentially changing settings
              _loadPregnancyData();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE9458D)))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tab bar
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFE9458D),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey.shade700,
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: const [
                          Tab(text: 'Kalender'),
                          Tab(text: 'Ringkasan'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Calendar tab
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Calendar widget
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: _buildCalendar(),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Calendar legend
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildLegendItem('Pemeriksaan', const Color(0xFF4CAF50)),
                                      _buildLegendItem('Gejala', const Color(0xFFF44336)),
                                      _buildLegendItem('Berat Badan', const Color(0xFF2196F3)),
                                      _buildLegendItem('Catatan', const Color(0xFFFF9800)),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Selected day details
                                _buildSelectedDayDetails(),
                                
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                          
                          // Overview tab
                          SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: _buildOverview(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: _activePregnancy == null
          ? null
          : FloatingActionButton(
              onPressed: () {
                // Show action sheet for adding new records
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tambah Data Baru',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.medical_services,
                              color: Colors.green.shade700,
                            ),
                          ),
                          title: const Text('Pemeriksaan Kehamilan'),
                          onTap: () async {
                            Navigator.pop(context);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddCheckupPage(
                                  pregnancyId: _activePregnancy!.id,
                                  selectedDate: DateTime.now(),
                                ),
                              ),
                            );
                            _loadPregnancyData();
                          },
                        ),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.healing,
                              color: Colors.red.shade700,
                            ),
                          ),
                          title: const Text('Gejala Kehamilan'),
                          onTap: () async {
                            Navigator.pop(context);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddPregnancySymptomPage(
                                  pregnancyId: _activePregnancy!.id,
                                  selectedDate: DateTime.now(),
                                ),
                              ),
                            );
                            _loadPregnancyData();
                          },
                        ),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.monitor_weight,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          title: const Text('Berat Badan'),
                          onTap: () async {
                            Navigator.pop(context);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddWeightPage(
                                  pregnancyId: _activePregnancy!.id,
                                  selectedDate: DateTime.now(),
                                ),
                              ),
                            );
                            _loadPregnancyData();
                          },
                        ),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.note_add,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          title: const Text('Catatan Kehamilan'),
                          onTap: () async {
                            Navigator.pop(context);
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddNotePage(
                                  pregnancyId: _activePregnancy!.id,
                                  selectedDate: DateTime.now(),
                                ),
                              ),
                            );
                            _loadPregnancyData();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              backgroundColor: const Color(0xFFE9458D),
              child: const Icon(Icons.add),
            ),
    );
  }
}