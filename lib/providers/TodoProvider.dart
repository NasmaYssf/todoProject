import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plantask/Model/Todo.dart';
import 'package:plantask/DataBase/DatabaseHelper.dart';
import 'dart:async';


class Todoprovider with ChangeNotifier {
  List<Todo> _todos = [];
  bool _isLoading = false;
  List<Todo> get todos => _todos;
  bool get isLoading => _isLoading;

  List<bool> _checkedStates = [];
  List<bool> get checkedStates => _checkedStates;


  // methode pour filtrer uniquement les tache en attente
  void setTodos(List<Todo> list) {
    _todos = list.where((t) => !t.isCompleted).toList();
    notifyListeners();
  }

  Future<void> checkTask(int index) async {
    if (index < 0 || index >= _todos.length) return;

    // Sauvegarder l'ancien état pour le rollback
    final oldState = _todos[index].isCompleted;

    // Basculer l'état localement
    _todos[index].isCompleted = !_todos[index].isCompleted;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;

      // Mettre à jour dans SQLite
      final updatedRows = await db.update(
        'todos',
        {
          'done': _todos[index].isCompleted ? 1 : 0,
          'synced': 0,
        },
        where: 'LocalTodoId = ?',
        whereArgs: [_todos[index].LocalTodoId],
      );

      if (updatedRows > 0) {
        print("✅ Tâche mise à jour en local: ${_todos[index].todo} (done: ${_todos[index].isCompleted ? 1 : 0})");


        if (_todos[index].isCompleted) {
          _todos.removeAt(index);
          _checkedStates.removeAt(index);
          print("📝 Tâche retirée de l'affichage");
        }

        notifyListeners();
      } else {
        throw Exception("Aucune ligne mise à jour - Tâche introuvable");
      }

    } catch (e) {
      print("❌ Erreur mise à jour SQLite: $e");

      // Rollback : remettre l'ancien état
      _todos[index].isCompleted = oldState;
      notifyListeners();

    }
  }

