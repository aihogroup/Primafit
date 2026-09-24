import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/UI/navigasi/navigation.dart';
// import 'package:primafit/Database/database.dart';
import 'package:primafit/UI/pengingat/obat/detail_obat.dart';
import 'package:primafit/UI/pengingat/obat/obat_page.dart';
import 'package:primafit/database/pengingat/database_obat.dart';
import 'package:primafit/database/navigasi/database_profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String namaPengguna = '';
  String? fotoProfilPath;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final db = ProfileDatabaseHelper();
    final profiles = await db.getProfiles();

    if (profiles.isNotEmpty) {
      setState(() {
        namaPengguna = profiles.first['nama'] ?? '';
        fotoProfilPath = profiles.first['foto'];
      });
    }
  }

  String getGreeting() {
    int hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  Widget _buildProfileImage() {
    if (fotoProfilPath != null && File(fotoProfilPath!).existsSync()) {
      return Image.file(
        File(fotoProfilPath!),
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'assets/avatar/avatar1.jpg',
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildFeatureCards(),
                const SizedBox(height: 24),
                // _buildReminderObat(),
                // const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }

Widget _buildReminderObat() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, right: 4, bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pengingat Obat',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ObatPage(),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64D1DE),
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color: Color(0xFF64D1DE),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseObatHelper.instance.getAllObat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF64D1DE),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.red,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.doc_text_search,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pengingat obat',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Group obat by name to show cards for each unique medicine
            Map<String, List<Map<String, dynamic>>> groupedObat = {};
            for (var obat in snapshot.data!) {
              // ignore: unnecessary_null_comparison
              if (obat != null) {
                String name = obat['nama'] ?? 'Obat';
                if (!groupedObat.containsKey(name)) {
                  groupedObat[name] = [];
                }
                groupedObat[name]!.add(obat);
              }
            }

            if (groupedObat.isEmpty) {
              return Center(
                child: Text(
                  'Tidak ada data obat yang valid',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              );
            }

            return SizedBox(
              height: 200, // Adjust based on your card height
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: groupedObat.length,
                itemBuilder: (context, index) {
                  String nama = groupedObat.keys.elementAt(index);
                  List<Map<String, dynamic>> obatList = groupedObat[nama]!;
                  
                  // Get first entry for this medicine to display basic info
                  Map<String, dynamic> obat = obatList.first;
                  
                  // Memastikan ID obat ada dan valid
                  final obatId = obat['id'];
                  if (obatId == null) {
                    return const SizedBox(); // Skip this item if ID is null
                  }
                  
                  // Get future alarm times for this obat
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: DatabaseObatHelper.instance.getAlarmsByObatId(obatId),
                    builder: (context, alarmSnapshot) {
                      List<Map<String, dynamic>> alarms = [];
                      if (alarmSnapshot.hasData) {
                        alarms = alarmSnapshot.data!;
                      }
                      
                      // Format next alarm time if available
                      String nextAlarmTime = "Tidak ada jadwal";
                      if (alarms.isNotEmpty) {
                        // Versi baru dengan jam dan menit terpisah
                        var alarm = alarms.first;
                        if (alarm.containsKey('jam') && alarm.containsKey('menit')) {
                          int jam = alarm['jam'] ?? 0;
                          int menit = alarm['menit'] ?? 0;
                          nextAlarmTime = "Pukul ${jam.toString().padLeft(2, '0')}.${menit.toString().padLeft(2, '0')}";
                        } 
                        // Versi lama dengan waktu_alarm
                        else if (alarm.containsKey('waktu_alarm') && alarm['waktu_alarm'] != null) {
                          DateTime alarmTime = DateTime.fromMillisecondsSinceEpoch(
                            alarm['waktu_alarm'],
                          );
                          nextAlarmTime = "Pukul ${alarmTime.hour.toString().padLeft(2, '0')}.${alarmTime.minute.toString().padLeft(2, '0')}";
                        }
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailObat(obatId: obatId),
                              ),
                            ).then((_) {
                              // Refresh the list when returning from detail page
                              setState(() {});
                            });
                          },
                          child: Container(
                            width: 180,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF64D1DE).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            _getMedicineIcon(obat['jenis'] ?? ''),
                                            color: const Color(0xFF64D1DE),
                                            size: 32,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              obat['nama'] ?? 'Obat',
                                              style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              obat['dosis'] ?? '-',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    obat['instruksi'] ?? 'Tidak ada instruksi',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Spacer(),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF64D1DE),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        nextAlarmTime,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    ],
  );
}

// Pastikan _getMedicineIcon implementasi juga menangani null value
IconData _getMedicineIcon(String jenis) {
  switch (jenis.toLowerCase()) {
    case 'tablet':
    case 'oral':
    case 'pil':
      return CupertinoIcons.capsule_fill;
    case 'sirup':
    case 'cair':
      return CupertinoIcons.drop_fill;
    case 'suntik':
    case 'injeksi':
      return CupertinoIcons.bandage;
    case 'tetes':
      return CupertinoIcons.eyedropper;
    case 'salep':
    case 'krim':
    case 'topikal':
      return CupertinoIcons.bandage_fill;
    default:
      return CupertinoIcons.capsule_fill;
  }
}

// Helper function to get appropriate icon based on medicine type
IconData getMedicineIcon(String jenis) {
  switch (jenis.toLowerCase()) {
    case 'tablet':
    case 'pil':
      return CupertinoIcons.capsule_fill;
    case 'sirup':
    case 'cair':
      return CupertinoIcons.drop_fill;
    case 'suntik':
    case 'injeksi':
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getGreeting(),
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            Text(
              namaPengguna,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFD8C4FF),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: _buildProfileImage(),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildFeatureCards() {
  // List of feature data with icons, labels, and routes
  final List<Map<String, dynamic>> features = [
    {
      'icon': 'assets/fitur/fitur1.png',
      'label': 'Kolesterol',
      'route': '/kolesterol',
    },
    {
      'icon': 'assets/fitur/fitur2.png',
      'label': 'Asam Urat',
      'route': '/asamurat',
    },
    {
      'icon': 'assets/fitur/fitur3.png',
      'label': 'Tensi',
      'route': '/tensi',
    },
    {
      'icon': 'assets/fitur/fitur4.png',
      'label': 'BMI',
      'route': '/bmi',
    },
    {
      'icon': 'assets/fitur/fitur5.png',
      'label': 'Gula Darah',
      'route': '/guladarah',
    },
    {
      'icon': 'assets/fitur/suhu.png',
      'label': 'Suhu Tubuh',
      'route': '/suhu',
    },
    {
      'icon': 'assets/fitur/makan.png',
      'label': 'Makanan',
      'route': '/makanan',
    },
    {
      'icon': 'assets/fitur/fitur8.png',
      'label': 'Semua Fitur',
      'route': '/semua',
    },
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Padding(
      //   padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
      //   child: Text(
      //     'Fitur',
      //     style: TextStyle(
      //       fontFamily: 'Poppins',
      //       fontSize: 18,
      //       fontWeight: FontWeight.w600,
      //       color: Colors.black87,
      //     ),
      //   ),
      // ),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 0.9,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                return _buildFeatureItem(
                  context,
                  features[index]['icon'],
                  features[index]['label'],
                  features[index]['route'],
                );
              },
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildFeatureItem(
    BuildContext context, String iconPath, String label, String route) {
  return InkWell(
    onTap: () {
      // Add haptic feedback for better user experience
      HapticFeedback.lightImpact();
      
      // Navigate with hero animation
      Navigator.of(context).pushReplacementNamed(route);
    },
    borderRadius: BorderRadius.circular(12),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Feature icon with background
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF64D1DE).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Hero(
            tag: route,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
                semanticLabel: label.replaceAll('\n', ' '),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Feature label
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          softWrap: true,
        ),
      ],
    ),
  );
}
}