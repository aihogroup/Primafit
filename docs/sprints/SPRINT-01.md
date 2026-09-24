# Sprint 1: Identitas & RBAC

**Periode:** 25 Sep – 8 Okt 2026 (2 minggu)
**Sprint goal:** Setiap orang bisa mendaftar dan masuk dengan akun Supabase, lalu mengajukan diri
sebagai Dokter, Instansi, atau Mitra. Superadmin bisa memverifikasi pengajuan, dan peran langsung
aktif. Pengguna MVP lama tidak kehilangan data.

**Kapasitas:** 34 story point (SP)
**Project Supabase:** `Primafit` (`iwkjyzgiggmlztbjvtih`, region Singapura)

## Backlog

| ID | User story | SP | Status |
|---|---|---|---|
| S1-01 | Project Supabase dengan migrasi berversi | 2 | ✅ project `Primafit`; 2 migrasi ter-apply |
| S1-02 | Skema identitas & RBAC + RLS + storage bucket | 5 | ✅ ter-apply, 29/29 tes RLS lulus, security advisor bersih |
| S1-03 | Domain & data layer auth (`UserRole`, `AppSession`, `AuthRepository`) | 3 | ✅ |
| S1-04 | Daftar dengan email + kata sandi dan verifikasi email | 5 | ✅ kode + test · ⏳ uji di perangkat |
| S1-05 | Masuk, keluar, dan reset kata sandi | 3 | ✅ kode + test · ⏳ uji di perangkat, perlu Redirect URL |
| S1-06 | Profil lokal MVP dipindah ke akun saat pertama login | 3 | ✅ kode + test · ⏳ uji di perangkat |
| S1-07 | Dokter mengajukan verifikasi (STR, SIP, spesialisasi, dokumen) | 5 | 🔜 backend siap (tabel, trigger, bucket) |
| S1-08 | Instansi/mitra mendaftarkan organisasi | 3 | 🔜 backend siap |
| S1-09 | Superadmin: antrean verifikasi, approve/reject + catatan | 5 | 🔜 backend siap (`verification_note`, audit log) |
| S1-10 | Role switcher untuk pengguna multi-peran | 2 | 🔜 domain siap (`AppSession.switchRole`) |

## Yang sudah jalan

### Database (Supabase)
- Migrasi `supabase/migrations/20260924130326_identity_rbac.sql` dan `20260924130402_storage_buckets.sql`
  (versi file = versi di Supabase). Rollback di `supabase/rollbacks/`.
- Fungsi `SECURITY DEFINER` ada di schema `private`, jadi tidak bisa dipanggil lewat API. Grant eksplisit
  (least privilege), termasuk grant UPDATE per kolom di `profiles`.
- Aturan verifikasi (trigger `private.guard_verification`):
  - Pendaftaran profesional selalu `pending`.
  - Hanya superadmin (atau service_role / SQL owner) yang bisa approve/reject.
  - Superadmin tidak bisa me-review pendaftarannya sendiri.
  - Approve → peran diberikan; keluar dari approved → peran dicabut.
  - Pemilik yang mengubah STR/SIP/NIB/izin setelah disetujui → status kembali `pending` dan peran dicabut.
  - Semua perubahan status tercatat di `audit_logs`.
- Bucket privat `avatars` (2 MB, gambar) dan `verification-docs` (5 MB, PDF/JPG/PNG). Path file:
  `<bucket>/<user_id>/...`.
- Tes integrasi: `supabase/tests/identity_rbac_test.sql` (29 skenario, selalu di-rollback).

### Aplikasi
| Alur | Perilaku |
|---|---|
| Startup gate (splash) | Belum masuk → intro (pertama kali) / halaman Masuk · Profil belum lengkap → form profil · Lengkap → Home |
| Daftar | Nama, email, kata sandi (≥ 8, huruf + angka). Supabase mengirim email verifikasi; tautan membuka aplikasi (`primafit://auth-callback`) |
| Masuk / Keluar | Email + kata sandi. Keluar dengan dialog konfirmasi; cache profil di perangkat dihapus |
| Lupa kata sandi | Tautan reset membuka aplikasi → halaman "Buat kata sandi baru" |
| Profil | `public.profiles` = sumber kebenaran; SQLite lokal = cache write-through (8 layar catatan kesehatan masih membacanya) |
| Migrasi MVP (S1-06) | Profil lokal lama tanpa pemilik digabung ke akun saat login pertama; data akun selalu menang; cache milik akun lain tidak pernah digabung |
| Mode offline | Tanpa key Supabase di `env/*.json`, aplikasi berjalan seperti MVP (profil lokal, tanpa login) |

## ⚠️ Pengaturan dashboard yang wajib dilakukan pemilik project

Pengaturan ini tidak bisa diubah lewat migrasi SQL:

1. **Authentication → URL Configuration → Redirect URLs:** tambahkan `primafit://auth-callback`.
   Tanpa ini, tautan reset kata sandi tidak membuka aplikasi. Verifikasi email tetap berhasil, tapi
   pengguna harus kembali ke aplikasi dan masuk secara manual.
2. **Authentication → Policies (Password):** panjang minimal 8, wajib huruf + angka (sama dengan
   validasi di aplikasi).
3. **SMTP:** tanpa custom SMTP, Supabase **hanya mengirim email ke anggota tim organisasi** (dan dengan
   rate limit rendah). Untuk uji coba, daftar memakai email anggota tim. Sebelum rilis, pasang custom
   SMTP (Resend, Brevo, SES, dll.).
4. **Email Templates** (opsional): terjemahkan template verifikasi & reset ke Bahasa Indonesia.

## Bootstrap superadmin pertama

Setelah pemilik mendaftar & memverifikasi email lewat aplikasi, jalankan di SQL Editor:

```sql
insert into public.user_roles (user_id, role)
select id, 'superadmin' from auth.users where email = 'EMAIL-SUPERADMIN@contoh.com'
on conflict do nothing;
```

## Keputusan yang masih dibutuhkan dari Product Owner

1. **Metode login tambahan:** Google Sign-In / OTP nomor HP (sekarang email + kata sandi).
2. **Nama paket Android** final (mis. `id.primafit.app`) untuk menggantikan `com.example.primafit`.
3. **Email superadmin pertama** (lihat SQL di atas).
4. **Project staging** terpisah (disarankan sebelum rilis; bisa berbiaya).

## Risiko & catatan

- Data catatan kesehatan (SQLite) belum terikat akun: bila dua akun bergantian memakai satu perangkat,
  catatan kesehatan masih terlihat oleh keduanya. Prioritas pertama Sprint 2 (sinkronisasi per akun).
- Foto profil masih disimpan lokal; upload ke bucket `avatars` di Sprint 2.

## Definition of Done

Mengikuti [ARCHITECTURE.md §8](../ARCHITECTURE.md#8-definition-of-done-setiap-story), ditambah:
- [x] Setiap tabel baru lolos Supabase security advisor
- [x] Tes RLS integrasi lulus di project Supabase
- [ ] Alur auth dites end-to-end di perangkat Android (daftar → verifikasi → masuk → profil → keluar)
