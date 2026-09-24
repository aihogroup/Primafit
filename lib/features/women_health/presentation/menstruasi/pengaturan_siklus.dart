import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/features/women_health/data/database_menstruasi.dart';

class MenstrualSettingsPage extends StatefulWidget {
  const MenstrualSettingsPage({super.key});

  @override
  _MenstrualSettingsPageState createState() => _MenstrualSettingsPageState();
}

class _MenstrualSettingsPageState extends State<MenstrualSettingsPage> {
  int _averageCycleLength = 28;
  int _averagePeriodLength = 5;
  bool _notificationEnabled = true;
  String _notificationTime = '08:00';
  int _notificationsBeforePeriod = 2;
  bool _isLoading = true;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final settings = await DatabaseHelperMenstrual.instance.getSettings();
      
      setState(() {
        _averageCycleLength = settings['average_cycle_length'] as int;
        _averagePeriodLength = settings['average_period_length'] as int;
        _notificationEnabled = settings['notification_enabled'] as bool;
        _notificationTime = settings['notification_time'] as String;
        _notificationsBeforePeriod = settings['notifications_before_period'] as int;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });
    
    try {
      await DatabaseHelperMenstrual.instance.saveSettings(
        averageCycleLength: _averageCycleLength,
        averagePeriodLength: _averagePeriodLength,
        notificationEnabled: _notificationEnabled,
        notificationTime: _notificationTime,
        notificationsBeforePeriod: _notificationsBeforePeriod,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pengaturan berhasil disimpan',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _isSaving = false;
        });
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan pengaturan: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  
  Future<void> _showTimePickerDialog() async {
    final TimeOfDay initialTime = TimeOfDay(
      hour: int.parse(_notificationTime.split(':')[0]),
      minute: int.parse(_notificationTime.split(':')[1]),
    );
    
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
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
    
    if (pickedTime != null) {
      setState(() {
        _notificationTime = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      });
    }
  }
  
  Widget _buildCycleLengthSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Panjang Siklus Rata-rata (hari)',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_averageCycleLength > 15) {
                    setState(() {
                      _averageCycleLength--;
                    });
                  }
                },
                icon: Icon(
                  CupertinoIcons.minus_circle,
                  color: Colors.grey.shade600,
                ),
                splashRadius: 24,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_averageCycleLength',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_averageCycleLength < 50) {
                    setState(() {
                      _averageCycleLength++;
                    });
                  }
                },
                icon: Icon(
                  CupertinoIcons.plus_circle,
                  color: Colors.grey.shade600,
                ),
                splashRadius: 24,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        Text(
          'Rata-rata siklus normal antara 21-35 hari',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPeriodLengthSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lama Menstruasi Rata-rata (hari)',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_averagePeriodLength > 1) {
                    setState(() {
                      _averagePeriodLength--;
                    });
                  }
                },
                icon: Icon(
                  CupertinoIcons.minus_circle,
                  color: Colors.grey.shade600,
                ),
                splashRadius: 24,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_averagePeriodLength',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_averagePeriodLength < 15) {
                    setState(() {
                      _averagePeriodLength++;
                    });
                  }
                },
                icon: Icon(
                  CupertinoIcons.plus_circle,
                  color: Colors.grey.shade600,
                ),
                splashRadius: 24,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        Text(
          'Rata-rata menstruasi normal antara 3-7 hari',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktifkan Notifikasi',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            CupertinoSwitch(
              value: _notificationEnabled,
              activeTrackColor: const Color(0xFFE9458D),
              onChanged: (value) {
                setState(() {
                  _notificationEnabled = value;
                });
              },
            ),
          ],
        ),
        
        if (_notificationEnabled) ...[
          const SizedBox(height: 16),
          
          // Notification time
          Text(
            'Waktu Pengingat',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _showTimePickerDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _notificationTime,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(
                    CupertinoIcons.clock,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Days before period to notify
          Text(
            'Pengingat Sebelum Periode (hari)',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_notificationsBeforePeriod > 0) {
                      setState(() {
                        _notificationsBeforePeriod--;
                      });
                    }
                  },
                  icon: Icon(
                    CupertinoIcons.minus_circle,
                    color: Colors.grey.shade600,
                  ),
                  splashRadius: 24,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_notificationsBeforePeriod',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_notificationsBeforePeriod < 10) {
                      setState(() {
                        _notificationsBeforePeriod++;
                      });
                    }
                  },
                  icon: Icon(
                    CupertinoIcons.plus_circle,
                    color: Colors.grey.shade600,
                  ),
                  splashRadius: 24,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          Text(
            'Jumlah hari sebelum periode untuk mendapatkan pengingat',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
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
          'Pengaturan Siklus',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE9458D)))
          : SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9458D).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE9458D).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9458D).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.settings,
                                  color: Color(0xFFE9458D),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pengaturan Siklus Menstruasi',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Sesuaikan parameter pelacakan siklus Anda',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Cycle Settings Section
                        Text(
                          'Pengaturan Siklus',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Average cycle length
                        _buildCycleLengthSelector(),
                        
                        const SizedBox(height: 16),
                        
                        // Average period length
                        _buildPeriodLengthSelector(),
                        
                        const SizedBox(height: 24),
                        
                        // Notifications Section
                        Text(
                          'Pengaturan Notifikasi',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Notification settings
                        _buildNotificationSettings(),
                        
                        // Save button padding
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                  
                  // Save button at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveSettings,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFFE9458D),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3.0,
                              )
                            : Text(
                                'Simpan Pengaturan',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}