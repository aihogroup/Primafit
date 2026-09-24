import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:primafit/UI/navigasi/artikel/detail_artikel.dart';
import 'package:primafit/UI/navigasi/navigation.dart';
import 'dart:math' as math;
import 'package:primafit/database/navigasi/database_artikel.dart'; // Import database
// import 'package:share_plus/share_plus.dart';

class ArticlePage extends StatefulWidget {
  const ArticlePage({Key? key}) : super(key: key);

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final String apiKey = "REDACTED_NEWS_API_KEY"; // Replace with your actual News API key
  final ArtikelDatabase _dbHelper = ArtikelDatabase.instance;
  
  bool isLoading = true;
  List<dynamic> articles = [];
  List<dynamic> filteredArticles = [];
  List<dynamic> favoriteArticles = [];
  String errorMessage = '';
  String searchQuery = '';
  
  // Filter states
  bool showOnlyFavorites = false;
  String? selectedSource;
  SortOption selectedSortOption = SortOption.newest;
  bool isSearchActive = false;
  
  // Controllers
  late TextEditingController searchController;
  late AnimationController _animationController;
  
  // Expanded filter panel
  bool isFilterExpanded = false;
  
  @override
  bool get wantKeepAlive => true;

  @override
void initState() {
  super.initState();
  searchController = TextEditingController();
  _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  fetchArticles();
  loadFavorites();
}
  
