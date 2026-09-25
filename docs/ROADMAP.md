# Roadmap Primafit Super-App

Sprint = 2 minggu. Item **Wajib** dari *Istilah Pengembangan Aplikasi* (sheet FRONTEND, API, BACKEND,
DATABASE, SERVICE, UIUX) masuk ke *Definition of Done* sejak Sprint 1. Sprint 8 adalah audit penuh
terhadap standar itu dan penutupan celah yang tersisa, bukan satu-satunya tempat standar diterapkan.

| Sprint | Tema | Peran | Output utama |
|---|---|---|---|
| **0** ✅ | Fondasi & refactor | — | Toolchain, arsitektur feature-first, Riverpod, router + role guard, bug fix, test, CI, APK |
| **1** ✅ | Identitas & RBAC | Semua | Supabase Auth, 5 peran, registrasi & verifikasi profesional, audit log (kode selesai; menunggu uji perangkat) |
| **2** 🔄 | Platform data & sinkronisasi | User | ✅ Isolasi data per akun (40 database) + sinkronisasi 6 catatan kesehatan · 🔜 modul lain, Storage file, modul generik |
| 3 | Knowledge base & mesin rekomendasi | Superadmin, User | Aturan CSV → tabel `kb_*` berversi, CMS Superadmin, inferensi via Edge Function |
| 4 | Telemedisin | Dokter, User | Jadwal & ketersediaan dokter, booking, chat realtime, catatan konsultasi, notifikasi FCM |
| 5 | Layanan instansi | Instansi, User | Dashboard instansi, katalog layanan (MCU, vaksin, donor darah PMR), antrean, fasilitas terdekat dari data sendiri |
| 6 | Marketplace mitra | Mitra, User | Toko & katalog produk, promosi, hasil rekomendasi → produk, order, payment gateway (webhook idempoten) |
| 7 | Konsol Superadmin & analitik | Superadmin | Dashboard web, moderasi, laporan, feature flag, analytics |
| 8 | Hardening standar Backend & Frontend | Semua | Audit penuh checklist Wajib + rilis Play Store |

## Sprint 0: Fondasi & refactor ✅ (selesai 24 Sep 2026)

Lihat [sprints/SPRINT-00.md](sprints/SPRINT-00.md).

## Sprint 1: Identitas & RBAC ✅ (kode selesai 24 Sep 2026; menunggu uji perangkat)

Lihat [sprints/SPRINT-01.md](sprints/SPRINT-01.md).

## Sprint 2: Platform data & sinkronisasi 🔄

Lihat [sprints/SPRINT-02.md](sprints/SPRINT-02.md). Selesai: isolasi per akun + sync 6 catatan
kesehatan. Sisa (Sprint 2b):

- ~~Satu database lokal~~ → diganti pendekatan per akun: 40 file tetap, tetapi terisolasi per akun
  lewat `LocalDb` (lebih aman tanpa migrasi skema besar).
- Modul `health_record` generik: 6 metrik (kolesterol, gula darah, asam urat, tensi, BMI, suhu) memakai
  1 set layar + konfigurasi, bukan 24 file duplikat (±20 ribu baris).
- Tabel `health_records`, `medications`, `agendas`, `documents` ber-RLS (pemilik saja + dokter yang
  diberi *consent*).
- Supabase Storage bucket privat + signed URL; enkripsi kolom PII sensitif.
- Sinkronisasi offline-first: antrean tulis lokal, *idempotency key*, resolusi konflik `updated_at`.

## Sprint 3: Knowledge base & mesin rekomendasi

- Skema `kb_diseases`, `kb_symptoms`, `kb_rules` (bobot), `kb_versions` (publish/rollback).
- CMS Superadmin untuk data "mesin pembelajaran": tambah/ubah aturan, uji coba sebelum publish.
- Edge Function `diagnose` dan `recommend`; klien hanya mengirim jawaban.
- Disclaimer medis & log hasil untuk evaluasi akurasi.

## Sprint 4: Telemedisin (Dokter)

- Profil publik dokter terverifikasi, spesialisasi, tarif, jadwal praktik.
- Booking + status (requested → confirmed → ongoing → done/cancelled) dengan *optimistic locking*.
- Chat realtime (Supabase Realtime) + lampiran; catatan konsultasi & rujukan.
- Akses rekam kesehatan pasien hanya dengan *consent* eksplisit berbatas waktu.

## Sprint 5: Layanan instansi (RS, PMR, organisasi kesehatan)

- Dashboard instansi, anggota staf (multi-user per instansi).
- Katalog layanan & event (vaksinasi massal, donor darah, penyuluhan), pendaftaran & kuota.
- Fitur "Temukan" (RS/apotek/ambulans) memakai data instansi terverifikasi + geolokasi.

## Sprint 6: Marketplace mitra

- Toko mitra (apotek, skincare, fashion, gym), katalog, stok, promosi berbayar.
- Rekomendasi skincare/olahraga/fashion menautkan produk mitra yang relevan.
- Keranjang, order, payment gateway (Midtrans/Xendit) via Edge Function + webhook idempoten + retry.

## Sprint 7: Konsol Superadmin & analitik

- Flutter Web admin: antrean verifikasi, manajemen user/peran, moderasi konten & produk.
- Laporan: registrasi, konsultasi, GMV, retensi. Feature flag. Google Analytics.

## Sprint 8: Hardening standar Backend & Frontend (sprint terakhir)

Audit dan penutupan seluruh item **Wajib** yang relevan:

- **Keamanan:** MFA, account lockout, secure password policy, rate limiting & throttling di Edge
  Functions, token rotation, dependency vulnerability scanning, security testing / pentest,
  OWASP (injection, BOLA, SSRF, XSS).
- **API/Backend:** OpenAPI spec untuk Edge Functions, API versioning, standard response & error code,
  global exception handler, pagination kursor, idempotent write, health check, structured logging.
- **Database:** audit index (under/over-index), query profiling, backup + PITR + restore testing,
  data dictionary & ERD, retention policy.
- **Frontend/UIUX:** WCAG AA (semantics, kontras, text scaling), skeleton loading, lazy loading &
  caching gambar, offline state, i18n (ARB), design system lengkap, bundle font lokal.
- **Observability:** Sentry (crash + performance), monitoring & alert.
- **Delivery:** signing rilis, Play Store internal → closed → production, rollback strategy.
- **Kepatuhan:** UU PDP (consent, privacy notice, ekspor & hapus data pengguna).
