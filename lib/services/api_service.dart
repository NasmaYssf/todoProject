import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  static const String baseUrl = "http://192.168.1.9/todo";

  static Future<Map<String,dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode == 200) {
      print("Réponse brute: ${res.body}");
      final decoded = jsonDecode(res.body);


      if (decoded['data'] != null && decoded['data']['account_id'] != null) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('account_id', int.parse(decoded['data']['account_id'].toString()));
        return {
          "success": true,
          "account_id": decoded['data']['account_id'],
          "email": decoded['data']['email']
        };
      }

      return {"success": false, "message": "Identifiants incorrects"};
    } else {
      throw Exception('Erreur ${res.statusCode}: ${res.body}');
    }
  }


  static Future<Map<String, dynamic>> register(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    print("Réponse brute inscription: ${res.body}");

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return {"success": true, "data": decoded};
    } else {
      return {
        "success": false,
        "message": "Erreur ${res.statusCode} : ${res.body}"
      };
    }
  }


  static Future<Map<String, dynamic>> getTodos(int accountId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/todos"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"account_id": accountId}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } else {
      throw Exception('Erreur getTodos ${res.statusCode}');
    }
  }


  static Future<Map<String,dynamic>> insertTodo(Map<String,dynamic> todo) async {
    final res = await http.post(
      Uri.parse("$baseUrl/inserttodo"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(todo),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Erreur insertTodo ${res.statusCode}');
  }

  static Future<Map<String,dynamic>> updateTodo(Map<String,dynamic> todo) async {
    final res = await http.post(
      Uri.parse("$baseUrl/updatetodo"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(todo),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Erreur updateTodo ${res.statusCode}');
  }

  static Future<Map<String,dynamic>> deleteTodo(int todoId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/deletetodo"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"todo_id": todoId}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Erreur deleteTodo ${res.statusCode}');
  }
}
