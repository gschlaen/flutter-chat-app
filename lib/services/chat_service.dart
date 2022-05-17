import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:chat_app/global/environment.dart';
import 'package:chat_app/models/mensajes_response.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/services/auth_service.dart';

class ChatService extends ChangeNotifier {
  late User targetUser;

  Future<List<Mensaje>> getChat(String userID) async {
    final resp = await http.get(Uri.parse('${Environment.apiUrl}/mensajes/$userID'), headers: {
      'Content-Type': 'application/json',
      'x-token': await AuthService.getToken(),
    });

    final mensajesResponse = MensajesResponse.fromJson(resp.body);

    return mensajesResponse.mensajes;
  }
}
