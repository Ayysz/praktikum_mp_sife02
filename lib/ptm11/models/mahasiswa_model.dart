// File: lib/ptm11/models/mahasiswa_model.dart
// Model data Mahasiswa untuk modul MVVM Pertemuan 11

class MahasiswaModel {
  final int? id;
  final String nim;
  final String nama;
  final String jurusan;

  const MahasiswaModel({
    this.id,
    required this.nim,
    required this.nama,
    required this.jurusan,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nim': nim,
      'nama': nama,
      'jurusan': jurusan,
    };
  }

  factory MahasiswaModel.fromMap(Map<String, dynamic> map) {
    return MahasiswaModel(
      id: map['id'] as int?,
      nim: map['nim'] as String? ?? '',
      nama: map['nama'] as String? ?? '',
      jurusan: map['jurusan'] as String? ?? '',
    );
  }

  MahasiswaModel copyWith({
    int? id,
    String? nim,
    String? nama,
    String? jurusan,
  }) {
    return MahasiswaModel(
      id: id ?? this.id,
      nim: nim ?? this.nim,
      nama: nama ?? this.nama,
      jurusan: jurusan ?? this.jurusan,
    );
  }
}
