import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:plantask/SyncData/SyncService.dart';
import 'package:plantask/DataBase/DatabaseHelper.dart';

class SyncManager {
  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static bool _isMonitoring = false;

  static Future<void> startMonitoring() async {


    if (_isMonitoring) {
      print("🔄 SyncManager déjà actif, vérification forcée...");
      await _forceSyncCheck();
      return;
    }

    print("▶️ Démarrage du monitoring SyncManager");
    _isMonitoring = true;

    await _forceSyncCheck();


    _subscription = Connectivity().onConnectivityChanged.listen((results) async {
      final hasConnection = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);

      if (hasConnection) {
        print("🔄 Connexion détectée, tentative de synchronisation...");
        await _performSync();
      }
    });
  }

  static Future<void> stopMonitoring() async {
    print("🛑 Arrêt du monitoring SyncManager");
    _isMonitoring = false;
    _subscription?.cancel();
    _subscription = null;
  }

  // vérification forcée (même sans changement de connectivité)
  static Future<void> _forceSyncCheck() async {
    // Vérifier d'abord la connectivité
    final connectivityResults = await Connectivity().checkConnectivity();
    final hasConnection = connectivityResults.contains(ConnectivityResult.mobile) ||
        connectivityResults.contains(ConnectivityResult.wifi);

    if (hasConnection) {
      print("🔄 Vérification forcée - Connexion disponible, synchronisation...");
      await _performSync();
    } else {
      print("❌ Vérification forcée - Pas de connexion disponible");
    }
  }


  static Future<void> _performSync() async {
    try {
      final db = await DatabaseHelper.database;
      final users = await db.query('users', where: 'synced = ?', whereArgs: [1]);

      if (users.isNotEmpty) {
        await SyncService.syncTodos(db);
        print("✅ Synchronisation des tâches terminée");
      } else {
        print("⚠️ Aucun utilisateur synchronisé trouvé pour syncTodos");
      }
    } catch (e) {
      print("❌ Erreur lors de la synchronisation: $e");
    }
  }


}
