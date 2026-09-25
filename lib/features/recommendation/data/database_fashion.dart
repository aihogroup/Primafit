import 'package:primafit/core/database/local_db.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperFashion {
  static final DatabaseHelperFashion instance = DatabaseHelperFashion._init();
  static Database? _database;

  DatabaseHelperFashion._init();

  // Fungsi untuk menambahkan data rekomendasi fashion
  Future<bool> addFashionRecommendations() async {
    try {
      final db = await database;
      
      // Check if data already exists
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM fashion_recommendations'));
      if (count != null && count > 0) {
        debugPrint('Data rekomendasi fashion sudah ada');
        return true;
      }
      
      // Contoh rekomendasi fashion untuk berbagai kategori
      final List<Map<String, dynamic>> recommendations = [
        // Rekomendasi untuk acara formal pria
        {
          'category': 'formal_pria',
          'title': 'Formal Pria',
          'top_options': 'Kemeja putih atau biru langit; Kemeja oxford solid color; Kemeja bergaris halus dengan warna netral; Kemeja hitam elegan.',
          'bottom_options': 'Celana bahan warna hitam, navy, atau abu-abu; Celana wool dengan pressing sempurna; Celana bahan dengan potongan slim fit; Celana formal dengan pleat.',
          'outer_options': 'Jas hitam atau navy; Blazer semi-formal; Vest formal yang senada dengan celana; Jas dengan pola subtle.',
          'shoes_options': 'Oxford shoes hitam; Pantofel hitam mengkilap; Brogue shoes cokelat tua untuk acara semi-formal; Derby shoes hitam.',
          'accessories_options': 'Dasi sutra solid color; Dasi dengan pola halus; Pocket square; Jam tangan dengan strap kulit; Kancing manset (cufflinks); Ikat pinggang kulit premium.',
          'styling_tips': 'Pastikan ukuran jas tepat di bahu dan tidak terlalu panjang di lengan; Kemeja harus terlihat sekitar 1-2 cm dari lengan jas; Panjang celana sebaiknya sedikit menyentuh sepatu (break); Sesuaikan warna ikat pinggang dengan sepatu; Gunakan kaos kaki yang cukup tinggi agar tidak terlihat kulit saat duduk.',
          'color_coordination': 'Warna netral (hitam, navy, abu-abu, cokelat) sebagai dasar; Aksen warna melalui dasi atau pocket square; Hindari terlalu banyak warna berbeda; Untuk warna kulit gelap, warna terang seperti putih dan pastel sangat menonjolkan; Untuk warna kulit cerah, hampir semua warna bekerja dengan baik.',
          'occasion_specific': 'Untuk pernikahan: Jas lengkap dengan dasi dan pocket square; Untuk interview kerja: Blazer atau jas dengan kemeja solid color; Untuk acara bisnis: Suit lengkap dengan dasi konservatif; Untuk gala dinner: Jas hitam atau tuxedo untuk black tie event.',
          'body_type_tips': 'Untuk postur tinggi kurus: Pilih jas dengan padding di bahu dan potongan slim fit; Untuk postur gemuk: Hindari pattern horizontal, pilih garis vertikal halus; Untuk postur pendek: Hindari celana dengan cuff, pilih potongan vertikal; Untuk postur atletis: Kebanyakan style akan terlihat baik, fokus pada kecocokan di bahu.',
          'seasonal_adaptation': 'Musim panas: Pilih bahan ringan seperti linen atau katun; Musim hujan: Bawa outer coat atau trench coat anti air; Musim dingin: Layer dengan sweater tipis di bawah jas.',
        },
        
        // Rekomendasi untuk acara casual pria
        {
          'category': 'casual_pria',
          'title': 'Casual Pria',
          'top_options': 'T-shirt polos premium; Henley shirt; Polo shirt; Kemeja casual dengan lengan digulung; Sweater rajut; Flannel shirt untuk musim yang lebih sejuk.',
          'bottom_options': 'Jeans dengan potongan slim atau straight; Chino pants dalam warna khaki, navy, atau olive; Jogger pants berbahan premium; Celana pendek chino untuk cuaca panas.',
          'outer_options': 'Bomber jacket; Denim jacket; Harrington jacket; Overshirt/shirt jacket; Hoodie premium; Sweater cardigan.',
          'shoes_options': 'Sneakers putih bersih; Desert boots; Loafers casual; Sepatu boat (boat shoes); Ankle boots untuk musim dingin.',
          'accessories_options': 'Jam tangan casual atau sporty; Gelang kulit atau manik-manik; Topi baseball atau beanie; Kacamata hitam klasik; Ikat pinggang casual.',
          'styling_tips': 'Fokus pada kenyamanan tanpa terlihat berantakan; Layer pakaian untuk tampilan lebih stylish; T-shirt dan jeans bisa jadi pilihan klasik, tapi pilih yang fit dan kualitas baik; Pastikan sepatu bersih meski casual; Untuk acara smart casual, pilih polo atau kemeja daripada t-shirt.',
          'color_coordination': 'Warna netral sebagai dasar (putih, hitam, navy, grey); Tambahkan satu atau dua warna aksen; Warna earthy (olive, camel, burgundy) sangat versatile; Sesuaikan tone warna dengan musim (warna cerah untuk musim panas, warna gelap untuk musim dingin); Pertimbangkan color blocking untuk tampilan lebih menarik.',
          'occasion_specific': 'Untuk hangout: T-shirt, jeans, dan sneakers bersih; Untuk date casual: Kemeja casual atau polo dengan chinos; Untuk smart casual: Kemeja oxford dengan chinos dan desert boots; Untuk weekend getaway: Layer t-shirt, kemeja terbuka, dan jaket ringan.',
          'body_type_tips': 'Untuk postur tinggi kurus: Layer untuk menambah volume, pilih horizontal stripes; Untuk postur gemuk: Hindari motif besar dan cerah, pilih warna solid dan potongan lurus; Untuk postur pendek: Pilih monokrom atau warna senada, hindari cut off di kaki; Untuk postur atletis: Gunakan fitted clothes untuk menonjolkan bentuk badan.',
          'seasonal_adaptation': 'Musim panas: Pilih bahan breathable seperti katun dan linen; Musim hujan: Jaket weather-resistant dan sepatu tahan air; Musim dingin: Layer dengan thermal wear, jaket tebal, atau hoodies.',
        },
        
        // Rekomendasi untuk acara formal wanita
        {
          'category': 'formal_wanita',
          'title': 'Formal Wanita',
          'top_options': 'Blouse sutra atau satin; Kemeja putih crisp; Top dengan detail elegant seperti ruffle halus; Shell top untuk di bawah blazer; Turtleneck premium untuk musim dingin.',
          'bottom_options': 'Pencil skirt; A-line skirt midi; Celana bahan high-waisted; Palazzo pants; Celana cigarette; Celana cullotes.',
          'outer_options': 'Blazer fitted; Blazer oversized; Longline vest; Cardigan structured; Cape blazer untuk tampilan statement.',
          'shoes_options': 'Pumps dengan heel 5-7 cm; Pointed toe flats; Slingback heels; Block heels; Heeled ankle boots untuk musim dingin.',
          'accessories_options': 'String pearl; Statement earrings (untuk acara malam); Structured handbag; Clutch elegant; Jam tangan slim; Scarf sutra; Belt slim.',
          'styling_tips': 'Prioritaskan potongan dan fit yang baik daripada tren; Pilih pakaian yang tidak terlalu ketat atau terlalu longgar; Investasi pada beberapa piece formal klasik yang timeless; Sesuaikan panjang rok/dress (sebaiknya di sekitar lutut untuk acara bisnis); Permainkan tekstur untuk menambah dimensi pada outfit.',
          'color_coordination': 'Warna netral (hitam, navy, beige, putih) sebagai dasar; Tambahkan satu warna statement jika diinginkan; Monochromatic look selalu elegan; Pertimbangkan warna jewel tone (emerald, ruby, sapphire) untuk acara formal malam; Untuk warna kulit gelap, warna pastel dan bright colors sangat menonjolkan; Untuk warna kulit cerah, warna deep jewel tones sangat cocok.',
          'occasion_specific': 'Untuk pernikahan: Midi dress atau combination blouse dan rok A-line; Untuk interview: Blazer dengan blouse dan pencil skirt/pants; Untuk acara bisnis: Setelan formal (pantsuit) atau sheath dress; Untuk gala: Floor-length gown atau cocktail dress.',
          'body_type_tips': 'Untuk bentuk apel: Tonjolkan kaki dan decolletage, pilih tops yang mengalir di area pinggang; Untuk bentuk pear: Highlight pinggang kecil, pilih tops dengan detail atau volume; Untuk bentuk hourglass: Accentuate pinggang dengan belt atau potongan yang fitted; Untuk bentuk rectangle: Ciptakan ilusi kurva dengan peplum tops atau detail di pinggang.',
          'seasonal_adaptation': 'Musim panas: Pilih bahan breathable seperti katun dan linen; Musim hujan: Jaket weather-resistant dan sepatu tertutup; Musim dingin: Layer blazer dengan turtleneck atau sweater tipis.',
        },
        
        // Rekomendasi untuk acara casual wanita
        {
          'category': 'casual_wanita',
          'title': 'Casual Wanita',
          'top_options': 'T-shirt polos berbahan premium; Blouse casual; Crop top (untuk younger style); Oversized shirt; Graphic tee stylish; Halter neck; Off-shoulder top.',
          'bottom_options': 'Jeans high-waisted; Mom jeans; Shorts denim; Rok midi; Rok mini A-line; Cullotes casual; Jumpsuits casual.',
          'outer_options': 'Cardigan oversize; Denim jacket; Leather jacket; Utility jacket; Blazer casual; Hoodie stylish; Shacket (shirt jacket).',
          'shoes_options': 'Sneakers putih; Flat sandals; Mules; Ankle boots; Slip-on shoes; Platform sneakers; Loafers casual.',
          'accessories_options': 'Tote bag; Crossbody bag; Mini backpack; Bucket hat; Bandana; Kacamata hitam; Beberapa layer kalung; Cincin statement; Scrunchies stylish; Anting hoop.',
          'styling_tips': 'Eksperimen dengan layering (misal: t-shirt di bawah slip dress); Ciptakan keseimbangan antara loose dan fitted pieces; French-tuck (memasukkan bagian depan atasan) untuk look yang lebih polished; Permainkan tekstur untuk menambahkan dimensi; Fokuskan pada fit yang tepat bahkan untuk pakaian oversize.',
          'color_coordination': 'Ikuti color wheel - warna berseberangan untuk kontras, warna berdekatan untuk harmoni; Tren warna pastel atau terang untuk outfit cerah; Pertimbangkan color blocking; Gunakan warna netral sebagai dasar dan tambahkan pop of color; Sesuaikan dengan warna kulit: warna hangat untuk undertone kuning, warna dingin untuk undertone pink.',
          'occasion_specific': 'Untuk brunch: Rok midi dengan blouse casual dan flat sandals; Untuk shopping: Jeans, t-shirt, dan sneakers nyaman; Untuk movie date: Jeans, atasan cute, dan cardigan; Untuk piknik: Dress casual atau rok dengan t-shirt.',
          'body_type_tips': 'Untuk bentuk apel: Pilih tops yang mengalir melewati pinggang dan tonjolkan kaki; Untuk bentuk pear: Gunakan atasan dengan detail dan volume, bottoms yang simpel; Untuk bentuk hourglass: High-waisted bottoms sangat cocok; Untuk bentuk rectangle: Gunakan belt untuk menekankan pinggang.',
          'seasonal_adaptation': 'Musim panas: Dresses ringan, rok, shorts dengan atasan breathable; Musim hujan: Layer dengan outer waterproof dan pilih sepatu tertutup; Musim dingin: Sweater chunky, boots, dan jaket tebal.',
        },
        
        // Rekomendasi untuk acara semi-formal pria
        {
          'category': 'semiformal_pria',
          'title': 'Semi-Formal Pria',
          'top_options': 'Kemeja oxford button-down; Kemeja dress tanpa dasi; Polo premium; Kemeja dengan pattern subtle; Turtleneck premium (untuk musim dingin).',
          'bottom_options': 'Chinos premium; Celana bahan casual (tanpa pleat); Jeans dark wash (tanpa distressed elements); Celana wool casual; Celana linen untuk iklim panas.',
          'outer_options': 'Blazer non-structured; Sports jacket; Pullover V-neck; Cardigan premium; Vest casual; Jaket harrington.',
          'shoes_options': 'Loafers kulit; Desert boots; Chelsea boots; Sepatu kulit casual; Brogues casual; Driving moccasins.',
          'accessories_options': 'Jam tangan dressy-casual; Ikat pinggang kulit premium; Pocket square (untuk dengan blazer); Gelang kulit sederhana; Syal untuk musim dingin.',
          'styling_tips': 'Balans antara formal dan casual (misal: blazer dengan jeans atau kemeja formal dengan chinos); Tidak perlu dasi tapi outfit tetap rapi; Pastikan semua pakaian well-fitted; Sepatu harus bersih dan terawat; Permainan tekstur bisa menambah dimensi outfit.',
          'color_coordination': 'Mix warna netral dengan satu atau dua warna yang lebih bold; Navy dan burgundy adalah pilihan warna yang sangat versatile; Warna earth tone bekerja sangat baik untuk busana semi-formal; Pertimbangkan subtle patterns seperti windowpane atau houndstooth; Untuk kontras yang bagus, padukan warna gelap dan terang.',
          'occasion_specific': 'Untuk dinner: Blazer dengan kemeja tanpa dasi; Untuk acara keluarga: Sports jacket dengan chinos; Untuk pertemuan sosial: Kemeja premium dan celana wool; Untuk museum/gallery visit: Turtle neck dengan blazer; Untuk date night: Smart casual outfit dengan detail menarik.',
          'body_type_tips': 'Untuk postur tinggi kurus: Pilih pakaian dengan detail dan texture untuk menambah volume; Untuk postur gemuk: Pilih warna solid dan vertikal lines; Untuk postur pendek: Jaga warna senada dari atas ke bawah; Untuk postur atletis: Kemeja dan blazer fitted untuk menonjolkan bentuk badan.',
          'seasonal_adaptation': 'Musim panas: Linen blazer dengan celana ringan; Musim hujan: Jaket water-resistant dan sepatu kulit; Musim dingin: Layer dengan sweater fine-knit di bawah blazer.',
        },
        
        // Rekomendasi untuk acara semi-formal wanita
        {
          'category': 'semiformal_wanita',
          'title': 'Semi-Formal Wanita',
          'top_options': 'Blouse elegan; Kemeja silk; Sweater fine-knit; Halter top elegan; Shell top; Wrap top; Peplum top.',
          'bottom_options': 'A-line skirt; Pleated skirt midi; Tailored trousers; Palazzo pants; Cullottes dressy; Pencil skirt casual; Wrap skirt.',
          'outer_options': 'Blazer casual; Cardigan structured; Bolero jacket; Kimono dressy; Cape lightweight; Duster coat.',
          'shoes_options': 'Low heels; Kitten heels; Slingbacks; Mules elegan; Block heels; Flat pointed shoes; Heeled sandals.',
          'accessories_options': 'Structured handbag medium; Clutch casual; Statement necklace; Drop earrings; Jam tangan slim; Bracelet sederhana; Scarf premium.',
          'styling_tips': 'Balans antara satu item statement dengan basic pieces; Pilih pakaian yang tidak terlalu sexy atau terlalu casual; Aksesoris bisa mengubah look dari day to night; Pastikan grooming rapi (rambut, makeup natural); Permainan tekstur (satin, lace, knit) menambah dimensi.',
          'color_coordination': 'Kombinasi warna netral dengan satu pop of color; Colorblocking dengan warna yang complementary; Prints subtle seperti polka dots kecil atau floral halus; Pertimbangkan monochromatic look dengan permainan tekstur; Pilih warna berdasarkan season (jewel tones untuk musim dingin, pastels untuk musim semi).',
          'occasion_specific': 'Untuk dinner: Midi dress atau blouse dengan skirt midi; Untuk gallery opening: Tampilan artsy dengan separates unik; Untuk acara keluarga: Dressy pants dengan blouse elegan; Untuk cocktail casual: Dress knee-length atau jumpsuit elegan; Untuk pertemuan sosial: Mix statement piece dengan basics.',
          'body_type_tips': 'Untuk bentuk apel: Fokus pada atasan flowy dan rok/celana slim; Untuk bentuk pear: Tonjolkan pinggang dengan fitted tops dan A-line skirts; Untuk bentuk hourglass: Wrap dresses atau apapun yang mengaksentuasi pinggang; Untuk bentuk rectangle: Busana dengan ruffle, peplum, atau detail yang menciptakan kurva.',
          'seasonal_adaptation': 'Musim panas: Fabrics ringan seperti chiffon dan cotton-silk blend; Musim hujan: Layer dengan cardigan dan sepatu tertutup; Musim dingin: Sweater dress atau sweater dengan rok midi dan tights.',
        },
        
        // Rekomendasi untuk acara formal gender-neutral
        {
          'category': 'formal_neutral',
          'title': 'Formal Gender-Neutral',
          'top_options': 'Kemeja button-up putih crisp; Turtleneck premium; Blouse minimalist; Kemeja dengan potongan straight; Tunic shirt with mandarin collar.',
          'bottom_options': 'Tailored trousers; Wide-leg pants; Straight cut pants; Ankle-length formal pants; High-waisted tailored pants.',
          'outer_options': 'Blazer structured; Long-line blazer; Tailored vest; Structured coat; Minimalist suit jacket.',
          'shoes_options': 'Oxford shoes; Brogues; Loafers formal; Block heel boots; Minimal leather shoes; Derby shoes.',
          'accessories_options': 'Slim watch; Minimalist jewelry; Pocket square; Structured portfolio/bag; Silk scarf; Minimal tie; Suspenders.',
          'styling_tips': 'Fokus pada clean lines dan struktur yang baik; Fit adalah kunci utama - tidak terlalu longgar atau terlalu ketat; Pilih high quality pieces dengan detail minimal; Mainkan dengan proporsi (crop, oversize, longline); Layering dengan pieces yang structured.',
          'color_coordination': 'Palette monokrom (hitam, putih, abu-abu); Warna netral seperti navy, olive, dan camel; Minimalisir pattern, utamakan color blocking; Kontras halus dengan tone-on-tone styling; Aksen warna bisa melalui aksesoris kecil.',
          'occasion_specific': 'Untuk business setting: Full suit atau blazer dengan tailored pants; Untuk formal dinner: Structured ensemble dengan sentuhan formal; Untuk wedding: Elevated tailoring dengan detail subtle; Untuk creative formal: Experimental shapes dengan basic colors; Untuk interview: Clean professional look.',
          'body_type_tips': 'Untuk semua body types: Fokus pada potongan yang terstruktur tapi tidak restricting; Tailoring bisa disesuaikan untuk membuat proporsi yang balanced; Permainan layer bisa menyamarkan area yang tidak diinginkan; Aksen di area yang ingin ditonjolkan.',
          'seasonal_adaptation': 'Musim panas: Lighter fabrics seperti tropical wool dan linen; Musim hujan: Water-resistant outer layers; Musim dingin: Woolen pieces dan structured layering.',
        },
        
        // Rekomendasi untuk acara casual gender-neutral
        {
          'category': 'casual_neutral',
          'title': 'Casual Gender-Neutral',
          'top_options': 'Oversized t-shirt premium; Boxy cut shirt; Button-up shirt relaxed; Henley top; Crewneck sweater; Turtleneck casual; Loose-fit tank top.',
          'bottom_options': 'Straight leg jeans; High-waisted pants; Cargo pants updated; Relaxed cotton pants; Drawstring pants premium; Shorts bermuda; Utility pants.',
          'outer_options': 'Denim jacket; Bomber jacket; Utility jacket; Cardigan oversize; Hoodie premium; Shacket; Unstructured blazer.',
          'shoes_options': 'Minimal sneakers; Canvas shoes; Combat boots modernized; Chunky derby shoes; Slide sandals premium; High-top sneakers; Ankle boots.',
          'accessories_options': 'Tote bag canvas; Backpack minimalist; Bucket hat; Beanie; Bandana; Waist bag (fanny pack); Digital watch; Statement socks; Enamel pins.',
          'styling_tips': 'Bermain dengan siluet oversized dan fitted; Mix high and low pieces untuk tampilan effortless; Eksperimen dengan proporsi non-tradisional; Layer pieces dengan panjang berbeda; French tuck untuk menambah struktur pada outfit loose.',
          'color_coordination': 'Warna netral sebagai dasar (hitam, putih, beige, navy); Tambahkan warna desaturated seperti rust, sage, atau dusty blue; Eksperimen dengan tonal dressing (satu warna dengan berbagai tone); Pattern yang gender-neutral seperti stripes, checks, atau abstract prints; Color blocking dengan warna complementary.',
          'occasion_specific': 'Untuk hangout: Loose jeans dengan oversized tee dan sneakers; Untuk creative space: Pattern mixing dengan siluet modern; Untuk weekend: Utility style dengan comfortable footwear; Untuk casual dinner: Elevated basics dengan aksesoris statement; Untuk travel: Practical layering dengan fabrics comfortable.',
          'body_type_tips': 'Untuk semua body types: Focus pada proportional balance; Belt atau tucking bisa define waistline jika diinginkan; Layering bisa memberikan visual interest dan structure; Pilih focal points yang menonjolkan fitur favorit.',
          'seasonal_adaptation': 'Musim panas: Lightweight fabrics natural seperti linen dan cotton; Musim hujan: Functional outerwear dengan design modern; Musim dingin: Strategic layering tanpa mengorbankan style.',
        },
      ];
      
      // Gunakan batch untuk performa lebih baik
      final Batch batch = db.batch();
      for (var rec in recommendations) {
        batch.insert('fashion_recommendations', rec);
      }
      
      await batch.commit(noResult: true);
      debugPrint('Rekomendasi fashion berhasil ditambahkan');
      return true;
    } catch (e) {
      debugPrint('Error menambahkan rekomendasi fashion: $e');
      return false;
    }
  }

  Future<Database> get database async {
    if (_database?.isOpen ?? false) return _database!;
    _database = await _initDB('fashion_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await LocalDb.open(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Tabel untuk menyimpan jawaban user untuk analisis rekomendasi fashion
    await db.execute('''
    CREATE TABLE user_answers_fashion (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      gender TEXT,
      age_group TEXT,
      style_preference TEXT,
      event_type TEXT,
      color_preference TEXT,
      body_type TEXT,
      height TEXT,
      preferred_fit TEXT,
      season TEXT,
      budget TEXT,
      style_icons TEXT,
      fashion_challenges TEXT,
      created_at TEXT
    )
    ''');
    
    // Tabel untuk menyimpan hasil analisis fashion
    await db.execute('''
    CREATE TABLE fashion_analysis_results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_answer_id INTEGER,
      main_category TEXT NOT NULL,
      secondary_category TEXT,
      color_palette TEXT,
      style_direction TEXT,
      created_at TEXT,
      FOREIGN KEY (user_answer_id) REFERENCES user_answers_fashion (id)
    )
    ''');
    
    // Tabel untuk rekomendasi fashion berdasarkan kategori
    await db.execute('''
    CREATE TABLE fashion_recommendations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category TEXT UNIQUE NOT NULL,
      title TEXT,
      top_options TEXT,
      bottom_options TEXT,
      outer_options TEXT,
      shoes_options TEXT,
      accessories_options TEXT,
      styling_tips TEXT,
      color_coordination TEXT,
      occasion_specific TEXT,
      body_type_tips TEXT,
      seasonal_adaptation TEXT
    )
    ''');
  }

  // Fungsi untuk menyimpan jawaban user
  Future<int> saveUserAnswers(Map<String, dynamic> answers) async {
    final db = await database;
    
    try {
      // Normalisasi jawaban
      final Map<String, dynamic> normalizedAnswers = {...answers};
      
      // Tambahkan timestamp
      normalizedAnswers['created_at'] = DateTime.now().toIso8601String();
      
      // Gunakan transaksi untuk operasi atomik
      int insertId = 0;
      await db.transaction((txn) async {
        // Simpan jawaban baru
        insertId = await txn.insert('user_answers_fashion', normalizedAnswers);
      });
      
      debugPrint('Jawaban user untuk analisis fashion berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan jawaban user analisis fashion: $e');
      rethrow;
    }
  }

  // Fungsi untuk menyimpan hasil analisis fashion
  Future<int> saveAnalysisResult(int userAnswerId, Map<String, dynamic> result) async {
    final db = await database;
    
    try {
      final Map<String, dynamic> resultData = {
        'user_answer_id': userAnswerId,
        'main_category': result['mainCategory'],
        'secondary_category': result['secondaryCategory'],
        'color_palette': result['colorPalette'],
        'style_direction': result['styleDirection'],
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final int insertId = await db.insert('fashion_analysis_results', resultData);
      debugPrint('Hasil analisis fashion berhasil disimpan dengan ID: $insertId');
      
      return insertId;
    } catch (e) {
      debugPrint('Error menyimpan hasil analisis fashion: $e');
      rethrow;
    }
  }

  // Fungsi untuk mendapatkan rekomendasi fashion berdasarkan kategori
  Future<Map<String, dynamic>?> getRecommendationByCategory(String category) async {
    final db = await database;
    
    try {
      // Pastikan tabel rekomendasi tidak kosong
      await addFashionRecommendations();
      
      final List<Map<String, dynamic>> results = await db.query(
        'fashion_recommendations',
        where: 'category = ?',
        whereArgs: [category],
      );
      
      if (results.isEmpty) {
        // Jika tidak ditemukan rekomendasi spesifik, kembalikan rekomendasi untuk casual gender-neutral
        return (await db.query(
          'fashion_recommendations',
          where: 'category = ?',
          whereArgs: ['casual_neutral'],
        )).first;
      }
      
      return results.first;
    } catch (e) {
      debugPrint('Error mendapatkan rekomendasi fashion: $e');
      return null;
    }
  }

  // Fungsi untuk mendapatkan hasil analisis fashion terbaru
  Future<Map<String, dynamic>?> getLatestAnalysisResult() async {
    final db = await database;
    
    try {
      // Ambil hasil analisis terbaru
      final List<Map<String, dynamic>> analysisResults = await db.query(
        'fashion_analysis_results',
        orderBy: 'created_at DESC',
        limit: 1
      );
      
      if (analysisResults.isEmpty) {
        return null;
      }
      
      final analysis = analysisResults.first;
      final String mainCategory = analysis['main_category'];
      
      // Ambil rekomendasi fashion berdasarkan kategori
      final recommendation = await getRecommendationByCategory(mainCategory);
      
      return {
        'analysis': analysis,
        'recommendation': recommendation,
      };
    } catch (e) {
      debugPrint('Error mendapatkan hasil analisis fashion terbaru: $e');
      return null;
    }
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}