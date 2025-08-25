import 'package:flutter/material.dart';
import 'package:plantask/Model/User.dart';
import 'package:plantask/services/service.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  int _completedTasks = 0;
  int _pendingTasks = 0;
  int _missedTasks = 0;
  bool _isLoading = false;

  // Getters
  User? get currentUser => _currentUser;
  int get completedTasks => _completedTasks;
  int get pendingTasks => _pendingTasks;
  int get missedTasks => _missedTasks;
  bool get isLoading => _isLoading;

  //=========================== Charger un utilisateur ===========================
  Future<void> loadLoggedInUser(int accountId) async {
    _isLoading = true;
    notifyListeners();

    final data = await Service.getLoggedInUserWithStats(accountId);

    if (data != null) {
      _currentUser = data['user'] as User?;
      _completedTasks = data['completedTasks'] as int? ?? 0;
      _pendingTasks = data['pendingTasks'] as int? ?? 0;
      _missedTasks = data['missedTasks'] as int? ?? 0;
    } else {
      _currentUser = null;
      _completedTasks = 0;
      _pendingTasks = 0;
      _missedTasks = 0;
    }

    _isLoading = false;
    notifyListeners();
  }

  //============================ Mise à jour de la photo ========================
  Future<bool> updateProfilePhoto(int accountId, String photoPath) async {
    final success = await Service.updateUserProfilePhoto(accountId, photoPath);
    if (success && _currentUser != null) {
      _currentUser = _currentUser!.copyWith(profilePhotoPath: photoPath);
      notifyListeners();
    }
    return success;
  }
}
