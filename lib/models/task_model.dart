// File: lib/models/task_model.dart
// Model data untuk Task / To-Do List yang mendukung SQLite & Supabase

class TaskModel {
  final int? id;
  final String? userId; // ID Akun pemilik tugas (UUID Supabase atau string akun)
  final String judul;
  final String isi;
  final bool isCompleted;

  TaskModel({
    this.id,
    this.userId,
    required this.judul,
    required this.isi,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'judul': judul,
      'isi': isi,
      'is_completed': isCompleted ? 1 : 0,
    };
    if (userId != null) {
      map['user_id'] = userId;
    }
    return map;
  }

  // Format JSON untuk REST API / Supabase
  Map<String, dynamic> toSupabaseJson() {
    final map = <String, dynamic>{
      'judul': judul,
      'isi': isi,
      'is_completed': isCompleted,
    };
    if (userId != null) {
      map['user_id'] = userId;
    }
    return map;
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] is int ? map['id'] as int : int.tryParse(map['id']?.toString() ?? ''),
      userId: map['user_id']?.toString(),
      judul: map['judul'] as String? ?? '',
      isi: map['isi'] as String? ?? '',
      isCompleted: map['is_completed'] == 1 ||
          map['is_completed'] == true ||
          map['isCompleted'] == 1 ||
          map['isCompleted'] == true,
    );
  }
}
