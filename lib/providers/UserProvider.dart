import 'package:flutter/cupertino.dart';
import 'package:plantask/Model/User.dart';
import 'package:plantask/services/service.dart';

class UserProvider with ChangeNotifier {

  User? _currentUser;
  int _completedTasks = 0;
  int _pendingTasks = 0;
  int _missedTasks = 0;

  User? get currentUser => _currentUser;
  int get completedTasks => _completedTasks;
  int get pendingTasks => _pendingTasks;
  int get missedTasks => _missedTasks;



  //=========================== Affichage des donnes des user ===================================
  Future<void> loadLoggedInUser(int accountId) async {
    // SEUL CHANGEMENT: Remplacer getLoggedInUserData par getLoggedInUserWithStats
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

    notifyListeners();
  }

// Optionnel : Version avec debug pour tester
  Future<void> loadLoggedInUserDebug(int accountId) async {
    // debugPrint('🔄 Chargement utilisateur avec stats - accountId: $accountId');

    final data = await Service.getLoggedInUserWithStats(accountId);

    debugPrint('📊 Données reçues: $data');

    if (data != null) {
      _currentUser = data['user'] as User?;
      _completedTasks = data['completedTasks'] as int? ?? 0;
      _pendingTasks = data['pendingTasks'] as int? ?? 0;
      _missedTasks = data['missedTasks'] as int? ?? 0;

      debugPrint('✅ Stats chargées: completed=$_completedTasks, pending=$_pendingTasks, missed=$_missedTasks');
    } else {
      _currentUser = null;
      _completedTasks = 0;
      _pendingTasks = 0;
      _missedTasks = 0;

      debugPrint('❌ Aucune donnée reçue');
    }

    notifyListeners();
  }



  //============================ mise a jour de la photo de profile =====================================
  Future<bool> updateProfilePhoto(int accoundId, String photoPath) async {
    final success = await Service.updateUserProfilePhoto(accoundId, photoPath);
    if (success && _currentUser != null) {
      _currentUser = _currentUser!.copyWith(profilePhotoPath: photoPath);
      notifyListeners();
    }
    return success;
  }

}