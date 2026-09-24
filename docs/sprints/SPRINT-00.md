# Sprint 0: Fondasi & refactor (selesai 24 Sep 2026)

**Sprint goal:** MVP yang sudah ada bisa di-build di toolchain terbaru, dengan arsitektur yang siap
menampung 5 peran dan backend Supabase, tanpa mengubah perilaku fitur yang sudah jalan.

## Kondisi awal (hasil audit)

| Temuan | Dampak |
|---|---|
| `flutter build apk` **gagal** di Flutter 3.47: Gradle 8.11 < minimum 8.14, AGP 8.7 < 8.11.1, Kotlin 1.9 < 2.2.20, `google_fonts 6.2.1` tidak kompatibel | MVP tidak bisa dirilis |
| ±140 ribu baris dalam 205 file, logika bisnis + SQL + UI bercampur di `StatefulWidget` 1.000–2.500 baris | Sulit dirawat & dites |
| 40 helper SQLite, masing-masing membuka file `.db` sendiri | Tidak ada migrasi terpusat |
| Tanpa state management; profil dimuat ulang manual di tiap layar | Data tidak sinkron antarlayar |
| API key NewsAPI hard-coded di source (2 file) | Kebocoran secret |
| `flutter_lints` salah tempat di `pubspec.yaml` → linter tidak aktif; 1.049 isu analyzer | Kualitas kode tak terjaga |
| 7 package tak terpakai; `http` & `path_provider` dipakai tapi tidak dideklarasikan | Build rapuh |
| Test bawaan (counter) tidak menguji apa pun | Tidak ada jaring pengaman |

## Yang dikerjakan

### Build & dependency
- Upgrade Gradle 8.14.3, AGP 8.13.0, Kotlin 2.2.20, Java 17, NDK 29, desugar 2.1.5.
- Signing rilis via `android/key.properties` (fallback debug key untuk MVP).
- `pubspec.yaml`: hapus 7 package tak terpakai, deklarasikan `http`/`path_provider`, tambah
  `flutter_riverpod`, `supabase_flutter`, `mocktail`; `flutter_lints` dipindah ke `dev_dependencies`.

### Arsitektur
- 202 file dipindah dari `lib/UI` + `lib/database` ke `lib/features/<fitur>/{data,presentation}`
  (16 fitur); semua import ditulis ulang otomatis.
- Lapisan baru: `app/` (bootstrap, router, role guard), `core/` (env, `Result`/`Failure`, logger,
  design tokens, state views, `ConfirmPopScope`).
- Riverpod 3 + `ProfileRepository` → `profileControllerProvider` dipakai Splash, Home, Onboarding, Profil.
- Route terpusat (`AppRoutes`) + `onGenerateRoute` + `RoleGuard` per route + halaman 404.
- Domain multi-peran: `UserRole` (5 peran), `AppSession`, `AuthRepository` (lokal & Supabase).

### Bug yang diperbaiki
| Bug | Lokasi |
|---|---|
| Tombol tambah obat crash: route `/input_obat` tidak pernah didaftarkan | `reminder/obat/obat_page.dart` |
| Filter opsi tipe tubuh memutasi list statis → opsi "Wanita" hilang setelah memilih "Pria" | `recommendation/pakaian/list_pertanyaan.dart` |
| Kunci map duplikat `secondarySkinType` → teks "Kecenderungan … ke" kosong | `skincare/jenis_kulit/list_pertanyaan_kulit.dart` |
| "Foto dokumen diubah" selalu tampil (kondisi tautologi); tombol "Hapus" tanpa aksi | `health_wallet/dokumen/edit_dokumen.dart` |
| Foto profil hilang saat cache OS dibersihkan (path cache image_picker) | `profile/data/local_profile_repository.dart` |
| 60 pemakaian `BuildContext` setelah `await` tanpa cek `mounted` (potensi crash) | 30+ layar |
| `setState` setelah halaman diganti (onboarding) | `onboarding/login.dart` |
| Import `database_Bmi.dart` salah huruf besar, gagal di Linux/macOS/CI | `health_record/bmi/read_bmi.dart` |
| `initializeDateFormatting` tidak di-`await` | `main.dart` → `bootstrap.dart` |
| Query profil SQLite tak terpakai di 4 layar grafik (dead store) | `health_record/{tensi,guladarah}` |

### Clean code
- `dart fix`: ±2.000 perbaikan otomatis (deprecated API `withOpacity`, super parameters, final locals, dll.).
- 14 `WillPopScope` (deprecated, merusak predictive back Android 14+) → `ConfirmPopScope`.
- ±1.200 baris dead code dihapus (27 method tak terpakai + turunannya, field & variabel tak terbaca).
- 43 `print` → `debugPrint`/`AppLogger`.

### Kualitas
- `analysis_options.yaml` lebih ketat; CI GitHub Actions (format → analyze → test → build APK).
- 20 test (unit + widget): `Result`, `AppSession`, `UserRole` ↔ enum SQL, `ProfileController`,
  `RoleGuard`, regresi bug fashion.

## Metrik

| Metrik | Sebelum | Sesudah |
|---|---|---|
| Build APK rilis | ❌ gagal | ✅ |
| Analyzer: error / warning | 0 / 94 | **0 / 0** |
| Analyzer: total isu (rule set lama) | 1.049 | 113 |
| Test | 1 (tidak relevan) | 20 lulus |
| Secret di source | 1 API key | 0 |

> Dengan rule set baru yang lebih ketat, tersisa ±596 *info* (terutama `avoid_dynamic_calls` akibat
> `Map<String, dynamic>` di layar lama). Semuanya dicatat sebagai tech debt dan turun per fitur
> saat dimigrasi.

## Tech debt yang sengaja ditunda

| Item | Rencana |
|---|---|
| 40 file SQLite terpisah | Sprint 2: satu DB + migrasi data |
| 24 layar `health_record` duplikat (±20 ribu baris) | Sprint 2: modul generik |
| `utility.dart` punya class `AppColors` sendiri (duplikat design token) | Sprint 2 |
| `google_fonts` mengunduh Poppins saat runtime (offline pertama gagal) | Sprint 8: bundel font di assets |
| `applicationId = com.example.primafit` (ditolak Play Store) | Sebelum rilis pertama; perlu keputusan nama paket |
| NewsAPI dipanggil dari klien | Sprint 3: proxy Edge Function |
| `dart format` global untuk kode lama | Commit terpisah agar diff logika tetap terbaca |
| Override `compileSdk = 36` untuk semua plugin di `android/build.gradle.kts` (file_picker 10.x masih android-34) | Sprint 2: upgrade `file_picker` 13.x, `flutter_local_notifications`, `share_plus` ke major terbaru lalu hapus override |
| `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=...` wajib di mesin Windows ini | Set sekali per mesin (lihat ARCHITECTURE §7) |
