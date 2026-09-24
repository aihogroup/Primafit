# Arsitektur Primafit

Primafit adalah *health super-app* dengan 5 peran: **User**, **Dokter**, **Instansi**, **Mitra**, dan
**Superadmin**. Dokumen ini adalah acuan struktur kode, aturan dependensi, dan konvensi yang wajib
diikuti setiap kontribusi.

## 1. Tech stack

| Lapisan | Pilihan | Alasan |
|---|---|---|
| UI | Flutter 3.47 (Material 3) | Satu codebase Android/iOS/Web (admin console) |
| State management | **Riverpod 3** (`flutter_riverpod`) | Compile-safe DI, mudah di-*override* untuk test, tanpa `BuildContext` |
| Backend | **Supabase** (Postgres 17, Auth, Storage, Realtime, Edge Functions) | RLS sebagai lapisan otorisasi utama |
| Lokal | SQLite (`sqflite`) | Mode offline & cache |
| CI | GitHub Actions | `analyze` → `test` → `build apk` |

## 2. Struktur folder (feature-first + clean architecture)

```
lib/
├── main.dart                  # hanya memanggil bootstrap()
├── app/
│   ├── bootstrap.dart         # urutan init: error handler → intl → Supabase → ProviderScope
│   ├── app.dart               # MaterialApp + theme
│   └── router/
│       ├── app_routes.dart    # SEMUA nama route (konstanta)
│       └── app_router.dart    # tabel route + role guard per route
├── core/                      # lintas fitur, TIDAK boleh import dari features/
│   ├── config/env.dart        # konfigurasi via --dart-define
│   ├── error/                 # Failure (sealed) + Result<T> + guard()
│   ├── logging/app_logger.dart
│   ├── theme/                 # design tokens: warna, spacing, radius, ThemeData
│   └── widgets/               # state views (loading/empty/error), bottom nav, ConfirmPopScope
└── features/<fitur>/
    ├── domain/                # entity + interface repository (Dart murni, tanpa Flutter/SQL)
    ├── data/                  # implementasi repository (SQLite / Supabase)
    └── presentation/          # halaman, widget, providers (Riverpod)
```

Fitur saat ini: `auth`, `profile`, `onboarding`, `home`, `analytics`, `article`, `health_record`,
`diagnosis`, `cancer_screening`, `women_health`, `reminder`, `recommendation`, `skincare`,
`health_wallet`, `nearby`, `symptom_history`.

### Aturan dependensi

```
presentation ──▶ domain ◀── data
      │                       │
      └───────▶ core ◀────────┘
```

- `domain` tidak boleh import `data`, `presentation`, Flutter UI, `sqflite`, atau `supabase`.
- `presentation` hanya bicara ke `domain` melalui provider; **tidak ada** `XxxDatabaseHelper()` di widget
  baru.
- Antar-fitur hanya lewat `domain` fitur lain (mis. `home` membaca `profileControllerProvider`).

## 3. Pola state management (contoh referensi: `features/profile`)

```dart
// 1. Interface di domain
abstract interface class ProfileRepository {
  Future<Result<UserProfile?>> getProfile();
  Future<Result<UserProfile>> saveProfile(UserProfile profile);
}

// 2. Provider repository (mudah di-override saat test)
final profileRepositoryProvider = Provider<ProfileRepository>(...);

// 3. AsyncNotifier sebagai single source of truth
final profileControllerProvider = AsyncNotifierProvider<ProfileController, UserProfile?>(...);

// 4. UI
final profile = ref.watch(profileControllerProvider).value;
```

Aturan:
- State **immutable** (`@immutable`, `copyWith`).
- Repository mengembalikan `Result<T>`, bukan melempar exception mentah; pesan `Failure` aman
  ditampilkan ke pengguna (Bahasa Indonesia).
- Gunakan `AsyncValueView` / `AppLoadingView` / `AppEmptyView` / `AppErrorView` untuk state standar.
- Setelah `await`, selalu cek `mounted` (State) atau `context.mounted` sebelum memakai `context`.

## 4. Role & otorisasi

- `UserRole` (Dart) ↔ enum Postgres `public.app_role`. Kesesuaiannya dijaga oleh
  `test/features/auth/user_role_test.dart`.
- Satu akun bisa punya banyak peran (dokter juga user). `AppSession.activeRole` menentukan shell.
- **Penegakan akses yang sebenarnya ada di RLS Supabase.** `RoleGuard` di klien hanya untuk UX.
- Peran profesional (dokter/instansi/mitra) diberikan otomatis oleh trigger `guard_verification`
  ketika Superadmin menyetujui verifikasi; setiap perubahan status tercatat di `audit_logs`.

## 5. Konfigurasi & secret

```bash
cp env/example.json env/dev.json   # isi nilainya; env/*.json di-gitignore
flutter run --dart-define-from-file=env/dev.json
```

| Key | Keterangan |
|---|---|
| `APP_ENV` | `dev` / `staging` / `prod` |
| `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` | Kosong = mode offline (perilaku MVP) |
| `NEWS_API_KEY` | Sementara; akan dipindah ke Edge Function (key di APK bisa diekstrak) |

## 6. Database & migrasi

- Migrasi berversi di `supabase/migrations/<timestamp>_<nama>.sql`; rollback di `supabase/rollbacks/`
  (sengaja di luar folder migrations agar tidak ikut dieksekusi).
- Setiap tabel baru **wajib**: PK, FK + index FK, `NOT NULL`/`CHECK` yang relevan, `created_at`/`updated_at`,
  RLS aktif + policy eksplisit, fungsi `SECURITY DEFINER` dengan `search_path = ''`.

## 7. Build Android (Windows)

Nama user Windows yang mengandung spasi/titik membuat JDK gagal membuat Unix-domain socket
(`Unable to establish loopback connection`). Set sekali di environment user:

```bash
setx JAVA_TOOL_OPTIONS "-Djdk.net.unixdomain.tmpdir=C:/Users/Public"
```

Lalu:

```bash
flutter build apk --release --dart-define-from-file=env/dev.json
```

Signing rilis dibaca dari `android/key.properties` (tidak di-commit); tanpa file itu build memakai
debug key (hanya untuk MVP/internal testing).

## 8. Definition of Done (setiap story)

- [ ] `flutter analyze --fatal-warnings --no-fatal-infos` lulus
- [ ] Unit/widget test untuk logika baru; `flutter test` hijau
- [ ] Tidak ada secret/hard-coded key; tidak ada `print`
- [ ] Loading, empty, error (+retry) state ditangani
- [ ] Semua akses data lewat repository; tabel baru ber-RLS
- [ ] Teks UI Bahasa Indonesia, touch target ≥ 48dp, kontras WCAG AA
- [ ] Code review 1 reviewer
