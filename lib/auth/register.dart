import 'package:flutter/material.dart';
import 'package:praktikum_mp_04sife02_ammar/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final message = await AuthService.instance.register(
        nama: _namaController.text.trim(),
        identifier: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().replaceAll('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
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
      appBar: AppBar(title: const Text('Registrasi Akun')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Nama Lengkap',
                    hintText: 'Masukkan Nama Anda',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _emailController,
                  keyboardType: isSupabase
                      ? TextInputType.emailAddress
                      : TextInputType.text,
                  decoration: InputDecoration(
                    icon: Icon(isSupabase ? Icons.email : Icons.account_circle),
                    labelText: isSupabase ? 'Email' : 'Username',
                    hintText: isSupabase
                        ? 'contoh: nama@gmail.com'
                        : 'Masukkan username',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return isSupabase
                          ? 'Email tidak boleh kosong'
                          : 'Username tidak boleh kosong';
                    }
                    if (isSupabase &&
                        (!value.contains('@') || !value.contains('.'))) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordHidden,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.lock),
                    labelText: 'Password',
                    hintText: 'Minimal 6 karakter',
                    border: const OutlineInputBorder(),
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
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmPasswordHidden,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.lock_outline),
                    labelText: 'Konfirmasi Password',
                    hintText: 'Ulangi password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: _isConfirmPasswordHidden
                          ? const Icon(Icons.visibility_off)
                          : const Icon(Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password tidak boleh kosong';
                    }
                    if (value != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _handleRegister,
                        child: const Text('Daftar'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
