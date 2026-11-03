// File: lib/ptm8/supabase_config.dart
// Konfigurasi koneksi Supabase & helper pembuatan HTTP Header untuk REST API

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Ganti dengan Project URL dari Supabase Dashboard -> Settings -> API
  static const String supabaseUrl = 'https://vgadzxaaocowgsjrkcih.supabase.co';

  // Ganti dengan anon/publishable public key dari Supabase Dashboard -> Settings -> API
  static const String supabasePublishableKey = 'sb_publishable_Fi7uLvLKIBx087sd0pbfRQ_SN1D3P1B';

  // Alias untuk kompatibilitas ke belakang
  static const String supabaseAnonKey = supabasePublishableKey;

  // Endpoint REST API tabel 'orders'
  static const String ordersEndpoint = '$supabaseUrl/rest/v1/orders';

  // Inisialisasi Supabase secara aman (hanya sekali)
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      // Cek apakah Supabase sudah diinisialisasi
      Supabase.instance.client;
      _isInitialized = true;
    } catch (_) {
      // Jika belum diinisialisasi, jalankan initialize
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabasePublishableKey,
      );
      _isInitialized = true;
    }
  }

  // Helper untuk HTTP Header setiap request CRUD ke PostgREST API
  static Map<String, String> getHeaders([String? accessToken]) {
    final token = (accessToken != null && accessToken.isNotEmpty)
        ? accessToken
        : supabasePublishableKey;
    return {
      'apikey': supabasePublishableKey,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    };
  }
}
