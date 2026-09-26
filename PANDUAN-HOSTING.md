# Panduan Hosting SIMAS

Semua persiapan dari sisi kode sudah selesai. Tinggal **2 langkah yang wajib
Anda kerjakan sendiri**, karena keduanya butuh akun dan browser Anda:

1. Upload kode ke GitHub
2. Sambungkan GitHub ke Render

Total sekitar **10 menit**.

---

# BAGIAN 1 — TUNNEL PUBLIK (tanpa akun, sudah aktif sekarang)

Aplikasi Anda **sudah berjalan dan bisa diakses dari internet** di alamat:

```
https://sleeps-audio-inn-klein.trycloudflare.com
```

Buka di HP atau browser mana pun, lalu masuk dengan `admin@simas.test` /
`simas123`. Tidak perlu akun apa pun.

**Syarat aktif:** komputer menyala dan dua program berjalan, yaitu
`node server/index.js` dan `cloudflared`. Matikan salah satu, alamat ikut mati.

**Alamat berubah** setiap kali tunnel diulang.

## Cara mengulang tunnel

```bash
# Terminal 1 - server aplikasi
npm run build
set PORT=8080
node server/index.js

# Terminal 2 - tunnel
"%LOCALAPPDATA%\cloudflared.exe" tunnel --url http://localhost:8080
```

Alamat baru muncul pada baris `INF ... https://xxxx.trycloudflare.com`.

## Menghentikan tunnel

Tutup terminal `cloudflared`, atau tekan `Ctrl+C`.

> ⚠️ Password akun demo (`simas123`) menjadi bisa ditebak siapa pun selama
> alamat aktif. Bagikan hanya kepada orang tepercaya, lalu matikan tunnel.

---

# BAGIAN 2 — HOSTING PERMANEN DI RENDER

## 2.1 Buat repo di GitHub

1. Buka `https://github.com`, klik **Sign up**, daftar dengan email Anda.
2. Klik tombol **+** di kanan atas, pilih **New repository**.
3. Isi: **Repository name** `simas-masjid`, pilih **Private**, dan **jangan**
   centang "Add a README file".
4. Klik **Create repository**.
5. Klik tombol **code** (ikon `<>`), lalu salin alamat HTTPS.

## 2.2 Kirim kode dari komputer ini

Buka **PowerShell**, jalankan (sesuaikan akun dan email):

```powershell
cd D:\kemas
git config user.name  "Nama Anda"
git config user.email "email@anda.com"
git remote add origin https://github.com/akun-anda/simas-masjid.git
git push -u origin main
```

GitHub sudah tidak menerima password akun sejak 2021, jadi siapkan token dulu:

1. Foto profil, lalu **Settings**, lalu **Developer settings**.
2. **Personal access tokens** → **Tokens (classic)** → **Generate new token**.
3. Isi **Note** dengan `simas`, centang **repo**, klik **Generate token**.
4. Salin token yang muncul (hanya ditampilkan sekali).
5. Saat `git push` meminta password, tempel token tersebut.

## 2.3 Deploy ke Render

1. Buka `https://render.com`, klik **Get Started**, masuk dengan akun GitHub.
2. Klik **New +** → **Web Service**.
3. Pilih repo **simas-masjid**, klik **Connect**.
4. Isi kolom berikut:

| Kolom | Isi |
|---|---|
| Name | `simas-masjid` |
| Region | `Singapore` |
| Branch | `main` |
| Root Directory | kosongkan |
| Runtime | `Node` |
| Build Command | `npm ci && npm run build` |
| Start Command | `npm start` |
| Instance Type | `Free` |

5. Klik **Create Web Service**, tunggu sekitar 2 menit sampai status **Live**.
6. Alamat aplikasi: `https://simas-masjid.onrender.com`

## 2.4 Versions Node

Aplikasi memakai modul bawaan `node:sqlite` yang butuh Node 22.5 ke atas.
Berkas `.node-version` sudah berisi `24`, jadi Render otomatis memakai Node 24.

---

# BAGIAN 3 — APAKAH DATA HILANG?

| Keadaan | Akibat |
|---|---|
| Cloudflare Tunnel | Aman, data tetap ada selama komputer menyala |
| Render Free | Database dan foto hilang tiap kali deploy atau restart |

Pada Render Free, setelah restart aplikasi membuat ulang database beserta data
contoh, jadi aplikasi tetap bisa dicoba. Hanya data yang Anda masukkan sendiri
yang ikut hilang.

Kalau data tidak boleh hilang, siapkan persistent disk di Render, tambahkan
Environment Variable `SIMAS_DATA_DIR = /var/data`, dan pasang Disk bertipe
`Persistent` ke `/var/data`.

Alternatif lebih aman: pindahkan ke database terkelola seperti Supabase atau
Neon, lalu lakukan backup rutin dari komputer ini.

---

# BAGIAN 4 — MASALAH YANG SERING MUNCUL

| Gejala | Penyebab dan solusi |
|---|---|
| `Cannot find module 'node:sqlite'` | Node terlalu lama. Pastikan Node 24 |
| Halaman tampil tapi menu kosong | Build gagal. Buka tab **Logs** di Render |
| Build gagal di `tsc` | Jalankan `npm run build` di komputer untuk melihat detail |
| Halaman lambat dibuka pertama kali | Free tier tidur 15 menit, buka pertama 30 sampai 60 detik |
| `npm ci` gagal | `package.json` dan `package-lock.json` harus sama-sama ter-commit |
| Perubahan kode tidak muncul | `git push` ulang, Render auto-deploy tiap push ke `main` |

---

# BAGIAN 5 — BERAPA LAMA?

| Bagian | Waktu |
|---|---|
| Daftar GitHub | 3 menit |
| Upload kode | 3 menit |
| Deploy Render | 3 menit |
| **Total** | **10 menit** |

# Berkas pendukung yang sudah disiapkan

| Berkas | Fungsi |
|---|---|
| `Dockerfile` | Alur deploy di platform apa pun yang mendukung Docker |
| `render.yaml` | Konfigurasi Render otomatis (Blueprint) |
| `.node-version` | Memaksa platform memakai Node 24 |
| `.gitignore` | Mencegah database, `node_modules`, dan `dist` ikut ter-commit |


Jika muncul pesan `Cannot find module 'node:sqlite'`, tambahkan Environment
Variable `NODE_VERSION` bernilai `24`, lalu **Save & Deploy**.
