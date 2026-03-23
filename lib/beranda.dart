import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart'; 
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Import file lokal
import 'database_helper.dart';
import 'format_uang.dart';
import 'halaman_login.dart';
import 'version_check.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});
  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  String namaGor = "";
  double hargaGor = 0;
  double hargaRaket = 0;
  double hargaKok = 0;
  double totalGor = 0;
  double totalRaket = 0;
  double totalKok = 0;
  double totalPemasukan = 0;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController gorController = TextEditingController();
  final TextEditingController raketController = TextEditingController();
  final TextEditingController kokController = TextEditingController();

  List<Map<String, dynamic>> riwayat = [];
  List<Map<String, dynamic>> filteredRiwayat = [];
  int _currentIndex = 0;
  bool isSearching = false;
  DateTime selectedDate = DateTime.now();

  // --- FUNGSI BAWAAN FLUTTER ---
  @override
  void initState() {
    super.initState();
    _loadSettings(); // Ambil harga dari Pengaturan
    _refreshData();  // Ambil data dari SQLite via DatabaseHelper
    
    // Check versi ke server
    Future.delayed(Duration.zero, () => VersionCheck.checkUpdate(context));
  }

  // --- FUNGSI LOADING DATA ---
  Future<void> _loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  final user = FirebaseAuth.instance.currentUser;

  // 1. Cek Lokal
  String? nama = prefs.getString('nama_gor');
  
  // 2. Jika lokal kosong, ambil dari Cloud (Firestore)
  if (nama == null && user != null) {
    var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      await prefs.setString('nama_gor', doc['nama_gor']);
      await prefs.setDouble('hrg_gor', doc['hrg_gor']?.toDouble() ?? 0);
      await prefs.setDouble('hrg_raket', doc['hrg_raket']?.toDouble() ?? 0);
      await prefs.setDouble('hrg_kok', doc['hrg_kok']?.toDouble() ?? 0);
    }
  }
  
  // 3. PENTING: Pindahkan data dari prefs ke variabel aktif aplikasi
  setState(() {
    namaGor = prefs.getString('nama_gor') ?? "";
    hargaGor = prefs.getDouble('hrg_gor') ?? 0;
    hargaRaket = prefs.getDouble('hrg_raket') ?? 0;
    hargaKok = prefs.getDouble('hrg_kok') ?? 0;

    // Update juga isi teks di kotak input agar sinkron
    namaController.text = namaGor;
    gorController.text = hargaGor.toInt().toString();
    raketController.text = hargaRaket.toInt().toString();
    kokController.text = hargaKok.toInt().toString();
  });

  _refreshData();
}

  Future<void> _resetSemuaData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool konfirmasi = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reset Semua Data?"),
        content: const Text("Seluruh transaksi di HP dan Cloud akan dihapus permanen!"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("BATAL")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text("RESET", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      try {
        // 1. Hapus Semua di Lokal (SQLite)
        await DatabaseHelper.instance.deleteAll();

        // 2. Hapus Semua di Cloud (Firestore)
        var snapshots = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transaksi')
            .get();

        for (var doc in snapshots.docs) {
          await doc.reference.delete();
        }

        _refreshData(); // Refresh UI agar kosong
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data berhasil direset total ✅"))
          );
        }
      } catch (e) {
        // print("Error reset: $e");
      }
    }
  }

  Future<void> _refreshData() async {
    // Mengambil data melalui DatabaseHelper
    final List<Map<String, dynamic>> maps = await DatabaseHelper.instance.queryAllRows();
    _hitungStatistik(maps);
    setState(() { 
      riwayat = maps; 
      filteredRiwayat = maps; 
    });
  }

  Future<void> _hapusTransaksi(int id) async {
    // Ambil User ID yang sedang login
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Anda belum login!")),
      );
      return;
    }
  
    try {
      // 1. Hapus di lokal (SQLite)
      await DatabaseHelper.instance.delete(id);
      
      // 2. Hapus di Cloud Firestore (Folder Pribadi User)
      await FirebaseFirestore.instance
          .collection('users') // Koleksi Utama
          .doc(user.uid)       // Folder unik milik akun Anda
          .collection('transaksi') // Sub-koleksi transaksi Anda
          .doc(id.toString())
          .delete();
  
      _refreshData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data terhapus dari HP & Cloud pribadi ✅")),
        );
      }
    } catch (e) {
      // print("Gagal hapus di Cloud: $e");
      _refreshData();
    }
  }

  void _showDetailTransaksi(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Detail: ${item['nama']}", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tanggal: ${item['tanggal']}"),
            Text("Jam: ${item['jam_mulai']} - ${item['jam_selesai']}"),
            const Divider(),
            Text("Sewa GOR: ${item['gor']} Jam"),
            Text("Sewa Raket: ${item['raket']} Unit"),
            Text("Beli Kok: ${item['kok']} Pcs"),
            const Divider(),
            Text("Total: ${formatUang(item['total'])}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            Text("Bayar: ${formatUang(item['bayar'])}"),
            Text("Kembali: ${formatUang(item['kembali'])}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("TUTUP")),
        ],
      ),
    );
  }

  void _buatRekapBulanan() {
    // Ambil bulan dan tahun saat ini (format MM-yyyy)
    String bulanIni = DateFormat('MM-yyyy').format(DateTime.now());
    double totalPemasukan = 0;

    String detail = "📊 REKAP GOR BADMINTON - $bulanIni\n";
    detail += "==========================\n\n";

    // Filter data berdasarkan bulan ini
    for (var item in riwayat) {
      if (item['tanggal'].toString().contains(bulanIni)) {
        detail += "📅 ${item['tanggal']}\n";
        detail += "👤 Pelanggan: ${item['nama']}\n";
        detail += "💰 Total: ${formatUang(item['total'])}\n";
        detail += "--------------------------\n";
        totalPemasukan += item['total'];
      }
    }

    detail += "\n✅ TOTAL PENDAPATAN: ${formatUang(totalPemasukan)}";

    // Menggunakan package share_plus untuk mengirim teks rekap
    Share.share(detail, subject: 'Rekap Bulanan GOR');
  }

  Future<void> _sinkronkanKeCloud() async {
    try {
      // 1. Ambil User yang sedang login
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silakan login terlebih dahulu.")));
        return;
      }

      final dataLokal = await DatabaseHelper.instance.queryAllRows();

      if (dataLokal.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tidak ada data untuk disinkronkan.")));
        return;
      }

      final firestore = FirebaseFirestore.instance;

      // 2. Gunakan Batch agar lebih cepat dan hemat kuota
      WriteBatch batch = firestore.batch();

      for (var row in dataLokal) {
        // Masukkan ke: users -> [UID ANDA] -> bookings -> [ID]
        var docRef = firestore
            .collection('users')
            .doc(user.uid)
            .collection('bookings') // Ganti nama koleksi agar rapi di bawah user
            .doc(row['id'].toString());

        batch.set(docRef, row, SetOptions(merge: true));
      }

      await batch.commit();

      // 3. Update tampilan lokal agar angka pemasukan sinkron
      _refreshData(); 

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Semua data berhasil dicadangkan ke Cloud! ☁️ ✅")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal sinkron: $e")));
    }
  }

  Future<void> _saveSettings(String nama, double g, double r, double k) async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
  
    // Simpan di Lokal
    await prefs.setString('nama_gor', nama);
    await prefs.setDouble('hrg_gor', g);
    await prefs.setDouble('hrg_raket', r);
    await prefs.setDouble('hrg_kok', k);
  
    // Simpan di Cloud agar tidak hilang saat uninstall
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'nama_gor': nama,
            'hrg_gor': g,
            'hrg_raket': r,
            'hrg_kok': k,
          }, SetOptions(merge: true)); // Gunakan merge agar tidak menimpa sub-koleksi transaksi
    }
    _loadSettings();
  }

  void _hitungStatistik(List<Map<String, dynamic>> data) {
    double g = 0, r = 0, k = 0, total = 0;
    String filterBulan = DateFormat('MM-yyyy').format(selectedDate);
    for (var item in data) {
      if (item['tanggal'].toString().contains(filterBulan)) {
        g += (item['gor'] * hargaGor);
        r += (item['raket'] * hargaRaket);
        k += (item['kok'] * hargaKok);
        total += item['total'];
      }
    }
    setState(() { totalGor = g; totalRaket = r; totalKok = k; totalPemasukan = total; });
  }

  String formatUang(dynamic angka) => NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(angka);

  @override
  Widget build(BuildContext context) {
    final pages = [_buildMenuUtama(), _buildMenuRiwayat(), _buildMenuStatistik(), _buildMenuSettings()];
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() { _currentIndex = i; isSearching = false; }),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: "Beranda"),
          NavigationDestination(icon: Icon(Icons.receipt_long_rounded), label: "Riwayat"),
          NavigationDestination(icon: Icon(Icons.analytics_rounded), label: "Statistik"),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: "Pengaturan"),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton.extended(
        onPressed: hargaGor > 0 ? () => _showInputTahap1(context) : () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Atur harga di menu Pengaturan dulu ya!")));
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text("Booking"),
        backgroundColor: hargaGor > 0 ? null : Colors.grey,
      ) : null,
    );
  }

  // --- MENU UTAMA (Custom Title) ---
  Widget _buildMenuUtama() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 150, pinned: true,
          actions: [ // <--- TAMBAHKAN INI
            IconButton(
              icon: const Icon(Icons.cloud_sync, color: Colors.white),
              onPressed: _sinkronkanKeCloud,
              tooltip: "Sinkron Cloud",
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(namaGor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            background: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF388E3C)]))),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              if(hargaGor == 0) Card(
                color: Colors.orange.shade100,
                child: const ListTile(
                  leading: Icon(Icons.warning, color: Colors.orange), 
                  title: Text("Harga belum diatur!", style: TextStyle(color: Colors.black))
                  ),
                ),
              const SizedBox(height: 10),
              _statBox("Pemasukan ${DateFormat('MMMM').format(selectedDate)}", formatUang(totalPemasukan), Colors.green),
            ]),
          ),
        ),
        SliverList(delegate: SliverChildBuilderDelegate((ctx, i) => _itemCard(riwayat[i]), childCount: riwayat.length > 5 ? 5 : riwayat.length)),
      ],
    );
  }

  // --- MENU PENGATURAN (Fitur Baru) ---
  Widget _buildMenuSettings() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Row(
          children: [
            Icon(Icons.settings_suggest, color: Colors.green),
            SizedBox(width: 10),
            Text(
              "Konfigurasi Harga GOR",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // URUTAN SEKARANG: Controller -> Label -> Icon
        _inputHarga(namaController, "Nama GOR", Icons.business, false), 
        const SizedBox(height: 10),
        _inputHarga(gorController, "Harga Sewa Lapangan", Icons.stadium, true), 
        const SizedBox(height: 10),
        _inputHarga(raketController, "Harga Sewa Raket", Icons.sports_tennis, true), 
        const SizedBox(height: 10),
        _inputHarga(kokController, "Harga Satuan Kok", Icons.sports_baseball, true),

        const SizedBox(height: 25),

        ElevatedButton.icon(
          onPressed: () async {
            // 1. Ambil data dari masing-masing controller
            String nama = namaController.text;

            // 2. Hilangkan titik format uang sebelum disimpan ke database (angka murni)
            double g = double.tryParse(gorController.text.replaceAll('.', '')) ?? 0;
            double r = double.tryParse(raketController.text.replaceAll('.', '')) ?? 0;
            double k = double.tryParse(kokController.text.replaceAll('.', '')) ?? 0;

            // 3. Panggil fungsi simpan yang sudah kita buat sebelumnya
            await _saveSettings(nama, g, r, k);

            // 4. Beri notifikasi ke user
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pengaturan berhasil disimpan! ✅"), backgroundColor: Colors.green),
              );
            }
          },
          icon: const Icon(Icons.save),
          label: const Text("SIMPAN PERUBAHAN"),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 25),
          child: Divider(thickness: 1),
        ),

        const Text(
          "Manajemen Akun & Data",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 15),

        // Tombol Reset Data
        Card(
          elevation: 0,
          color: Colors.red.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.shade100),
          ),
          child: ListTile(
            leading: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
            title: const Text("Reset Semua Data", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            subtitle: const Text("Hapus riwayat di HP & Cloud secara permanen"),
            onTap: _resetSemuaData,
          ),
        ),

        const SizedBox(height: 10),

        // Tombol Logout
        Card(
          elevation: 0,
          color: Colors.orange.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange.shade100),
          ),
          child: ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.orange),
            title: const Text("Keluar (Logout)", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            subtitle: const Text("Keluar dari sesi admin saat ini"),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HalamanLogin()),
                  (route) => false,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _inputHarga(TextEditingController c, String l, IconData i, bool isNomor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: c,
        // Jika isNomor true maka tampilkan keyboard angka, jika false keyboard biasa
        keyboardType: isNomor ? TextInputType.number : TextInputType.text,
        inputFormatters: isNomor ? [
          FilteringTextInputFormatter.digitsOnly,
          CurrencyInputFormatter(),
        ] : [], // Jika bukan nomor, biarkan kosong agar bisa ngetik huruf
        decoration: InputDecoration(
          labelText: l,
          prefixIcon: Icon(i),
          // Hanya tampilkan Rp jika itu adalah input nomor/harga
          prefixText: isNomor ? "Rp " : null, 
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // --- LOGIKA TRANSAKSI ---
  void _showInputTahap1(BuildContext context) {
    int jam = 0, raket = 0, kok = 0;
    TimeOfDay startTime = TimeOfDay.now();
    TextEditingController namaCtrl = TextEditingController();

    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setS) {
        int endHour = (startTime.hour + jam) % 24;
        String jamM = "${startTime.hour.toString().padLeft(2,'0')}:${startTime.minute.toString().padLeft(2,'0')}";
        String jamS = "${endHour.toString().padLeft(2,'0')}:${startTime.minute.toString().padLeft(2,'0')}";

        return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("Input Booking", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: "Nama Pelanggan", border: OutlineInputBorder())),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Jam Main:"),
              ActionChip(label: Text(jamM), onPressed: () async {
                final t = await showTimePicker(context: context, initialTime: startTime);
                if(t != null) setS(() => startTime = t);
              }),
              const Icon(Icons.arrow_forward),
              Chip(label: Text(jamS)),
            ]),
            _counter("Sewa GOR (Jam)", jam, (v) => setS(() => jam = v)),
            _counter("Sewa Raket", raket, (v) => setS(() => raket = v)),
            _counter("Beli Kok", kok, (v) => setS(() => kok = v)),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () {
              Navigator.pop(ctx);
              _showInputTahap2(context, namaCtrl.text, jam, raket, kok, jamM, jamS);
            }, child: const Text("LANJUT KE PEMBAYARAN")))
          ]));
      });
    });
  }

  void _showInputTahap2(BuildContext context, String n, int g, int r, int k, String s, String e) {
    double total = (g * hargaGor) + (r * hargaRaket) + (k * hargaKok);
    TextEditingController bCtrl = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setS) {
        double bayar = double.tryParse(bCtrl.text.replaceAll('.', '')) ?? 0;
        return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("Total Tagihan: ${formatUang(total)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 15),
            TextField(controller: bCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Uang Bayar", prefixText: "Rp "),
              onChanged: (v) {
                if(v.isNotEmpty) {
                  String val = v.replaceAll('.', '');
                  String fmt = NumberFormat.decimalPattern('id').format(int.parse(val));
                  bCtrl.value = TextEditingValue(text: fmt, selection: TextSelection.collapsed(offset: fmt.length));
                }
                setS(() {});
              },
            ),
            const SizedBox(height: 20),
            // Baris 573: Tombol Simpan Transaksi
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: bayar >= total ? () async {
                  // 1. Simpan ke Database Lokal (SQLite)
                  await DatabaseHelper.instance.insert({
                    'nama': n.isEmpty ? "Pelanggan" : n,
                    'gor': g,
                    'raket': r,
                    'kok': k,
                    'total': total,
                    'bayar': bayar,
                    'kembali': bayar - total,
                    'waktu': DateFormat('HH:mm').format(DateTime.now()),
                    'jam_mulai': s,
                    'jam_selesai': e,
                    'tanggal': DateFormat('dd-MM-yyyy').format(DateTime.now()),
                  });
            
                  // 2. TRIGGER AUTO-SYNC (TAMBAHKAN INI)
                  try {
                    await _sinkronkanKeCloud(); // Memanggil fungsi sinkron Anda
                    // Notifikasi sukses sudah ada di dalam fungsi _sinkronkanKeCloud
                  } catch (e) {
                    // Jika offline atau error, beri peringatan lembut
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Data aman di HP! 📱 Hubungkan internet lalu tekan ☁️ untuk cadangkan."),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
            
                  // 3. Tutup Dialog & Refresh
                  _refreshData();
                  Navigator.pop(ctx);
                } : null,
                child: const Text("SIMPAN TRANSAKSI"),
              ),
            ),
          ]));
      });
    });
  }

  // --- UI LAINNYA ---
  Widget _statBox(String lbl, String val, Color clr) => Card(child: ListTile(title: Text(lbl), subtitle: Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: clr))));
  
  Widget _buildMenuRiwayat() {
    List<Map<String, dynamic>> filter(String category) {
      DateTime now = DateTime.now();
      String today = DateFormat('dd-MM-yyyy').format(now);
      String yesterday = DateFormat('dd-MM-yyyy').format(now.subtract(const Duration(days: 1)));

      // Ambil data berdasarkan kategori waktu dulu
      List<Map<String, dynamic>> temp = [];
      if (category == "Hari Ini") {
        temp = riwayat.where((i) => i['tanggal'] == today).toList();
      } else if (category == "Kemarin") {
        temp = riwayat.where((i) => i['tanggal'] == yesterday).toList();
      } else {
        temp = List.from(riwayat);
      }

      // Kemudian filter berdasarkan nama jika ada input di pencarian
      if (_searchController.text.isNotEmpty) {
        temp = temp.where((i) => 
          i['nama'].toLowerCase().contains(_searchController.text.toLowerCase())
        ).toList();
      }
      return temp;
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Riwayat"),
          // TAMBAHKAN TOMBOL REKAP DI SINI
          actions: [
            IconButton(
              icon: const Icon(Icons.summarize),
              onPressed: _buatRekapBulanan,
              tooltip: "Buat Rekap Bulanan",
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100), // Tinggi ditambah untuk search bar
            child: Column(
              children: [
                // SEARCH BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari nama pelanggan...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onChanged: (val) => setState(() {}), // Refresh tiap ketik
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(text: "Hari Ini"),
                    Tab(text: "Kemarin"),
                    Tab(text: "Semua"),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _listRiwayatCustom(filter("Hari Ini")),
            _listRiwayatCustom(filter("Kemarin")),
            _listRiwayatCustom(filter("Semua")),
          ],
        ),
      ),
    );
  }

