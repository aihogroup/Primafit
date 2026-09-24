import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:primafit/features/women_health/presentation/menstruasi/model_menstruasi.dart';
import 'package:primafit/features/women_health/data/database_menstruasi.dart';
import 'package:primafit/features/women_health/presentation/menstruasi/tambah_siklus.dart';
import 'package:primafit/features/women_health/presentation/menstruasi/tambah_gejala.dart';
import 'package:primafit/features/women_health/presentation/menstruasi/statistik_siklus.dart';
import 'package:primafit/features/women_health/presentation/menstruasi/pengaturan_siklus.dart';

class MenstrualTrackerHomePage extends StatefulWidget {
  const MenstrualTrackerHomePage({super.key});

  @override
  _MenstrualTrackerHomePageState createState() => _MenstrualTrackerHomePageState();
}

class _MenstrualTrackerHomePageState extends State<MenstrualTrackerHomePage> with SingleTickerProviderStateMixin {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;

  late TabController _tabController;
  
  List<MenstrualCycle> _cycles = [];
  DateTime? _nextPeriodDate;
  DateTime? _nextOvulationDate;
  MenstrualCycle? _currentCycle;
  bool _isLoading = true;
  
  Map<DateTime, List<MenstrualSymptom>> _symptoms = {};
  final DateFormat _dateFormat = DateFormat('d MMMM yyyy');
  
  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _tabController = TabController(length: 2, vsync: this);
    
    _loadCycleData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCycleData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load all cycles
      final cycles = await DatabaseHelperMenstrual.instance.getAllCycles();
      MenstrualCycle? currentCycle;
      
      // Load current or latest cycle
      if (cycles.isNotEmpty) {
        // Check if today is in any active cycle
        for (var cycle in cycles) {
          if (cycle.isInPeriod(_selectedDay)) {
            currentCycle = cycle;
            break;
          }
        }
        
        // If not in active cycle, use the most recent one
        currentCycle ??= cycles.first;
        
        // Calculate next period and ovulation
        _nextPeriodDate = currentCycle.predictNextPeriod();
        _nextOvulationDate = currentCycle.predictNextOvulation();
      }
      
      // Load symptoms for the current month
      await _loadMonthSymptoms(_focusedDay);
      
