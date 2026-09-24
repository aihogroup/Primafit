import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Model untuk Item Fitur
class FeatureItem {
  final String name;
  final String imageAsset;
  final String route;
  bool isHidden;

  FeatureItem({
    required this.name,
    required this.imageAsset,
    required this.route,
    this.isHidden = false,
  });

  // Konversi dari JSON
  factory FeatureItem.fromJson(Map<String, dynamic> json) {
    return FeatureItem(
      name: json['name'] as String,
      imageAsset: json['imageAsset'] as String,
      route: json['route'] as String,
      isHidden: json['isHidden'] as bool? ?? false,
    );
  }

  // Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imageAsset': imageAsset,
      'route': route,
      'isHidden': isHidden,
    };
  }

  // Membuat salinan objek dengan modifikasi
  FeatureItem copyWith({
    String? name,
    String? imageAsset,
    String? route,
    bool? isHidden,
  }) {
    return FeatureItem(
      name: name ?? this.name,
      imageAsset: imageAsset ?? this.imageAsset,
      route: route ?? this.route,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}

// Model untuk Kategori Fitur
class CategoryData {
  final String title;
  bool isHidden;
  List<FeatureItem> items;

  CategoryData({
    required this.title,
    this.isHidden = false,
    required this.items,
  });

  // Konversi dari JSON
  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      title: json['title'] as String,
      isHidden: json['isHidden'] as bool? ?? false,
      items: (json['items'] as List)
          .map((item) => FeatureItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  // Konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isHidden': isHidden,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Membuat salinan objek dengan modifikasi
  CategoryData copyWith({
    String? title,
    bool? isHidden,
    List<FeatureItem>? items,
  }) {
    return CategoryData(
      title: title ?? this.title,
      isHidden: isHidden ?? this.isHidden,
      items: items ?? List.from(this.items),
    );
  }
}

// Database untuk menyimpan dan mengambil preferensi fitur
class FiturDatabase {
  static const String _categoriesKey = 'user_categories_preference';
  
  // Simpan kategori ke SharedPreferences
  Future<void> saveCategories(List<CategoryData> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(categories.map((cat) => cat.toJson()).toList());
      await prefs.setString(_categoriesKey, jsonData);
    } catch (e) {
      print('Error saving categories: $e');
      throw Exception('Failed to save categories');
    }
  }

  // Ambil kategori dari SharedPreferences
  Future<List<CategoryData>> getCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_categoriesKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        // Jika belum ada data, kembalikan daftar default
        return getDefaultCategories();
      }
      
      final jsonData = jsonDecode(jsonString) as List;
      return jsonData
          .map((item) => CategoryData.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error retrieving categories: $e');
      // Jika terjadi error, kembalikan daftar default
      return getDefaultCategories();
    }
  }
  
  // Reset kategori ke default
  Future<void> resetCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_categoriesKey);
    } catch (e) {
      print('Error resetting categories: $e');
      throw Exception('Failed to reset categories');
    }
  }
  
  // Mendapatkan daftar kategori default
  static List<CategoryData> getDefaultCategories() {
    return [
      CategoryData(
        title: 'Catatan Kesehatan',
        items: [
          FeatureItem(name: 'Kolesterol', imageAsset: 'fitur1', route: 'kolesterol'),
          FeatureItem(name: 'Asam Urat', imageAsset: 'fitur2', route: 'asamurat'),
          FeatureItem(name: 'Tensi', imageAsset: 'fitur3', route: 'tensi'),
          FeatureItem(name: 'BMI', imageAsset: 'fitur4', route: 'bmi'),
          FeatureItem(name: 'Gula Darah', imageAsset: 'fitur5', route: 'guladarah'),
          FeatureItem(name: 'Suhu Tubuh', imageAsset: 'suhu', route: 'suhu'),
        ],
      ),
      CategoryData(
        title: 'Diagnosa Penyakit',
        items: [
          FeatureItem(name: 'Umum', imageAsset: 'dokter', route: 'umum'),
          FeatureItem(name: 'Paru-Paru', imageAsset: 'paru', route: 'paru'),
          FeatureItem(name: 'Kulit', imageAsset: 'kulit', route: 'kulit'),
          FeatureItem(name: 'Pencernaan', imageAsset: 'pencernaan', route: 'pencernaan'),
          FeatureItem(name: 'Mental', imageAsset: 'mental', route: 'mental'),
        ],
      ),
      CategoryData(
        title: 'Analisis Resiko Kanker',
        items: [
          FeatureItem(name: 'Payudara', imageAsset: 'payudara', route: 'payudara'),
          FeatureItem(name: 'Rahim', imageAsset: 'rahim', route: 'rahim'),
          FeatureItem(name: 'Paru-Paru', imageAsset: 'paru', route: 'kankerparu'),
          FeatureItem(name: 'Usus', imageAsset: 'usus', route: 'usus'),
          FeatureItem(name: 'Hati', imageAsset: 'hati', route: 'hati'),
          FeatureItem(name: 'Prostat', imageAsset: 'prostat', route: 'prostat'),
        ],
      ),
      CategoryData(
        title: 'Rekomendasi Skincare',
        items: [
          FeatureItem(name: 'Jenis Kulit', imageAsset: 'kulit', route: 'jeniskulit'),
          FeatureItem(name: 'Facial Wash', imageAsset: 'soap', route: 'facial'),
          FeatureItem(name: 'Sunscreen', imageAsset: 'sun', route: 'sunscreen'),
          FeatureItem(name: 'Serum', imageAsset: 'pipet', route: 'serum'),
          FeatureItem(name: 'Toner', imageAsset: 'bottle', route: 'toner'),
          FeatureItem(name: 'Moisturizer', imageAsset: 'wadah', route: 'moisturizer'),
          FeatureItem(name: 'Exfoliator', imageAsset: 'bottle', route: 'toner'),
          // FeatureItem(name: 'Retinol', imageAsset: 'pipet', route: 'toner'),
          // FeatureItem(name: 'Night Cream', imageAsset: 'wadah', route: 'toner'),
          // FeatureItem(name: 'Face Mask', imageAsset: 'mask', route: 'toner'),
        ],
      ),
      // CategoryData(
      //   title: 'Olahraga',
      //   items: [
      //     FeatureItem(name: 'Lengan', imageAsset: 'lengan', route: 'lengan'),
      //     FeatureItem(name: 'Perut', imageAsset: 'perut', route: 'tangan'),
      //     FeatureItem(name: 'Pundak', imageAsset: 'pundak', route: 'pundak'),
      //     FeatureItem(name: 'Dada', imageAsset: 'dada', route: 'dada'),
      //     FeatureItem(name: 'Kaki', imageAsset: 'kaki', route: 'kaki'),
      //   ],
      // ),
      CategoryData(
        title: 'Rekomendasi lainnya',
          items: [
          FeatureItem(name: 'Makanan', imageAsset: 'makan', route: 'makanan'),
          FeatureItem(name: 'Olahraga', imageAsset: 'lengan', route: 'olahraga'),
          FeatureItem(name: 'Pakaian', imageAsset: 'pakaian', route: 'pakaian'),
        ],
      ),
      CategoryData(
        title: 'Kewanitaan',
        items: [
          FeatureItem(name: 'Menstruasi', imageAsset: 'fitur9', route: 'menstruasi'),
          FeatureItem(name: 'Testpack', imageAsset: 'janin', route: 'testpack'),
          FeatureItem(name: 'Kehamilan', imageAsset: 'hamil', route: 'kehamilan'),
          FeatureItem(name: 'Anak', imageAsset: 'baby', route: 'parenting'),
        ],
      ),
      CategoryData(
        title: 'Asisten Pengingat',
        items: [
          FeatureItem(name: 'Jadwal Obat', imageAsset: 'fitur6', route: 'obat'),
          FeatureItem(name: 'Atur Jadwal', imageAsset: 'fitur7', route: 'agenda'),
        ],
      ),
      CategoryData(
        title: 'Simpan Dokumen',
        items: [
          FeatureItem(name: 'Kartu BPJS', imageAsset: 'fitur10', route: 'bpjs'),
          FeatureItem(name: 'Kartu Vaksin', imageAsset: 'fitur11', route: 'vaksin'),
          FeatureItem(name: 'Check Up', imageAsset: 'fitur12', route: 'dokumen'),
        ],
      ),
      CategoryData(
        title: 'Temukan Lokasi',
        items: [
          FeatureItem(name: 'Rumah Sakit', imageAsset: 'fitur14', route: 'hospital'),
          FeatureItem(name: 'Apotek', imageAsset: 'fitur15', route: 'apotek'),
          FeatureItem(name: 'Ambulance', imageAsset: 'fitur16', route: 'ambulan'),
        ],
      ),
    ];
  }
}