Widget _listRiwayatCustom(List<Map<String, dynamic>> data) {
  if (data.isEmpty) return const Center(child: Text("Belum ada data"));
  return ListView.builder(
    itemCount: data.length,
    itemBuilder: (ctx, i) => _itemCard(data[i]),
  );
}

  Widget _itemCard(Map<String, dynamic> item) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    child: ListTile(
      onTap: () => _showDetailTransaksi(item),
      title: Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("${item['tanggal']} | ${item['jam_mulai']} - ${item['jam_selesai']}"),
      trailing: Row( // Ubah trailing menjadi Row agar bisa menampung 2 tombol
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.blue),
            onPressed: () => _shareStruk(item),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              // Tampilkan konfirmasi sebelum hapus
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Hapus Data?"),
                  content: const Text("Data ini akan dihapus permanen dari HP."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("BATAL")),
                    TextButton(
                      onPressed: () {
                        _hapusTransaksi(item['id']);
                        Navigator.pop(ctx);
                      },
                      child: const Text("HAPUS", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );

  void _shareStruk(Map<String, dynamic> item) {
    String struk = """
🏸 *STRUK ${namaGor.toUpperCase()}* 🏸
------------------------------------------
Pelanggan: ${item['nama']}
Jadwal: ${item['jam_mulai']} - ${item['jam_selesai']}
------------------------------------------
DETAIL:
${item['gor'] > 0 ? '• GOR (${item['gor']} Jam) : ${formatUang(item['gor'] * hargaGor)}' : ''}
${item['raket'] > 0 ? '• Raket (${item['raket']} Unit) : ${formatUang(item['raket'] * hargaRaket)}' : ''}
${item['kok'] > 0 ? '• Kok (${item['kok']} Pcs) : ${formatUang(item['kok'] * hargaKok)}' : ''}
------------------------------------------
*TOTAL : ${formatUang(item['total'])}*
------------------------------------------
""";
    Share.share(struk);
  }

  Widget _buildMenuStatistik() => Scaffold(
    appBar: AppBar(title: const Text("Statistik")),
    body: Center(child: Column(children: [
      const SizedBox(height: 20),
      Text("Total Pemasukan: ${formatUang(totalPemasukan)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      SizedBox(height: 300, child: PieChart(PieChartData(sections: [
        PieChartSectionData(value: totalGor, title: "GOR", color: Colors.blue),
        PieChartSectionData(value: totalRaket, title: "Raket", color: Colors.orange),
        PieChartSectionData(value: totalKok, title: "Kok", color: Colors.red),
      ])))
    ])),
  );

  Widget _counter(String l, int c, Function(int) onUpd) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(l), Row(children: [IconButton(onPressed: c > 0 ? () => onUpd(c - 1) : null, icon: const Icon(Icons.remove_circle_outline)), Text("$c"), IconButton(onPressed: () => onUpd(c + 1), icon: const Icon(Icons.add_circle_outline))])
  ]);
}