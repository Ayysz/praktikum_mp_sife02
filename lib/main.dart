import 'package:flutter/material.dart';
import 'package:praktikum_mp_04sife02_ammar/auth/login.dart';
import 'package:praktikum_mp_04sife02_ammar/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Wajib dipanggil sebelum operasi async di main()
  WidgetsFlutterBinding.ensureInitialized();

  // Cek apakah user sudah pernah login sebelumnya
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.isLoggedIn,
  });


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikkum Mobile Progamming',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: isLoggedIn 
        ? const Navbar() 
        : const LoginPage(),
    );
  }
}

