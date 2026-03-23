# 🏸 Badminton Cashier - Aplikasi Kasir GOR Pintar (v1.1)

Aplikasi kasir mobile berbasis Flutter yang dirancang untuk efisiensi operasional Gelanggang Olahraga (GOR) Badminton. Versi terbaru ini kini dilengkapi dengan integrasi **Cloud Configuration** untuk manajemen aplikasi yang lebih dinamis.

## ✨ Fitur Unggulan (Terbaru!)
- **🆕 Firebase Remote Config:** Kendali jarak jauh untuk fitur aplikasi tanpa perlu update manual di sisi pengguna.

- **🆕 Smart Auto-Update:** Notifikasi pembaruan otomatis yang memastikan pengguna selalu menggunakan versi terbaru langsung dari aplikasi.

- **🆕 Dynamic Dark Mode:** Antarmuka yang lebih nyaman di mata dengan dukungan tema gelap yang modern.

- **Custom Branding & Pricing:** Pengaturan nama GOR dan harga sewa (Lapangan, Raket, Kok) secara mandiri.

- **Otomatisasi Jadwal:** Kalkulasi durasi main dan jadwal selesai secara presisi dan otomatis.

- **Struk Digital Professional:** Kirim struk rapi langsung ke WhatsApp atau Telegram pelanggan.

- **Keamanan Data Lokal:** Menggunakan SQLite (Database) dan SharedPreferences untuk penyimpanan data yang stabil.

## 🛠️ Tech Stack & Integrasi

- **🆕 Backend Service:** Firebase (Remote Config & Analytics)

- **Framework:** Flutter (Dart)

- **Database Lokal:** SQLite (`sqflite`)

- **Storage:** `shared_preferences`

- **Charts:** `fl_chart`

- **Utilities:** `intl`, `share_plus`, `path`, `url_launcher`

## 🚀 Cara Menjalankan Project (Local Development)

1. **Clone Repository**
Salin link repository ini dan jalankan di terminal:
```Bash
git clone https://github.com/bimofakot/gor_badminton.git
```
2. **Setup Konfigurasi (PENTING)**
Karena repository ini bersifat publik, file konfigurasi Firebase (`google-services.json`) disembunyikan melalui .gitignore. Anda perlu menggunakan file konfigurasi Firebase Anda sendiri di folder `android/app/`.

3. **Install Dependensi**
Jalankan perintah berikut di root folder project:
```Bash
flutter pub get
```

4. **Jalankan Aplikasi**
Pastikan emulator atau perangkat fisik terhubung, lalu jalankan:
```Bash
flutter run
```

## 📦 Distribusi & Build

Untuk membuat file instalasi (APK):
```Bash
flutter build apk --release
```

Lokasi Output: `build/app/outputs/flutter-apk/app-release.apk`

---

Dibuat oleh Bimo fakot di lingkungan CachyOS (Arch Linux).