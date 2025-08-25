// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:plantask/providers/SignupProvider.dart';
// import 'App.dart';
//
// class Inscription extends StatelessWidget {
//   const Inscription({super.key});
//
//   InputDecoration _inputDecoration(String hint, IconData icon) {
//     return InputDecoration(
//       prefixIcon: Icon(icon, color: Colors.teal[700]),
//       hintText: hint,
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15),
//         borderSide: BorderSide.none,
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15),
//         borderSide: BorderSide(color: Colors.teal),
//       ),
//       contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
//     );
//   }
//
//   void _signup(BuildContext context) async {
//     final signupProvider = context.read<SignupProvider>();
//
//     bool success = await signupProvider.signup();
//
//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Inscription réussie !"),
//           backgroundColor: Colors.black,
//           duration: Duration(seconds: 2),
//         ),
//       );
//       await Future.delayed(const Duration(seconds: 2));
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const App()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(signupProvider.error ?? "Erreur inconnue")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final primaryGreen = const Color(0xFF6BAEAB);
//     final mediaQuery = MediaQuery.of(context);
//     final minHeight = mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom;
//
//     return Scaffold(
//       backgroundColor: primaryGreen,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 25),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(minHeight: minHeight),
//             child: IntrinsicHeight(
//               child: Consumer<SignupProvider>(
//                 builder: (context, signupProvider, child) => Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Center(
//                       child: Text(
//                         "Créer un compte",
//                         style: TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white.withOpacity(0.9),
//                           letterSpacing: 1.2,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 50),
//
//                     TextField(
//                       controller: signupProvider.emailController,
//                       keyboardType: TextInputType.emailAddress,
//                       decoration: _inputDecoration("Entrez votre adresse mail", Icons.email_outlined),
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                     const SizedBox(height: 25),
//
//                     TextField(
//                       controller: signupProvider.passwordController,
//                       obscureText: true,
//                       decoration: _inputDecoration("Saisissez un mot de passe", Icons.lock_outline),
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                     const SizedBox(height: 25),
//
//                     TextField(
//                       controller: signupProvider.confirmPasswordController,
//                       obscureText: true,
//                       decoration: _inputDecoration("Confirmez le mot de passe", Icons.lock_outline),
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                     const SizedBox(height: 40),
//
//                     ElevatedButton(
//                       onPressed: signupProvider.loading ? null : () => _signup(context),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.teal[700],
//                         padding: const EdgeInsets.symmetric(vertical: 18),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         elevation: 5,
//                       ),
//                       child: signupProvider.loading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : const Text(
//                         "S'inscrire",
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           letterSpacing: 1,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//
//                     Center(
//                       child: Wrap(
//                         alignment: WrapAlignment.center,
//                         children: [
//                           const Text(
//                             "Vous avez déjà un compte ? ",
//                             style: TextStyle(color: Colors.white70, fontSize: 16),
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: const Text(
//                               "Connectez-vous",
//                               style: TextStyle(
//                                 color: Colors.tealAccent,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                                 decoration: TextDecoration.underline,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plantask/providers/SignupProvider.dart';
import 'package:plantask/App.dart';

class Inscription extends StatelessWidget {
  // const Inscription({super.key});
  const Inscription({super.key});

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.teal[700]),
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.teal),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    );
  }

  void _signup(BuildContext context) async {
    final signupProvider = context.read<SignupProvider>();

    bool success = await signupProvider.signup();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inscription réussie !"),
          backgroundColor: Colors.black,
          duration: Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));

      Navigator.pop(context, MaterialPageRoute(builder: (_) => const App()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(signupProvider.error ?? "Erreur inconnue")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryGreen = const Color(0xFF6BAEAB);
    final mediaQuery = MediaQuery.of(context);
    final minHeight =
        mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;

    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: IntrinsicHeight(
              child: Consumer<SignupProvider>(
                builder: (context, signupProvider, child) => Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          "Créer un compte",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      TextFormField(
                        controller: signupProvider.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          "Entrez votre adresse mail",
                          Icons.email_outlined,
                        ),
                        style: const TextStyle(fontSize: 18),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une adresse email';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Adresse email invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),

                      TextField(
                        controller: signupProvider.passwordController,
                        obscureText: true,
                        decoration: _inputDecoration(
                          "Saisissez un mot de passe",
                          Icons.lock_outline,
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 25),

                      TextField(
                        controller: signupProvider.confirmPasswordController,
                        obscureText: true,
                        decoration: _inputDecoration(
                          "Confirmez le mot de passe",
                          Icons.lock_outline,
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 40),

                      ElevatedButton(
                        onPressed: signupProvider.loading
                            ? null
                            : () {
                                _signup(context);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[700],
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: signupProvider.loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "S'inscrire",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                      const SizedBox(height: 25),

                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            const Text(
                              "Vous avez déjà un compte ? ",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Connectez-vous",
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
