import 'package:flutter/material.dart';
import 'package:praktikum_mp_04sife02_ammar/helpers/db_helper.dart';
import 'package:praktikum_mp_04sife02_ammar/models/user_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // controller untuk masing masing input
  final _namaController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Fungsi Register
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final String nama = _namaController.text.trim();
      final newUser = UserModel(
        nama: nama,
        username: _userNameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await DbHelper.instance.registerUser(newUser);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registrasi berhasil! Silahkan login $nama"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    if (value == null || value.isEmpty) {
                      return 'Nama gaboleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: _userNameController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Username',
                    hintText: 'Masukkan Username Anda',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username gaboleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: _passwordController,
                  obscuringCharacter: '*',
                  obscureText: _isPasswordHidden,
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: 'Password',
                    hintText: 'Masukkan Password Anda',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: _isPasswordHidden
                          ? Icon(Icons.visibility_off)
                          : Icon(Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isPasswordHidden = !_isPasswordHidden;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password gaboleh kosong';
                    }
                    return null;
                  },
                  
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscuringCharacter: "*",
                  obscureText: _isConfirmPasswordHidden,
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: 'Confirm Password',
                    hintText: 'Masukkan Confirm Password Anda',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: _isConfirmPasswordHidden
                          ? Icon(Icons.visibility_off)
                          : Icon(Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm Password gaboleh kosong';
                    }
                    if (value != _passwordController.text) {
                      return 'Confirm Password tidak cocok';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Daftar'),
                ),
                SizedBox(height: 20),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     const Text(
                //       'Sudah punya akun? '
                //     ),
                //     TextButton(
                //       onPressed: () {
                //         Navigator.pop(context);
                //       },
                //       child: const Text('Login'),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
