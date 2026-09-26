# SIMAS — Sistem Informasi Manajemen Masjid

MVP aplikasi manajemen masjid berbasis web dengan React, Vite, Express, dan SQLite bawaan Node.js.

## Menjalankan aplikasi

```bash
npm install
npm run dev
```

- Frontend: `http://localhost:5173`
- API: `http://localhost:3001`

Untuk build produksi:

```bash
npm run build
npm start
```

Build produksi dilayani Express pada `http://localhost:3001`.

## Akun demo

Semua akun demo menggunakan password `simas123`:

| Role | Email |
|---|---|
| Super Admin | `admin@simas.test` |
| Ketua DKM | `ketua@simas.test` |
| Bendahara | `bendahara@simas.test` |
| Operator | `operator@simas.test` |
| Viewer/Jamaah | `jamaah@simas.test` |

## Fitur MVP

- Login session cookie `HttpOnly` dan password hash `scrypt`.
- Role-based access control untuk admin, ketua, bendahara, operator, dan viewer.
- Dashboard saldo, pemasukan, pengeluaran, approval, dana, agenda, dan pengumuman.
- Laporan keuangan dengan rekap per bulan, per sumber dana, per kategori, dan per metode pembayaran plus cetak/PDF.
- Fund accounting: operasional, pembangunan, sosial, dan pendidikan.
- Input transaksi dengan validasi nominal, tanggal, kategori, sumber dana, dan peruntukan.
- Workflow pending → approve/reject; saldo tidak boleh minus untuk approval bendahara.
- Audit log append-only yang dilindungi trigger SQLite.
- Transparansi publik melalui `/api/public/summary` tanpa login.
- Agenda/pengumuman, inventaris, struktur DKM, audit log, dan export CSV.
- Menu **Ubah** (edit) untuk inventaris, agenda, pengumuman, dan pengurus DKM — bisa mengubah nama, lokasi, jabatan, dan kolom lainnya tanpa membuat data baru.
- Dokumentasi acara: unggah foto bukti kegiatan per agenda, tampil sebagai kolase mozaik dengan panel detail, dan bisa dihapus kapan saja.
- Identitas masjid (nama & alamat) berbasis data dengan halaman pengaturan khusus Super Admin.
- **Unggah logo manual** oleh Super Admin langsung dari Pengaturan Masjid.
- **Peta lokasi masjid** di bawah halaman Struktur DKM.
- **Surat-menyurat** berbasis template dengan pratinjau A4, cetak/PDF, dan riwayat.
- **Modul zakat**: panitia, bacaan, pemberi, penerima, serta rekap.
- Responsive UI desktop/mobile dengan sidebar.

## Cetak dan PDF

SIMAS menggunakan dialog print browser native (`window.print`) agar tidak membutuhkan library PDF tambahan.

- **Dashboard:** tombol `🖨 Cetak / PDF` di header dashboard.
- **Transaksi:** buka menu `Keuangan`, klik `Detail` pada transaksi, lalu klik `🖨 Cetak / PDF`.
- **Jadwal Jumat:** buka `Dashboard` atau `Agenda & Jadwal`, lalu klik `🖨 Cetak detail` pada panel Jadwal Jumat.
- **Laporan keuangan:** buka menu `Laporan Keuangan`, pilih periode, lalu klik `🖨 Cetak / PDF`. Header cetak menampilkan nama masjid, periode, dan penanggung jawab laporan.
- Pilih printer atau pilih **Save as PDF** pada dialog print. Layout print menggunakan ukuran A4 dan menyembunyikan sidebar, topbar, tombol, serta elemen navigasi.


## Laporan keuangan

Halaman `Laporan Keuangan` menyusun rekap dari transaksi **berstatus disetujui** (transaksi menunggu approval tidak dihitung).

- Filter periode: `Bulan ini`, `Bulan lalu`, `3 bulan terakhir`, `Tahun ini`, atau rentang tanggal khusus; tambahan filter per sumber dana.
- Isi laporan: KPI pemasukan/pengeluaran/surplus/saldo akhir, grafik arus kas per bulan, tabel saldo awal → saldo akhir tiap sumber dana, rekap kategori pemasukan dan pengeluaran lengkap dengan porsi persen, serta rekap metode pembayaran.
- `⇩ Export CSV` mengunduh laporan periode yang sedang tampil dalam format CSV bertingkat (ringkasan, per dana, per kategori, per metode pembayaran).


