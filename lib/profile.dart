import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:plantask/providers/loginProvider.dart';
import 'package:plantask/providers/UserProvider.dart';
import 'package:plantask/Home.dart';
import 'package:plantask/providers/WeatherProvider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authProvider = Provider.of<LoginProvider>(context, listen: false);
      final accountId = authProvider.currentUser?.accountId ?? 0;
      Provider.of<UserProvider>(context, listen: false).loadLoggedInUser(accountId);
      Provider.of<WeatherProvider>(context, listen: false).loadWeather();
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      final authProvider = Provider.of<LoginProvider>(context, listen: false);
      final accountId = authProvider.currentUser?.accountId ?? 0;

      final success = await Provider.of<UserProvider>(context, listen: false)
          .updateProfilePhoto(accountId, pickedFile.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? "✅ Photo de profil mise à jour" : "❌ Échec de la mise à jour"),
          backgroundColor: success ? Colors.black : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildStatCard(
      String label, String value, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 13, color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStats(UserProvider userProv) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard("Complétées", "${userProv.completedTasks}",
            const Color(0xFFC8E9E8), Colors.teal),
        _buildStatCard("En attente", "${userProv.pendingTasks}",
            const Color(0xFFF6E1A7), Colors.white),
        _buildStatCard("Manquées", "${userProv.missedTasks}",
            const Color(0xFFE39E9F), Colors.white),
      ],
    );
  }

  Widget _buildProfileInfoCombined(String email, String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Adresse email",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.email_outlined, color: Colors.black, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  email.isEmpty ? "Non renseigné" : email,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 0.8, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Localisation",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: Colors.black, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(location,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;

    final userProv = Provider.of<UserProvider>(context);
    final weatherProv = Provider.of<WeatherProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: userProv.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.06,
            vertical: height * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                shape: const CircleBorder(),
                elevation: 4,
                color: Colors.white,
                child: IconButton(
                  icon: Icon(Icons.chevron_left,
                      size: 32, color: Colors.teal[700]),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const Home()),
                  ),
                ),
              ),
              SizedBox(height: height * 0.025),
              Center(
                child: Text("Mon profil",
                    style: TextStyle(
                        fontSize: width * 0.09,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                        letterSpacing: 1.1)),
              ),
              SizedBox(height: height * 0.04),
              Center(
                child: SizedBox(
                  width: width * 0.40,
                  height: width * 0.40,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: width * 0.20,
                          backgroundColor: Colors.white,
                          backgroundImage: userProv.currentUser
                              ?.profilePhotoPath !=
                              null
                              ? FileImage(File(userProv
                              .currentUser!.profilePhotoPath!))
                              : const AssetImage(
                              'assets/images/profile01.jpg')
                          as ImageProvider,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.teal, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.1),
              _buildTaskStats(userProv),
              SizedBox(height: height * 0.06),
              _buildProfileInfoCombined(
                  userProv.currentUser?.email ?? "",
                  weatherProv.location),
            ],
          ),
        ),
      ),
    );
  }
}

