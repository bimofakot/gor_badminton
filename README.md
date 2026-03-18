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

1. **Clone repository ini:**
   ```bash
   git clone [https://github.com/USERNAME_ANDA/gor_badminton.git](https://github.com/USERNAME_ANDA/gor_badminton.git)

    Masuk ke direktori project:
    Bash

    cd gor_badminton

    Install dependensi:
    Bash

    flutter pub get

    Jalankan aplikasi (Debug Mode):
    Bash

    flutter run

📦 Distribusi & Build

Untuk membuat file instalasi APK milik Anda sendiri:
Bash

flutter build apk --release

File output akan berada di: build/app/outputs/flutter-apk/app-release.apk
