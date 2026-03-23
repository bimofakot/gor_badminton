🏸 Badminton Cashier - Aplikasi Kasir GOR Pintar (v1.1)

Aplikasi kasir mobile berbasis Flutter yang dirancang untuk efisiensi operasional Gelanggang Olahraga (GOR) Badminton. Versi terbaru ini kini dilengkapi dengan integrasi Cloud Configuration untuk manajemen aplikasi yang lebih dinamis.
✨ Fitur Unggulan (Terbaru!)

    🆕 Firebase Remote Config: Kendali jarak jauh untuk fitur aplikasi tanpa perlu update manual di sisi pengguna.

    🆕 Smart Auto-Update: Notifikasi pembaruan otomatis yang memastikan pengguna selalu menggunakan versi terbaru langsung dari aplikasi.

    🆕 Dynamic Dark Mode: Antarmuka yang lebih nyaman di mata dengan dukungan tema gelap yang modern.

    Custom Branding & Pricing: Pengaturan nama GOR dan harga sewa (Lapangan, Raket, Kok) secara mandiri.

    Otomatisasi Jadwal: Kalkulasi durasi main dan jadwal selesai secara presisi dan otomatis.

    Struk Digital Professional: Kirim struk rapi langsung ke WhatsApp atau Telegram pelanggan.

    Keamanan Data Lokal: Menggunakan SQLite (Database) dan SharedPreferences untuk penyimpanan data yang stabil.

🛠️ Tech Stack & Integrasi

    Framework: Flutter (Dart)

    Backend Service: Firebase (Remote Config & Analytics)

    Database Lokal: SQLite (sqflite)

    Storage: shared_preferences

    Charts: fl_chart

    Utilities: intl, share_plus, path, url_launcher

🚀 Cara Menjalankan Project (Local Development)

    Clone Repository
    Salin link repository ini dan jalankan di terminal:
    git clone https://github.com/bimofakot/gor_badminton.git

    Setup Konfigurasi (PENTING)
    Karena repository ini bersifat publik, file konfigurasi Firebase (google-services.json) disembunyikan melalui .gitignore. Anda perlu menggunakan file konfigurasi Firebase Anda sendiri di folder android/app/.

    Install Dependensi
    Jalankan perintah berikut di root folder project:
    flutter pub get

    Jalankan Aplikasi
    Pastikan emulator atau perangkat fisik terhubung, lalu jalankan:
    flutter run

📦 Distribusi & Build

Untuk membuat file instalasi (APK):
flutter build apk --release

Lokasi Output: build/app/outputs/flutter-apk/app-release.apk

Dibuat oleh Bimo Fakot di lingkungan CachyOS (Arch Linux).