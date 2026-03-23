import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'halaman_login.dart';
import 'beranda.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AplikasiGOR());
}

class AplikasiGOR extends StatelessWidget {
  const AplikasiGOR({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true, 
        colorSchemeSeed: const Color(0xFF1B5E20), 
        brightness: Brightness.light),
      darkTheme: ThemeData(useMaterial3: true, 
      colorSchemeSeed: const Color(0xFF1B5E20), 
      brightness: Brightness.dark),
      home: FirebaseAuth.instance.currentUser == null 
          ? const HalamanLogin() 
          : const Beranda(),
    );
  }
}