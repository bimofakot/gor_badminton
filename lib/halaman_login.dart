import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'beranda.dart';

class HalamanLogin extends StatefulWidget {
  const HalamanLogin({super.key});
  @override
  State<HalamanLogin> createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // Fungsi SnackBar agar tidak ngetik berulang kali
  void _notif(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: warna,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _proses(bool isDaftar) async {
    String u = userCtrl.text.trim();
    String p = passCtrl.text.trim();

    // 1. Validasi Input Kosong
    if (u.isEmpty || p.isEmpty) {
      String pesanKosong = isDaftar 
          ? "Lengkapi username dan password untuk mendaftar ya! ✨" 
          : "Ops! Username dan password tidak boleh kosong 😊";
      _notif(pesanKosong, Colors.orange);
      return;
    }

    // Trik Email Bayangan agar Firebase tidak error invalid-email
    String email = "$u@gor.com";

    try {
      if (isDaftar) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: p);
        _notif("Pendaftaran berhasil! Silakan klik tombol Login 🎉", Colors.green);
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: p);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const Beranda()));
        }
      }
    } on FirebaseAuthException catch (e) {
      // 2. Terjemahan Error agar lebih ramah
      String pesanRamah = "Maaf, terjadi kesalahan teknis.";
      
      if (e.code == 'invalid-credential' || e.code == 'user-not-found' || e.code == 'wrong-password') {
        pesanRamah = "Username atau password salah. Cek lagi yuk! 🧐";
      } else if (e.code == 'email-already-in-use') {
        pesanRamah = "Username sudah terdaftar, silakan langsung login saja.";
      } else if (e.code == 'channel-error' || e.code == 'network-request-failed') {
        pesanRamah = "Gagal terhubung. Pastikan internetmu aktif ya! 🌐";
      }

      _notif(pesanRamah, Colors.red);
    } catch (e) {
      _notif("Terjadi kesalahan: ${e.toString()}", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Tambahkan ini agar tidak error saat keyboard muncul
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              const Icon(Icons.sports_tennis, size: 80, color: Colors.green),
              const SizedBox(height: 20),
              const Text("ADMIN GOR BADMINTON", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: userCtrl, 
                decoration: const InputDecoration(
                  labelText: "Username", 
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder()
                )
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passCtrl, 
                obscureText: true, 
                decoration: const InputDecoration(
                  labelText: "Password", 
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder()
                )
              ),
              const SizedBox(height: 30),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _proses(false), 
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 50)),
                    child: const Text("LOGIN")
                  )
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _proses(true), 
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50)),
                    child: const Text("DAFTAR")
                  )
                ),
              ])
            ]
          ),
        ),
      ),
    );
  }
}