import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KickCounterPage extends StatefulWidget {
  final int pregnancyId;
  
  const KickCounterPage({
    Key? key,
    required this.pregnancyId,
  }) : super(key: key);

  @override
  _KickCounterPageState createState() => _KickCounterPageState();
}

class _KickCounterPageState extends State<KickCounterPage> {
  int _kickCount = 0;
  DateTime? _startTime;
  Timer? _timer;
  String _elapsedTime = '00:00:00';
  bool _isSessionActive = false;
  List<KickSession> _recentSessions = [];
  
  final DateFormat _dateFormat = DateFormat('d MMM, HH:mm');
  
  @override
  void initState() {
    super.initState();
    _loadRecentSessions();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadRecentSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getStringList('kick_sessions_${widget.pregnancyId}') ?? [];
    
    setState(() {
      _recentSessions = sessionsJson
          .map((json) => KickSession.fromJson(json))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date (newest first)
    });
  }
  
  Future<void> _saveRecentSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = _recentSessions.map((session) => session.toJson()).toList();
    
    await prefs.setStringList('kick_sessions_${widget.pregnancyId}', sessionsJson);
  }
  
  void _startSession() {
    setState(() {
      _kickCount = 0;
      _startTime = DateTime.now();
      _isSessionActive = true;
      _elapsedTime = '00:00:00';
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        final elapsed = DateTime.now().difference(_startTime!);
        
        // Format as HH:MM:SS
        final hours = elapsed.inHours.toString().padLeft(2, '0');
        final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
        
        setState(() {
          _elapsedTime = '$hours:$minutes:$seconds';
        });
      }
    });
  }
  
  void _recordKick() {
    if (!_isSessionActive) return;
    
    setState(() {
      _kickCount++;
    });
    
    // If we've reached 10 kicks, suggest ending the session
    if (_kickCount == 10) {
      _showCompletionDialog();
    }
  }
  
  void _endSession() {
    _timer?.cancel();
    
    if (_startTime != null && _kickCount > 0) {
      final endTime = DateTime.now();
      final duration = endTime.difference(_startTime!);
      
      // Create a new session record
      final session = KickSession(
        date: _startTime!,
        kickCount: _kickCount,
        durationMinutes: duration.inMinutes,
      );
      
      // Add to recent sessions
      setState(() {
        _recentSessions.insert(0, session);
        // Keep only the last 10 sessions
        if (_recentSessions.length > 10) {
          _recentSessions = _recentSessions.sublist(0, 10);
        }
      });
      
      // Save to shared preferences
      _saveRecentSessions();
    }
    
    setState(() {
      _isSessionActive = false;
      _startTime = null;
    });
  }
  
  void _resetSession() {
    _timer?.cancel();
    
    setState(() {
      _kickCount = 0;
      _startTime = DateTime.now();
      _elapsedTime = '00:00:00';
    });
    
    // Restart the timer
    _startSession();
  }
  
  void _showCompletionDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Berhasil Mencatat 10 Tendangan!',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Anda telah mencatat 10 tendangan dalam waktu $_elapsedTime. Anda dapat mengakhiri sesi ini atau melanjutkan untuk mencatat lebih banyak tendangan.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Lanjutkan'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE9458D),
            ),
            child: const Text('Akhiri Sesi'),
          ),
        ],
      ),
    );
  }
  
  void _confirmEndSession() {
    if (!_isSessionActive) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Akhiri Sesi?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin mengakhiri sesi penghitungan tendangan saat ini?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE9458D),
            ),
            child: const Text('Akhiri'),
          ),
        ],
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
          'Penghitung Tendangan Bayi',
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info banner
            Container(
              color: const Color(0xFFE9458D),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.info_circle_fill,
                            color: Colors.amber.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Informasi Penting',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dokter merekomendasikan untuk menghitung gerakan/tendangan bayi setiap hari dimulai dari minggu ke-28 kehamilan. Idealnya, Anda harus merasakan minimal 10 gerakan dalam waktu 2 jam.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Penurunan gerakan bayi secara signifikan dapat menjadi tanda masalah. Hubungi dokter/bidan jika khawatir tentang gerakan bayi.',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Counter
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Session info
                        if (_isSessionActive) ...[
                          Text(
                            'Sesi Berlangsung',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.teal.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.timer,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _elapsedTime,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Text(
                            'Sesi Tidak Aktif',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tekan tombol di bawah untuk mulai',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 20),
                        
                        // Kick count
                        Text(
                          '$_kickCount',
                          style: GoogleFonts.poppins(
                            fontSize: 80,
                            fontWeight: FontWeight.w600,
                            color: _isSessionActive ? Colors.teal.shade600 : Colors.grey.shade400,
                          ),
                        ),
                        Text(
                          'Tendangan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: _isSessionActive ? Colors.teal.shade600 : Colors.grey.shade500,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Buttons
                        if (_isSessionActive) ...[
                          // Record kick button
                          ElevatedButton.icon(
                            onPressed: _recordKick,
                            icon: const Icon(Icons.add),
                            label: const Text('Catat Tendangan'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.teal.shade600,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              minimumSize: const Size(240, 50),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Session control buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _resetSession,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reset'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey.shade700,
                                  side: BorderSide(color: Colors.grey.shade400),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: _confirmEndSession,
                                icon: const Icon(Icons.stop),
                                label: const Text('Akhiri Sesi'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red.shade700,
                                  side: BorderSide(color: Colors.red.shade300),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Start session button
                          ElevatedButton.icon(
                            onPressed: _startSession,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Mulai Sesi Baru'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFFE9458D),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              minimumSize: const Size(200, 50),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent sessions
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sesi Terakhir',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        if (_recentSessions.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    CupertinoIcons.doc_text,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Belum ada sesi tercatat',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _recentSessions.length,
                            itemBuilder: (context, index) {
                              final session = _recentSessions[index];
                              return _buildSessionItem(session);
                            },
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Guide card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: Colors.amber.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Panduan Penghitungan',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildGuideItem(
                          '1. Pilih waktu tenang saat bayi biasanya aktif.'
                        ),
                        _buildGuideItem(
                          '2. Duduk atau berbaring dengan posisi miring ke kiri.'
                        ),
                        _buildGuideItem(
                          '3. Tekan tombol "Catat Tendangan" setiap kali merasakan gerakan bayi.'
                        ),
                        _buildGuideItem(
                          '4. Idealnya, Anda akan merasakan 10 gerakan dalam waktu kurang dari 2 jam.'
                        ),
                        _buildGuideItem(
                          '5. Hubungi dokter jika tidak merasakan 10 gerakan dalam 2 jam atau jika ada penurunan gerakan yang signifikan.'
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSessionItem(KickSession session) {
    // Determine status color
    Color statusColor;
    String statusText;
    
    if (session.durationMinutes <= 60 && session.kickCount >= 10) {
      statusColor = Colors.green.shade600;
      statusText = 'Sangat Baik';
    } else if (session.durationMinutes <= 120 && session.kickCount >= 10) {
      statusColor = Colors.teal.shade600;
      statusText = 'Baik';
    } else if (session.kickCount >= 10) {
      statusColor = Colors.amber.shade600;
      statusText = 'Normal';
    } else {
      statusColor = Colors.red.shade600;
      statusText = 'Perlu Perhatian';
    }
    
    // Format duration
    String durationText;
    if (session.durationMinutes < 60) {
      durationText = '${session.durationMinutes} menit';
    } else {
      final hours = session.durationMinutes ~/ 60;
      final minutes = session.durationMinutes % 60;
      durationText = '$hours jam ${minutes > 0 ? '$minutes menit' : ''}';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _dateFormat.format(session.date),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSessionStat(
                icon: CupertinoIcons.hand_raised_fill,
                value: '${session.kickCount}',
                label: 'Tendangan',
              ),
              _buildSessionStat(
                icon: CupertinoIcons.timer,
                value: durationText,
                label: 'Durasi',
              ),
              _buildSessionStat(
                icon: CupertinoIcons.speedometer,
                value: '${(session.kickCount / (session.durationMinutes / 60)).toStringAsFixed(1)}',
                label: 'Per Jam',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSessionStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFFE9458D),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildGuideItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.amber.shade700,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KickSession {
  final DateTime date;
  final int kickCount;
  final int durationMinutes;
  
  KickSession({
    required this.date,
    required this.kickCount,
    required this.durationMinutes,
  });
  
  // Convert to JSON string
  String toJson() {
    return '${date.toIso8601String()}|$kickCount|$durationMinutes';
  }
  
  // Create from JSON string
  factory KickSession.fromJson(String json) {
    final parts = json.split('|');
    return KickSession(
      date: DateTime.parse(parts[0]),
      kickCount: int.parse(parts[1]),
      durationMinutes: int.parse(parts[2]),
    );
  }
}