  @override
  void dispose() {
    searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Load favorites from database
  Future<void> loadFavorites() async {
    try {
      final favorites = await _dbHelper.getAllArtikel();
      setState(() {
        favoriteArticles = favorites;
      });
      updateFilteredArticles();
    } catch (e) {
      // Handle error silently
      debugPrint('Error loading favorites: $e');
    }
  }
  
  // Check if an article is a favorite
  bool isArticleFavorite(Map<String, dynamic> article) {
    final url = article['url'];
    return favoriteArticles.any((favArticle) => favArticle['url'] == url);
  }

  Future<void> fetchArticles() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://newsapi.org/v2/everything?domains=detik.com,liputan6.com&q=kesehatan&language=&apiKey=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          articles = data['articles'];
          isLoading = false;
          updateFilteredArticles();
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

  // Update filtered articles based on filters and search
  void updateFilteredArticles() {
    List<dynamic> result = List.from(articles);
    
    // Apply source filter
    if (selectedSource != null) {
      result = result.where((article) {
        final source = article['source']?['name']?.toLowerCase() ?? '';
        return source.contains(selectedSource!.toLowerCase());
      }).toList();
    }
    
    // Apply search filter
    if (searchQuery.isNotEmpty) {
      result = result.where((article) {
        final title = article['title']?.toLowerCase() ?? '';
        final description = article['description']?.toLowerCase() ?? '';
        final content = article['content']?.toLowerCase() ?? '';
        final query = searchQuery.toLowerCase();
        return title.contains(query) || 
               description.contains(query) || 
               content.contains(query);
      }).toList();
    }
    
    // Apply favorites filter
    if (showOnlyFavorites) {
      result = result.where((article) => 
        isArticleFavorite(article)
      ).toList();
    }
    
    // Apply sort
    result.sort((a, b) {
      DateTime dateA = DateTime.parse(a['publishedAt'] ?? DateTime.now().toIso8601String());
      DateTime dateB = DateTime.parse(b['publishedAt'] ?? DateTime.now().toIso8601String());
      
      if (selectedSortOption == SortOption.newest) {
        return dateB.compareTo(dateA);
      } else {
        return dateA.compareTo(dateB);
      }
    });
    
    setState(() {
      filteredArticles = result;
    });
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Map<String, dynamic> article) async {
    if (isArticleFavorite(article)) {
      // Remove from favorites
      await _dbHelper.deleteArtikel(article['url']);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Artikel dihapus dari favorit',
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
    } else {
      // Add to favorites
      await _dbHelper.saveArtikel(article);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Artikel disimpan ke favorit',
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
    
    // Reload favorites and update UI
    await loadFavorites();
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
        title: isSearchActive 
          ? _buildSearchField()
          : Text(
              'Artikel',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
        actions: [
          // Search toggle button
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isSearchActive ? CupertinoIcons.clear : CupertinoIcons.search,
                key: ValueKey<bool>(isSearchActive),
                color: const Color(0xFF64D1DE),
              ),
            ),
            onPressed: () {
              setState(() {
                isSearchActive = !isSearchActive;
                if (!isSearchActive) {
                  searchController.clear();
                  searchQuery = '';
                  updateFilteredArticles();
                } else {
                  // Focus on search field
                  FocusScope.of(context).requestFocus(FocusNode());
                }
              });
            },
          ),
          // Filter button
          IconButton(
            icon: AnimatedBuilder(
              animation: _animationController,
              builder: (_, child) {
                return Transform.rotate(
                  angle: _animationController.value * math.pi * 2/4,
                  child: Icon(
                    CupertinoIcons.slider_horizontal_3,
                    color: const Color(0xFF64D1DE),
                  ),
                );
              },
            ),
            onPressed: () {
              setState(() {
                isFilterExpanded = !isFilterExpanded;
                if (isFilterExpanded) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF64D1DE),
        onRefresh: () async {
          await fetchArticles();
          await loadFavorites();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            if (!isSearchActive && !isFilterExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(
                  'Tambah informasi pengetahuan anda tentang kesehatan di sini',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            
            // Filter panel
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isFilterExpanded ? 180 : 0,
              curve: Curves.easeInOut,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: _buildFilterPanel(),
              ),
            ),
            
            // Results info
            if (searchQuery.isNotEmpty || selectedSource != null || showOnlyFavorites)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF64D1DE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.info_circle, size: 16, color: Color(0xFF64D1DE)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getFilterInfoText(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.clear_circled_solid, size: 16, color: Color(0xFF64D1DE)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            searchController.clear();
                            searchQuery = '';
                            selectedSource = null;
                            showOnlyFavorites = false;
                            isFilterExpanded = false;
                            _animationController.reverse();
                            updateFilteredArticles();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            
            // Content
            Expanded(
              child: isLoading
                  ? _buildLoadingIndicator()
                  : errorMessage.isNotEmpty
                      ? _buildErrorView()
                      : filteredArticles.isEmpty
                          ? _buildEmptyView()
                          : _buildArticlesList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }

  String _getFilterInfoText() {
    List<String> activeFilters = [];
    
    if (searchQuery.isNotEmpty) {
      activeFilters.add('Pencarian: "$searchQuery"');
    }
    
    if (selectedSource != null) {
      activeFilters.add('Sumber: $selectedSource');
    }
    
    if (showOnlyFavorites) {
      activeFilters.add('Hanya favorit');
    }
    
    if (selectedSortOption == SortOption.newest) {
      activeFilters.add('Urutan: Terbaru');
    } else {
      activeFilters.add('Urutan: Terlama');
    }
    
    return 'Menampilkan ${filteredArticles.length} artikel dengan ${activeFilters.join(', ')}';
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        style: GoogleFonts.poppins(fontSize: 14),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: 'Cari artikel kesehatan...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
          border: InputBorder.none,
          prefixIcon: const Icon(CupertinoIcons.search, color: Color(0xFF64D1DE)),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
            updateFilteredArticles();
          });
        },
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Artikel',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Source filter
                Expanded(
                  child: _buildSourceFilter(),
                ),
                const SizedBox(width: 12),
                // Sort order
                Expanded(
                  child: _buildSortOption(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Favorite filter
            InkWell(
              onTap: () {
                setState(() {
                  showOnlyFavorites = !showOnlyFavorites;
                  updateFilteredArticles();
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      showOnlyFavorites ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                      size: 20,
                      color: showOnlyFavorites ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tampilkan hanya artikel favorit',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: showOnlyFavorites ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Switch.adaptive(
                      value: showOnlyFavorites,
                      activeColor: const Color(0xFF64D1DE),
                      onChanged: (value) {
                        setState(() {
                          showOnlyFavorites = value;
                          updateFilteredArticles();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          icon: const Icon(CupertinoIcons.chevron_down, size: 16, color: Color(0xFF64D1DE)),
          hint: Text(
            'Sumber',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          value: selectedSource,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
          ),
          items: const [
            DropdownMenuItem<String>(
              value: 'detik.com',
              child: Text('Detik.com'),
            ),
            DropdownMenuItem<String>(
              value: 'liputan6.com',
              child: Text('Liputan6.com'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              selectedSource = value;
              updateFilteredArticles();
            });
          },
        ),
      ),
    );
  }

  Widget _buildSortOption() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          isExpanded: true,
          icon: const Icon(CupertinoIcons.chevron_down, size: 16, color: Color(0xFF64D1DE)),
          hint: Text(
            'Urutkan',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          value: selectedSortOption,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
          ),
          items: const [
            DropdownMenuItem<SortOption>(
              value: SortOption.newest,
              child: Text('Terbaru'),
            ),
            DropdownMenuItem<SortOption>(
              value: SortOption.oldest,
              child: Text('Terlama'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              selectedSortOption = value!;
              updateFilteredArticles();
            });
          },
        ),
      ),
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
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    IconData iconData;
    String title;
    String subtitle;
    
    if (showOnlyFavorites) {
      iconData = CupertinoIcons.heart;
      title = 'Tidak ada artikel favorit';
      subtitle = 'Simpan artikel ke favorit untuk melihatnya di sini';
    } else if (searchQuery.isNotEmpty) {
      iconData = CupertinoIcons.search;
      title = 'Tidak ada hasil';
      subtitle = 'Coba kata kunci pencarian lain';
    } else if (selectedSource != null) {
      iconData = CupertinoIcons.news;
      title = 'Tidak ada artikel';
      subtitle = 'Coba pilih sumber lain atau segarkan halaman';
    } else {
      iconData = CupertinoIcons.news;
      title = 'Tidak ada artikel';
      subtitle = 'Tarik ke bawah untuk menyegarkan';
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          if (searchQuery.isNotEmpty || selectedSource != null || showOnlyFavorites)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  searchController.clear();
                  searchQuery = '';
                  selectedSource = null;
                  showOnlyFavorites = false;
                  isFilterExpanded = false;
                  _animationController.reverse();
                  updateFilteredArticles();
                });
              },
              icon: const Icon(CupertinoIcons.clear),
              label: Text(
                'Hapus Filter',
                style: GoogleFonts.poppins(),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64D1DE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildArticlesList() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView.builder(
        key: ValueKey<int>(filteredArticles.length),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredArticles.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final article = filteredArticles[index];
          final title = article['title'] ?? 'Lorem ipsum dolor sit amet';
          final description = article['description'] ?? 'Lorem ipsum dolor sit amet, consectetur adipisicing elit';
          final publishedAt = article['publishedAt'] ?? DateTime.now().toIso8601String();
          final urlToImage = article['urlToImage'];
          final isFavorite = isArticleFavorite(article);
          
          return _buildArticleCard(article, title, description, publishedAt, urlToImage, isFavorite);
        },
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article, String title, String description, String publishedAt, String? imageUrl, bool isFavorite) {
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
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => DetailArtikelPage(article: article),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(position: offsetAnimation, child: child);
                },
              ),
            ).then((_) {
              // Refresh favorites when returning from detail page
              loadFavorites();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: 'article_image_${article['url'] ?? ''}',
                      child: ClipRRect(
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
                    ),
                    // Source badge
                    // Positioned(
                    //   top: 0,
                    //   left: 0,
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    //     decoration: BoxDecoration(
                    //       color: Colors.black.withOpacity(0.6),
                    //       borderRadius: const BorderRadius.only(
                    //         topLeft: Radius.circular(12),
                    //         bottomRight: Radius.circular(12),
                    //       ),
                    //     ),
                    //     child: Text(
                    //       article['source']?['name'] ?? 'Source',
                    //       style: GoogleFonts.poppins(
                    //         fontSize: 8,
                    //         color: Colors.white,
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Hero(
                              tag: 'article_title_${article['title'] ?? ''}',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          // Favorite button
                          IconButton(
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(scale: animation, child: child);
                              },
                              child: Icon(
                                isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                key: ValueKey<bool>(isFavorite),
                                size: 20,
                                color: isFavorite ? Colors.red : Colors.grey[400],
                              ),
                            ),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            onPressed: () => toggleFavorite(article),
                          ),
                        ],
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
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.time,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatDate(publishedAt),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          
                          // Add reading time estimate
                          const SizedBox(width: 12),
                          Icon(
                            CupertinoIcons.book,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getReadingTime(description),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
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
  
  // Helper to estimate reading time
  String _getReadingTime(String text) {
    // Average reading speed: ~200 words per minute
    final wordCount = text.split(' ').length;
    final minutes = (wordCount / 200).ceil();
    
    if (minutes < 1) {
      return '< 1 min';
    } else {
      return '$minutes min';
    }
  }
}

// Enum for sort options
enum SortOption {
  newest,
  oldest,
}