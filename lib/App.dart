import 'package:flutter/material.dart';
import 'package:plantask/Home.dart';
import 'package:plantask/inscription.dart';
import 'package:provider/provider.dart';
import 'package:plantask/providers/loginProvider.dart';

class App extends StatelessWidget {
  const App({super.key});

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

  void _handleLogin(BuildContext context) async {
    final provider = context.read<LoginProvider>();
    final result = await provider.login();

    if (result["success"] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Erreur de connexion")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
      builder: (context, provider, child) {
        if (provider.isCheckingLogin) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.isLoggedIn) {
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Home()),
            );
          });
          return const Scaffold(); // écran vide temporaire pendant la redirection
        }

        final primaryGreen = const Color(0xFF6BAEAB);
        final mediaQuery = MediaQuery.of(context);
        final minHeight =
            mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom;

        return Scaffold(
          backgroundColor: primaryGreen,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          "Connexion",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      TextField(
                        controller: provider.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          "Entrez votre adresse mail",
                          Icons.email_outlined,
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 25),

                      TextField(
                        controller: provider.passwordController,
                        obscureText: true,
                        decoration: _inputDecoration(
                          "Saisissez un mot de passe",
                          Icons.lock_outline,
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 40),

                      ElevatedButton(
                        onPressed: provider.isLoading
                            ? null
                            : () => _handleLogin(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[700],
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: provider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "Se connecter",
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
                              "Vous n’avez pas de compte? ",
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Inscription(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Inscrivez-vous",
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
        );
      },
    );
  }
}
