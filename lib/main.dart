import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const AplikasiGOR());

class AplikasiGOR extends StatelessWidget {
  const AplikasiGOR({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF1B5E20), brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF1B5E20), brightness: Brightness.dark),
      home: const Beranda(),
    );
  }
}

class Beranda extends StatefulWidget {
  const Beranda({super.key});
  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  int _currentIndex = 0;
  double tGor = 0, tRaket = 0, tKok = 0, totalPemasukan = 0;
  List<Map<String, dynamic>> riwayat = [];
  List<Map<String, dynamic>> filteredRiwayat = [];
  late Database db;
  bool isSearching = false;
  DateTime selectedDate = DateTime.now();
  
  // Variabel Pengaturan User
  String namaGOR = "Badminton Cashier";
  double hrgGor = 0, hrgRaket = 0, hrgKok = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initDb();
  }

  // Load Nama GOR dan Harga dari Memori HP
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      namaGOR = prefs.getString('nama_gor') ?? "Badminton Cashier";
      hrgGor = prefs.getDouble('hrg_gor') ?? 0;
      hrgRaket = prefs.getDouble('hrg_raket') ?? 0;
      hrgKok = prefs.getDouble('hrg_kok') ?? 0;
    });
  }

  Future<void> _saveSettings(String nama, double g, double r, double k) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama_gor', nama);
    await prefs.setDouble('hrg_gor', g);
    await prefs.setDouble('hrg_raket', r);
    await prefs.setDouble('hrg_kok', k);
    _loadSettings();
  }

  Future<void> _initDb() async {
    db = await openDatabase(p.join(await getDatabasesPath(), 'gor_pro_v1.db'),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE transaksi(id INTEGER PRIMARY KEY AUTOINCREMENT, nama TEXT, gor INTEGER, raket INTEGER, kok INTEGER, total REAL, bayar REAL, kembali REAL, waktu TEXT, jam_mulai TEXT, jam_selesai TEXT, tanggal TEXT)");
    }, version: 1);
    _refreshData();
  }

  Future<void> _refreshData() async {
    final List<Map<String, dynamic>> maps = await db.query('transaksi', orderBy: "id DESC");
    _hitungStatistik(maps);
    setState(() { riwayat = maps; filteredRiwayat = maps; });
  }

  void _hitungStatistik(List<Map<String, dynamic>> data) {
    double g = 0, r = 0, k = 0, total = 0;
    String filterBulan = DateFormat('MM-yyyy').format(selectedDate);
    for (var item in data) {
      if (item['tanggal'].toString().contains(filterBulan)) {
        g += (item['gor'] * hrgGor);
        r += (item['raket'] * hrgRaket);
        k += (item['kok'] * hrgKok);
        total += item['total'];
      }
    }
    setState(() { tGor = g; tRaket = r; tKok = k; totalPemasukan = total; });
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
        onPressed: hrgGor > 0 ? () => _showInputTahap1(context) : () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Atur harga di menu Pengaturan dulu ya!")));
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text("Booking"),
        backgroundColor: hrgGor > 0 ? null : Colors.grey,
      ) : null,
    );
  }

  // --- MENU UTAMA (Custom Title) ---
  Widget _buildMenuUtama() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 150, pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(namaGOR, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            background: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF388E3C)]))),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              if(hrgGor == 0) Card(
                color: Colors.orange.shade100,
                child: const ListTile(leading: Icon(Icons.warning, color: Colors.orange), title: Text("Harga belum diatur!", style: TextStyle(color: Colors.black))),
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
    final nCtrl = TextEditingController(text: namaGOR);
    final gCtrl = TextEditingController(text: hrgGor.toInt().toString());
    final rCtrl = TextEditingController(text: hrgRaket.toInt().toString());
    final kCtrl = TextEditingController(text: hrgKok.toInt().toString());

    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan Profil & Harga")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: nCtrl, decoration: const InputDecoration(labelText: "Nama GOR / Bisnis", border: OutlineInputBorder(), prefixIcon: Icon(Icons.store))),
          const SizedBox(height: 20),
          const Text("Atur Harga Sewa (Per Unit/Jam)", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _inputHarga(gCtrl, "Harga GOR / Jam", Icons.stadium),
          _inputHarga(rCtrl, "Harga Raket", Icons.sports_tennis),
          _inputHarga(kCtrl, "Harga Kok", Icons.sports_volleyball),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              _saveSettings(nCtrl.text, double.parse(gCtrl.text), double.parse(rCtrl.text), double.parse(kCtrl.text));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pengaturan Berhasil Disimpan!")));
            },
            child: const Text("SIMPAN PERUBAHAN"),
          )
        ],
      ),
    );
  }

  Widget _inputHarga(TextEditingController c, String l, IconData i) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(controller: c, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: l, prefixIcon: Icon(i), prefixText: "Rp ", border: const OutlineInputBorder())),
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
    double total = (g * hrgGor) + (r * hrgRaket) + (k * hrgKok);
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
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: bayar >= total ? () async {
              await db.insert('transaksi', {
                'nama': n.isEmpty ? "Pelanggan" : n, 'gor': g, 'raket': r, 'kok': k,
                'total': total, 'bayar': bayar, 'kembali': bayar-total,
                'waktu': DateFormat('HH:mm').format(DateTime.now()),
                'jam_mulai': s, 'jam_selesai': e,
                'tanggal': DateFormat('dd-MM-yyyy').format(DateTime.now())
              });
              _refreshData(); Navigator.pop(ctx);
            } : null, child: const Text("SIMPAN TRANSAKSI")))
          ]));
      });
    });
  }

  // --- UI LAINNYA ---
  Widget _statBox(String lbl, String val, Color clr) => Card(child: ListTile(title: Text(lbl), subtitle: Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: clr))));
  
  Widget _buildMenuRiwayat() => Scaffold(
    appBar: AppBar(title: const Text("Riwayat")),
    body: ListView.builder(itemCount: filteredRiwayat.length, itemBuilder: (ctx, i) => _itemCard(filteredRiwayat[i])),
  );

  Widget _itemCard(Map<String, dynamic> item) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    child: ListTile(
      title: Text(item['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("${item['tanggal']} | ${item['jam_mulai']} - ${item['jam_selesai']}"),
      trailing: IconButton(icon: const Icon(Icons.share, color: Colors.blue), onPressed: () => _shareStruk(item)),
    ),
  );

  void _shareStruk(Map<String, dynamic> item) {
    String struk = """
🏸 *STRUK ${namaGOR.toUpperCase()}* 🏸
------------------------------------------
Pelanggan: ${item['nama']}
Jadwal: ${item['jam_mulai']} - ${item['jam_selesai']}
------------------------------------------
DETAIL:
${item['gor'] > 0 ? '• GOR (${item['gor']} Jam) : ${formatUang(item['gor'] * hrgGor)}' : ''}
${item['raket'] > 0 ? '• Raket (${item['raket']} Unit) : ${formatUang(item['raket'] * hrgRaket)}' : ''}
${item['kok'] > 0 ? '• Kok (${item['kok']} Pcs) : ${formatUang(item['kok'] * hrgKok)}' : ''}
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
        PieChartSectionData(value: tGor, title: "GOR", color: Colors.blue),
        PieChartSectionData(value: tRaket, title: "Raket", color: Colors.orange),
        PieChartSectionData(value: tKok, title: "Kok", color: Colors.red),
      ])))
    ])),
  );

  Widget _counter(String l, int c, Function(int) onUpd) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(l), Row(children: [IconButton(onPressed: c > 0 ? () => onUpd(c - 1) : null, icon: const Icon(Icons.remove_circle_outline)), Text("$c"), IconButton(onPressed: () => onUpd(c + 1), icon: const Icon(Icons.add_circle_outline))])
  ]);
}