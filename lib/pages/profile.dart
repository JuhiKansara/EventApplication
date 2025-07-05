// import 'package:eventbooking/pages/edit_profile.dart';
// import 'package:eventbooking/pages/signup.dart';
// import 'package:eventbooking/services/auth.dart';
// import 'package:eventbooking/services/database.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   String userName = '';
//   String userEmail = '';
//   String profileImageUrl = '';
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadUserData();
//   }

//   Future<void> loadUserData() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid != null) {
//       final data = await DatabaseMethods().getUserDetails(uid);
//       if (data != null) {
//         setState(() {
//           userName = data['Name'] ?? '';
//           userEmail = data['Email'] ?? '';
//           profileImageUrl = data['Image'] ?? '';
//           isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 50),
//                     const Text(
//                       "My Profile",
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     CircleAvatar(
//                       radius: 60,
//                       backgroundImage:
//                           profileImageUrl.isNotEmpty
//                               ? NetworkImage(profileImageUrl)
//                               : null,
//                       child:
//                           profileImageUrl.isEmpty
//                               ? const Icon(Icons.person, size: 60)
//                               : null,
//                     ),
//                     const SizedBox(height: 20),
//                     Text(userName, style: const TextStyle(fontSize: 20)),
//                     const SizedBox(height: 5),
//                     Text(userEmail, style: const TextStyle(color: Colors.grey)),
//                     const SizedBox(height: 30),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.edit),
//                       label: const Text('Edit Profile'),
//                       onPressed: () async {
//                         final result = await Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (context) => EditProfilePage(
//                                   currentName: userName,
//                                   currentEmail: userEmail,
//                                   currentImageUrl: profileImageUrl,
//                                 ),
//                           ),
//                         );

//                         if (result == true) {
//                           await loadUserData();
//                         }
//                       },
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.logout),
//                       label: const Text('Logout'),
//                       onPressed: () async {
//                         await AuthMethod().signOut(context);
//                         Navigator.pushAndRemoveUntil(
//                           context,
//                           MaterialPageRoute(builder: (_) => const SignUp()),
//                           (_) => false,
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }
// }



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

  static const Color kAccent = Color(0xff6351ec);
  static const List<Color> kGradient = [
    Color(0xffe3e6ff),
    Color(0xfff1f3ff),
    Colors.white,
  ];

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
              padding: const EdgeInsets.only(top: 40.0),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: kGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "My Profile",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 30),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage:
                                  profileImageUrl.isNotEmpty
                                      ? NetworkImage(profileImageUrl)
                                      : null,
                              child: profileImageUrl.isEmpty
                                  ? const Icon(Icons.person, size: 60)
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              userEmail,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Edit Profile
                            buildProfileOption(
                              icon: Icons.edit,
                              title: 'Edit Profile',
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfilePage(
                                      currentName: userName,
                                      currentEmail: userEmail,
                                      currentImageUrl: profileImageUrl,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  await loadUserData();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Profile updated successfully")),
                                  );
                                }
                              },
                            ),

                            // Logout
                            buildProfileOption(
                              icon: Icons.logout,
                              title: 'Logout',
                              onTap: () async {
                                await AuthMethod().signOut(context);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUp(),
                                  ),
                                  (route) => false,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: kAccent),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
