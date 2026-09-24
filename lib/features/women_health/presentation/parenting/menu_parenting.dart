import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/features/women_health/presentation/parenting/beranda_parenting.dart';


class ParentingMenuPage extends StatefulWidget {
  const ParentingMenuPage({super.key});

  @override
  State<ParentingMenuPage> createState() => _ParentingMenuPageState();
}

class _ParentingMenuPageState extends State<ParentingMenuPage> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToParenting() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading for better UX
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              const ParentingHomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            
            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ).then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  void _showFeatureComingSoon(String featureName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9458D).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.info_circle_fill,
                  color: Color(0xFFE9458D),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Segera Hadir',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Text(
            'Fitur $featureName sedang dalam pengembangan dan akan segera tersedia untuk Anda.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Mengerti',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFE9458D),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9458D),
        elevation: 0,
        title: Text(
          'Parenting & Tumbuh Kembang',
          style: GoogleFonts.poppins(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Kembali',
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.question_circle, color: Colors.white),
            onPressed: () => _showFeatureComingSoon('Bantuan'),
            tooltip: 'Bantuan',
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hero Banner
                      Container(
                        height: screenHeight * 0.28,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFE9458D),
                              Color(0xCCE9458D),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Decorative circles
                            Positioned(
                              top: -30,
                              right: -30,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -50,
                              left: -20,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 40,
                              left: 20,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.05),
                                ),
                              ),
                            ),
                            
                            // Main content
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 60 : 40,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        CupertinoIcons.person_2_fill,
                                        size: isTablet ? 60 : 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Parenting & Tumbuh Kembang',
                                      style: GoogleFonts.poppins(
                                        fontSize: isTablet ? 24 : 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Pantau perkembangan si kecil dengan panduan lengkap dan milestone tracker',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: isTablet ? 16 : 14,
                                        color: Colors.white.withValues(alpha: 0.9),
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Content section
                      Padding(
                        padding: EdgeInsets.all(isTablet ? 32 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Quick stats section
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9458D).withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE9458D).withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildStatItem(
                                      icon: CupertinoIcons.chart_bar_alt_fill,
                                      title: 'Milestone',
                                      subtitle: 'Tracker',
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: const Color(0xFFE9458D).withValues(alpha: 0.2),
                                  ),
                                  Expanded(
                                    child: _buildStatItem(
                                      icon: CupertinoIcons.book_fill,
                                      title: 'Panduan',
                                      subtitle: 'Lengkap',
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: const Color(0xFFE9458D).withValues(alpha: 0.2),
                                  ),
                                  Expanded(
                                    child: _buildStatItem(
                                      icon: CupertinoIcons.heart_fill,
                                      title: 'Tips',
                                      subtitle: 'Kesehatan',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            Text(
                              'Mengapa Monitoring Tumbuh Kembang Penting?',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Benefit items
                            _buildFeatureItem(
                              icon: CupertinoIcons.eye_fill,
                              title: 'Deteksi Dini',
                              description: 'Identifikasi potensi keterlambatan perkembangan sejak dini untuk intervensi yang tepat waktu.',
                            ),
                            _buildFeatureItem(
                              icon: CupertinoIcons.graph_circle_fill,
                              title: 'Tracking Progress',
                              description: 'Pantau kemajuan perkembangan anak secara konsisten dengan milestone yang terstruktur.',
                            ),
                            _buildFeatureItem(
                              icon: CupertinoIcons.lightbulb_fill,
                              title: 'Panduan Stimulasi',
                              description: 'Dapatkan rekomendasi aktivitas dan stimulasi sesuai usia untuk optimal growth.',
                            ),
                            _buildFeatureItem(
                              icon: CupertinoIcons.doc_chart_fill,
                              title: 'Rekam Medis Digital',
                              description: 'Simpan catatan lengkap perkembangan untuk konsultasi dengan tenaga kesehatan.',
                            ),
                            
                            const SizedBox(height: 32),
                            
                            Text(
                              'Fitur Utama Aplikasi',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Feature grid
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: isTablet ? 3 : 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: isTablet ? 1.2 : 1.0,
                              children: [
                                _buildFeatureCard(
                                  icon: CupertinoIcons.calendar_badge_plus,
                                  title: 'Milestone\nTracker',
                                  description: 'Catat pencapaian milestone anak',
                                ),
                                _buildFeatureCard(
                                  icon: CupertinoIcons.chart_bar_square_fill,
                                  title: 'Growth\nChart',
                                  description: 'Grafik pertumbuhan berat & tinggi',
                                ),
                                _buildFeatureCard(
                                  icon: CupertinoIcons.camera_fill,
                                  title: 'Photo\nMemories',
                                  description: 'Album perkembangan si kecil',
                                ),
                                _buildFeatureCard(
                                  icon: CupertinoIcons.bell_fill,
                                  title: 'Smart\nReminder',
                                  description: 'Pengingat vaksin & checkup',
                                ),
                                if (isTablet) ...[
                                  _buildFeatureCard(
                                    icon: CupertinoIcons.book_circle_fill,
                                    title: 'Tips\nParenting',
                                    description: 'Panduan dari ahli',
                                  ),
                                  _buildFeatureCard(
                                    icon: CupertinoIcons.star_circle_fill,
                                    title: 'Achievement\nBadges',
                                    description: 'Reward untuk pencapaian',
                                  ),
                                ],
                              ],
                            ),
                            
                            if (!isTablet) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFeatureCard(
                                      icon: CupertinoIcons.book_circle_fill,
                                      title: 'Tips\nParenting',
                                      description: 'Panduan dari ahli',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildFeatureCard(
                                      icon: CupertinoIcons.star_circle_fill,
                                      title: 'Achievement\nBadges',
                                      description: 'Reward untuk pencapaian',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            
                            const SizedBox(height: 32),
                            
                            Text(
                              'Cara Menggunakan Aplikasi',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 20 : 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Step items
                            _buildStepItem(
                              number: '1',
                              title: 'Input Data Anak',
                              description: 'Masukkan informasi dasar anak seperti nama, tanggal lahir, dan data awal.',
                            ),
                            _buildStepItem(
                              number: '2',
                              title: 'Mulai Tracking',
                              description: 'Catat milestone, pertumbuhan, dan perkembangan anak secara berkala.',
                            ),
                            _buildStepItem(
                              number: '3',
                              title: 'Monitor Progress',
                              description: 'Lihat grafik perkembangan dan dapatkan insight tentang tumbuh kembang anak.',
                            ),
                            _buildStepItem(
                              number: '4',
                              title: 'Konsultasi Ahli',
                              description: 'Gunakan data untuk konsultasi dengan dokter anak atau ahli tumbuh kembang.',
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _navigateToParenting,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE9458D),
                                      foregroundColor: Colors.white,
                                      minimumSize: Size(double.infinity, isTablet ? 60 : 55),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 3,
                                      shadowColor: const Color(0xFFE9458D).withValues(alpha: 0.3),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(CupertinoIcons.arrow_right_circle_fill),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Mulai Tracking',
                                                style: GoogleFonts.poppins(
                                                  fontSize: isTablet ? 18 : 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Secondary button
                            OutlinedButton(
                              onPressed: () => _showFeatureComingSoon('Panduan Lengkap'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFE9458D),
                                side: const BorderSide(color: Color(0xFFE9458D)),
                                minimumSize: Size(double.infinity, isTablet ? 60 : 55),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(CupertinoIcons.book_circle),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Lihat Panduan Lengkap',
                                    style: GoogleFonts.poppins(
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Disclaimer
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    CupertinoIcons.info_circle_fill,
                                    color: Colors.orange.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Penting: Aplikasi ini adalah alat bantu pemantauan dan bukan pengganti konsultasi medis profesional. Selalu konsultasikan perkembangan anak dengan dokter anak atau ahli tumbuh kembang.',
                                      style: GoogleFonts.poppins(
                                        fontSize: isTablet ? 14 : 12,
                                        color: Colors.orange.shade800,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: isTablet ? 60 : 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFFE9458D),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE9458D).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFE9458D),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
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
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE9458D).withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE9458D).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFE9458D),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE9458D), Color(0xFFD63384)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE9458D).withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
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
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}