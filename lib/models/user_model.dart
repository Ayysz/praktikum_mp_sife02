class UserModel {
  final int? id;
  final String nama;
  final String username;
  final String password;

  // Ini constructornya
  UserModel({
    this.id,
    required this.nama,
    required this.username,
    required this.password,
  });


  // Konversi dari UserModel ke Map (untuk SQLite INSERT / UPDATE)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'username': username,
      'password': password,
    };
  }

  // Konversi dari Map SQLite ke objek UserModel (untuk SQLite QUERY)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
    );
  }
}