## Identitas masjid

Nama dan alamat masjid disimpan di tabel `settings` (key `masjid_name` dan `masjid_address`) dan menjadi sumber data tunggal untuk seluruh tampilan: chip sidebar, footer halaman login, banner transparansi publik, dan kop cetak laporan keuangan.

- `GET /api/public/profile` tersedia tanpa login untuk halaman publik dan halaman login, dan juga mengembalikan `logo` serta `developer`.
- Menu **Pengaturan Masjid** (khusus Super Admin) menampilkan form nama/alamat/logo, form kontak pengembang, daftar parameter sistem baca-saja, dan pratinjau tampilan. Perubahan langsung berlaku di seluruh aplikasi tanpa perlu login ulang, dan tercatat pada audit log. Endpoint `POST /api/masjid` menerima update parsial (hanya kirim field yang diubah).
- Nilai bawaan berada di `server/db.js` (`defaultMasjidProfile`). Migrasi dijalankan idempotent saat start: nilai demo lama hanya diganti bila masih persis sama, sehingga hasil edisi Super Admin tidak pernah tertimpa.


## Dokumentasi acara (foto)

Kolase foto pada halaman `Agenda & Jadwal` menyimpan bukti kegiatan per agenda.

- Penyimpanan: tabel `schedule_photos` (terhubung ke `schedules` dengan `ON DELETE CASCADE`) + berkas di `data/uploads/`. Keduanya otomatis terhapus bersama saat agenda dihapus, dan folder ikut ter-*ignore* di `.gitignore`.
- Unggah: pilih agenda, isi keterangan (opsional), lalu `＋ Unggah foto` (maks. 8 foto sekali jalan). Foto dikompres di browser (JPEG, sisi terpanjang 1400px, kualitas 0,82) sebelum dikirim, jadi tetap ringan meski foto HP berukuran besar.
- Keamanan: hanya PNG/JPEG/WEBP/GIF, maksimal 5MB, dan **signature berkas diverifikasi** (bukan sekadar trusting `Content-Type`) supaya file berbahaya tidak tersimpan.
- Berkas hanya bisa diakses pengguna yang sudah login (`GET /uploads/:file` + `requireAuth`) dan nama berkas divalidasi untuk mencegah path traversal.
- Hapus: tombol `×` pada setiap foto (atau `🗑 Hapus foto` di panel detail) tersedia bagi Super Admin, Ketua DKM, dan Operator. Setiap unggah/hapus tercatat pada audit log.


## Logo, latar, dan footer

- **Logo:** `public/logo-masjid.svg` dipakai otomatis di sidebar (kiri), halaman login, layar splash, dan footer. Path logo disimpan di `settings` key `masjid_logo`. Untuk memakai berkas PNG asli: simpan di `public/`, lalu ubah nilainya di **Pengaturan Masjid** (contoh `/logo-masjid.png`). Logo eksternal (http/https) dan ekstensi lain ditolak; bila berkas gagal dimuat, sistem otomatis kembali ke mark "S".
- **Latar:** setiap halaman memakai pola geometrisislami (SVG inline, tanpa berkas tambahan) plus dua semburat warna lembut di pojok atas. Latar otomatis dihilangkan saat printing.
- **Footer:** tampil di semua halaman — copyright, identitas masjid, serta kredit pengembang dengan tautan WhatsApp (`wa.me/&lt;nomor&gt;`) dan Instagram untuk permintaan pembuatan website statis. Footer tidak ikut tercetak saat print/PDF.
- **Kontak pengembang** disimpan di `settings` (`developer_name`, `developer_wa`, `developer_instagram`) dan hanya dapat diubah Super Admin lewat **Pengaturan Masjid**. Nomor WhatsApp dibersihkan menjadi digit saja, dan tanda `@` Instagram dihapus otomatis.


## Unggah logo manual

- Tombol **Unggah logo** ada di **Pengaturan Masjid** dan hanya bisa dipakai Super Admin.
- Format PNG, JPEG, atau WEBP, maksimal 2MB. Berkas dikirim apa adanya (tanpa dikompresi ulang) supaya logo tetap tajam dan tidak kehilangan transparansi.
- Server memverifikasi **signature berkas** (bukan sekadar `Content-Type`), menulisnya ke `data/uploads/`, lalu menghapus logo lama yang diunggah sebelumnya.
- Tombol **Kembalikan logo bawaan** mengembalikan logo ke berkas bawaan di `public/`.
- **Catatan performa:** `public/logo-masjid.svg` hasil *tracing* vektor berukuran besar (~894KB, 1650 path) terlalu berat untuk dimuat di setiap halaman, sehingga versi PNG 900px (~147KB) dipakai sebagai bawaan. Berkas SVG asli ada di `data/logo-masjid.svg.asli`.

