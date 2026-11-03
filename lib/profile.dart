import 'package:flutter/material.dart';
import 'package:praktikum_mp_04sife02_ammar/auth/login.dart';
import 'package:praktikum_mp_04sife02_ammar/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _nama = "";
  String _email = "";
  String _nim = "241011750161";

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final currentEmail = await AuthService.instance.getCurrentUserEmail();
    if (mounted) {
      setState(() {
        _nama = prefs.getString('nama') ?? 'Pengguna';
        _email = currentEmail ?? (prefs.getString('email') ?? prefs.getString('username') ?? '-');
        _nim = prefs.getString('nim') ?? '241011750161';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await AuthService.instance.logout();

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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: CircleAvatar(
                radius: 46,
                backgroundImage: AssetImage('assets/cat_aaa.jpeg'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: const Text('Nama Pengguna', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(_nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email_outlined, color: Colors.blue),
                      title: const Text('Email Akun', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(_email, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.badge_outlined, color: Colors.blue),
                      title: const Text('NIM', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      subtitle: Text(_nim, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _handleLogout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout dari Aplikasi', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
