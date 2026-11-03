class TaskModel {
  final int? id;
  final String judul;
  final String isi;
  final bool isCompleted;

  TaskModel({
    this.id,
    required this.judul,
    required this.isi,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'isCompleted': isCompleted,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      judul: map['judul'] as String,
      isi: map['isi'] as String,
      isCompleted: map['isCompleted'] == 1 || map['isCompleted'] == true ,
    );
  }
}