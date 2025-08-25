// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:plantask/Home.dart';
// import 'package:plantask/providers/TodoProvider.dart';
// import 'package:provider/provider.dart';
// import 'package:plantask/App.dart';
// import 'package:plantask/meteoPage.dart';
// import 'package:plantask/profile.dart';
// import 'package:plantask/providers/loginProvider.dart';
//
// class Historique extends StatefulWidget {
//   const Historique({super.key});
//
//   @override
//   State<Historique> createState() => _HomeState();
// }
//
// class _HomeState extends State<Historique> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() {
//       final authProvider = Provider.of<LoginProvider>(context, listen: false);
//       final accountId = authProvider.currentUser?.accountId ?? 0;
//       // debugPrint('accountId récupéré dans Historique: $accountId');
//       Provider.of<Todoprovider>(context, listen: false)
//           .getDone(accountId);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<LoginProvider>(context);
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F9F9),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Profil + menu hamburger
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (_) => const Profile()));
//                     },
//                     child: Container(
//                       decoration: const BoxDecoration(
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 6,
//                             offset: Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: Material(
//                         shape: const CircleBorder(),
//                         elevation: 4,
//                         color: Colors.white,
//                         child: IconButton(
//                           icon: Icon(Icons.chevron_left, size: 32, color: Colors.teal[700]),
//                           onPressed: () {
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(builder: (_) => const Home()),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//
//                   ),
//                   const Text(
//                     "Mon historique",
//                     style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87),
//                   ),
//                   // ✅ Nouveau menu hamburger
//                   PopupMenuButton<String>(
//                     icon: const Icon(Icons.menu, size: 28, color: Colors.black87),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     color: Colors.white,
//                     elevation: 6,
//                     onSelected: (value) async {
//                       switch (value) {
//                         case 'Profil':
//                           Navigator.push(context, MaterialPageRoute(builder: (_) => const Profile()));
//                           break;
//                         case 'Météo':
//                           Navigator.push(context, MaterialPageRoute(builder: (_) => const MeteoPage()));
//                           break;
//                         case 'Historique':
//                           Navigator.push(context, MaterialPageRoute(builder: (_) => const Historique()));
//                           break;
//                         case 'Déconnexion':
//                           if (!authProvider.isLoggingOut) {
//                             await authProvider.logout();
//                             Navigator.pushAndRemoveUntil(
//                               context,
//                               MaterialPageRoute(builder: (_) => const App()),
//                                   (route) => false,
//                             );
//                           }
//                           break;
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => [
//                       const PopupMenuItem(value: 'Profil', child: Row(
//                         children: const [
//                           Icon(Icons.person, color: Colors.teal, size: 20),
//                           SizedBox(width: 10),
//                           Text('Profil'),
//                         ],
//                       )),
//                       const PopupMenuItem(value: 'Météo', child: Row(
//                         children: const [
//                           Icon(Icons.sunny_snowing, color: Colors.teal, size: 20),
//                           SizedBox(width: 10),
//                           Text('Météo'),
//                         ],
//                       )),
//                       const PopupMenuItem(value: 'Historique', child: Row(
//                         children: const [
//                           Icon(Icons.library_books, color: Colors.teal, size: 20),
//                           SizedBox(width: 10),
//                           Text('Historique'),
//                         ],
//                       )),
//                       PopupMenuItem(
//                         value: 'Déconnexion',
//                         child: Row(
//                           children: [
//                             const Icon(Icons.login, color: Colors.teal, size: 20),
//                             const SizedBox(width: 10),
//                             const Text('Déconnexion'),
//                             if (authProvider.isLoggingOut)
//                               const SizedBox(
//                                 width: 16,
//                                 height: 16,
//                                 child: CircularProgressIndicator(strokeWidth: 2),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 40),
//
//               // ✅ Champ de recherche
//               TextField(
//                 decoration: InputDecoration(
//                   hintText: "Rechercher une tâche...",
//                   hintStyle: const TextStyle(color: Colors.black45),
//                   prefixIcon: const Icon(Icons.search, color: Colors.teal),
//                   filled: true,
//                   fillColor: Colors.white,
//                   contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: BorderSide(color: Colors.teal.withOpacity(0.2)),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: const BorderSide(color: Colors.teal),
//                   ),
//                 ),
//                 onChanged: (value) {
//                   context.read<Todoprovider>().searchTasks(value);  // 👈 Appel de ta méthode de recherche
//                 },
//               ),
//
//               const SizedBox(height: 30),
//               Expanded(
//                 child: Consumer<Todoprovider>(
//                   builder: (context, provider, _) {
//                     if (provider.isLoading) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//
//                     // Ici on utilise la nouvelle liste à afficher
//                     final todosToDisplay = provider.todosView.where((todo) => todo.isCompleted).toList();
//
//                     if (todosToDisplay.isEmpty) {
//                       return const Center(child: Text("Aucune tâche trouvée"));
//                     }
//
//                     return ListView.builder(
//                       physics: const BouncingScrollPhysics(),
//                       itemCount: todosToDisplay.length,
//                       itemBuilder: (context, index) {
//                         return _buildTaskCard(
//                           todosToDisplay[index].todo,
//                           todosToDisplay[index].date ?? 'Pas de date fixe',
//                           // todosToDisplay[index].date,
//                           index,
//                           provider,
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTaskCard(String title, String date, int index, Todoprovider provider) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Card(
//         elevation: 3,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           child: Row(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.teal.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 padding: const EdgeInsets.all(10),
//                 child: const Icon(Icons.assignment, size: 26, color: Colors.teal),
//               ),
//               const SizedBox(width: 18),
//               Expanded(
//                 child: GestureDetector(
//                   onTapDown: (TapDownDetails details) {
//                     // vibration
//                     HapticFeedback.vibrate();
//                     final tapPosition = details.globalPosition;
//
//                     showMenu(
//                       context: context,
//                       position: RelativeRect.fromLTRB(
//                         tapPosition.dx,
//                         tapPosition.dy,
//                         tapPosition.dx,
//                         tapPosition.dy,
//                       ),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       items: [
//                         PopupMenuItem(
//                           value: 'edit',
//                           child: Container(
//                             child: Row(
//                               children: const [
//                                 Icon(Icons.edit, size: 18, color: Colors.teal),
//                                 SizedBox(width: 8),
//                                 Text("Modifier", style: TextStyle(fontSize: 14, color: Colors.teal)),
//                               ],
//                             ),
//                           ),
//                         ),
//                         PopupMenuItem(
//                           value: 'delete',
//                           child: Container(
//                             child: Row(
//                               children: const [
//                                 Icon(Icons.delete, size: 18, color: Colors.red),
//                                 SizedBox(width: 8),
//                                 Text("Supprimer", style: TextStyle(fontSize: 14, color: Colors.red)),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ).then((value) {
//                       if (value == 'edit') {
//                         _showEditDialog(context, provider, index);
//                       } else if (value == 'delete') {
//                         _showDeleteConfirm(context, provider, index);
//                       }
//                     });
//                   },
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                         decoration: TextDecoration.lineThrough,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Text(date,
//                         style: const TextStyle(color: Colors.black54, fontSize: 14)),
//                   ],
//                 ),
//               ),
//               ),
//               Checkbox(
//                 value: provider.checkedStates[index],
//                 activeColor: Colors.teal,
//                 onChanged: (bool? value) async {
//                   // On veut remettre en done=0
//                   await provider.checkTask(index); // ton checkTask va faire updateTodo & removeAt
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   //==========Dialogue delete
//   void _showDeleteConfirm(BuildContext context, Todoprovider provider, int index) {
//     showDialog(
//       context: context,
//       builder: (_) => Dialog(
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header
//               Row(
//                 children: const [
//                   Icon(Icons.delete_forever, size: 28, color: Colors.teal),
//                   SizedBox(width: 10),
//                   Text(
//                     "Supprimer la tâche",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.teal,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               const Divider(thickness: 1, color: Colors.teal),
//               const SizedBox(height: 16),
//
//               // Message
//               Text(
//                 "Voulez-vous vraiment supprimer cette tâche ?",
//                 style: TextStyle(fontSize: 16, color: Colors.grey[800]),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//
//               // Boutons
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: Colors.teal),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10)),
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text(
//                         "Annuler",
//                         style: TextStyle(color: Colors.teal),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10)),
//                       ),
//                       onPressed: () {
//                         Navigator.pop(context);
//                         provider.deleteTask(index);
//
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: const Text("🗑️ Tâche supprimée"),
//                             backgroundColor: Colors.black,
//                             behavior: SnackBarBehavior.floating,
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//                             duration: const Duration(seconds: 2),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         "Supprimer",
//                         style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//   //============ dialogue update
//   void _showEditDialog(BuildContext context, Todoprovider provider, int index) {
//     final titleCtrl = TextEditingController(text: provider.todos[index].todo);
//     final dateCtrl  = TextEditingController(text: provider.todos[index].date);
//
//     showDialog(
//       context: context,
//       builder: (_) => Dialog(
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header
//               Row(
//                 children: const [
//                   Icon(Icons.edit_calendar, size: 28, color: Colors.teal),
//                   SizedBox(width: 10),
//                   Text(
//                     "Modifier la tâche",
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.teal,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               const Divider(thickness: 1, color: Colors.tealAccent),
//               const SizedBox(height: 16),
//
//               // Champ Tâche
//               TextField(
//                 controller: titleCtrl,
//                 decoration: InputDecoration(
//                   hintText: "Entrez la tâche",
//                   prefixIcon: const Icon(Icons.assignment, color: Colors.teal),
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 14),
//
//               // Champ Date
//               TextField(
//                 controller: dateCtrl,
//                 readOnly: true,
//                 decoration: InputDecoration(
//                   hintText: "Sélectionnez une date",
//                   prefixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 onTap: () async {
//                   final pickedDate = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now(),
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime(2100),
//                   );
//
//                   if (pickedDate != null) {
//                     dateCtrl.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
//                   }
//                 },
//               ),
//               const SizedBox(height: 24),
//
//               // Boutons
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: Colors.redAccent),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text(
//                         "Annuler",
//                         style: TextStyle(color: Colors.redAccent),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.teal,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       onPressed: () {
//                         final authProvider = Provider.of<LoginProvider>(context, listen: false);
//                         final accountId = authProvider.currentUser?.accountId ?? 0;
//                         provider.updateDone(
//                           index,
//                           titleCtrl.text.trim(),
//                           dateCtrl.text.trim(),
//                           provider.todos[index].isCompleted,
//                             accountId
//                         );
//
//                         Navigator.pop(context);
//
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: const Text("✏️ La tâche a été modifiée"),
//                             backgroundColor: Colors.black,
//                             behavior: SnackBarBehavior.floating,
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//                             duration: const Duration(seconds: 2),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         "Modifier",
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plantask/Home.dart';
import 'package:plantask/providers/TodoProvider.dart';
import 'package:provider/provider.dart';
import 'package:plantask/App.dart';
import 'package:plantask/meteoPage.dart';
import 'package:plantask/profile.dart';
import 'package:plantask/providers/loginProvider.dart';

class Historique extends StatefulWidget {
  const Historique({super.key});

  @override
  State<Historique> createState() => _HomeState();
}

class _HomeState extends State<Historique> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authProvider = Provider.of<LoginProvider>(context, listen: false);
      final accountId = authProvider.currentUser?.accountId ?? 0;
      // debugPrint('accountId récupéré dans Historique: $accountId');
      Provider.of<Todoprovider>(context, listen: false)
          .getDone(accountId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profil + menu hamburger
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const Profile()));
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        shape: const CircleBorder(),
                        elevation: 4,
                        color: Colors.white,
                        child: IconButton(
                          icon: Icon(Icons.chevron_left, size: 32, color: Colors.teal[700]),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const Home()),
                            );
                          },
                        ),
                      ),
                    ),

                  ),
                  const Text(
                    "Mon historique",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  // ✅ Nouveau menu hamburger
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.menu, size: 28, color: Colors.black87),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.white,
                    elevation: 6,
                    onSelected: (value) async {
                      switch (value) {
                        case 'Profil':
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const Profile()));
                          break;
                        case 'Météo':
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MeteoPage()));
                          break;
                        case 'Historique':
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const Historique()));
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
                      const PopupMenuItem(value: 'Profil', child: Row(
                        children: const [
                          Icon(Icons.person, color: Colors.teal, size: 20),
                          SizedBox(width: 10),
                          Text('Profil'),
                        ],
                      )),
                      const PopupMenuItem(value: 'Météo', child: Row(
                        children: const [
                          Icon(Icons.sunny_snowing, color: Colors.teal, size: 20),
                          SizedBox(width: 10),
                          Text('Météo'),
                        ],
                      )),
                      const PopupMenuItem(value: 'Historique', child: Row(
                        children: const [
                          Icon(Icons.library_books, color: Colors.teal, size: 20),
                          SizedBox(width: 10),
                          Text('Historique'),
                        ],
                      )),
                      PopupMenuItem(
                        value: 'Déconnexion',
                        child: Row(
                          children: [
                            const Icon(Icons.login, color: Colors.teal, size: 20),
                            const SizedBox(width: 10),
                            const Text('Déconnexion'),
                            if (authProvider.isLoggingOut)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ✅ Champ de recherche
              TextField(
                decoration: InputDecoration(
                  hintText: "Rechercher une tâche...",
                  hintStyle: const TextStyle(color: Colors.black45),
                  prefixIcon: const Icon(Icons.search, color: Colors.teal),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                  context.read<Todoprovider>().searchTasks(value);  // 👈 Appel de ta méthode de recherche
                },
              ),

              const SizedBox(height: 30),
              Expanded(
                child: Consumer<Todoprovider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Ici on utilise la nouvelle liste à afficher
                    final todosToDisplay = provider.todosView.where((todo) => todo.isCompleted).toList();

                    if (todosToDisplay.isEmpty) {
                      return const Center(child: Text("Aucune tâche trouvée"));
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: todosToDisplay.length,
                      itemBuilder: (context, index) {
                        return _buildTaskCard(
                          todosToDisplay[index].todo,
                          todosToDisplay[index].date ?? 'Pas de date fixe',
                          index,
                          provider,
                          todosToDisplay[index], // 👈 Passer l'objet todo complet
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

  // 👈 Modifier la signature pour accepter l'objet todo
  Widget _buildTaskCard(String title, String date, int index, Todoprovider provider, dynamic todo) {
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
                child: const Icon(Icons.assignment, size: 26, color: Colors.teal),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    // vibration
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      items: [
                        PopupMenuItem(
                          value: 'edit',
                          child: Container(
                            child: Row(
                              children: const [
                                Icon(Icons.edit, size: 18, color: Colors.teal),
                                SizedBox(width: 8),
                                Text("Modifier", style: TextStyle(fontSize: 14, color: Colors.teal)),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Container(
                            child: Row(
                              children: const [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text("Supprimer", style: TextStyle(fontSize: 14, color: Colors.red)),
                              ],
                            ),
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
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(date,
                          style: const TextStyle(color: Colors.black54, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              Checkbox(
                value: todo.isCompleted, // 👈 Utiliser directement todo.isCompleted au lieu de provider.checkedStates[index]
                activeColor: Colors.teal,
                onChanged: (bool? value) async {
                  // On veut remettre en done=0
                  await provider.checkTask(index); // ton checkTask va faire updateTodo & removeAt
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //==========Dialogue delete
  void _showDeleteConfirm(BuildContext context, Todoprovider provider, int index) {
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
                            borderRadius: BorderRadius.circular(10)),
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
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        provider.deleteTask(index);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("🗑️ Tâche supprimée"),
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text(
                        "Supprimer",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
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
    final dateCtrl  = TextEditingController(text: provider.todos[index].date);

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
                  prefixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
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
                    dateCtrl.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
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
                        final authProvider = Provider.of<LoginProvider>(context, listen: false);
                        final accountId = authProvider.currentUser?.accountId ?? 0;
                        provider.updateDone(
                            index,
                            titleCtrl.text.trim(),
                            dateCtrl.text.trim(),
                            provider.todos[index].isCompleted,
                            accountId
                        );

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("✏️ La tâche a été modifiée"),
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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