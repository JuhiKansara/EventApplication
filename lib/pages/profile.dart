import 'package:eventbooking/pages/edit_profile.dart';
import 'package:eventbooking/pages/signup.dart';
import 'package:eventbooking/services/auth.dart';
import 'package:eventbooking/services/database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = '';
  String userEmail = '';
  String profileImageUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final data = await DatabaseMethods().getUserDetails(uid);
      if (data != null) {
        setState(() {
          userName = data['Name'] ?? '';
          userEmail = data['Email'] ?? '';
          profileImageUrl = data['Image'] ?? '';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff7F7FD5), Color(0xff86A8E7), Color(0xff91EAE4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    "My Profile",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 25),
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl.isEmpty
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          buildOptionCard(
                            icon: Icons.edit,
                            title: 'Edit Profile',
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfilePage(
                                    currentEmail: userEmail,
                                    currentImageUrl: profileImageUrl,
                                  ),
                                ),
                              );
                              if (result == true) {
                                await loadUserData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Profile updated")),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 15),
                          buildOptionCard(
                            icon: Icons.logout,
                            title: 'Logout',
                            onTap: () async {
                              await AuthMethod().signOut(context);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const SignUp()),
                                (route) => false,
                              );
                            },
                            color: const Color(0xff6351ec),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color(0xff6351ec),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),

        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
