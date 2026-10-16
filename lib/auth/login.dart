import 'package:flutter/material.dart';
import 'package:praktikum_mp_04sife02_ammar/auth/register.dart';
import 'package:praktikum_mp_04sife02_ammar/helpers/db_helper.dart';
import 'package:praktikum_mp_04sife02_ammar/home.dart';
import 'package:praktikum_mp_04sife02_ammar/materi.dart';
import 'package:praktikum_mp_04sife02_ammar/navbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = await DbHelper.instance.loginUser(
        _userNameController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user == null) {
        throw Exception('Username atau Password salah');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
      print("================================================");
      print(user.toString());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // builder: (context) => Home(user: user, onNavigateToMateri: onNavigateToMateri),
          builder: (context) => Home(onNavigateToMateri: () => Navbar()),
        ),
      );
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
      appBar: AppBar(title: const Text('Login'), backgroundColor: Colors.blue),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.green,
                  width: double.infinity,
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Form Mahasiswa',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: _userNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama gaboleh kosong';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Nama Lengkap',
                    hintText: 'Masukkan Nama Anda',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password gaboleh kosong';
                    }
                    return null;
                  },
                  obscureText: _isPasswordHidden,
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
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
                    labelText: 'Password',
                    hintText: 'Masukkan Password Anda',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                TextButton(
                  onPressed: (){
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
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _isLoading
          ? const CircularProgressIndicator()
          : FloatingActionButton.extended(
              onPressed: _handleLogin,
              label: const Text('Login'),
              icon: _isLoading ? 
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ) : 
                  const Icon(Icons.login),
            ),
    );
  }
}
