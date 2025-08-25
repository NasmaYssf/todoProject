import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:plantask/DataBase/DatabaseHelper.dart';
import '../services/api_service.dart';

class SignupProvider with ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;


  Future<bool> signup() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      _error = "Les mots de passe ne correspondent pas";
      notifyListeners();
      return false;
    }

    if (email.isEmpty || password.isEmpty) {
      _error = "Veuillez remplir tous les champs";
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.register(email, password);

      if (result["success"] == true) {
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = result["message"] ?? "Erreur inconnue";
      }
    } catch (e) {
      _error = "Serveur inaccessible";
    }

    _loading = false;
    notifyListeners();
    return false;
  }


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