## Peta lokasi

- Peta OpenStreetMap ditampilkan di bawah daftar **Struktur DKM**, lengkap dengan alamat, koordinat, tombol **Buka di Google Maps**, dan **Salin alamat**.
- Titik koordinat disimpan di `settings` (`masjid_lat`, `masjid_lng`) dan dapat dikoreksi kapan saja dari **Pengaturan Masjid** (salin koordinat dari Google Maps dengan klik kanan pada lokasi).
- Nilai bawaan memakai koordinat perkiraan Jatijajar/Tapos: `-6.40270, 106.75900`.

## Surat-menyurat

Halaman **Surat-menyurat** menyediakan tujuh template administrasi masjid siap pakai:

1. **Berita Acara** — hadirin dan hasil keputusan ditulis per baris, lalu otomatis menjadi daftar bernomor.
2. **Surat Kuasa** — pemberi dan penerima kuasa, uraian tugas, tanggal berlaku.
3. **Proposal Permohonan Dana** - 11 bagian dengan rencana anggaran berupa tabel, nominal, dan jumlah dalam kata yang dihitung otomatis.
4. **Undangan Rapat Takmir/DKM**
5. **Undangan PHBI ke Masjid Lain** - lengkap dengan nama kegiatan, tema, dan nama penceramah.

- Pratinjau A4 dengan dukungan judul, paragraf, daftar bernomor, dan tabel anggaran.
- Alur kerja: pilih template → isi tanggal, nama/alamat penerima, jam, tempat, isi utama, dan penanda tangan → klik **Buat pratinjau** → cetak/PDF atau simpan ke riwayat.
- Placeholder `{{nama}}`, `{{tanggal}}`, `{{waktu}}`, `{{tempat}}`, `{{isi}}`, `{{nilai}}`, `{{nama_masjid}}`, `{{ttd_nama}}`, dan sejenisnya digantikan **di server** saat surat disusun, sehingga hasil cetak selalu konsisten.
- Nomor surat otomatis dengan format `YYYYMM/XXX` dan tanggal berbahasa Indonesia.
- Header surat memakai logo dan identitas masjid yang aktif di **Pengaturan Masjid**.
- Cetak memakai dialog print browser dengan gaya A4 khusus surat; tombol **Simpan ke riwayat** menyimpan salinan agar bisa dibuka kembali.
- Data: tabel `letter_templates` dan `letters`. Nilai awal template berada di `server/letter-templates.js`, dan seluruh isinya tetap dapat diubah Super Admin/Ketua DKM dari antarmuka.

## Modul zakat

Lima tab: **Panitia & Bacaan**, **Pemberi**, **Penerima**, **Penyaluran**, dan **Rekap**.

- **Panitia:** nama, jabatan, kontak, dan tugas; dapat ditambah dan diubah.
- **Bacaan:** niat zakat maal, niat zakat fitrah, doa setoran, taawudduts, dan dokumen ijab qabul. Teks Arab, arti, dan keterangan dapat disesuaikan Ketua DKM.
- **Pemberi:** nama, alamat, kontak, jenis (zakat maal, zakat fitrah, infak, shadaqah), nominal, jumlah jiwa, dan tanggal setoran.
- **Penerima:** mustahik dengan delapan asnaf (fakir, miskin, amil, muqti, mualim, riqab, gharim, sabil), jumlah jiwa, dan total yang sudah diterima.
- **Penyaluran:** zakat yang diserahkan kepada mustahik beserta tanggal dan jenisnya.
- **Rekap:** total terkumpul, terdistribusi, dan sisa zakat, dirinci per jenis. Tersedia **cetak rekap** dan **export CSV** (UTF-8 dengan BOM agar rapi di Excel).
- Akses: Super Admin, Ketua DKM, dan Bendahara dapat menambah/mengubah/menghapus; role lain hanya melihat. Semua mutasi tercatat pada audit log.
- Data: tabel `zakat_committee`, `zakat_readings`, `zakat_payers`, `zakat_recipients`, dan `zakat_distributions`. Nilai awal ada di `server/seed-documents.js`.