//========================================== Affichage des todos =================================
  Future<void> getTodos(int accountId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.database;

      // Récupération des todos depuis SQLite
      final localTodos = await db.query(
        'todos',
        where: 'account_id = ? AND done = 0',
        whereArgs: [accountId],
        orderBy: 'id DESC',
      );

      // Transformation en objets Todo
      _todos = localTodos.map((e) => Todo.fromMap(e)).toList();
      _checkedStates = List<bool>.generate(_todos.length, (_) => false);

      // Ne notifier que si la liste n'est pas vide
      if (_todos.isNotEmpty) {
        notifyListeners();
      }

      print("📥 ${_todos.length} tâches chargées depuis SQLite");

    } catch (e) {
      print("❌ Erreur getTodos: $e");
      _todos = [];
      _checkedStates = [];
      // notifier quand erreur pour réinitialiser l'état UI
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners(); // Mise à jour de l'état loading
    }
  }


  Future<void> getDone(int accountId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Chargement UNIQUEMENT depuis SQLite
      final db = await DatabaseHelper.database;
      final localTodos = await db.query(
        'todos',
        where: 'account_id = ? AND done = 1',
        whereArgs: [accountId],
        orderBy: 'id DESC',
      );

      _todos = localTodos.map((e) => Todo.fromMap(e)).toList();

      _checkedStates = List<bool>.generate(_todos.length, (index) => false);

      print("📥 ${_todos.length} tâches chargées depuis SQLite");

    } catch (e) {
      print("❌ Erreur getTodos: $e");
      _todos = [];
      _checkedStates = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<String> addTodo(String task, String date, int accountId) async {
    final localTodoId = DateTime.now().millisecondsSinceEpoch;
    final db = await DatabaseHelper.database;

    final newTodo = Todo(
      todo: task,
      date: date,
      isCompleted: false,
      userId: accountId,
      id: null,
      LocalTodoId: localTodoId,
    );

    try {
      await db.insert('todos', {
        'todo_id': null,
        'LocalTodoId': localTodoId,
        'account_id': accountId,
        'date': date,
        'todo': task,
        'done': 0,
        'synced': 0,
        'created_locally': 1,
      });

      _todos.add(newTodo);

      if (_checkedStates.length < _todos.length) {
        _checkedStates = List<bool>.from(_checkedStates)..add(false);
      }

      notifyListeners();
      return '📥 tâche enregistrée';
    } catch (e) {
      debugPrint("❌ Erreur sauvegarde locale: $e");
      return '❌ Erreur lors de la sauvegarde locale';
    }
  }


  //================ Delete task ===============
  Future<void> deleteTask(int index) async {
    if (index < 0 || index >= _todos.length) return;

    final todo = _todos[index];

    // Sauvegarder pour un éventuel rollback
    final removedTodo = todo;
    final removedIndex = index;

    try {
      final db = await DatabaseHelper.database;

      // Supprimer de la liste d'affichage immédiatement
      _todos.removeAt(index);
      _checkedStates.removeAt(index);
      notifyListeners();

      // Supprimer de SQLite
      final deletedRows = await db.delete(
        'todos',
        where: 'LocalTodoId = ?',
        whereArgs: [todo.LocalTodoId],
      );

      if (deletedRows > 0) {
        debugPrint("✅ Tâche supprimée : ${todo.todo}");
      } else {
        throw Exception("Tâche introuvable en base");
      }

    } catch (e) {
      debugPrint("❌ Erreur suppression : $e");

      // Rollback : remettre la tâche dans la liste
      _todos.insert(removedIndex, removedTodo);
      _checkedStates.insert(removedIndex, false);
      notifyListeners();
    }
  }



  //========================== Update tache ============================
  Future<void> updateTask(int index, String newTitle, String newDate, bool isDone, int accountId) async {
    if (index < 0 || index >= _todos.length) return;

    final todo = _todos[index];

    try {
      final db = await DatabaseHelper.database;

      // Mettre à jour dans SQLite
      final updatedRows = await db.update(
        'todos',
        {
          'todo': newTitle,
          'date': newDate,
          'done': isDone ? 1 : 0,
          'synced': 0,
        },
        where: 'LocalTodoId = ?',
        whereArgs: [todo.LocalTodoId],
      );

      if (updatedRows > 0) {
        debugPrint("✅ Tâche mise à jour : $newTitle");

        // Recharger la liste depuis SQLite (plus simple et sûr)
        await getTodos(accountId);

      } else {
        throw Exception("Tâche introuvable en base");
      }

    } catch (e) {
      debugPrint("❌ Erreur updateTask : $e");
    }
  }


  Future<void> updateDone(int index, String newTitle, String newDate, bool isDone, int accountId) async {
    if (index < 0 || index >= _todos.length) return;

    final todo = _todos[index];

    try {
      final db = await DatabaseHelper.database;

      // Mettre à jour dans SQLite
      final updatedRows = await db.update(
        'todos',
        {
          'todo': newTitle,
          'date': newDate,
          'done': isDone ? 1 : 0,
          'synced': 0,
        },
        where: 'LocalTodoId = ?',
        whereArgs: [todo.LocalTodoId],
      );

      if (updatedRows > 0) {
        debugPrint("✅ Tâche mise à jour : $newTitle");

        // Recharger la liste depuis SQLite (plus simple et sûr)
        await getDone(accountId);

      } else {
        throw Exception("Tâche introuvable en base");
      }

    } catch (e) {
      debugPrint("❌ Erreur updateTask : $e");
    }
  }


  //===========recherche todo
  String _searchQuery = "";
  List<Todo> _filteredTodos = [];

  // getter qui retourne soit la liste normale soit celle filtrée
  List<Todo> get todosView =>
      _searchQuery.isEmpty ? _todos : _filteredTodos;

  // méthode de recherche
  void searchTasks(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredTodos = [];
    } else {
      _filteredTodos = _todos
          .where((t) =>
          t.todo.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

}