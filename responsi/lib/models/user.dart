import 'package:hive/hive.dart';

class User {
  final String username;
  final String password;
  final String nama;

  User({required this.username, required this.password, required this.nama});

  Map<String, dynamic> toMap() {
    return {'username': username, 'password': password, 'nama': nama};
  }

  factory User.fromMap(Map<dynamic, dynamic> map) {
    return User(
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      nama: map['nama'] ?? '',
    );
  }
}

class UserAdapter extends TypeAdapter<User> {
  @override
  int get typeId => 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      username: fields[0] as String,
      password: fields[1] as String,
      nama: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.password)
      ..writeByte(2)
      ..write(obj.nama);
  }
}
