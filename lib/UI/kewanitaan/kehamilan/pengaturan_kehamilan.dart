import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/database/kewanitaan/database_kehamilan.dart';

class PregnancySettingsPage extends StatefulWidget {
  const PregnancySettingsPage({Key? key}) : super(key: key);

  @override
  _PregnancySettingsPageState createState() => _PregnancySettingsPageState();
}

class _PregnancySettingsPageState extends State<PregnancySettingsPage> {
  bool _notificationEnabled = true;
  String _notificationTime = '08:00';
  bool _weeklySummaryEnabled = true;
  bool _kickCounterEnabled = true;
  String _weightUnit = 'kg';
  String _heightUnit = 'cm';
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
      final settings = await DatabaseHelperPregnancy.instance.getSettings();
      
      setState(() {
        _notificationEnabled = settings['notification_enabled'] as bool;
        _notificationTime = settings['notification_time'] as String;
        _weeklySummaryEnabled = settings['weekly_summary_enabled'] as bool;
        _kickCounterEnabled = settings['kick_counter_enabled'] as bool;
        _weightUnit = settings['weight_unit'] as String;
        _heightUnit = settings['height_unit'] as String;
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
      await DatabaseHelperPregnancy.instance.saveSettings(
        notificationEnabled: _notificationEnabled,
        notificationTime: _notificationTime,
        weeklySummaryEnabled: _weeklySummaryEnabled,
        kickCounterEnabled: _kickCounterEnabled,
        weightUnit: _weightUnit,
        heightUnit: _heightUnit,
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
  
  Widget _buildSettingSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
            children: children,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE9458D).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFFE9458D),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: const Color(0xFFE9458D),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeSetting({
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE9458D).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFFE9458D),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    CupertinoIcons.chevron_down,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRadioSetting<T>({
    required String title,
    required String subtitle,
    required T value,
    required T groupValue,
    required Function(T?) onChanged,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE9458D).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFFE9458D),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Radio<T>(
            value: value,
            groupValue: groupValue,
            activeColor: const Color(0xFFE9458D),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
  
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade200,
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
          'Pengaturan Kehamilan',
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
                            color: const Color(0xFFE9458D).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE9458D).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9458D).withOpacity(0.2),
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
                                      'Pengaturan Pemantauan Kehamilan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'Sesuaikan preferensi pemantauan kehamilan Anda',
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
                        
                        // Notification Settings
                        _buildSettingSection(
                          title: 'Pengaturan Notifikasi',
                          children: [
                            _buildSwitchSetting(
                              title: 'Aktifkan Notifikasi',
                              subtitle: 'Dapatkan pengingat tentang perkembangan kehamilan Anda',
                              value: _notificationEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _notificationEnabled = value;
                                });
                              },
                              icon: CupertinoIcons.bell,
                            ),
                            
                            if (_notificationEnabled) ...[
                              _buildDivider(),
                              _buildTimeSetting(
                                title: 'Waktu Notifikasi',
                                subtitle: 'Waktu Anda ingin menerima notifikasi harian',
                                value: _notificationTime,
                                onTap: _showTimePickerDialog,
                                icon: CupertinoIcons.time,
                              ),
                              _buildDivider(),
                              _buildSwitchSetting(
                                title: 'Ringkasan Mingguan',
                                subtitle: 'Dapatkan ringkasan perkembangan kehamilan mingguan',
                                value: _weeklySummaryEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _weeklySummaryEnabled = value;
                                  });
                                },
                                icon: CupertinoIcons.calendar,
                              ),
                              _buildDivider(),
                              _buildSwitchSetting(
                                title: 'Pengingat Tendangan',
                                subtitle: 'Dapatkan pengingat untuk menghitung tendangan bayi',
                                value: _kickCounterEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _kickCounterEnabled = value;
                                  });
                                },
                                icon: CupertinoIcons.hand_raised,
                              ),
                            ],
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Unit Settings
                        _buildSettingSection(
                          title: 'Pengaturan Unit',
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE9458D).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.arrow_up_right_square,
                                      size: 20,
                                      color: Color(0xFFE9458D),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Unit Berat',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Unit untuk pengukuran berat badan',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildDivider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _weightUnit = 'kg';
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: _weightUnit == 'kg' 
                                              ? const Color(0xFFE9458D).withOpacity(0.1) 
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: _weightUnit == 'kg' 
                                                ? const Color(0xFFE9458D) 
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Kilogram (kg)',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: _weightUnit == 'kg' 
                                                  ? FontWeight.w600 
                                                  : FontWeight.normal,
                                              color: _weightUnit == 'kg' 
                                                  ? const Color(0xFFE9458D) 
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _weightUnit = 'lbs';
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: _weightUnit == 'lbs' 
                                              ? const Color(0xFFE9458D).withOpacity(0.1) 
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: _weightUnit == 'lbs' 
                                                ? const Color(0xFFE9458D) 
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Pound (lbs)',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: _weightUnit == 'lbs' 
                                                  ? FontWeight.w600 
                                                  : FontWeight.normal,
                                              color: _weightUnit == 'lbs' 
                                                  ? const Color(0xFFE9458D) 
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildDivider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE9458D).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.arrow_up_down,
                                      size: 20,
                                      color: Color(0xFFE9458D),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Unit Tinggi',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Unit untuk pengukuran tinggi badan',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildDivider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _heightUnit = 'cm';
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: _heightUnit == 'cm' 
                                              ? const Color(0xFFE9458D).withOpacity(0.1) 
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: _heightUnit == 'cm' 
                                                ? const Color(0xFFE9458D) 
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Sentimeter (cm)',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: _heightUnit == 'cm' 
                                                  ? FontWeight.w600 
                                                  : FontWeight.normal,
                                              color: _heightUnit == 'cm' 
                                                  ? const Color(0xFFE9458D) 
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _heightUnit = 'in';
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: _heightUnit == 'in' 
                                              ? const Color(0xFFE9458D).withOpacity(0.1) 
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: _heightUnit == 'in' 
                                                ? const Color(0xFFE9458D) 
                                                : Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Inci (in)',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: _heightUnit == 'in' 
                                                  ? FontWeight.w600 
                                                  : FontWeight.normal,
                                              color: _heightUnit == 'in' 
                                                  ? const Color(0xFFE9458D) 
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // About Section
                        _buildSettingSection(
                          title: 'Tentang',
                          children: [
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9458D).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.info,
                                  size: 20,
                                  color: Color(0xFFE9458D),
                                ),
                              ),
                              title: Text(
                                'Versi Aplikasi',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                '1.0.0',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: const Icon(
                                CupertinoIcons.chevron_right,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onTap: () {
                                // Show version info
                              },
                            ),
                            _buildDivider(),
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9458D).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.doc_text,
                                  size: 20,
                                  color: Color(0xFFE9458D),
                                ),
                              ),
                              title: Text(
                                'Kebijakan Privasi',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                'Lihat kebijakan privasi kami',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: const Icon(
                                CupertinoIcons.chevron_right,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onTap: () {
                                // Show privacy policy
                              },
                            ),
                            _buildDivider(),
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9458D).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.square_list,
                                  size: 20,
                                  color: Color(0xFFE9458D),
                                ),
                              ),
                              title: Text(
                                'Syarat dan Ketentuan',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                'Lihat syarat dan ketentuan kami',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: const Icon(
                                CupertinoIcons.chevron_right,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onTap: () {
                                // Show terms and conditions
                              },
                            ),
                          ],
                        ),
                        
                        // Save button padding
                        const SizedBox(height: 80),
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
                            color: Colors.black.withOpacity(0.05),
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