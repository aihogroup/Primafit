import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/core/widgets/app_bottom_navigation.dart';
import 'package:flutter/rendering.dart';

// Import graph components
import 'package:primafit/features/health_record/presentation/guladarah/analisis_guladarah.dart';
import 'package:primafit/features/health_record/presentation/suhu/analisis_suhu.dart';
import 'package:primafit/features/health_record/presentation/suhu/read_suhu.dart';
import 'package:primafit/features/health_record/presentation/tensi/analisis_tensi.dart';
import 'package:primafit/features/health_record/presentation/kolesterol/analisis_kolesterol.dart';
import 'package:primafit/features/health_record/presentation/asamurat/analisis_asamurat.dart';
import 'package:primafit/features/health_record/presentation/bmi/analisis_bmi.dart';

// Import screens
import 'package:primafit/features/health_record/presentation/asamurat/read_asamurat.dart';
import 'package:primafit/features/health_record/presentation/bmi/read_bmi.dart';
import 'package:primafit/features/health_record/presentation/guladarah/read_guladarah.dart';
import 'package:primafit/features/health_record/presentation/kolesterol/read_kolesterol.dart';
import 'package:primafit/features/health_record/presentation/tensi/read_tensi.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analisa Kesehatan',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'pantau Perkembangan kesehatan anda',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverFadeTransition(
              opacity: _animationController.drive(CurveTween(curve: Curves.easeOut)),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Gula Darah Chart Card
                  FadeTransition(
                    opacity: _animationController.drive(CurveTween(curve: Curves.easeOut)),
                    child: SlideTransition(
                      position: _animationController.drive(
                        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeOut)),
                      ),
                      child: GrafikGulaDarah(
                        onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => const ReadGulaDarahScreen()),
                        ),
                      ),
                    ),
                  ),
                  
                  // Tekanan Darah Chart Card
                  FadeTransition(
                    opacity: _animationController.drive(CurveTween(curve: Curves.easeOut)),
                    child: SlideTransition(
                      position: _animationController.drive(
                        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeOut)),
                      ),
                      child: GrafikTensi(
                        onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => const ReadTensiScreen()),
                        ),
                      ),
                    ),
                  ),
                  
                  // Kolesterol Chart Card
                  FadeTransition(
                    opacity: _animationController.drive(CurveTween(curve: Curves.easeOut)),
                    child: SlideTransition(
                      position: _animationController.drive(
                        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeOut)),
                      ),
                      child: GrafikKolesterol(
                        onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => const ReadKolesterolScreen()),
                        ),
                      ),
                    ),
                  ),

                  // Suhu Chard Card
                  FadeTransition(
                    opacity: _animationController.drive(CurveTween(curve: Curves.easeOut)),
                    child: SlideTransition(
                      position: _animationController.drive(
                        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeOut)),
                      ),
                      child: GrafikSuhu(
                        onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => const ReadSuhuScreen()),
                        ),
                      ),
                    ),
                  ),
                  
                  // Asam Urat Chart Card
                  FadeTransition(
                    opacity: _animationController.drive(CurveTween(curve: Curves.easeOut)),
                    child: SlideTransition(
                      position: _animationController.drive(
                        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeOut)),
                      ),
                      child: GrafikAsamUrat(
                        onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => const ReadAsamUratScreen()),
                        ),
                      ),
                    ),
                  ),
                  
                  // BMI Chart Card
                  FadeTransition(
                    opacity: _animationController.drive(CurveTween(curve: Curves.easeOut)),
                    child: SlideTransition(
                      position: _animationController.drive(
                        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeOut)),
                      ),
                      child: GrafikBmi(
                        onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => const ReadBmiScreen()),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 100), // Extra space at bottom
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 2),
    );
  }
}

// Helper class for SliverFadeTransition
class SliverFadeTransition extends SingleChildRenderObjectWidget {
  final Animation<double> opacity;

  const SliverFadeTransition({
    super.key,
    required this.opacity,
    required Widget sliver,
  }) : super(child: sliver);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSliverFadeTransition(opacity);
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderSliverFadeTransition renderObject) {
    renderObject.opacity = opacity;
  }
}

class _RenderSliverFadeTransition extends RenderProxySliver {
  _RenderSliverFadeTransition(Animation<double> opacity) : _opacity = opacity {
    _opacity.addListener(_handleOpacityChanged);
  }

  Animation<double> _opacity;

  Animation<double> get opacity => _opacity;
  set opacity(Animation<double> value) {
    if (_opacity == value) return;
    
    _opacity.removeListener(_handleOpacityChanged);
    _opacity = value;
    _opacity.addListener(_handleOpacityChanged);
    markNeedsPaint();
  }

  void _handleOpacityChanged() {
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Skip painting when fully transparent
    if (_opacity.value <= 0.0) {
      return;
    }
    
    if (_opacity.value >= 1.0) {
      // Fully opaque - paint normally
      super.paint(context, offset);
    } else {
      // Semi-transparent - apply opacity layer
      context.pushOpacity(
        offset, 
        (_opacity.value * 255).round(), 
        super.paint,
      );
    }
  }

  @override
  void dispose() {
    _opacity.removeListener(_handleOpacityChanged);
    super.dispose();
  }
}