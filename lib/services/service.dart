import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:plantask/Model/User.dart';
import 'package:plantask/DataBase/DatabaseHelper.dart';

class Service {

  //====================== logout =========================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('account_id');
  }


  //========================= get user data ================================
  static Future<Map<String, dynamic>?> getLoggedInUserWithStats(int accountId) async {
    try {
      final db = await DatabaseHelper.database;

      // Récupérer l'utilisateur
      final result = await db.query(
        'users',
        where: 'server_account_id = ?',
        whereArgs: [accountId],
      );

      if (result.isEmpty) return null;

      final user = User.fromMap(result.first);

      final now = DateTime.now();
      final today = "${now.year.toString().padLeft(4,'0')}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}";


      final stats = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN done = 1 THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN done = 0 AND (date IS NULL OR substr(date,1,10) >= ?) THEN 1 ELSE 0 END) as pending,
        SUM(CASE WHEN done = 0 AND date IS NOT NULL AND substr(date,1,10) < ? THEN 1 ELSE 0 END) as missed
      FROM todos 
      WHERE account_id = ?
    ''', [today, today, accountId]);

      final row = stats.first;

      return {
        'user': user,
        'completedTasks': (row['completed'] as int?) ?? 0,
        'pendingTasks': (row['pending'] as int?) ?? 0,
        'missedTasks': (row['missed'] as int?) ?? 0,
      };
    } catch (e) {
      debugPrint('Erreur dans getLoggedInUserWithStats: $e');
      return null;
    }
  }


  //============================== ajouter une photo de profile ====================================
  static Future<bool> updateUserProfilePhoto(int accountId, String profilePhotoPath) async {
    try {
      final db = await DatabaseHelper.database;
      // debugPrint('Mise à jour de la photo de profil pour: $email');
      debugPrint('Nouveau chemin: $profilePhotoPath');

      final result = await db.update(
        'users',
        {'profile_photo_path': profilePhotoPath},
        where: 'server_account_id = ?',
        whereArgs: [accountId],
      );

      debugPrint('Nombre de lignes mises à jour: $result');

      if (result > 0) {
        debugPrint('Photo de profil mise à jour avec succès');
        return true;
      } else {
        debugPrint('Aucune ligne mise à jour - utilisateur non trouvé');
        return false;
      }
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la photo: $e');
      return false;
    }
  }


}
