# 🎟️ Pentasera App

**Pentasera** adalah platform marketplace event dan manajemen tiket digital terpadu berbasis mobile. Aplikasi ini mempertemukan **Penyelenggara Event (Creator)** dengan **Pencari Event (Buyer)** secara aman dan praktis, dilengkapi dengan verifikasi kehadiran penonton (check-in) berbasis **Kode QR** di lokasi acara.

Aplikasi ini menggunakan arsitektur terpisah (*decoupled architecture*):
- Sisi Client Mobile dibangun menggunakan framework **Flutter (Dart)**.
- Sisi Server Backend API dibangun menggunakan framework **Laravel (PHP)** dan database **MySQL**.

---

## 🚀 Fitur Utama

### 👤 Buyer (Pembeli Tiket)
- **Registrasi & Login Akun**: Keamanan autentikasi berbasis token API (Laravel Sanctum).
- **Eksplorasi Event**: Cari event secara real-time dan saring berdasarkan kategori (Musik, Seni, Budaya, Seminar).
- **Pembelian Tiket & Pembayaran**: Pemesanan tiket instan disertai unggahan bukti transfer pembayaran bank secara manual.
- **E-Ticket & Kode QR**: Tiket elektronik unik berformat kode QR terbit otomatis setelah pembayaran dikonfirmasi.
- **Manajemen Profil**: Ubah data diri (nama, nomor handphone) dan perbarui foto profil (avatar) dengan fallback inisial nama.

### 🎨 Creator (Penyelenggara Event)
- **Pengajuan Event Baru**: Unggah informasi detail acara beserta gambar poster.
- **Manajemen Tiket**: Buat variasi tiket (VIP, Reguler) beserta kuota dan harga masing-masing.
- **Dashboard Ringkasan**: Pantau statistik penjualan tiket dan pendapatan event.
- **Scan Check-In Pengunjung**: Verifikasi tiket pengunjung langsung menggunakan kamera perangkat saat event berlangsung.

### 🛠️ Admin (Administrator Platform)
- **Verifikasi Pembayaran**: Tinjau bukti transfer dari Buyer dan konfirmasi transaksi menjadi 'Paid'.
- **Moderasi Event**: Setujui (Approve) atau tolak (Reject) ajuan event baru sebelum dipublikasikan ke halaman utama.
- **Kelola Akses Pengguna**: Panel khusus untuk melihat seluruh data user dan mengubah peran (role) pengguna secara dinamis.
- *Keamanan*: Admin tidak diizinkan menggunakan fitur "Switch Role" demi menjaga integritas token sesi admin.

---

## 🛠️ Spesifikasi Teknologi (Tech Stack)

### Frontend (Mobile App)
- **Framework**: Flutter SDK v3.x (Dart v3.x)
- **State Management & Storage**: `flutter_secure_storage` (menyimpan Bearer Token secara aman)
- **Pustaka Utama**: `http`, `image_picker`, `google_fonts`, `intl`, `cached_network_image`

### Backend (REST API)
- **Framework**: Laravel v10.x (PHP 8.2+)
- **Database**: MySQL Server
- **Autentikasi**: Laravel Sanctum (Token-Based Bearer Authentication)
- **Media Storage**: Local storage disimbolkan ke link publik (`public/storage`) untuk berkas poster event dan avatar profil.

---

## 📂 Struktur Repositori & Dokumentasi

Berikut adalah direktori penting di dalam proyek ini:

```text
pentasera_app/
├── android/                   # Konfigurasi platform Android
├── assets/                    # Aset lokal (gambar, font, dll.)
├── docs/                      # Dokumentasi Proyek
│   ├── USER_MANUAL.md         # 📖 Panduan Penggunaan Lengkap (Buyer, Creator, Admin)
│   ├── API_DOCUMENTATION.md   # 🔌 Dokumentasi REST API Endpoints
│   ├── prd_pentasera.md       # 📋 Product Requirement Document (PRD) Utama
│   ├── PRD_EVENT_IMAGE_UPLOAD.md # 🖼️ PRD Tambahan untuk Alur Unggah Gambar
│   └── laporan_uas_pentasera.md  # 📝 Laporan Akhir UAS Pengembangan Sistem
├── ios/                       # Konfigurasi platform iOS
├── lib/                       # Sumber Kode Utama (Flutter)
│   ├── main.dart              # Entry point utama aplikasi
│   ├── features/              # Modul antarmuka berdasarkan fitur
│   │   ├── public_pages/      # Halaman publik (Beranda/Search)
│   │   ├── buyer/             # Halaman & Alur khusus Buyer (Profil, dll.)
│   │   └── admin/             # Halaman & Panel khusus Administrator
│   └── services/              # Integrasi API Client (Auth, User, Event)
└── pubspec.yaml               # Manajemen dependensi pustaka Flutter
```

*Dokumentasi Terkait:*
- [Panduan Pengguna / User Manual](file:///c:/Users/Baari%20Muhammad/Documents/Projects/pentasera_app/docs/USER_MANUAL.md)
- [Dokumentasi API Backend](file:///c:/Users/Baari%20Muhammad/Documents/Projects/pentasera_app/docs/API_DOCUMENTATION.md)
- [Product Requirement Document (PRD)](file:///c:/Users/Baari%20Muhammad/Documents/Projects/pentasera_app/docs/prd_pentasera.md)
- [PRD Unggah Gambar Event](file:///c:/Users/Baari%20Muhammad/Documents/Projects/pentasera_app/docs/PRD_EVENT_IMAGE_UPLOAD.md)
- [Laporan UAS Pentasera](file:///c:/Users/Baari%20Muhammad/Documents/Projects/pentasera_app/docs/laporan_uas_pentasera.md)

---

## ⚙️ Cara Memulai & Konfigurasi Jaringan

### 1. Konfigurasi Jaringan Lokal (Android Debug Bridge)
Karena backend Laravel berjalan di localhost PC pengembangan sedangkan pengujian menggunakan emulator atau perangkat fisik Android, buatlah jembatan koneksi agar aplikasi dapat mengakses API:
```bash
adb reverse tcp:8000 tcp:8000
```
Dengan ini, request dari perangkat mobile ke `http://127.0.0.1:8000` akan dialihkan secara otomatis ke server Laravel di PC.

### 2. Menjalankan Backend API
1. Pastikan server web lokal (seperti XAMPP/Laragon) dan database MySQL telah aktif.
2. Konfigurasikan file `.env` di direktori backend, lalu jalankan:
   ```bash
   php artisan migrate:fresh --seed
   php artisan storage:link
   php artisan serve
   ```

### 3. Menjalankan Frontend Flutter
1. Jalankan `flutter pub get` untuk mengunduh semua pustaka dependensi.
2. Hubungkan perangkat uji Android (aktifkan USB Debugging).
3. Jalankan aplikasi menggunakan VS Code, Android Studio, atau perintah berikut:
   ```bash
   flutter run
   ```

---
*Dikembangkan oleh Tim Pengembang Pentasera - 2026*
