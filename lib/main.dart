import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plantask/App.dart';
import 'package:plantask/SyncData/SyncManager.dart';
import 'package:plantask/providers/TodoProvider.dart';
import 'package:plantask/providers/UserProvider.dart';
import 'package:plantask/providers/WeatherProvider.dart';
import 'package:provider/provider.dart';
import 'package:plantask/providers/loginProvider.dart';
import 'package:plantask/providers/SignupProvider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final dbHelper = DatabaseHelper();
  // await dbHelper.deleteAllTodos();
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    await SyncManager.startMonitoring();
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => SignupProvider()),
        ChangeNotifierProvider(create: (_) => Todoprovider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlanTask',
      debugShowCheckedModeBanner: false,
      home: App(), // ou ta page d’accueil
    );
  }
}