## Deployment (hosting gratis)

Aplikasi ini adalah satu proses Node.js: Express melayani API sekaligus berkas
statis hasil build Vite, sehingga cukup **satu port**.

```bash
npm ci
npm run build     # tsc -b && vite build
npm start         # node server/index.js
```

Variabel lingkungan:

| Variabel | Fungsi |
|---|---|
| `PORT` | Port server. Wajib diisi di platform hosting. |
| `SIMAS_DATA_DIR` | Folder database dan unggahan. Bawaan: `./data`. |

**Kebutuhan versi:** Node.js 24 (atau minimal 22.5) karena memakai modul bawaan
`node:sqlite`. Jangan pakai runtime Node 20 ke bawah.

### Pilihan hosting gratis

| Platform | Catatan |
|---|---|
| **Render** (Web Service) | Paling mudah. Build `npm ci && npm run build`, Start `npm start`, Runtime Node 24. **Disk bersifat sementara**, jadi database dan berkas unggahan kembali ke awal setiap kali aplikasi di-*deploy* atau di-*restart*. |
| **Koyeb** | Serupa dengan Render, free tier 1 instansi. Penyimpanan juga sementara. |
| **Oracle Cloud Always Free** / **Google Cloud Free Tier** | VM asli dengan disk persisten, jadi data benar-benar tersimpan. Perlu kartu kredit untuk verifikasi, dan biayanya bisa muncul jika kuota terlampaui. |

### Batasan penting gratis

- **Data hilang saat restart/deploy** pada paket tanpa persistent disk. Untuk data demo ini tidak menjadi masalah karena sistem akan membuat ulang database beserta data contohnya. Jangan dipakai untuk data keuangan nyata yang tidak ada salinannya.
- **Cold start**: layanan gratis biasanya tidur setelah beberapa menit tanpa aktivitas, sehingga halaman pertama butuh 30–60 detik.
- Untuk deployment dengan data yang harus awet, siapkan persistent disk dan arahkan `SIMAS_DATA_DIR` ke folder tersebut, atau pindahkan ke database terkelola.

### Kalau folder data perlu bertahan

Contoh untuk Linux dengan disk persisten:

```bash
SIMAS_DATA_DIR=/mnt/data node server/index.js
```

## Database

Database demo dibuat otomatis di `data/simas.db` menggunakan API `node:sqlite` Node.js 24+. File database tidak di-commit karena masuk `.gitignore`.

Untuk reset data demo, hentikan server lalu hapus `data/simas.db`, `data/simas.db-shm`, dan `data/simas.db-wal`. Jalankan server kembali untuk membuat seed baru.

## Endpoint utama

- `POST /api/auth/login`, `POST /api/auth/logout`, `GET /api/auth/me`
- `GET /api/dashboard`
- `GET /api/catalog`
- `GET /api/transactions`, `POST /api/transactions`
- `POST /api/transactions/:id/review`
- `GET /api/transactions/export.csv`
- `GET /api/reports/finance`, `GET /api/reports/finance.csv` (parameter `from`, `to`, `fund_id`)
- `GET /api/schedules`, `GET /api/inventory`, `GET /api/dkm`, `GET /api/announcements`
- `POST /api/schedules/:id`, `POST /api/inventory/:id`, `POST /api/dkm/:id`, `POST /api/announcements/:id` (Ubah, Super Admin/Ketua/Operator)
- `GET /api/photos`, `POST /api/schedules/:id/photos`, `DELETE /api/photos/:id`, `GET /uploads/:file` (Dokumentasi acara)
- `GET /api/audit`
- `GET /api/public/summary`, `GET /api/public/profile`
- `GET /api/masjid`, `POST /api/masjid` (Super Admin)

## Catatan ruang lingkup

Ini adalah MVP fondasi yang dapat dijalankan. Modul lanjutan seperti QRIS pembayaran otomatis, perhitungan jadwal sholat eksternal, dokumen digital, peminjaman inventaris, budget, rapat, task management, backup/restore, notifikasi real-time, dan donor management belum diimplementasikan pada versi MVP. Parameter approval bertingkat, PDF report, dan integrasi pembayaran perlu-developed pada fase berikutnya.

