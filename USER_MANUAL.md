# 📖 PANDUAN PENGGUNA (USER MANUAL) PENTASERA

Dokumen ini berisi panduan lengkap penggunaan aplikasi **Pentasera** untuk ketiga peran (role) pengguna: **Buyer (Pembeli Tiket)**, **Creator (Penyelenggara Event)**, dan **Admin (Administrator)**.

---

## 📌 DAFTAR ISI
1. [Pengenalan Sistem](#1-pengenalan-sistem)
2. [Panduan Buyer (Pembeli Tiket)](#2-panduan-buyer-pembeli-tiket)
   - [2.1 Registrasi Akun & Login](#21-registrasi-akun--login)
   - [2.2 Mengelola Profil & Foto Avatar](#22-mengelola-profil--foto-avatar)
   - [2.3 Eksplorasi Event](#23-eksplorasi-event)
   - [2.4 Memesan Tiket & Mengunggah Bukti Pembayaran](#24-memesan-tiket--mengunggah-bukti-pembayaran)
   - [2.5 Mengakses E-Ticket & Kode QR](#25-mengakses-e-ticket--kode-qr)
3. [Panduan Creator (Penyelenggara Event)](#3-panduan-creator-penyelenggara-event)
   - [3.1 Mengajukan Event & Unggah Poster](#31-mengajukan-event--unggah-poster)
   - [3.2 Menambahkan Tiket Event](#32-menambahkan-tiket-event)
   - [3.3 Memantau Penjualan di Dashboard](#33-memantau-penjualan-di-dashboard)
   - [3.4 Melakukan Check-in QR Pengunjung](#34-melakukan-check-in-qr-pengunjung)
4. [Panduan Admin (Administrator)](#4-panduan-admin-administrator)
5. [Konfigurasi Jaringan & Pemecahan Masalah (Troubleshooting)](#5-konfigurasi-jaringan--pemecahan-masalah-troubleshooting)

---

## 1. PENGENALAN SISTEM

**Pentasera** adalah platform mobile berbasis Android yang memfasilitasi publikasi event, penjualan tiket, dan manajemen check-in tiket secara real-time. Aplikasi ini bekerja secara terintegrasi dengan backend API Laravel. Sesi login pengguna disimpan dengan aman pada hardware-level perangkat menggunakan `flutter_secure_storage`.

---

## 2. PANDUAN BUYER (PEMBELI TIKET)

Peran **Buyer** digunakan oleh pengguna yang ingin mencari event, membeli tiket, dan melakukan check-in di lokasi acara.

### 2.1 Registrasi Akun & Login
1. **Registrasi Akun Baru**:
   - Buka aplikasi Pentasera, pilih **Registrasi**.
   - Masukkan **Nama Lengkap**, **Email**, **Password**, dan **Konfirmasi Password**.
   - Tekan **Daftar**. Akun Anda akan dibuat di sistem secara otomatis.
2. **Login Pengguna**:
   - Masukkan **Email** dan **Password** yang sudah terdaftar.
   - Tekan **Masuk** untuk masuk ke beranda aplikasi.

### 2.2 Mengelola Profil & Foto Avatar
Menu profil dapat diakses dengan mengetuk foto profil/inisial di kanan atas halaman utama.
1. **Ubah Informasi Profil**:
   - Tekan tombol **Ubah Data Profil**.
   - Perbarui **Nama Lengkap** atau **Nomor Handphone**.
   - Tekan **Simpan Perubahan**.
2. **Mengganti Foto Profil (Avatar)**:
   - Di menu Ubah Profil, ketuk **Ganti Foto Avatar**.
   - Pilih gambar dari galeri handphone Anda (maksimal ukuran file 2MB, format `.jpg`/`.png`/`.webp`).
   - Sistem akan mengunggah gambar tersebut ke server secara otomatis dan memperbarui tampilan profil Anda.
   - *Catatan*: Jika Anda belum mengunggah foto profil, sistem secara estetis akan menampilkan inisial huruf pertama nama Anda di dalam lingkaran.

### 2.3 Eksplorasi Event
1. **Pencarian Event**:
   - Ketik kata kunci (misal: "Jazz" atau "Wayang") pada kolom pencarian di bagian atas beranda.
   - Daftar event akan ter-filter secara real-time berdasarkan teks yang dimasukkan.
2. **Filter Kategori**:
   - Ketuk salah satu chip kategori di bawah kolom pencarian (seperti *Musik*, *Seni*, *Budaya*, atau *Seminar*).
   - Beranda hanya akan memuat event yang sesuai dengan kategori terpilih.

### 2.4 Memesan Tiket & Mengunggah Bukti Pembayaran
1. **Memilih Event**:
   - Ketuk kartu event yang diinginkan untuk membuka halaman detail. Tinjau jadwal, lokasi, deskripsi, dan sisa tiket.
2. **Membuat Pesanan**:
   - Ketuk tombol **Beli Tiket**.
   - Pilih jenis tiket (misal: VIP) dan tentukan jumlah tiket menggunakan tombol `+` / `-`.
   - Tekan **Pesan Sekarang**. Status pesanan pertama kali dibuat adalah **Pending**.
3. **Mengunggah Bukti Pembayaran**:
   - Lakukan transfer bank sesuai dengan total nominal harga ke rekening yang tertera di aplikasi.
   - Buka halaman detail transaksi/pesanan Anda, ketuk **Unggah Bukti Bayar**.
   - Pilih file foto bukti transfer ATM/Mobile Banking dari galeri handphone.
   - Tekan **Kirim Bukti**. Status transaksi Anda akan berubah menjadi menunggu tinjauan admin.

### 2.5 Mengakses E-Ticket & Kode QR
1. Setelah bukti transfer disetujui oleh Admin, status transaksi Anda akan berubah menjadi **Paid** (Lunas).
2. Sistem akan menerbitkan E-ticket secara otomatis yang berisi kode QR unik.
3. Buka detail transaksi Anda di aplikasi Pentasera untuk menampilkan **Kode QR Tiket**. Tunjukkan kode QR ini kepada petugas pintu masuk (Creator/Admin) di lokasi acara untuk dipindai.

---

## 3. PANDUAN CREATOR (PENYELENGGARA EVENT)

Peran **Creator** digunakan oleh penyelenggara acara untuk mempublikasikan acara dan memverifikasi tiket pengunjung di lokasi acara.

### 3.1 Mengajukan Event & Unggah Poster
Untuk membuat event, ikuti alur pembuatan 2-Langkah berikut:
1. **Langkah 1: Informasi Event**:
   - Masuk ke menu **Buat Event** (hanya muncul bagi akun dengan role Creator/Admin).
   - Masukkan **Nama Event**, pilih **Kategori**, tulis **Deskripsi Event**, masukkan **Tanggal & Waktu Mulai/Selesai**, **Lokasi Event**, dan **Kapasitas Event**.
   - Ketuk pada area **Foto Event** untuk memilih poster event dari galeri.
   - Tekan **Lanjut** ke langkah kedua.
2. **Langkah 2: Publikasi**:
   - Pada halaman preview, periksa kembali informasi event Anda.
   - Tentukan status publikasi:
     - **Draft**: Simpan event untuk diedit kembali nanti (belum dipublikasikan ke publik).
     - **Publikasikan**: Mengajukan event ke Admin agar ditinjau dan diterbitkan.
   - Tekan **Simpan Draft** atau **Publikasikan**.

### 3.2 Menambahkan Tiket Event
1. Pada Langkah 2 pembuatan event, Anda dapat menambahkan informasi tiket yang ingin dijual.
2. Masukkan **Nama Tiket** (misal: VIP atau Reguler), **Harga Tiket** (dalam Rupiah), dan **Stok Kuota Tiket**.
3. Tiket akan terbuat dan dikaitkan ke event tersebut setelah Anda menekan tombol simpan/publikasikan.

### 3.3 Memantau Penjualan di Dashboard
1. Masuk ke halaman **Event Saya**.
2. Halaman ini dibagi menjadi 3 tab:
   - **Draft**: Berisi event yang belum diajukan.
   - **Aktif**: Berisi event yang sudah disetujui Admin dan sedang berlangsung.
   - **Lalu**: Berisi arsip event yang sudah selesai.
3. Ketuk salah satu kartu event untuk melihat statistik jumlah tiket terjual, sisa kuota, serta total pendapatan terkumpul secara real-time.

### 3.4 Melakukan Check-in QR Pengunjung
Saat event berlangsung di lokasi fisik:
1. Buka aplikasi Pentasera, masuk ke menu **Scan Tiket** / **Scanner**.
2. Arahkan kamera smartphone Creator ke layar handphone pengunjung yang menampilkan Kode QR E-Ticket mereka.
3. **Mekanisme Validasi**:
   - **Tiket Valid (Centang Hijau)**: E-ticket terverifikasi belum pernah digunakan, pengunjung dipersilakan masuk, status check-in dicatat oleh sistem dengan detail waktu kedatangan.
   - **Tiket Invalid (Silang Merah)**: Kode QR tidak terdaftar di sistem.
   - **Tiket Duplikat (Peringatan)**: Tiket tersebut valid namun sudah dipindai (check-in) sebelumnya. Akses masuk ditolak untuk mencegah penyalahgunaan tiket.

---

## 4. PANDUAN ADMIN (ADMINISTRATOR)

Peran **Admin** memiliki wewenang penuh untuk memoderasi konten dan menjaga keamanan ekosistem aplikasi.

### 4.1 Kelola Akses & Peran Pengguna
Fitur ini mempermudah manajemen role pengguna secara dinamis:
1. Buka menu **Kelola Akses** di aplikasi Admin.
2. Halaman ini menampilkan 2 Tab:
   - **Daftar Pengguna**: Melihat seluruh daftar pengguna beserta foto avatar mereka. Jika pengguna belum memasang foto, sistem menampilkan inisial nama dengan warna identitas peran (Admin: Merah, Creator: Biru, Buyer: Oranye).
   - **Atur Role**: Untuk menyunting peran pengguna.
3. Di tab **Atur Role**, ketuk ikon edit di sebelah nama pengguna yang ingin diubah perannya.
4. Jendela dialog radio button akan muncul. Pilih peran baru untuk pengguna tersebut (antara **Buyer**, **Creator**, atau **Admin**).
5. Tekan **Simpan**. Peran pengguna tersebut di database akan langsung terperbarui saat itu juga.
6. *Catatan*: Demi keamanan token akses, Admin tidak memiliki tombol "Switch Role" di halaman profilnya.

### 4.2 Moderasi Event Pending
Setiap event baru yang dipublikasikan oleh Creator berstatus **Pending** secara default dan belum muncul di beranda utama.
1. Admin masuk ke menu **Moderasi Event**.
2. Pilih event berstatus 'Pending' untuk melihat rincian detail dan gambarnya.
3. Tekan **Approve (Setujui)** untuk mempublikasikan event tersebut ke beranda utama agar bisa dibeli oleh Buyer, atau tekan **Reject (Tolak)** jika event melanggar ketentuan.

### 4.3 Verifikasi Pembayaran Tiket
1. Admin masuk ke menu **Verifikasi Transaksi**.
2. Pilih transaksi berstatus 'Pending' untuk meninjau bukti transfer gambar yang diunggah oleh Buyer.
3. Cocokkan nominal transfer yang tertera pada gambar bukti transfer dengan total harga yang harus dibayar.
4. Tekan **Verifikasi (Approve Payment)** jika bukti valid. Status pemesanan akan otomatis berubah menjadi **Paid** dan kode QR E-ticket diterbitkan ke Buyer.
5. Tekan **Tolak (Reject Payment)** jika bukti transfer salah/tidak valid.

---

## 5. KONFIGURASI JARINGAN & PEMECAHAN MASALAH (TROUBLESHOOTING)

### 5.1 Masalah Koneksi Emulator/Perangkat ke Backend (Localhost)
Jika aplikasi Flutter menampilkan pesan kesalahan *"Kesalahan jaringan: SocketException"* saat mencoba mendaftar/login:
- **Penyebab**: Perangkat Android (terutama Emulator) tidak mengenali alamat `127.0.0.1` atau `localhost` komputer sebagai dirinya sendiri.
- **Solusi**: 
  1. Pastikan handphone tersambung ke PC via kabel data dan USB Debugging aktif (atau emulator berjalan).
  2. Buka terminal di PC Anda, jalankan perintah bridge berikut:
     ```bash
     adb reverse tcp:8000 tcp:8000
     ```
  3. Pastikan server Laravel Anda berjalan di port 8000 (`php artisan serve`).

### 5.2 Masalah Unggah Foto (Avatar/Poster)
Jika terjadi error saat memilih atau mengunggah gambar:
- **Batasan Ukuran**: Pastikan ukuran file gambar Anda **tidak melebihi 2MB**. Server Laravel secara otomatis membatasi unggahan maksimal 2MB demi performa.
- **Format File**: Pastikan ekstensi gambar adalah format populer seperti `.jpg`, `.jpeg`, `.png`, atau `.webp`.
- **Izin Aplikasi**: Pastikan Anda telah memberikan izin (permission) akses Galeri / Kamera kepada aplikasi Pentasera pada sistem operasi Android perangkat Anda.

### 5.3 Masalah Sesi Pengguna (Token Expired)
Jika Anda tiba-tiba kembali ke halaman Login atau mendapat pesan error otorisasi (401 Unauthorized):
- **Penyebab**: Sesi login/token bearer Anda di server Laravel Sanctum sudah kedaluwarsa atau terhapus dari database.
- **Solusi**: Silakan lakukan proses login kembali pada aplikasi untuk mendapatkan token bearer baru yang valid.

---
*Dokumen Versi: 1.0.0 - Pemutakhiran Terakhir: Juni 2026*
