import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:primafit/features/reminder/data/database_obat.dart';

class DetailObat extends StatefulWidget {
  final int obatId;

  const DetailObat({super.key, required this.obatId});

  @override
  State<DetailObat> createState() => _DetailObatState();
}

class _DetailObatState extends State<DetailObat> with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>?> _futureObat;
  late Future<List<Map<String, dynamic>>> _futureAlarms;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  void _loadData() {
    _futureObat = DatabaseObatHelper.instance.getObatById(widget.obatId);
    _futureAlarms = DatabaseObatHelper.instance.getAlarmsByObatId(widget.obatId);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getFormattedTime(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('HH:mm').format(dateTime);
  }

  IconData _getMedicineIcon(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'tablet':
      case 'pil':
        return CupertinoIcons.capsule_fill;
      case 'sirup':
      case 'cair':
        return CupertinoIcons.drop_fill;
      case 'suntik':
      case 'injeksi':
        // return CupertinoIcons.syringe_fill;
        return CupertinoIcons.drop_fill;
      case 'tetes':
        return CupertinoIcons.eyedropper;
      case 'salep':
      case 'krim':
        return CupertinoIcons.bandage_fill;
      default:
        return CupertinoIcons.capsule_fill;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, int obatId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Konfirmasi Hapus',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus obat ini? Semua pengingat terkait juga akan dihapus.',
            style: TextStyle(
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                setState(() {
                  _isLoading = true;
                });
                
                try {
                  // Hapus alarm terkait terlebih dahulu
                  final alarms = await DatabaseObatHelper.instance.getAlarmsByObatId(obatId);
                  for (var alarm in alarms) {
                    await DatabaseObatHelper.instance.deleteAlarmObat(alarm['id']);
                  }
                  
                  // Kemudian hapus obat
                  await DatabaseObatHelper.instance.deleteObat(obatId);
                  
                  // Animasi keluar sebelum pop
                  await _animationController.reverse();
                  
                  if (mounted) {
                    // Tampilkan snackbar feedback dan kembali ke halaman sebelumnya
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Obat berhasil dihapus',
                          style: TextStyle(fontFamily: 'Poppins'),
                        ),
                        backgroundColor: Color(0xFF64D1DE),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  if (mounted) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error: $e',
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Hapus',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _futureObat,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF64D1DE),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_circle,
                    size: 60,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF64D1DE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.doc_text_search,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Obat tidak ditemukan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF64D1DE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
            );
          }

          final obat = snapshot.data!;
          return FadeTransition(
            opacity: _animation,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: const Color(0xFF64D1DE),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      obat['nama'],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF64D1DE),
                            const Color(0xFF64D1DE).withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Hero(
                          tag: 'medicine_icon_${obat['id']}',
                          child: Icon(
                            _getMedicineIcon(obat['jenis']),
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(CupertinoIcons.back, color: Colors.white),
                    onPressed: () async {
                      await _animationController.reverse();
                      if (mounted) {
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      }
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(CupertinoIcons.pencil, color: Colors.white),
                      onPressed: () {
                        // Navigate to edit obat page
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => EditObat(obatId: obat['id']),
                        //   ),
                        // ).then((_) => _loadData());
                      },
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.trash, color: Colors.white),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, obat['id']);
                      },
                      tooltip: 'Hapus',
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Informasi Dasar
                        _buildInfoSection(
                          title: 'Informasi Obat',
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  _buildInfoRow('Nama', obat['nama']),
                                  _buildInfoRow('Dosis', obat['dosis']),
                                  _buildInfoRow('Jenis', obat['jenis']),
                                  _buildInfoRow('Stok', obat['stok']),
                                  _buildInfoRow('Frekuensi', '${obat['frekuensi_harian']} kali sehari'),
                                  _buildInfoRow('Instruksi', obat['instruksi']),
                                  if (obat['deskripsi'] != null && obat['deskripsi'].toString().isNotEmpty)
                                    _buildInfoRow('Deskripsi', obat['deskripsi']),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Jadwal Konsumsi
                        _buildInfoSection(
                          title: 'Jadwal Konsumsi',
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: _futureAlarms,
                            builder: (context, alarmSnapshot) {
                              if (alarmSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF64D1DE),
                                  ),
                                );
                              } else if (alarmSnapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Error: ${alarmSnapshot.error}',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.red,
                                    ),
                                  ),
                                );
                              } else if (!alarmSnapshot.hasData || alarmSnapshot.data!.isEmpty) {
                                return const Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Text(
                                        'Belum ada jadwal yang diatur',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              
                              final alarms = alarmSnapshot.data!;
                              alarms.sort((a, b) => a['waktu_alarm'].compareTo(b['waktu_alarm']));
                              
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: alarms.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final alarm = alarms[index];
                                    final timeStr = _getFormattedTime(alarm['waktu_alarm']);
                                    
                                    return ListTile(
                                      leading: Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF64D1DE).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            CupertinoIcons.clock,
                                            color: Color(0xFF64D1DE),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        'Pukul $timeStr',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        obat['instruksi'],
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          CupertinoIcons.bell_fill,
                                          color: Color(0xFF64D1DE),
                                        ),
                                        onPressed: () {
                                          // Option to edit alarm time
                                        },
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF64D1DE),
        onPressed: () {
          // Navigate to add alarm page
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => AddAlarm(obatId: widget.obatId),
          //   ),
          // ).then((_) => _loadData());
        },
        tooltip: 'Tambah Alarm',
        child: const Icon(CupertinoIcons.bell_fill, color: Colors.white),
      ),
    );
  }
  
  Widget _buildInfoSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64D1DE),
            ),
          ),
        ),
        child,
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}