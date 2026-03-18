import 'package:flutter/material.dart';

void main() => runApp(const AplikasiGOR());

class AplikasiGOR extends StatelessWidget {
  const AplikasiGOR({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
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
  
  // Data Total Hari Ini
  double totalHariIni = 0;
  double totalSewaGor = 0;
  double totalSewaRaket = 0;
  double totalBeliKok = 0;

  // Riwayat Transaksi (List sederhana)
  List<Map<String, dynamic>> riwayat = [];

  void _simpanTransaksi(String nama, int gor, int raket, int kok, double bayar) {
    double subGor = gor * 15000;
    double subRaket = raket * 10000;
    double subKok = kok * 13000;
    double total = subGor + subRaket + subKok;

    setState(() {
      totalHariIni += total;
      totalSewaGor += subGor;
      totalSewaRaket += subRaket;
      totalBeliKok += subKok;
      
      riwayat.insert(0, {
        'nama': nama.isEmpty ? "Pelanggan Umum" : nama,
        'detail': "$gor Jam, $raket Raket, $kok Kok",
        'total': total,
        'bayar': bayar,
        'kembali': bayar - total,
        'waktu': "${DateTime.now().hour}:${DateTime.now().minute}"
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildMenuUtama(),
      _buildMenuRiwayat(),
      const Center(child: Text("Halaman Statistik (Coming Soon)")),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Badminton Cashier"), centerTitle: true),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Beranda"),
          NavigationDestination(icon: Icon(Icons.history), label: "Riwayat"),
          NavigationDestination(icon: Icon(Icons.analytics), label: "Statistik"),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton.large(
        onPressed: () => _showInputSheet(context),
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  Widget _buildMenuUtama() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // KARTU UTAMA
          Card(
            color: Colors.green.shade600,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text("PENDAPATAN HARI INI", style: TextStyle(color: Colors.white70)),
                  Text("Rp ${totalHariIni.toInt()}", 
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 3 KARTU KECIL
          Row(
            children: [
              _smallCard("GOR", totalSewaGor, Colors.blue),
              _smallCard("Raket", totalSewaRaket, Colors.orange),
              _smallCard("Kok", totalBeliKok, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallCard(String label, double nilai, Color warna) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text("Rp ${nilai.toInt()}", 
                style: TextStyle(fontWeight: FontWeight.bold, color: warna, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuRiwayat() {
    return riwayat.isEmpty 
      ? const Center(child: Text("Belum ada transaksi hari ini"))
      : ListView.builder(
          itemCount: riwayat.length,
          itemBuilder: (context, i) {
            final item = riwayat[i];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text("${item['nama']} (${item['waktu']})"),
              subtitle: Text("${item['detail']}\nBayar: ${item['bayar']} | Kembali: ${item['kembali']}"),
              trailing: Text("Rp ${item['total'].toInt()}", style: const TextStyle(fontWeight: FontWeight.bold)),
              isThreeLine: true,
            );
          },
        );
  }

  void _showInputSheet(BuildContext context) {
    int jam = 0, raket = 0, kok = 0;
    TextEditingController namaCtrl = TextEditingController();
    TextEditingController bayarCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder( // Agar UI di dalam pop-up bisa berubah saat tombol +/- ditekan
          builder: (context, setSheetState) {
            double total = (jam * 15000) + (raket * 10000) + (kok * 13000);
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 20, right: 20, top: 20
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: "Nama Pelanggan")),
                  _counterRow("Sewa GOR (Jam)", jam, (v) => setSheetState(() => jam = v)),
                  _counterRow("Sewa Raket", raket, (v) => setSheetState(() => raket = v)),
                  _counterRow("Beli Kok", kok, (v) => setSheetState(() => kok = v)),
                  const Divider(),
                  Text("Total Tagihan: Rp ${total.toInt()}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: bayarCtrl, 
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Uang Diterima"),
                    onChanged: (v) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 10),
                  if (bayarCtrl.text.isNotEmpty)
                    Text("Kembalian: Rp ${(double.tryParse(bayarCtrl.text) ?? 0) - total}",
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () {
                        _simpanTransaksi(namaCtrl.text, jam, raket, kok, double.tryParse(bayarCtrl.text) ?? 0);
                        Navigator.pop(context);
                      }, 
                      child: const Text("SIMPAN TRANSAKSI")
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _counterRow(String label, int count, Function(int) onUpdate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            IconButton(onPressed: count > 0 ? () => onUpdate(count - 1) : null, icon: const Icon(Icons.remove_circle_outline)),
            Text("$count", style: const TextStyle(fontSize: 18)),
            IconButton(onPressed: () => onUpdate(count + 1), icon: const Icon(Icons.add_circle_outline)),
          ],
        )
      ],
    );
  }
}