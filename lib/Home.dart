import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plantask/Historique.dart';
import 'package:plantask/providers/TodoProvider.dart';
import 'package:plantask/providers/UserProvider.dart';
import 'package:plantask/providers/WeatherProvider.dart';
import 'package:provider/provider.dart';
import 'package:plantask/App.dart';
import 'package:plantask/meteoPage.dart';
import 'package:plantask/profile.dart';
import 'package:plantask/providers/loginProvider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late TextEditingController taskController;
  late TextEditingController dateController;

  @override
  void dispose() {
    taskController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    taskController = TextEditingController();
    dateController = TextEditingController();
    // Charger la météo
    Future.microtask(
      () => Provider.of<WeatherProvider>(context, listen: false).loadWeather(),
    );

    // Charger les tâches + lancer la synchronisation
    Future.microtask(() {
      final authProvider = Provider.of<LoginProvider>(context, listen: false);
      final accountId = authProvider.currentUser?.accountId ?? 0;

      final todoProvider = Provider.of<Todoprovider>(context, listen: false);
      todoProvider.getTodos(accountId);

      // AJOUTER CETTE LIGNE : Charger les données utilisateur
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.loadLoggedInUser(accountId);
    });
  }

  //============= affichage de l'imahe profile'

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<LoginProvider>(context);
    final weatherProv = Provider.of<WeatherProvider>(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      floatingActionButton: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              barrierDismissible: false,
              useSafeArea: true,
              context: context,
              builder: (context) {
                return Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),

                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header custom
                          Row(
                            children: const [
                              Icon(
                                Icons.playlist_add_check,
                                size: 28,
                                color: Colors.teal,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Nouvelle tâche",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(thickness: 1, color: Colors.tealAccent),
                          const SizedBox(height: 16),

                          // Champ Tâche
                          TextField(
                            controller: taskController,
                            decoration: InputDecoration(
                              hintText: "Entrez la tâche",
                              prefixIcon: const Icon(
                                Icons.assignment,
                                color: Colors.teal,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Champ Date
                          TextField(
                            controller: dateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: "Sélectionnez une date",
                              prefixIcon: const Icon(
                                Icons.calendar_today,
                                color: Colors.teal,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );

                              if (pickedDate != null) {
                                dateController.text =
                                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                              }
                            },
                          ),
                          const SizedBox(height: 24),

                          // Boutons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Colors.redAccent,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    "Annuler",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final task = taskController.text.trim();
                                    final date = dateController.text.trim();

                                    if (task.isEmpty || date.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "⚠ Veuillez remplir tous les champs",
                                          ),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      return;
                                    }

                                    final authProvider =
                                        Provider.of<LoginProvider>(
                                          context,
                                          listen: false,
                                        );
                                    final accountId =
                                        authProvider.currentUser?.accountId ??
                                        0;

                                    final provider = Provider.of<Todoprovider>(
                                      context,
                                      listen: false,
                                    );
                                    final message = await provider.addTodo(
                                      task,
                                      date,
                                      accountId,
                                    );

                                    await provider.getTodos(accountId);

                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        backgroundColor: Colors.black,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },

                                  child: const Text(
                                    "Ajouter",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          backgroundColor: Colors.teal,
          child: const Icon(Icons.add, size: 40, color: Colors.white),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      final user = userProvider.currentUser;

                      ImageProvider imageProvider;

                      if (user != null &&
                          user.profilePhotoPath != null &&
                          user.profilePhotoPath!.isNotEmpty &&
                          File(user.profilePhotoPath!).existsSync()) {
                        imageProvider = FileImage(File(user.profilePhotoPath!));
                      } else {
                        imageProvider = const AssetImage(
                          'assets/images/profile01.jpg',
                        );
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Profile()),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 27,
                            backgroundImage: imageProvider,
                          ),
                        ),
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.menu,
                      size: 28,
                      color: Colors.black87,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    elevation: 6,
                    onSelected: (value) async {
                      switch (value) {
                        case 'Profil':
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Profile()),
                          );
                          break;
                        case 'Météo':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MeteoPage(),
                            ),
                          );
                          break;
                        case 'Historique':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Historique(),
                            ),
                          );
                          break;
                        case 'Déconnexion':
                          if (!authProvider.isLoggingOut) {
                            await authProvider.logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const App()),
                              (route) => false,
                            );
                          }
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'Profil',
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Colors.teal, size: 20),
                            SizedBox(width: 10),
                            Text('Profil'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Météo',
                        child: Row(
                          children: [
                            Icon(
                              Icons.sunny_snowing,
                              color: Colors.teal,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text('Météo'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'Historique',
                        child: Row(
                          children: [
                            Icon(
                              Icons.library_books,
                              color: Colors.teal,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text('Historique'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Déconnexion',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.login,
                              color: Colors.teal,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Text('Déconnexion'),
                            if (authProvider.isLoggingOut)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ✅ Champ de recherche
              TextField(
                decoration: InputDecoration(
                  hintText: "Rechercher une tâche...",
                  hintStyle: const TextStyle(color: Colors.black45),
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.teal.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.teal),
                  ),
                ),
                onChanged: (value) {
                  context.read<Todoprovider>().searchTasks(
                    value,
                  ); // 👈 Appel de ta méthode de recherche
                },
              ),
              const SizedBox(height: 24),

              const Text(
                "Mes Tâches",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MeteoPage()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.03,
                    vertical: width * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(width * 0.05),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.shade300.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: width * 0.10,
                        height: width * 0.10,
                        // 2em solution
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.shade200,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.shade100,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: weatherProv.icon.isEmpty
                              ? Icon(
                                  Icons.sunny_snowing,
                                  size: width * 0.06,
                                  color: Colors.white,
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.network(
                                    'https://openweathermap.org/img/wn/${weatherProv.icon}@4x.png',
                                    width: width * 0.07,
                                    height: width * 0.07,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      Text(
                        "${weatherProv.temperature}°C à ${weatherProv.location}",
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Expanded(
                child: Consumer<Todoprovider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Ici on utilise la nouvelle liste à afficher
                    final todosToDisplay = provider.todosView
                        .where((todo) => !todo.isCompleted)
                        .toList();

                    if (todosToDisplay.isEmpty) {
                      return const Center(child: Text("Aucune tâche trouvée"));
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: todosToDisplay.length,
                      itemBuilder: (context, index) {
                        return _buildTaskCard(
                          todosToDisplay[index].todo,
                          // todosToDisplay[index].date,
                          // todosToDisplay[index].date!,
                          todosToDisplay[index].date ?? 'Pas de date fixe',
                          index,
                          provider,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(
    String title,
    String date,
    int index,
    Todoprovider provider,
  ) {
    // 🔎 Vérifier si la tâche est expirée
    bool isExpired = false;
    try {
      if (date.isNotEmpty && date != 'Pas de date fixe') {
        final taskDate = DateTime.parse(date); // format attendu: YYYY-MM-DD
        final now = DateTime.now();
        isExpired = taskDate.isBefore(DateTime(now.year, now.month, now.day));
      }
    } catch (e) {
      print("⚠ Erreur parsing date: $e");
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.assignment,
                  size: 26,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 18),

              Expanded(
                child: GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    HapticFeedback.vibrate();
                    final tapPosition = details.globalPosition;

                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        tapPosition.dx,
                        tapPosition.dy,
                        tapPosition.dx,
                        tapPosition.dy,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      items: [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: const [
                              Icon(Icons.edit, size: 18, color: Colors.teal),
                              SizedBox(width: 8),
                              Text(
                                "Modifier",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: const [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                "Supprimer",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).then((value) {
                      if (value == 'edit') {
                        _showEditDialog(context, provider, index);
                      } else if (value == 'delete') {
                        _showDeleteConfirm(context, provider, index);
                      }
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isExpired
                              ? Colors
                                    .red // 🔴 Expirée
                              : provider.checkedStates[index]
                              ? Colors.grey
                              : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          decoration: provider.checkedStates[index]
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        date,
                        style: TextStyle(
                          color: isExpired ? Colors.redAccent : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Checkbox(
                value: provider.checkedStates[index],
                activeColor: Colors.teal,
                onChanged: (bool? value) {
                  provider.checkTask(index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //==========Dialogue delete
  void _showDeleteConfirm(
    BuildContext context,
    Todoprovider provider,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: const [
                  Icon(Icons.delete_forever, size: 28, color: Colors.teal),
                  SizedBox(width: 10),
                  Text(
                    "Supprimer la tâche",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 1, color: Colors.teal),
              const SizedBox(height: 16),

              // Message
              Text(
                "Voulez-vous vraiment supprimer cette tâche ?",
                style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.teal),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Annuler",
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        provider.deleteTask(index);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("🗑 Tâche supprimée"),
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text(
                        "Supprimer",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //============ dialogue update
  void _showEditDialog(BuildContext context, Todoprovider provider, int index) {
    final titleCtrl = TextEditingController(text: provider.todos[index].todo);
    final dateCtrl = TextEditingController(text: provider.todos[index].date);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: const [
                  Icon(Icons.edit_calendar, size: 28, color: Colors.teal),
                  SizedBox(width: 10),
                  Text(
                    "Modifier la tâche",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 1, color: Colors.tealAccent),
              const SizedBox(height: 16),

              // Champ Tâche
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  hintText: "Entrez la tâche",
                  prefixIcon: const Icon(Icons.assignment, color: Colors.teal),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Champ Date
              TextField(
                controller: dateCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Sélectionnez une date",
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Colors.teal,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    dateCtrl.text =
                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                  }
                },
              ),
              const SizedBox(height: 24),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Annuler",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        final authProvider = Provider.of<LoginProvider>(
                          context,
                          listen: false,
                        );
                        final accountId =
                            authProvider.currentUser?.accountId ?? 0;

                        provider.updateTask(
                          index,
                          titleCtrl.text.trim(),
                          dateCtrl.text.trim(),
                          provider.todos[index].isCompleted,
                          accountId,
                        );

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("✏ La tâche a été modifiée"),
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text(
                        "Modifier",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
