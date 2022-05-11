// To parse this JSON data, do
//
// final loginResponse = loginResponseFromMap(jsonString);

import 'dart:convert';

import 'package:chat_app/models/user.dart';

class LoginResponse {
  LoginResponse({
    required this.ok,
    required this.usuario,
    required this.token,
  });

  bool ok;
  User usuario;
  String token;

  factory LoginResponse.fromJson(String str) => LoginResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LoginResponse.fromMap(Map<String, dynamic> json) => LoginResponse(
        ok: json["ok"],
        usuario: User.fromMap(json["usuario"]),
        token: json["token"],
      );

  Map<String, dynamic> toMap() => {
        "ok": ok,
        "usuario": usuario.toMap(),
        "token": token,
      };
}
