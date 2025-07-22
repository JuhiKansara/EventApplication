import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventbooking/admin/adminhomepage.dart';
import 'package:eventbooking/pages/bottomnav.dart';
import 'package:eventbooking/pages/signup.dart';
import 'package:eventbooking/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethod {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  // SIGN IN WITH GOOGLE + ROLE CHECK
  Future<void> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount == null) return;

    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );

    UserCredential result = await auth.signInWithCredential(credential);
    User? userDetails = result.user;

    if (userDetails != null) {
      final userRef = firestore.collection('user').doc(userDetails.uid);
      final userSnap = await userRef.get();

      // 🔸 Add user if new
      if (!userSnap.exists) {
        Map<String, dynamic> userInfoMap = {
          "Name": userDetails.displayName,
          "Image": userDetails.photoURL,
          "Email": userDetails.email,
          "Id": userDetails.uid,
          "Role": "admin", // Default role for new user
        };
        await DatabaseMethods().addUserDetail(userInfoMap, userDetails.uid);
      }

      // 🔹 Get latest user data
      final updatedUserSnap = await userRef.get();
      final userData = updatedUserSnap.data() as Map<String, dynamic>;

      String role = userData['Role'] ?? 'user';

      // ✅ Auto-correct admin email role
      if (userData['Email'] == 'ebookings@gmail.com' && role != 'admin') {
        await userRef.update({'Role': 'admin'});
        role = 'admin';
      }

      // Navigate based on corrected role
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => role == 'admin' ? const AdminHomePage() : const BottomNav(),
          ),
        );
      });
    }
  }

  // SIGN OUT
  Future<void> signOut(BuildContext context) async {
    await GoogleSignIn().signOut();
    await auth.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignUp()),
      (route) => false,
    );
  }
}
