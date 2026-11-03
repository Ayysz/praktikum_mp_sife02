// File: lib/services/auth_service.dart
// Service autentikasi hybrid: Supabase Auth (Online) dengan fallback SQLite (Offline)

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../helpers/db_helper.dart';
import '../models/user_model.dart';
import '../ptm8/supabase_config.dart';

enum AuthMode {
  supabase, // Menggunakan Supabase Auth (Online)
  sqlite,   // Menggunakan SQLite lokal (Offline)
}

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  /// =========================================================================
  /// TOGGLE MODE AUTHENTIKASI (UNTUK DEVELOPER)
  /// Ganti ke `AuthMode.sqlite` jika ingin testing offline tanpa internet.
  /// Default: `AuthMode.supabase`
  /// =========================================================================
  static AuthMode activeMode = AuthMode.supabase;

  /// Helper untuk cek apakah mode Supabase aktif
  bool get isSupabaseMode => activeMode == AuthMode.supabase;

  /// Inisialisasi service saat aplikasi startup
  Future<void> initialize() async {
    if (isSupabaseMode) {
      try {
        await SupabaseConfig.initialize();
      } catch (e) {
        debugPrint('Supabase init warning: $e');
      }
    }
  }

  /// Cek apakah session login tersimpan (baik di Supabase atau SharedPreferences)
  Future<bool> checkLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final bool prefsLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isSupabaseMode) {
      try {
        await SupabaseConfig.initialize();
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          // Sync session ke SharedPreferences agar tetap sinkron
          final user = session.user;
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('email', user.email ?? '');
          await prefs.setString('userId', user.id);
          await prefs.setString('nama', user.userMetadata?['nama'] ?? user.email?.split('@').first ?? 'User');
          return true;
        }
      } catch (_) {
        // Jika offline atau error, fallback ke prefs
        return prefsLoggedIn;
      }
      return prefsLoggedIn;
    } else {
      return prefsLoggedIn;
    }
  }

  /// Ambil email pengguna yang sedang login
  Future<String?> getCurrentUserEmail() async {
    if (isSupabaseMode) {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user?.email != null) return user!.email;
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? prefs.getString('username');
  }

  /// Ambil ID unik pengguna (UUID untuk Supabase, atau String untuk SQLite)
  Future<String?> getCurrentUserId() async {
    if (isSupabaseMode) {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) return user.id;
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? prefs.getString('username');
  }

  /// =========================================================================
  /// LOGIN
  /// =========================================================================
  Future<void> login({
    required String identifier, // Email (Supabase) atau Username/Email (SQLite)
    required String password,
  }) async {
    if (isSupabaseMode) {
      // 1. Cek koneksi internet terlebih dahulu
      await _assertNetworkConnection();

      try {
        await SupabaseConfig.initialize();
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: identifier.trim(),
          password: password.trim(),
        );

        final user = response.user;
        if (user == null) {
          throw Exception('Gagal mendapatkan data akun. Silakan coba lagi.');
        }

        // Simpan sesi ke SharedPreferences agar aplikasi mengingat login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('email', user.email ?? identifier.trim());
        await prefs.setString('userId', user.id);
        await prefs.setString(
          'nama',
          user.userMetadata?['nama'] ?? user.email?.split('@').first ?? 'User',
        );
      } on SocketException {
        throw Exception(
          'Tidak dapat terhubung ke internet. Periksa koneksi WiFi atau kuota data Anda.',
        );
      } on AuthException catch (e) {
        throw Exception(_mapAuthError(e.message));
      } catch (e) {
        if (e.toString().contains('SocketException') ||
            e.toString().contains('Failed host lookup') ||
            e.toString().contains('Network is unreachable') ||
            e.toString().contains('ClientException')) {
          throw Exception(
            'Tidak dapat terhubung ke server Supabase. Pastikan internet Anda aktif.',
          );
        }
        rethrow;
      }
    } else {
      // 2. Mode SQLite Offline
      final user = await DbHelper.instance.loginUser(
        identifier.trim(),
        password.trim(),
      );
      if (user == null) {
        throw Exception('Username atau Password salah (Mode Offline SQLite)');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', user.username);
      await prefs.setString('email', '${user.username}@offline.local');
      await prefs.setString('nama', user.nama);
      await prefs.setString('userId', user.id?.toString() ?? user.username);
    }
  }

  /// =========================================================================
  /// REGISTER
  /// =========================================================================
  Future<String> register({
    required String nama,
    required String identifier, // Email untuk Supabase, username untuk SQLite
    required String password,
  }) async {
    if (isSupabaseMode) {
      await _assertNetworkConnection();

      try {
        await SupabaseConfig.initialize();
        final response = await Supabase.instance.client.auth.signUp(
          email: identifier.trim(),
          password: password.trim(),
          data: {'nama': nama.trim()},
        );

        final user = response.user;
        if (response.session == null) {
          return 'Pendaftaran berhasil! Jika konfirmasi email aktif di Supabase, silakan cek inbox email Anda.';
        } else if (user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('email', user.email ?? identifier.trim());
          await prefs.setString('userId', user.id);
          await prefs.setString('nama', nama.trim());
          return 'Registrasi dan login berhasil!';
        }
        return 'Registrasi berhasil! Silakan login.';
      } on SocketException {
        throw Exception(
          'Tidak dapat terhubung ke internet. Registrasi online membutuhkan koneksi aktif.',
        );
      } on AuthException catch (e) {
        throw Exception(_mapAuthError(e.message));
      } catch (e) {
        if (e.toString().contains('SocketException') ||
            e.toString().contains('Failed host lookup') ||
            e.toString().contains('ClientException')) {
          throw Exception(
            'Tidak dapat terhubung ke server Supabase. Pastikan internet Anda aktif.',
          );
        }
        rethrow;
      }
    } else {
      final newUser = UserModel(
        nama: nama.trim(),
        username: identifier.trim(),
        password: password.trim(),
      );
      await DbHelper.instance.registerUser(newUser);
      return 'Registrasi akun lokal (SQLite) berhasil!';
    }
  }

  /// =========================================================================
  /// LOGOUT
  /// =========================================================================
  Future<void> logout() async {
    try {
      if (isSupabaseMode) {
        await Supabase.instance.client.auth.signOut();
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Pengecekan koneksi internet aktif secara akurat
  Future<void> _assertNetworkConnection() async {
    try {
      final lookup = await InternetAddress.lookup('vgadzxaaocowgsjrkcih.supabase.co')
          .timeout(const Duration(seconds: 4));
      if (lookup.isEmpty || lookup.first.rawAddress.isEmpty) {
        throw const SocketException('No address found');
      }
    } on SocketException {
      throw Exception(
        'Aplikasi tidak terhubung ke internet. Silakan periksa koneksi data/WiFi Anda.',
      );
    } on TimeoutException {
      throw Exception(
        'Koneksi internet lambat atau terputus. Gagal menghubungi server.',
      );
    } catch (_) {
      // Biarkan proses lanjut ke http request jika platform menolak direct raw socket lookup
    }
  }

  /// Menerjemahkan pesan error umum dari Supabase Auth ke Bahasa Indonesia
  String _mapAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('email rate limit exceeded') ||
        lower.contains('over_email_send_rate_limit')) {
      return 'Batas pengiriman email Supabase tercapai (Rate Limit Exceeded).\n'
          'Solusi: Matikan opsi "Confirm email" di Supabase Dashboard -> Authentication -> Providers -> Email.';
    }
    if (lower.contains('rate limit')) {
      return 'Terlalu banyak permintaan dalam waktu singkat (Rate Limit). Silakan tunggu beberapa saat atau matikan "Confirm email" di Supabase Dashboard.';
    }
    if (lower.contains('invalid login credentials')) {
      return 'Email atau password salah. Silakan periksa kembali.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Silakan periksa inbox email Anda, atau matikan "Confirm Email" pada pengaturan Supabase Dashboard.';
    }
    if (lower.contains('user already registered')) {
      return 'Email sudah terdaftar. Silakan login atau gunakan email lain.';
    }
    if (lower.contains('password should be at least')) {
      return 'Password minimal harus terdiri dari 6 karakter.';
    }
    return message;
  }
}

