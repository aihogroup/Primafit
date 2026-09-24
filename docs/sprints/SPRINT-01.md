# Sprint 1: Identitas & RBAC

**Periode:** 25 Sep – 8 Okt 2026 (2 minggu)
**Sprint goal:** Setiap orang bisa mendaftar dan masuk dengan akun Supabase, lalu mengajukan diri
sebagai Dokter, Instansi, atau Mitra. Superadmin bisa memverifikasi pengajuan, dan peran langsung
aktif. Pengguna MVP lama tidak kehilangan data.

**Kapasitas:** 34 story point (SP)

## Backlog

| ID | User story | SP | Status |
|---|---|---|---|
| S1-01 | Sebagai tim, kami butuh project Supabase `dev` & `staging` dengan migrasi berversi | 2 | ⏳ perlu keputusan (biaya) |
| S1-02 | Skema identitas & RBAC (profiles, user_roles, doctor_profiles, institutions, partners, audit_logs) + RLS | 5 | ✅ migrasi ditulis & ditinjau; belum di-apply |
| S1-03 | Domain & data layer auth (`UserRole`, `AppSession`, `AuthRepository`, Supabase + lokal) | 3 | ✅ |
| S1-04 | Sebagai pengguna, saya bisa daftar dengan email + kata sandi dan verifikasi email | 5 | 🔜 |
| S1-05 | Sebagai pengguna, saya bisa masuk, keluar, dan reset kata sandi | 3 | 🔜 |
| S1-06 | Sebagai pengguna MVP lama, profil lokal saya dipindah ke akun baru saat pertama login | 3 | 🔜 |
| S1-07 | Sebagai dokter, saya bisa mengajukan verifikasi (STR, SIP, spesialisasi, unggah dokumen) | 5 | 🔜 |
| S1-08 | Sebagai instansi/mitra, saya bisa mendaftarkan organisasi (izin/NIB, alamat, kategori) | 3 | 🔜 |
| S1-09 | Sebagai superadmin, saya melihat antrean verifikasi dan bisa approve/reject dengan catatan | 5 | 🔜 |
| S1-10 | Sebagai pengguna multi-peran, saya bisa beralih peran aktif (role switcher) | 2 | 🔜 |

### Acceptance criteria utama

**S1-02 Skema (selesai):** `supabase/migrations/20260924000100_identity_rbac.sql`
- [x] Enum `app_role` = `user, doctor, institution, partner, superadmin` (disinkronkan dengan Dart lewat test)
- [x] Akun baru otomatis mendapat profil + peran `user` (trigger `handle_new_user`)
- [x] Pendaftaran profesional selalu `pending`, apa pun payload klien (trigger `force_pending_on_insert`)
- [x] Hanya superadmin yang bisa mengubah `verification_status`; approve → peran diberikan, cabut → peran dihapus, semua tercatat di `audit_logs`
- [x] RLS di semua tabel; `anon` tanpa akses; fungsi `SECURITY DEFINER` dengan `search_path` terkunci
- [ ] Di-apply ke project `dev` + dijalankan `get_advisors` (security & performance) tanpa temuan kritis

**S1-04/05 Auth:**
- Validasi inline: format email, kata sandi ≥ 8 karakter dengan kombinasi huruf & angka
- Pesan error dalam Bahasa Indonesia, tanpa detail teknis (sudah dipetakan di `SupabaseAuthRepository`)
- Loading state di tombol; tombol dinonaktifkan saat proses berjalan
- Sesi bertahan setelah aplikasi ditutup; sign-out membersihkan sesi

**S1-07/08/09 Verifikasi:**
- Dokumen verifikasi diunggah ke bucket privat `verification-docs`; hanya pemilik & superadmin yang bisa membaca
- Superadmin tidak bisa memverifikasi dirinya sendiri
- Pengaju menerima notifikasi status (in-app di Sprint 1, push di Sprint 4)

## Keputusan yang dibutuhkan dari Product Owner

1. **Project Supabase:** buat project baru `primafit-dev` (dan `staging`) di organisasi Supabase Anda?
   Pembuatan project bisa berbiaya sesuai plan organisasi.
2. **Metode login:** email + kata sandi saja, atau tambah Google Sign-In / OTP nomor HP di sprint ini?
3. **Nama paket Android** final (mis. `id.primafit.app`) untuk menggantikan `com.example.primafit`.
4. **Akun superadmin pertama:** email siapa yang di-*seed* sebagai superadmin?

## Definition of Done

Mengikuti [ARCHITECTURE.md §8](../ARCHITECTURE.md#8-definition-of-done-setiap-story), ditambah:
- Setiap tabel baru lolos Supabase advisors (security + performance)
- Alur auth dites end-to-end di project `dev`