      if (mounted) {
        setState(() {
          _cycles = cycles;
          _currentCycle = currentCycle;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading menstrual cycle data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _loadMonthSymptoms(DateTime month) async {
    try {
      // Clear previous symptoms
      _symptoms = {};
      
      // Get the first and last day of the month
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);
      
      // Load cycles in this date range
      final cycles = await DatabaseHelperMenstrual.instance.getCyclesByDateRange(
        firstDay.subtract(const Duration(days: 7)),  // Include a week before
        lastDay.add(const Duration(days: 7)),      // Include a week after
      );
      
      // Prepare symptoms map
      for (var cycle in cycles) {
        final cycleSymptoms = cycle.symptoms;
        for (var symptom in cycleSymptoms) {
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
      }
    } catch (e) {
      debugPrint('Error loading monthly symptoms: $e');
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
  
  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
    
    // Load symptoms for the new month
    _loadMonthSymptoms(focusedDay);
  }
  
  // Determine the event marker color based on cycle phase
  Color _getEventColor(DateTime date) {
    // Check if date is in period
    for (var cycle in _cycles) {
      if (cycle.isInPeriod(date)) {
        return const Color(0xFFE9458D); // Period color (pink)
      }
      
      if (cycle.isOvulation(date)) {
        return const Color(0xFFFFC400); // Ovulation color (amber)
      }
      
      if (cycle.isFertile(date)) {
        return const Color(0xFF8BC34A); // Fertile window color (green)
      }
    }
    
    // Default color for dates with symptoms
    final dateOnly = DateTime(date.year, date.month, date.day);
    if (_symptoms.containsKey(dateOnly) && _symptoms[dateOnly]!.isNotEmpty) {
      return Colors.purple; // Symptom color
    }
    
    return Colors.transparent;
  }
  
  
  
  // Get the phase for the selected day
  CyclePhase _getPhaseForSelectedDay() {
    for (var cycle in _cycles) {
      if (cycle.isInPeriod(_selectedDay)) {
        return CyclePhase.menstruation;
      }
      
      if (cycle.isOvulation(_selectedDay)) {
        return CyclePhase.ovulation;
      }
      
      // Check if in follicular phase (after period, before ovulation)
      final ovulationDate = cycle.predictNextOvulation();
      if (_selectedDay.isAfter(cycle.startDate.add(Duration(days: cycle.periodLength))) && 
          _selectedDay.isBefore(ovulationDate)) {
        return CyclePhase.follicular;
      }
      
      // Check if in luteal phase (after ovulation, before next period)
      final nextPeriod = cycle.predictNextPeriod();
      if (_selectedDay.isAfter(ovulationDate) && _selectedDay.isBefore(nextPeriod)) {
        return CyclePhase.luteal;
      }
    }
    
    // Default phase if not determined
    return CyclePhase.follicular;
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
      onPageChanged: _onPageChanged,
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
          color: Colors.purple.shade300,
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: Colors.purple,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return const SizedBox.shrink();
          
          return Positioned(
            bottom: 1,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getEventColor(date),
              ),
            ),
          );
        },
        // Customize day cells
        defaultBuilder: (context, day, focusedDay) {
          // Check if day is in period, ovulation or fertile window
          Color? cellColor;
          
          for (var cycle in _cycles) {
            if (cycle.isInPeriod(day)) {
              cellColor = const Color(0xFFE9458D).withValues(alpha: 0.2);
              break;
            } else if (cycle.isOvulation(day)) {
              cellColor = const Color(0xFFFFC400).withValues(alpha: 0.2);
              break;
            } else if (cycle.isFertile(day)) {
              cellColor = const Color(0xFF8BC34A).withValues(alpha: 0.1);
              break;
            }
          }
          
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cellColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  color: cellColor != null ? Colors.black87 : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Build the selected day details UI
  Widget _buildSelectedDayDetails() {
    final dateString = _dateFormat.format(_selectedDay);
    
    // Check if selected day is in current cycle
    bool isInPeriod = false;
    bool isOvulation = false;
    bool isFertile = false;
    
    for (var cycle in _cycles) {
      if (cycle.isInPeriod(_selectedDay)) {
        isInPeriod = true;
      }
      
      if (cycle.isOvulation(_selectedDay)) {
        isOvulation = true;
      }
      
      if (cycle.isFertile(_selectedDay)) {
        isFertile = true;
      }
    }
    
    // Get phase for selected day
    final phase = _getPhaseForSelectedDay();
    
    // Get symptoms for selected day
    final dateOnly = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final List<MenstrualSymptom> daySymptoms = _symptoms[dateOnly] ?? [];
    
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
          
          // Status of this day (period, ovulation, fertile window)
          Row(
            children: [
              Text(
                'Status:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(width: 8),
              if (isInPeriod)
                _buildStatusTag('Menstruasi', const Color(0xFFE9458D), CupertinoIcons.drop_fill)
              else if (isOvulation)
                _buildStatusTag('Ovulasi', const Color(0xFFFFC400), CupertinoIcons.star_fill)
              else if (isFertile)
                _buildStatusTag('Masa Subur', const Color(0xFF8BC34A), CupertinoIcons.leaf_arrow_circlepath)
              else
                _buildStatusTag('Normal', Colors.grey.shade400, CupertinoIcons.circle)
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Cycle phase information
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: phase.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: phase.color.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: phase.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    phase.icon,
                    color: phase.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phase.displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: phase.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phase.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Recorded symptoms
          Row(
            children: [
              Text(
                'Gejala Tercatat:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
              const Spacer(),
              // Add symptom button
              TextButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddSymptomPage(selectedDate: _selectedDay),
                    ),
                  );
                  // Reload data after adding symptoms
                  _loadCycleData();
                },
                icon: const Icon(CupertinoIcons.plus_circle, size: 16),
                label: const Text('Tambah'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE9458D),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Symptom list
          if (daySymptoms.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Belum ada gejala tercatat untuk tanggal ini',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: daySymptoms.length,
              itemBuilder: (context, index) {
                final symptom = daySymptoms[index];
                return _buildSymptomItem(symptom);
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatusTag(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSymptomItem(MenstrualSymptom symptom) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              symptom.type.icon,
              size: 16,
              color: Colors.purple.shade700,
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
                    ? Colors.purple.shade700 
                    : Colors.purple.shade200,
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
                await DatabaseHelperMenstrual.instance.deleteSymptom(symptom.id);
                _loadCycleData(); // Reload data
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
  
  // Build the overview UI
  Widget _buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current cycle information
        if (_currentCycle != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE9458D), Color(0xFFD81B60)],
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
                        CupertinoIcons.drop_fill,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Siklus Saat Ini',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        Text(
                          'Dimulai ${_dateFormat.format(_currentCycle!.startDate)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Cycle details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCycleStat(
                      'Panjang Siklus',
                      '${_currentCycle!.cycleLength} hari',
                      CupertinoIcons.arrow_2_circlepath,
                    ),
                    _buildCycleStat(
                      'Lama Periode',
                      '${_currentCycle!.periodLength} hari',
                      CupertinoIcons.calendar,
                    ),
                    if (_currentCycle!.endDate != null)
                      _buildCycleStat(
                        'Berakhir',
                        '${_dateFormat.format(_currentCycle!.endDate!).split(' ')[0]} ${_dateFormat.format(_currentCycle!.endDate!).split(' ')[1]}',
                        CupertinoIcons.flag_fill,
                      )
                    else
                      _buildCycleStat(
                        'Status',
                        'Aktif',
                        CupertinoIcons.circle_fill,
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Predictions
          Text(
            'Prediksi Mendatang',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Next period prediction
          if (_nextPeriodDate != null)
            _buildPredictionCard(
              title: 'Periode Berikutnya',
              date: _nextPeriodDate!,
              daysLeft: _nextPeriodDate!.difference(DateTime.now()).inDays,
              color: const Color(0xFFE9458D),
              icon: CupertinoIcons.drop_fill,
            ),
            
          const SizedBox(height: 12),
          
          // Next ovulation prediction
          if (_nextOvulationDate != null)
            _buildPredictionCard(
              title: 'Ovulasi Berikutnya',
              date: _nextOvulationDate!,
              daysLeft: _nextOvulationDate!.difference(DateTime.now()).inDays,
              color: const Color(0xFFFFC400),
              icon: CupertinoIcons.star_fill,
            ),
          
          const SizedBox(height: 24),
          
          // Record period or end period button
          if (_cycles.isEmpty || _currentCycle!.endDate != null) 
            _buildRecordPeriodButton()
          else
            _buildEndPeriodButton(),
        ]
        else ...[
          // No cycles found - show placeholder and button to add first cycle
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.calendar_badge_plus,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum Ada Data Siklus',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Catat periode menstruasi pertama Anda untuk memulai pelacakan siklus.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildRecordPeriodButton(),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildCycleStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPredictionCard({
    required String title,
    required DateTime date,
    required int daysLeft,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
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
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  _dateFormat.format(date),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(
              daysLeft <= 0 ? 'Hari ini' : '$daysLeft hari lagi',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecordPeriodButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddCyclePage(),
          ),
        );
        // Reload data after adding cycle
        _loadCycleData();
      },
      icon: const Icon(CupertinoIcons.plus),
      label: const Text('Catat Periode Baru'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFFE9458D),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }
  
  Widget _buildEndPeriodButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        // Show date picker
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: _currentCycle!.startDate,
          lastDate: DateTime.now().add(const Duration(days: 1)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFE9458D),
                ),
              ),
              child: child!,
            );
          },
        );
        
        if (selectedDate != null) {
          // Calculate period length
          final periodLength = selectedDate.difference(_currentCycle!.startDate).inDays + 1;
          
          // Update cycle
          await DatabaseHelperMenstrual.instance.endCycle(_currentCycle!.id, selectedDate);
          
          // Update period length if it's different from default
          if (periodLength != _currentCycle!.periodLength) {
            final updatedCycle = MenstrualCycle(
              id: _currentCycle!.id,
              startDate: _currentCycle!.startDate,
              endDate: selectedDate,
              cycleLength: _currentCycle!.cycleLength,
              periodLength: periodLength,
              symptoms: _currentCycle!.symptoms,
              notes: _currentCycle!.notes,
              mood: _currentCycle!.mood,
            );
            
            await DatabaseHelperMenstrual.instance.updateCycle(updatedCycle);
          }
          
          // Reload data
          _loadCycleData();
        }
      },
      icon: const Icon(CupertinoIcons.flag),
      label: const Text('Akhiri Periode Saat Ini'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple.shade400,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 50),
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
          'Siklus Menstruasi',
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
          // Statistics
          IconButton(
            icon: const Icon(CupertinoIcons.chart_bar_alt_fill, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MenstrualStatisticsPage(),
                ),
              );
            },
          ),
          // Settings
          IconButton(
            icon: const Icon(CupertinoIcons.settings, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MenstrualSettingsPage(),
                ),
              );
              // Reload data after potentially changing settings
              _loadCycleData();
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
                                      _buildLegendItem('Menstruasi', const Color(0xFFE9458D)),
                                      _buildLegendItem('Ovulasi', const Color(0xFFFFC400)),
                                      _buildLegendItem('Masa Subur', const Color(0xFF8BC34A)),
                                      _buildLegendItem('Gejala', Colors.purple),
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
}