// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final int? userId;
  final String name;
  final String userName;
  final String password;
  final bool isAdmin;

  UserModel({
    this.userId,
    required this.name,
    required this.userName,
    required this.password,
    required this.isAdmin,
  });

  UserModel copyWith({
    int? userId,
    String? name,
    String? userName,
    String? password,
    bool? isAdmin,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      userName: userName ?? this.userName,
      password: password ?? this.password,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'userName': userName,
      'password': password,
      'isAdmin': isAdmin ? 1 : 0,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] != null ? map['userId'] as int : null,
      name: map['name'] as String,
      userName: map['userName'] as String,
      password: map['password'] as String,
      isAdmin: map['isAdmin'] == 1 ? true : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(sizeId: $userId, name: $name, userName: $userName, password: $password, isAdmin: $isAdmin)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.name == name &&
        other.userName == userName &&
        other.password == password &&
        other.isAdmin == isAdmin;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        name.hashCode ^
        userName.hashCode ^
        password.hashCode ^
        isAdmin.hashCode;
  }
}
