// File: lib/ptm8/auth_page.dart
// AuthGate & Layar Login/Register untuk Chef menggunakan Supabase Auth

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'order_page.dart';

class AuthGatePtm8 extends StatefulWidget {
  const AuthGatePtm8({super.key});

  @override
  State<AuthGatePtm8> createState() => _AuthGatePtm8State();
}

class _AuthGatePtm8State extends State<AuthGatePtm8> {
  bool _initializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _setupSupabase();
  }

  Future<void> _setupSupabase() async {
    // Periksa apakah kredensial masih placeholder
    if (SupabaseConfig.supabaseUrl.contains('YOUR_PROJECT_ID') ||
        SupabaseConfig.supabaseAnonKey.contains('YOUR_SUPABASE_ANON_KEY')) {
      setState(() {
        _initializing = false;
        _initError = 'Kredensial Supabase belum diisi!\n'
            'Silakan masukkan Project URL & Anon Key Anda di:\n'
            'lib/ptm8/supabase_config.dart';
      });
      return;
    }

    try {
      await SupabaseConfig.initialize();
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _initError = 'Gagal inisialisasi Supabase: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Menghubungkan ke Supabase...'),
            ],
          ),
        ),
      );
    }

    if (_initError != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kitchen Orders - Supabase Setup'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFFDBA74)),
              ),
              color: const Color(0xFFFFF7ED),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 56,
                      color: Color(0xFFEA580C),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Konfigurasi Diperlukan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9A3412),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _initError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7C2D12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
                      ),
                      onPressed: () {
                        setState(() {
                          _initializing = true;
                          _initError = null;
                        });
                        _setupSupabase();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Langsung masuk ke daftar order tanpa perlu login
    return const OrderPage();
  }
}

class ChefAuthPage extends StatefulWidget {
  const ChefAuthPage({super.key});

  @override
  State<ChefAuthPage> createState() => _ChefAuthPageState();
}

class _ChefAuthPageState extends State<ChefAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoginMode = true; // true = Login, false = Register
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final auth = Supabase.instance.client.auth;

    try {
      if (_isLoginMode) {
        await auth.signInWithPassword(email: email, password: password);
      } else {
        final response = await auth.signUp(email: email, password: password);
        if (response.session == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registrasi berhasil! Silakan login atau nonaktifkan Confirm Email di dashboard Supabase.',
              ),
              backgroundColor: Color(0xFF0284C7),
            ),
          );
          setState(() {
            _isLoginMode = true;
          });
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal terhubung ke server: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Dapur & Kitchen Orders'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu_rounded,
                          size: 34,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isLoginMode ? 'Login Chef Dapur' : 'Daftar Akun Chef',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Kelola pesanan dapur pelanggan secara real-time',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Color(0xFFB91C1C), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Color(0xFFB91C1C),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Chef',
                          hintText: 'chef@dapur.com',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Minimal 6 karakter',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password wajib diisi';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _isLoading ? null : _submitAuth,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isLoginMode ? 'Masuk ke Dapur' : 'Daftar Akun Baru',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _isLoginMode = !_isLoginMode;
                                  _errorMessage = null;
                                });
                              },
                        child: Text(
                          _isLoginMode
                              ? 'Belum punya akun? Daftar Chef baru di sini'
                              : 'Sudah punya akun? Masuk di sini',
                          style: const TextStyle(color: Color(0xFFEA580C)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
