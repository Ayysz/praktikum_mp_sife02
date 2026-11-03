import 'package:flutter/material.dart';
import 'package:praktikum_mp_04sife02_ammar/auth/login.dart';
import 'package:praktikum_mp_04sife02_ammar/navbar.dart';
import 'package:praktikum_mp_04sife02_ammar/services/auth_service.dart';

void main() async {
  // Wajib dipanggil sebelum operasi async di main()
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi AuthService (Supabase / SQLite)
  await AuthService.instance.initialize();

  // Cek apakah user sudah pernah login sebelumnya
  final bool isLoggedIn = await AuthService.instance.checkLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum Mobile Programming',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const Navbar() : const LoginPage(),
    );
  }
}
