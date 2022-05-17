// To parse this JSON data, do
//
// final usersResponse = usersResponseFromMap(jsonString);

import 'dart:convert';

import 'package:chat_app/models/user.dart';

class UsersResponse {
  UsersResponse({
    required this.ok,
    required this.usuarios,
  });

  bool ok;
  List<User> usuarios;

  factory UsersResponse.fromJson(String str) => UsersResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UsersResponse.fromMap(Map<String, dynamic> json) => UsersResponse(
        ok: json["ok"],
        usuarios: List<User>.from(json["usuarios"].map((x) => User.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "ok": ok,
        "usuarios": List<dynamic>.from(usuarios.map((x) => x.toMap())),
      };
}
