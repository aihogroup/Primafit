# Primafit

*Health super-app* untuk semua kalangan generasi sehat: catatan kesehatan, skrining & rekomendasi,
kesehatan wanita & keluarga, serta (roadmap) konsultasi dokter online, layanan instansi kesehatan, dan
marketplace mitra.

| Peran | Fungsi |
|---|---|
| **User** | Pasien & masyarakat umum |
| **Dokter** | Konsultasi online (terverifikasi STR/SIP) |
| **Instansi** | RS, klinik, PMR, organisasi kesehatan |
| **Mitra** | Apotek, toko skincare, fashion, gym, dll. |
| **Superadmin** | Verifikasi dokter/instansi/mitra, kelola knowledge base rekomendasi |

## Mulai cepat

```bash
flutter pub get
cp env/example.json env/dev.json        # isi key; kosongkan Supabase untuk mode offline
flutter run --dart-define-from-file=env/dev.json
```

Build APK rilis:

```bash
flutter build apk --release --dart-define-from-file=env/dev.json
```

> Windows: bila muncul `Unable to establish loopback connection`, lihat
> [ARCHITECTURE.md §7](docs/ARCHITECTURE.md#7-build-android-windows).

## Kualitas

```bash
flutter analyze --fatal-warnings --no-fatal-infos
flutter test
```

## Dokumentasi

- [Arsitektur & konvensi](docs/ARCHITECTURE.md)
- [Roadmap sprint](docs/ROADMAP.md)
- [Sprint 0: fondasi & refactor](docs/sprints/SPRINT-00.md)
- [Sprint 1: identitas & RBAC](docs/sprints/SPRINT-01.md)
- [Sprint 2: platform data & sinkronisasi](docs/sprints/SPRINT-02.md)
- Skema database: [`supabase/migrations`](supabase/migrations)
