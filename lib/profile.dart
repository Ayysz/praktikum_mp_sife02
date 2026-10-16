import 'package:flutter/material.dart';
import 'package:praktikum_mp_04sife02_ammar/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  String _nama = "";
  String _nim = "241011750161";

  Future<void> _loadNama() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nama = prefs.getString('nama') ?? '';
    });
  }

  Future<void> _loadNim() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nim = prefs.getString('nim') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadNama();
    _loadNim();
  }

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // atau prefs.remove('isLoggedIn');

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 10,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: CircleAvatar(radius: 40, backgroundImage: AssetImage('assets/cat_aaa.jpeg')),
            ),
            Text("Nama: $_nama"),
            Text("NIM: $_nim"),
            ElevatedButton(
              onPressed: () => _handleLogout(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('loguttt>>'),
            ),
          ],
        ),
      ),
    );
  }
}