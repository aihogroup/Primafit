# Sprint 2: Platform data & sinkronisasi

**Periode:** 9 – 22 Okt 2026 (2 minggu) · dikerjakan lebih awal mulai 25 Sep 2026
**Sprint goal:** Data kesehatan milik satu akun tidak pernah terlihat oleh akun lain di perangkat yang
sama. Catatan kesehatan utama tercadang ke cloud dan bisa dipakai di beberapa perangkat, tanpa
menulis ulang 24 layar lama.

## Backlog

| ID | User story | SP | Status |
|---|---|---|---|
| S2-01 | Semua data di perangkat terisolasi per akun | 5 | ✅ kode + test · ⏳ uji perangkat |
| S2-02 | Data MVP lama pindah ke akun pertama yang login (lanjutan S1-06) | 3 | ✅ kode + test |
| S2-03 | Tabel cloud `health_measurements` + RPC sinkronisasi batch | 5 | ✅ ter-apply, 12/12 tes SQL |
| S2-04 | Sinkronisasi dua arah 6 catatan kesehatan (kolesterol, gula darah, asam urat, suhu, tensi, BMI) | 8 | ✅ kode + test · ⏳ uji perangkat |
| S2-05 | Status cadangan & tombol "Sinkronkan sekarang" di Profil | 2 | ✅ |
| S2-06 | Sinkronisasi modul lain (obat, agenda, BPJS, vaksin, dokumen + file) | 8 | 🔜 pola sama, lanjut Sprint 2b |
| S2-07 | Modul `health_record` generik (1 set layar untuk 6 metrik) | 8 | 🔜 |

## Desain

### Isolasi per akun (`core/database/local_db.dart`)
- Semua 40 helper SQLite kini membuka file lewat `LocalDb.open()`, pengganti langsung `openDatabase`
  dengan parameter yang sama. File disimpan di `databases/accounts/<user_id>/`. Perubahan di helper
  hanya 2 baris, dan kode CRUD lama tidak berubah.
- Pergantian akun menutup semua database akun sebelumnya. Getter helper memakai
  `_database?.isOpen`, jadi otomatis membuka ulang untuk akun baru.
- Data MVP lama (file di lokasi lama) diklaim oleh akun **pertama** yang membukanya (penanda
  `accounts/.legacy_owner`). Akun lain mulai kosong dan tidak pernah menerima data orang lain.
- Tanpa akun aktif, `LocalDb.open()` gagal dengan jelas (StateError), bukan diam-diam menulis ke
  lokasi bersama.

### Sinkronisasi (strangler: layar lama tidak diubah)
| Bagian | Cara kerja |
|---|---|
| Metadata lokal | Trigger SQLite menambah `sync_id` (UUID v4), `updated_at` (UTC), `dirty` secara otomatis saat helper lama insert/update; delete disalin ke `sync_tombstones` |
| Push | Baris `dirty = 1` + tombstone → RPC `sync_health_measurements` (maks. 500 baris/batch). Baris ditandai bersih hanya jika tidak diedit selama request |
| Server | *Last-write-wins* berdasarkan `client_updated_at`; `user_id` selalu dari JWT; soft delete; RLS pemilik saja; tanpa hard delete |
| Pull | Keyset cursor `(server_updated_at, id)` + overlap 30 detik; penerapan idempoten; baris yang dihapus lokal tidak bisa "hidup lagi" dari salinan server yang lebih lama |
| Data buruk | Nilai di luar batas CHECK server divalidasi di klien. Jika batch tetap ditolak, baris dikirim satu per satu dan baris bermasalah dikarantina (`dirty = 2`) tanpa menghambat yang lain |
| Pemicu | Login, aplikasi dibuka/dilanjutkan, aplikasi ke background, setiap 5 menit, tombol manual |

Status baris lokal: `dirty` 0 = tersinkron, 1 = menunggu, 2 = ditolak server (akan dicoba lagi setelah
diedit).

## Bukti

- **SQL** (`supabase/tests/health_sync_test.sql`, dijalankan di project): 12/12 lulus, mencakup LWW,
  replay idempoten, tombstone, batas 500 baris, BP tanpa diastolik ditolak, akun lain tidak bisa
  membaca/menimpa, anon ditolak, timestamp server unik per baris.
- **Flutter** (SQLite nyata via ffi + server palsu dengan aturan yang sama): isolasi akun, klaim data
  MVP, pemetaan format, dua perangkat konvergen, hapus menyebar, anti-resurrection, edit saat push,
  karantina, backfill data MVP. Total **86 test** lulus.
- **REST**: sintaks filter pull diterima PostgREST; anon ditolak (42501) di tabel dan RPC.
- Security advisor Supabase: 0 temuan.

## Risiko & catatan

- Modul selain 6 catatan kesehatan **sudah terisolasi per akun** tetapi **belum tercadang** ke cloud
  (S2-06). Jika aplikasi dihapus, datanya ikut terhapus.
- Waktu `client_updated_at` memakai jam perangkat. Jam HP yang sangat salah bisa membuat edit lama
  menang. Bisa dimitigasi dengan offset jam server (Sprint 8).
- Belum diuji di perangkat Android nyata.

## Definition of Done tambahan

- [x] Tabel baru ber-RLS + lolos security advisor
- [x] Tes SQL integrasi lulus di project
- [ ] Uji perangkat: dua HP satu akun → catat tensi di HP A → muncul di HP B; hapus di B → hilang di
      A; logout A, login akun lain → catatan akun pertama tidak terlihat
