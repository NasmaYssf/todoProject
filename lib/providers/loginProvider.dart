import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plantask/DataBase/DatabaseHelper.dart';
import 'package:plantask/services/service.dart';
import '../Model/User.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:plantask/SyncData/SyncManager.dart';

class LoginProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCheckingLogin = true;
  bool get isCheckingLogin => _isCheckingLogin;

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _isLoggingOut = false;
  bool get isLoggingOut => _isLoggingOut;


  // Variable pour forcer le nettoyage des données au prochain login
  bool _shouldClearDataOnNextLogin = false;

  LoginProvider() {
    _loadLoginStatus();
  }

  Future<void> _loadLoginStatus() async {
    _isCheckingLogin = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final storedAccountId = prefs.getInt('account_id');
    final storedUserJson = prefs.getString('user');

    if (storedAccountId != null && storedUserJson != null) {
      _currentUser = User.fromMap(jsonDecode(storedUserJson));
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
      _currentUser = null;
    }

    _isCheckingLogin = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      return {"success": false, "message": "Veuillez remplir tous les champs"};
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.login(email, password);
      if (result['success'] == true) {
        _currentUser = User(
          accountId: result['account_id'],
          email: result['email'],
          password: password,
        );

        //insersion de l'user en BD local
        final db = await DatabaseHelper.database;

        final existing = await db.query(
          'users',
          where: 'server_account_id = ?',
          whereArgs: [_currentUser!.accountId],
        );

        if (existing.isEmpty) {
          await db.insert('users', {
            'server_account_id': _currentUser!.accountId,
            'email': _currentUser!.email,
            'password': _currentUser!.password,
            'synced': 1,
          });
          print("✅ Utilisateur inséré localement: ${_currentUser!.email}");
        } else {
          print("🔄 Utilisateur déjà présent en local: ${_currentUser!.email}");
        }


        _isLoggedIn = true;

        _shouldClearDataOnNextLogin = true;

        // Sauvegarde locale de l'user
        final prefs = await SharedPreferences.getInstance();
        prefs.setInt('account_id', _currentUser!.accountId);
        prefs.setString('user', jsonEncode(_currentUser!.toMap()));

        SyncManager.startMonitoring();
        notifyListeners();
      }
      return result;
    } catch (e) {
      return {"success": false, "message": e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<void> logout() async {
    _isLoggingOut = true;
    notifyListeners();

    try {

      await Service.logout();

      // Réinitialise l'utilisateur
      _currentUser = null;
      _isLoggedIn = false;

      // Supprime les données locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('account_id');
      await prefs.remove('user');

    } catch (e) {
      print("Erreur lors de la déconnexion: $e");
      // On continue quand même la déconnexion locale
      _currentUser = null;
      _isLoggedIn = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('account_id');
      await prefs.remove('user');
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }



  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}