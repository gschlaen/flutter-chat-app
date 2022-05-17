import 'package:chat_app/models/users_response.dart';
import 'package:http/http.dart' as http;

import 'package:chat_app/global/environment.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/services/auth_service.dart';

class UsersService {
  Future<List<User>> getUsers() async {
    final token = await AuthService.getToken();
    try {
      final resp = await http.get(
        Uri.parse('${Environment.apiUrl}/usuarios'),
        headers: {
          'Content-Type': 'application/json',
          'x-token': token,
        },
      );

      final usersResponse = UsersResponse.fromJson(resp.body);
      return usersResponse.usuarios;
    } catch (e) {
      return [];
    }
  }
}
