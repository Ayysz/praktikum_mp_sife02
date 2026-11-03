import 'package:flutter/material.dart';
import 'package:praktikum_mp_04sife02_ammar/helpers/db_helper.dart';
import 'package:praktikum_mp_04sife02_ammar/models/task_model.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {

  List<TaskModel> _tasks = [];

  void loadData() async {
    _tasks = await DbHelper.instance.getAllTask();
  }

  void _toggleTask(int index) async {
    setState(() {
      _tasks[index] = TaskModel(
        id: _tasks[index].id,
        judul: _tasks[index].judul,
        isi: _tasks[index].isi,
        isCompleted: !_tasks[index].isCompleted,
      );
    });
    await DbHelper.instance.updateTask(_tasks[index]);
  }

  void _showAddDialog(TaskModel? data) {
    final _formKey = GlobalKey<FormState>();
    final _judulController = TextEditingController();
    final _isiController = TextEditingController();

    if (data != null) {
      _judulController.text = data.judul;
      _isiController.text = data.isi;
  }

  void _addData() {
    if (_formKey.currentState!.validate()) {
      final task = TaskModel(
        judul: _judulController.text,
        isi: _isiController.text,
        isCompleted: false,
      );
      DbHelper.instance.createTask(task);
      Navigator.pop(context);
      loadData();
    }
  }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Tugas'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                TextFormField(
                  controller: _judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _isiController,
                  decoration: const InputDecoration(
                    labelText: 'Isi',
                    prefixIcon: Icon(Icons.task_alt)
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Isi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: _addData,
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadData();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi tugas simple'),
      ),
      
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(task.judul),
            subtitle: Text(task.isi),
            trailing: Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                _toggleTask(index);
              },
            ),
          );
        },
      ),
      

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}