import 'package:flutter/material.dart';
import 'package:praktikum_mp_04sife02_ammar/auth/register.dart';
import 'package:praktikum_mp_04sife02_ammar/navbar.dart';
import 'package:praktikum_mp_04sife02_ammar/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await AuthService.instance.login(
        identifier: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login berhasil!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Navbar(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSupabase = AuthService.instance.isSupabaseMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum MP 04SIFE002'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // DEV BANNER TOGGLE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isSupabase
                        ? const Color(0xFFE0F2FE)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSupabase ? const Color(0xFF38BDF8) : const Color(0xFFFBBF24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSupabase ? Icons.cloud_done_rounded : Icons.storage_rounded,
                        color: isSupabase ? Colors.blue.shade700 : Colors.amber.shade900,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isSupabase
                              ? 'Mode Auth: Supabase (Online)'
                              : 'Mode Dev: SQLite (Offline)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSupabase
                                ? Colors.blue.shade900
                                : Colors.amber.shade900,
                          ),
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          setState(() {
                            AuthService.activeMode = isSupabase
                                ? AuthMode.sqlite
                                : AuthMode.supabase;
                          });
                        },
                        child: const Text('Ganti Mode'),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 168, 203, 255),
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        color: const Color.fromARGB(255, 90, 75, 226),
                        width: double.infinity,
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          isSupabase ? 'Login (Email)' : 'Login (Offline)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _emailController,
                        keyboardType: isSupabase
                            ? TextInputType.emailAddress
                            : TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return isSupabase
                                ? 'Email tidak boleh kosong'
                                : 'Username tidak boleh kosong';
                          }
                          if (isSupabase &&
                              (!value.contains('@') || !value.contains('.'))) {
                            return 'Format email tidak valid (contoh: user@gmail.com)';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          icon: Icon(isSupabase ? Icons.email : Icons.person),
                          labelText: isSupabase ? 'Email Pengguna' : 'Username',
                          hintText: isSupabase
                              ? 'Masukkan email terdaftar'
                              : 'Masukkan username',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                        obscureText: _isPasswordHidden,
                        decoration: InputDecoration(
                          icon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: _isPasswordHidden
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isPasswordHidden = !_isPasswordHidden;
                              });
                            },
                          ),
                          labelText: 'Password',
                          hintText: 'Masukkan Password Anda',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: const Color.fromARGB(255, 90, 75, 226),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _handleLogin,
                        child: const Text('Login'),
                      ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Belum punya akun? Daftar disini",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
