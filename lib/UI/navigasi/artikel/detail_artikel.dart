import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:primafit/database/navigasi/database_artikel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
// Alternatif 1, gunakan WebView (import 'package:webview_flutter/webview_flutter.dart';)
// Alternatif 2, gunakan flutter_inappwebview (import 'package:flutter_inappwebview/flutter_inappwebview.dart';)

class DetailArtikelPage extends StatefulWidget {
  final Map<String, dynamic> article;

  const DetailArtikelPage({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  State<DetailArtikelPage> createState() => _DetailArtikelPageState();
}
class _DetailArtikelPageState extends State<DetailArtikelPage> {
  bool isFavorite = false;
  bool isLoading = true;
  double scrollProgress = 0.0;
  final ScrollController _scrollController = ScrollController();
  final ArtikelDatabase _dbHelper = ArtikelDatabase.instance;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
    _checkFavoriteStatus();
    // Simulasi loading konten artikel
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

    void _updateScrollProgress() {
    if (_scrollController.position.maxScrollExtent > 0) {
      setState(() {
        scrollProgress = _scrollController.offset / _scrollController.position.maxScrollExtent;
        scrollProgress = scrollProgress.clamp(0.0, 1.0);
      });
    }
  }

    String formatDate(String dateString) {
    try {
      final DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _openArticleUrl() async {
  final url = widget.article['url'];
  print('Mencoba membuka URL: $url');
  
  if (url != null && url.isNotEmpty) {
    try {
      final Uri uri = Uri.parse(url);
      
      // Coba dengan mode inAppWebView
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppWebView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
        ),
      );
      
      if (!launched) {
        // Jika gagal, coba dengan mode platformDefault
        final bool platformLaunched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        
        if (!platformLaunched) {
          throw 'Tidak dapat membuka browser untuk URL: $url';
        }
      }
    } catch (e) {
      print('Error membuka URL: $e');
      
      // Tampilkan pesan error dan opsi untuk menyalin URL
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tidak dapat membuka browser',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Klik untuk menyalin URL artikel',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: 'Salin',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'URL disalin ke clipboard',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  } else {
    // Jika URL kosong
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'URL artikel tidak tersedia',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

  // Memeriksa status favorit artikel
  Future<void> _checkFavoriteStatus() async {
    final url = widget.article['url'];
    if (url != null) {
      final isFav = await _dbHelper.isArtikelFavorite(url);
      if (mounted) {
        setState(() {
          isFavorite = isFav;
        });
      }
    }
  }

  // Toggle favorit dengan database
  Future<void> _toggleFavorite() async {
    final article = widget.article;
    
    if (isFavorite) {
      // Hapus dari favorit
      await _dbHelper.deleteArtikel(article['url']);
      setState(() {
        isFavorite = false;
      });
    } else {
      // Tambah ke favorit
      await _dbHelper.saveArtikel(article);
      setState(() {
        isFavorite = true;
      });
    }
    
    // Tampilkan feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'Artikel disimpan ke favorit' : 'Artikel dihapus dari favorit',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF64D1DE),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _shareArticle() {
    final String title = widget.article['title'] ?? 'Artikel Kesehatan';
    final String url = widget.article['url'] ?? '';
    
    Share.share('$title\n\nBaca selengkapnya: $url', subject: title);
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan data API yang diberikan
    final String title = widget.article['title'] ?? 'Artikel tidak ditemukan';
    final String author = widget.article['author'] ?? 'Penulis tidak diketahui';
    final String publishedAt = widget.article['publishedAt'] ?? DateTime.now().toIso8601String();
    final String urlToImage = widget.article['urlToImage'] ?? '';
    final String content = widget.article['content'] ?? '';
    final String description = widget.article['description'] ?? '';
    final String source = widget.article['source']?['name'] ?? 'Sumber tidak diketahui';
    final String url = widget.article['url'] ?? '';

    // Expanded content (menggabungkan description dan content untuk tampilan yang lebih baik)
    String expandedContent = description;
    
    if (content.isNotEmpty) {
      // Menghapus "[+1468 chars]" atau sejenisnya dari akhir content
      String cleanContent = content.replaceAll(RegExp(r'\[\+\d+ chars\]'), '');
      
      if (expandedContent.isNotEmpty) {
        expandedContent += '<br><br>';
      }
      expandedContent += cleanContent;
    }

    // Tambahkan konten tambahan untuk sampel yang lebih lengkap
    if (title == "Jangan Asal, Ini Aturan Minum Obat Pereda Nyeri Biar Ginjal Nggak Rusak") {
      expandedContent += '''
<br><br>
<h2>Bahaya Konsumsi Obat Pereda Nyeri untuk Ginjal</h2>

Penggunaan obat pereda nyeri jangka panjang seperti NSAID (Non-Steroidal Anti-Inflammatory Drugs) dapat meningkatkan risiko kerusakan ginjal. Obat-obatan seperti ibuprofen, naproxen, dan aspirin bekerja dengan menghambat enzim yang menjaga aliran darah normal ke ginjal.

<h2>Aturan Minum Obat yang Aman</h2>

Berikut adalah aturan yang perlu diperhatikan saat mengonsumsi obat pereda nyeri:

1. <strong>Ikuti dosis yang dianjurkan</strong> - Jangan pernah melebihi dosis yang tertera pada kemasan atau yang diresepkan dokter.

2. <strong>Jangan konsumsi dalam jangka panjang</strong> - Batasi penggunaan obat pereda nyeri hanya saat diperlukan dan hindari penggunaan reguler lebih dari 10 hari tanpa pengawasan dokter.

3. <strong>Perhatikan efek samping</strong> - Hentikan penggunaan dan konsultasikan dengan dokter jika muncul gejala seperti pembengkakan, penurunan volume urin, atau urin berwarna gelap.

4. <strong>Kombinasi obat yang tepat</strong> - Hindari mengonsumsi lebih dari satu jenis obat pereda nyeri secara bersamaan kecuali direkomendasikan oleh dokter.

5. <strong>Perhatikan kondisi kesehatan</strong> - Jika Anda memiliki riwayat gangguan ginjal, tekanan darah tinggi, atau diabetes, konsultasikan dengan dokter sebelum mengonsumsi obat pereda nyeri.

<h2>Alternatif Obat Pereda Nyeri</h2>

Untuk mengurangi risiko kerusakan ginjal, pertimbangkan alternatif berikut:

- Kompres panas atau dingin pada area yang nyeri
- Istirahat yang cukup
- Terapi fisik
- Teknik relaksasi dan manajemen stres
- Pengobatan herbal yang aman (dengan konsultasi dokter)

"Penggunaan obat pereda nyeri harus bijak dan sesuai aturan. Jangan menganggap remeh efek sampingnya terhadap ginjal," ungkap Prof. Dr. Apt. Maksum Radji, M.Biomed., Guru Besar Farmasi Universitas Indonesia.
      ''';
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Content
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar dengan gambar di background
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFF64D1DE),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          CupertinoIcons.back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _toggleFavorite,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(scale: animation, child: child);
                            },
                            child: Icon(
                              isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                              key: ValueKey<bool>(isFavorite),
                              color: isFavorite ? Colors.red : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _shareArticle,
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            CupertinoIcons.share,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background image
                      urlToImage.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: urlToImage,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(CupertinoIcons.photo, color: Colors.grey, size: 50),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(CupertinoIcons.photo, color: Colors.grey, size: 50),
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF64D1DE).withOpacity(0.8),
                              child: const Center(
                                child: Icon(CupertinoIcons.news, color: Colors.white, size: 50),
                              ),
                            ),
                      // Gradient overlay for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Article content
              SliverToBoxAdapter(
                child: isLoading
                    ? _buildLoadingContent()
                    : _buildArticleContent(title, author, source, publishedAt, expandedContent, url),
              ),
            ],
          ),
          
          // Reading progress indicator
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: scrollProgress > 0.0 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                height: 3,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: scrollProgress,
                  child: Container(
                    color: const Color(0xFF64D1DE),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: scrollProgress > 0.3 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          mini: true,
          backgroundColor: const Color(0xFF64D1DE),
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: const Icon(CupertinoIcons.arrow_up, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer effect for title
          Container(
            height: 24,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 24,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          
          // Shimmer for metadata
          Container(
            height: 16,
            width: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 32),
          
          // Shimmer for content paragraphs
          for (int i = 0; i < 5; i++) ...[
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildArticleContent(String title, String author, String source, String publishedAt, String content, String url) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with hero animation
          Hero(
            tag: 'article_title_${widget.article['title'] ?? ''}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Author & date info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.person, size: 16, color: Color(0xFF64D1DE)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        author,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(CupertinoIcons.time, size: 16, color: Color(0xFF64D1DE)),
                    const SizedBox(width: 8),
                    Text(
                      formatDate(publishedAt),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(CupertinoIcons.link, size: 16, color: Color(0xFF64D1DE)),
                    const SizedBox(width: 8),
                    Text(
                      source,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Article content with accessibility
          Semantics(
            label: 'Isi artikel $title',
            child: Html(
              data: content,
              style: {
                'body': Style(
                  fontFamily: 'Poppins',
                  fontSize: FontSize(16),
                  lineHeight: LineHeight(1.8),
                  color: Colors.black87,
                ),
                'p': Style(
                  // margin: const EdgeInsets.only(bottom: 16),
                ),
                'h1': Style(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize(22),
                  // margin: const EdgeInsets.only(top: 24, bottom: 16),
                ),
                'h2': Style(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize(20),
                  // margin: const EdgeInsets.only(top: 20, bottom: 12),
                ),
                'li': Style(
                  // margin: const EdgeInsets.only(bottom: 8),
                ),
                'strong': Style(
                  fontWeight: FontWeight.bold,
                ),
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Baca selengkapnya button
          Center(
            child: ElevatedButton.icon(
              onPressed: _openArticleUrl,
              icon: const Icon(CupertinoIcons.arrow_right, color: Colors.white),
              label: Text(
                'Baca Selengkapnya',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64D1DE),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Footer actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                CupertinoIcons.heart,
                isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
                _toggleFavorite,
                iconColor: isFavorite ? Colors.red : null,
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                CupertinoIcons.share,
                'Bagikan artikel',
                _shareArticle,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Source attribution
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.globe, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  source,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, {Color? iconColor}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF64D1DE)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: iconColor ?? const Color(0xFF64D1DE),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64D1DE),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}