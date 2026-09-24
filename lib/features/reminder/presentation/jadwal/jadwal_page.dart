import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/core/widgets/app_bottom_navigation.dart';
import 'package:intl/intl.dart';
import 'package:primafit/features/reminder/presentation/jadwal/input_agenda.dart';
import 'package:primafit/features/reminder/data/database_agenda.dart';
import 'package:primafit/features/reminder/presentation/jadwal/detail_agenda.dart';
import 'package:flutter/cupertino.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<Agenda> _allAgendaItems = [];
  List<Agenda> _filteredAgendaItems = [];
  bool _isLoading = true;

  final Color _themeColor = const Color(0xFF64D1DE);

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedMonth = DateTime.now();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
    _loadAgendaItems();
  }

  Future<void> _loadAgendaItems() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final agendaItems = await DatabaseAgenda.instance.getAllAgenda();
      
      setState(() {
        _allAgendaItems = agendaItems;
        _filterAgendaForSelectedDate();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load agenda items');
    }
  }

  void _filterAgendaForSelectedDate() {
    final selectedDateFormatted = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    _filteredAgendaItems = _allAgendaItems
        .where((agenda) => agenda.date == selectedDateFormatted)
        .toList();
  }

  // Check if a specific date has agenda items
  bool _hasAgendaForDate(DateTime date) {
    final dateFormatted = DateFormat('yyyy-MM-dd').format(date);
    return _allAgendaItems.any((agenda) => agenda.date == dateFormatted);
  }

  // Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show success message
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _filterAgendaForSelectedDate();
    });
  }

  void _navigateToDetailPage(Agenda agenda) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailAgendaPage(agenda: agenda),
      ),
    );

    if (result == 'refresh') {
      _loadAgendaItems();
      _showSuccessSnackBar('Agenda updated successfully');
    } else if (result == 'deleted') {
      _loadAgendaItems();
      _showSuccessSnackBar('Agenda deleted successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildMonthSelector(),
            _buildWeekdaysHeader(),
            Expanded(
              flex: 3,
              child: FadeTransition(
                opacity: _animation,
                child: _buildCalendarGrid(),
              ),
            ),
            Expanded(
              flex: 4,
              child: _buildAgendaList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InputAgendaScreen(
                selectedDate: _selectedDate,
              ),
            ),
          );

          if (result == 'refresh') {
            _loadAgendaItems();
            _showSuccessSnackBar('New agenda added successfully');
          }
        },
        backgroundColor: _themeColor,
        tooltip: 'Add new agenda',
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavButton(CupertinoIcons.chevron_left, _previousMonth),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Show month/year picker (future implementation)
              },
              child: Column(
                children: [
                  Text(
                    DateFormat('MMMM').format(_focusedMonth),
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    DateFormat('yyyy').format(_focusedMonth),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          _buildNavButton(CupertinoIcons.chevron_right, _nextMonth),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black54),
        onPressed: onPressed,
        tooltip: icon == CupertinoIcons.chevron_left ? 'Previous month' : 'Next month',
      ),
    );
  }

  Widget _buildWeekdaysHeader() {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      margin: const EdgeInsets.only(bottom: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((day) {
          final isWeekend = day == 'Sat' || day == 'Sun';
          return Expanded(
            child: Text(
              day,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isWeekend ? _themeColor : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // Get the first day of the month
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    
    // Get the last day of the month
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    
    // Get the weekday of the first day (1 = Monday, 7 = Sunday)
    final int firstWeekday = firstDay.weekday;
    
    // Calculate days from previous month to show
    final prevMonthDays = firstWeekday - 1;
    
    // Get the last day of the previous month
    final lastDayPrevMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 0).day;
    
    // Generate list of days to display
    final List<Widget> dayWidgets = [];
    
    // Add days from previous month
    for (int i = 0; i < prevMonthDays; i++) {
      final day = lastDayPrevMonth - prevMonthDays + i + 1;
      final date = DateTime(_focusedMonth.year, _focusedMonth.month - 1, day);
      dayWidgets.add(_buildDayCell(day, date: date, isCurrentMonth: false));
    }
    
    // Add days from current month
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final isToday = _isToday(date);
      final isSelected = day == _selectedDate.day && 
        _focusedMonth.month == _selectedDate.month && 
        _focusedMonth.year == _selectedDate.year;
      
      dayWidgets.add(_buildDayCell(
        day, 
        date: date,
        isCurrentMonth: true, 
        isSelected: isSelected,
        isToday: isToday,
        hasEvents: _hasAgendaForDate(date),
      ));
    }
    
    // Calculate days from next month if needed to complete the grid
    final remainingCells = 42 - dayWidgets.length; // 6 rows of 7 days
    for (int day = 1; day <= remainingCells; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month + 1, day);
      dayWidgets.add(_buildDayCell(day, date: date, isCurrentMonth: false));
    }
    
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      children: dayWidgets,
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Widget _buildDayCell(int day, {
    required DateTime date,
    required bool isCurrentMonth, 
    bool isSelected = false,
    bool isToday = false,
    bool hasEvents = false,
  }) {
    return GestureDetector(
      onTap: isCurrentMonth ? () {
        _onDaySelected(date);
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isSelected 
              ? _themeColor 
              : isToday 
                  ? _themeColor.withValues(alpha: 0.1) 
                  : Colors.transparent,
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: _themeColor, width: 1)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
                color: !isCurrentMonth 
                    ? Colors.grey.shade400 
                    : isSelected 
                        ? Colors.white 
                        : Colors.black87,
              ),
            ),
            if (hasEvents && isCurrentMonth)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : _themeColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaList() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_themeColor),
        ),
      );
    }

    if (_filteredAgendaItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.calendar_badge_minus,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No agenda for ${DateFormat('MMMM d, yyyy').format(_selectedDate)}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a new agenda',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Text(
            DateFormat('EEEE, MMMM d').format(_selectedDate),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filteredAgendaItems.length,
            itemBuilder: (context, index) {
              final agenda = _filteredAgendaItems[index];
              return _buildAgendaCard(agenda);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAgendaCard(Agenda agenda) {
    // Parse time for display
    final timeFormat = DateFormat('HH:mm');
    String displayTime = agenda.time;
    try {
      final parsedTime = timeFormat.parse(agenda.time);
      displayTime = DateFormat('HH:mm').format(parsedTime);
    } catch (e) {
      // Keep original time format if parsing fails
    }

    return Hero(
      tag: 'agenda-${agenda.id}',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        shadowColor: Colors.grey.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _navigateToDetailPage(agenda),
          borderRadius: BorderRadius.circular(12),
          splashColor: _themeColor.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 80,
                  decoration: BoxDecoration(
                    color: agenda.isCompleted == 1 ? Colors.green : _themeColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _themeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              displayTime,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _themeColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (agenda.isCompleted == 1)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.check_mark_circled_solid,
                                    color: Colors.green,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Completed',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        agenda.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          decoration: agenda.isCompleted == 1 ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (agenda.description != null && agenda.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            agenda.description!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}