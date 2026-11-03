// File: lib/ptm9/todo_user_page.dart
// Modul Pertemuan 9: To-Do List per User dengan BottomSheet UI modern & error handling transparan

import 'package:flutter/material.dart';
import 'package:praktikum_mp_04sife02_ammar/models/task_model.dart';
import 'package:praktikum_mp_04sife02_ammar/services/auth_service.dart';
import 'package:praktikum_mp_04sife02_ammar/services/todo_service.dart';

class TodoUserPage extends StatefulWidget {
  const TodoUserPage({super.key});

  @override
  State<TodoUserPage> createState() => _TodoUserPageState();
}

class _TodoUserPageState extends State<TodoUserPage> {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String _userEmail = '';
  String _filter = 'ALL'; // 'ALL', 'ACTIVE', 'DONE'

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    loadData();
  }

  Future<void> _loadUserEmail() async {
    final email = await AuthService.instance.getCurrentUserEmail();
    if (mounted) {
      setState(() {
        _userEmail = email ?? 'Pengguna';
      });
    }
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await TodoService.instance.getTasks();
      if (mounted) {
        setState(() {
          _tasks = tasks;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memuat tugas: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleTask(int index, TaskModel task) async {
    final updated = TaskModel(
      id: task.id,
      userId: task.userId,
      judul: task.judul,
      isi: task.isi,
      isCompleted: !task.isCompleted,
    );
    setState(() {
      final targetIndex = _tasks.indexWhere((t) => t.id == task.id);
      if (targetIndex != -1) {
        _tasks[targetIndex] = updated;
      }
    });
    try {
      await TodoService.instance.updateTask(updated);
    } catch (e) {
      _showSnackBar('Gagal update status: $e', isError: true);
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas?'),
        content: Text('Tugas "${task.judul}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && task.id != null) {
      setState(() {
        _tasks.removeWhere((t) => t.id == task.id);
      });
      try {
        await TodoService.instance.deleteTask(task.id!);
        _showSnackBar('Tugas berhasil dihapus');
      } catch (e) {
        _showSnackBar('Gagal menghapus tugas: $e', isError: true);
        loadData();
      }
    }
  }

  void _showAddBottomSheet() {
    final formKey = GlobalKey<FormState>();
    final judulController = TextEditingController();
    final isiController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> handleSave() async {
              if (!formKey.currentState!.validate()) return;

              setModalState(() => isSaving = true);

              try {
                final judul = judulController.text.trim();
                final isi = isiController.text.trim();

                await TodoService.instance.addTask(judul: judul, isi: isi);

                if (bottomContext.mounted) {
                  Navigator.pop(bottomContext);
                }

                _showSnackBar('Tugas baru berhasil disimpan!');
                loadData();
              } catch (e) {
                setModalState(() => isSaving = false);
                final err = e.toString().replaceAll('Exception: ', '');
                _showSnackBar(err, isError: true);
              }
            }

            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.post_add_rounded,
                            color: Colors.deepPurple.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Tambah Todo Baru',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: judulController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Judul Tugas',
                        hintText: 'Misal: Belajar REST API Supabase',
                        prefixIcon: Icon(Icons.title_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Judul tugas wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: isiController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Catatan / Deskripsi',
                        hintText: 'Misal: Selesaikan tugas modul pertemuan 9',
                        prefixIcon: Icon(Icons.notes_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Catatan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isSaving ? null : handleSave,
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan Todo',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = AuthService.instance.isSupabaseMode;

    final filteredTasks = _filter == 'ACTIVE'
        ? _tasks.where((t) => !t.isCompleted).toList()
        : _filter == 'DONE'
            ? _tasks.where((t) => t.isCompleted).toList()
            : _tasks;

    final totalCount = _tasks.length;
    final doneCount = _tasks.where((t) => t.isCompleted).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Todo Per User',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Icon(
                  isOnline ? Icons.cloud_done : Icons.storage,
                  size: 13,
                  color: Colors.white70,
                ),
                const SizedBox(width: 4),
                Text(
                  _userEmail.isNotEmpty ? _userEmail : 'Pengguna',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Segarkan Data',
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Status Akun & Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tugas Selesai: $doneCount / $totalCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    Text(
                      isOnline ? 'Cloud Supabase' : 'Offline SQLite',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isOnline ? Colors.blue.shade700 : Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildFilterChip('Semua', 'ALL'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Belum Selesai', 'ACTIVE'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Selesai', 'DONE'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List Tasks
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTasks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.checklist_rtl_rounded,
                                size: 72,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _tasks.isEmpty
                                    ? 'Belum ada to-do untuk akun:\n$_userEmail'
                                    : 'Tidak ada tugas dengan filter ini',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _showAddBottomSheet,
                                icon: const Icon(Icons.add),
                                label: const Text('Buat Todo Sekarang'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: task.isCompleted
                                    ? Colors.green.shade100
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              leading: Checkbox(
                                value: task.isCompleted,
                                activeColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) => _toggleTask(index, task),
                              ),
                              title: Text(
                                task.judul,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.isCompleted
                                      ? Colors.grey
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  task.isi,
                                  style: TextStyle(
                                    color: task.isCompleted
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              trailing: IconButton(
                                tooltip: 'Hapus Tugas',
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _deleteTask(task),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: _showAddBottomSheet,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Todo'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _filter = value);
        }
      },
      selectedColor: Colors.deepPurple.shade100,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.deepPurple.shade900 : Colors.black87,
      ),
    );
  }
}
