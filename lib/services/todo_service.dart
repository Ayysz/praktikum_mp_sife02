// File: lib/services/todo_service.dart
// Service To-Do List yang mendukung Supabase (dengan RLS user_id) dan SQLite lokal

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../helpers/db_helper.dart';
import '../models/task_model.dart';
import '../ptm8/supabase_config.dart';
import 'auth_service.dart';

class TodoService {
  TodoService._internal();
  static final TodoService instance = TodoService._internal();

  String get _tasksEndpoint => '${SupabaseConfig.supabaseUrl}/rest/v1/tasks';

  String? get _supabaseAccessToken =>
      Supabase.instance.client.auth.currentSession?.accessToken;

  /// 1. Ambil daftar tugas milik user yang sedang aktif
  Future<List<TaskModel>> getTasks() async {
    final userId = await AuthService.instance.getCurrentUserId();

    if (AuthService.instance.isSupabaseMode) {
      final token = _supabaseAccessToken;
      if (token != null && token.isNotEmpty) {
        try {
          final uri = Uri.parse('$_tasksEndpoint?select=*&order=id.desc');
          final response = await http.get(
            uri,
            headers: SupabaseConfig.getHeaders(token),
          );

          if (response.statusCode == 200) {
            final List<dynamic> decoded = jsonDecode(response.body);
            return decoded
                .map((item) => TaskModel.fromMap(Map<String, dynamic>.from(item as Map)))
                .toList();
          } else {
            debugPrint('Supabase getTasks response ${response.statusCode}: ${response.body}');
          }
        } on SocketException {
          // Mode offline, baca dari lokal
        } catch (e) {
          debugPrint('getTasks network error: $e');
        }
      }
    }

    // Fallback SQLite lokal (difilter berdasarkan user_id akun aktif)
    return await DbHelper.instance.getAllTask(userId);
  }

  /// 2. Tambah tugas baru milik user aktif
  Future<TaskModel> addTask({
    required String judul,
    required String isi,
  }) async {
    final userId = await AuthService.instance.getCurrentUserId();

    final task = TaskModel(
      userId: userId,
      judul: judul.trim(),
      isi: isi.trim(),
      isCompleted: false,
    );

    // Selalu simpan ke SQLite lokal agar data tetap ada secara offline
    await DbHelper.instance.createTask(task);

    // Jika mode Supabase aktif
    if (AuthService.instance.isSupabaseMode) {
      final token = _supabaseAccessToken;
      if (token == null || token.isEmpty) {
        throw Exception(
          'Sesi login Supabase tidak ditemukan. Silakan login ulang.',
        );
      }

      try {
        final uri = Uri.parse(_tasksEndpoint);
        final response = await http.post(
          uri,
          headers: SupabaseConfig.getHeaders(token),
          body: jsonEncode(task.toSupabaseJson()),
        );

        if (response.statusCode == 201) {
          final List<dynamic> createdList = jsonDecode(response.body);
          if (createdList.isNotEmpty) {
            return TaskModel.fromMap(Map<String, dynamic>.from(createdList.first as Map));
          }
        } else {
          final body = response.body;
          if (body.contains('PGRST205') || body.contains('schema cache')) {
            throw Exception(
              'Tabel "tasks" belum dibuat di Supabase!\n'
              'Silakan jalankan SQL script di lib/ptm9/supabase_tasks.sql pada Supabase SQL Editor.',
            );
          }
          if (body.contains('row-level security') || response.statusCode == 403) {
            throw Exception(
              'Akses ditolak oleh RLS Supabase. Pastikan RLS policy sudah dijalankan di Supabase Dashboard.',
            );
          }
          throw Exception(
            'Gagal menyimpan ke server Supabase (Kode: ${response.statusCode}): $body',
          );
        }
      } on SocketException {
        throw Exception(
          'Tidak dapat terhubung ke internet. Tugas hanya tersimpan di SQLite lokal.',
        );
      } catch (e) {
        if (e.toString().contains('Exception:')) rethrow;
        throw Exception('Gagal menyimpan tugas ke cloud: $e');
      }
    }

    return task;
  }

  /// 3. Toggle / Update status tugas
  Future<void> updateTask(TaskModel task) async {
    await DbHelper.instance.updateTask(task);

    if (AuthService.instance.isSupabaseMode) {
      final token = _supabaseAccessToken;
      if (token != null && token.isNotEmpty && task.id != null) {
        try {
          final uri = Uri.parse('$_tasksEndpoint?id=eq.${task.id}');
          await http.patch(
            uri,
            headers: SupabaseConfig.getHeaders(token),
            body: jsonEncode({'is_completed': task.isCompleted}),
          );
        } catch (e) {
          debugPrint('Sync update task to Supabase error: $e');
        }
      }
    }
  }

  /// 4. Hapus tugas
  Future<void> deleteTask(int id) async {
    await DbHelper.instance.deleteTask(id);

    if (AuthService.instance.isSupabaseMode) {
      final token = _supabaseAccessToken;
      if (token != null && token.isNotEmpty) {
        try {
          final uri = Uri.parse('$_tasksEndpoint?id=eq.$id');
          await http.delete(
            uri,
            headers: SupabaseConfig.getHeaders(token),
          );
        } catch (e) {
          debugPrint('Sync delete task to Supabase error: $e');
        }
      }
    }
  }
}
