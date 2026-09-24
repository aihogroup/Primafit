import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:primafit/UI/navigasi/artikel/detail_artikel.dart';
import 'package:primafit/UI/navigasi/navigation.dart';


class ArticlePage extends StatefulWidget {
  const ArticlePage({Key? key}) : super(key: key);

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> with AutomaticKeepAliveClientMixin {
  final String apiKey = "REDACTED_NEWS_API_KEY"; // Replace with your actual News API key
  bool isLoading = true;
  List<dynamic> articles = [];
  String errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://newsapi.org/v2/everything?domains=&q=kesehatan&language=&apiKey=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          articles = data['articles'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load articles: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  String formatDate(String dateString) {
    try {
      final DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Artikel',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF64D1DE),
        onRefresh: fetchArticles,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'Tambah pengetahuan anda tentang kesehatan di sini',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? _buildLoadingIndicator()
                  : errorMessage.isNotEmpty
                      ? _buildErrorView()
                      : articles.isEmpty
                          ? _buildEmptyView()
                          : _buildArticlesList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF64D1DE)),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat artikel...',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.exclamationmark_circle, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat artikel',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: GoogleFonts.poppins(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: fetchArticles,
            icon: const Icon(CupertinoIcons.refresh),
            label: Text(
              'Coba Lagi',
              style: GoogleFonts.poppins(),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64D1DE),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.news, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Tidak ada artikel',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tarik ke bawah untuk menyegarkan',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: articles.length,
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final article = articles[index];
        final title = article['title'] ?? 'Lorem ipsum dolor sit amet';
        final description = article['description'] ?? 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
        final publishedAt = article['publishedAt'] ?? DateTime.now().toIso8601String();
        final urlToImage = article['urlToImage'];
        
        return _buildArticleCard(article, title, description, publishedAt, urlToImage);
      },
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article, String title, String description, String publishedAt, String? imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailArtikelPage(article: article),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(CupertinoIcons.photo, color: Colors.grey),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(CupertinoIcons.exclamationmark_circle, color: Colors.grey),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(CupertinoIcons.photo, color: Colors.grey),
                            ),
                          ),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatDate(publishedAt),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
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