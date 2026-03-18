# 🏸 Badminton Cashier - Aplikasi Kasir GOR Pintar

Aplikasi kasir mobile berbasis **Flutter** yang dirancang untuk memudahkan operasional Gelanggang Olahraga (GOR) Badminton. Fokus utama aplikasi ini adalah efisiensi transaksi, manajemen harga kustom, dan otomatisasi jadwal lapangan.

## ✨ Fitur Unggulan
- **Custom Branding & Pricing:** Pengguna dapat mengubah nama GOR dan mengatur harga sewa (Lapangan, Raket, Kok) secara mandiri melalui menu Pengaturan.
- **Otomatisasi Jadwal:** Fitur sinkronisasi waktu otomatis yang menghitung durasi main dan jadwal selesai secara presisi.
- **Statistik Penjualan:** Visualisasi data pemasukan bulanan menggunakan grafik pie yang interaktif.
- **Struk Digital Professional:** Format struk yang rapi dan transparan, siap dibagikan langsung ke WhatsApp atau Telegram pelanggan.
- **Keamanan Data Lokal:** Penyimpanan menggunakan SQLite (Database) dan SharedPreferences (Pengaturan) sehingga data tetap aman meski aplikasi ditutup.

## 🛠️ Tech Stack
- **Framework:** Flutter (Dart)
- **Database:** SQLite (`sqflite`)
- **Storage:** `shared_preferences`
- **Charts:** `fl_chart`
- **Utilities:** `intl`, `share_plus`, `path`

## 🚀 Cara Menjalankan Project (Local Development)
Ikuti langkah-langkah di bawah ini untuk menjalankan aplikasi di lingkungan pengembangan lokal Anda:

1. **Clone Repository**
   Salin repository ini ke laptop Anda menggunakan perintah berikut:
   ```Bash
   git clone [https://github.com/USERNAME_ANDA/gor_badminton.git](https://github.com/USERNAME_ANDA/gor_badminton.git)
2. **Masuk ke direktori project**
   Masuk ke folder project yang baru saja di-clone:
   ```Bash

    cd gor_badminton

3. **Install dependensi**
   Unduh semua library/package yang dibutuhkan oleh Flutter:
    ```Bash

    flutter pub get

4. **Jalankan aplikasi (Debug Mode)**
   Hubungkan perangkat Android Anda, lalu jalankan perintah:
    ```Bash

    flutter run

## 📦 Distribusi & Build
Jika Anda ingin membuat file instalasi (APK) untuk dipasang di HP lain tanpa perlu koding, jalankan perintah ini:

    ```Bash

    flutter build apk --release
**Lokasi File Output:**
Setelah proses selesai, file APK akan tersedia di:
`build/app/outputs/flutter-apk/app-release.apk`

---

Dibuat oleh Bimo di lingkungan CachyOS.
