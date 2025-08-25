import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:plantask/Model/Todo.dart';
import 'package:plantask/DataBase/DatabaseHelper.dart';
import 'package:plantask/services/api_service.dart';
import 'package:collection/collection.dart';


class SyncService {

  //============================== Sync todos ===================================
  static Future<void> syncTodos(Database db) async {
    debugPrint('🔁 Sync intelligent lancé');
    final prefs = await SharedPreferences.getInstance();
    final accountId = prefs.getInt('account_id');

    if (accountId == null) {
      debugPrint("⚠️ Aucun account_id trouvé, sync annulée");
      return;
    }

    try {
      // Récupérer les todos du serveur
      final response = await ApiService.getTodos(accountId);
      final List<dynamic> serverRaw = response['data'] ?? [];
      final List<Todo> serverTodos = serverRaw
          .map((item) => Todo.fromMap(Map<String, dynamic>.from(item)))
          .toList();

      for (final todo in serverTodos) {
        debugPrint("📝 Serveur: ${todo.id} | ${todo.todo} | ${todo.date} | done: ${todo.isCompleted}");
      }

      // Les todos sur le serveur sont déjà stockés au format "localId#todoText"
      final Set<String> serverKeys = serverTodos
          .map((t) => t.todo) // Directement la valeur todo du serveur (déjà "1#tache 1")
          .toSet();

      debugPrint("🔍 Clés serveur trouvées: $serverKeys");

      // Récupérer les todos locaux non synchronisés
      final localRaw = await db.query(
        'todos',
        where: 'synced = 0 AND account_id = ?',
        whereArgs: [accountId],
      );

      final List<Todo> localTodos = localRaw
          .map((item) => Todo.fromMap(Map<String, dynamic>.from(item)))
          .toList();

      int syncedCount = 0;
      int skippedCount = 0;
      int deletedCount = 0;

      for (final local in localTodos) {
        // debug : vérifier toutes les valeurs possibles d'ID
        debugPrint("🔍 Debug local todo:");
        debugPrint("   - local.id: ${local.id}");
        debugPrint("   - local.LocalTodoId: ${local.LocalTodoId}");
        debugPrint("   - local.todo: ${local.todo}");

        //  Essayer plusieurs sources pour l'ID local
        final localId = local.id?.toString() ??
            local.LocalTodoId?.toString() ??
            '';

        if (localId.isEmpty) {
          debugPrint("⚠️ Aucun ID local trouvé pour: ${local.todo}");
          continue;
        }

        final key = "$localId#${local.todo}";

        debugPrint("🔍 Vérification locale: $key");

        // Vérifier si cette clé existe déjà sur le serveur
        if (serverKeys.contains(key)) {
          debugPrint("🔍 Todo existe déjà: $key - Vérification des modifications...");

          final serverTodo = serverTodos.firstWhere((t) => t.todo == key);

          bool needsUpdate = false;
          final changedFields = <String, dynamic>{};

          // Comparer le statut done
          if (local.isCompleted != serverTodo.isCompleted) {
            needsUpdate = true;
            changedFields['done'] = local.isCompleted;
            debugPrint("📝 Modification détectée - done: ${serverTodo.isCompleted} → ${local.isCompleted}");
          }

          // Comparer la date
          if (local.date != serverTodo.date) {
            needsUpdate = true;
            changedFields['date'] = local.date;
            debugPrint("📝 Modification détectée - date: ${serverTodo.date} → ${local.date}");
          }

          if (needsUpdate) {
            //  Préparer le payload complet pour la mise à jour
            final updatePayload = <String, dynamic>{
              'todo_id': serverTodo.todoId, // ID du serveur pour identifier le todo
              'account_id': local.userId,
              ...changedFields, // Les champs modifiés (done, date, etc.)
            };

            debugPrint("📤 Mise à jour sur le serveur pour: $key");
            debugPrint("   Payload: $updatePayload");

            try {
              //  Utiliser votre méthode existante
              final updateResponse = await ApiService.updateTodo(updatePayload);

              // Marquer comme synchronisé en local
              await db.update(
                'todos',
                {
                  'synced': 1,
                  'updated_at': DateTime.now().toIso8601String(),
                },
                where: 'id = ?',
                whereArgs: [local.id],
              );
              debugPrint("✅ Todo mis à jour avec succès: $key");
              syncedCount++;

            } catch (e) {
              debugPrint("❌ Échec mise à jour serveur pour: $key - Erreur: $e");
            }
          } else {
            debugPrint("⏭️ Aucune modification détectée pour: $key");
            skippedCount++;
          }

          continue;
        }

        // Préparer le payload pour insertion
        final payload = {
          "account_id": accountId,
          "date": local.date,
          "todo": key, // Envoyer au format "localId#todoText"
          "done": local.isCompleted,
        };

        debugPrint("📤 Envoi vers serveur: $payload");

        //  Insérer dans le serveur
        final insertResponse = await ApiService.insertTodo(payload);

        if (insertResponse['success'] == true && insertResponse['todo_id'] != null) {
          final newServerId = int.tryParse(insertResponse['todo_id'].toString());

          //  Marquer comme synchronisé en local
          await db.update(
            'todos',
            {
              'todo_id': newServerId,
              'synced': 1,
              'created_locally': 0,
              'updated_at': DateTime.now().toIso8601String(),
            },
            where: 'id = ?', // Utiliser l'ID de la table locale
            whereArgs: [local.id],
          );

          debugPrint("✅ Todo synchronisé: $key -> serveur ID: $newServerId");
          syncedCount++;
        } else {
          debugPrint("❌ Échec insertion serveur pour: $key");
        }
      }

      //  ÉTAPE 2 : Supprimer du serveur les todos qui n'existent plus en local
      debugPrint("🗑️ Vérification des suppressions...");

      // Construire un Set des clés locales (format: id#todo)
      final Set<String> localKeys = localTodos.map((local) {
        final localId = local.id?.toString() ?? '';
        return "$localId#${local.todo}";
      }).toSet();

      debugPrint("🔍 Clés locales: $localKeys");

      for (final serverTodo in serverTodos) {
        final serverKey = serverTodo.todo;

        // Si la clé serveur n'existe pas en local, la tâche a été supprimée
        if (!localKeys.contains(serverKey)) {
          debugPrint("🗑️ Todo supprimé localement, suppression serveur: $serverKey");

          if (serverTodo.todoId != null) {
            try {
              // Utiliser votre méthode existante
              final deleteResponse = await ApiService.deleteTodo(serverTodo.todoId!);

              debugPrint("✅ Todo supprimé du serveur: $serverKey");
              deletedCount++;

            } catch (e) {
              debugPrint("❌ Échec suppression serveur pour: $serverKey - Erreur: $e");
            }
          } else {
            debugPrint("⚠️ Impossible de supprimer: todoId null pour $serverKey");
          }
        }
      }

      debugPrint("✅ Sync terminé : $syncedCount traités (insérés/mis à jour), $skippedCount ignorés, $deletedCount supprimés");

    } catch (e) {
      debugPrint("❌ Erreur lors du sync : $e");
    }
  }


}