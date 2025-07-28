import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  // Add user to Firestore
  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("user")
        .doc(id)
        .set(userInfoMap, SetOptions(merge: true));
  }

  // Get all event data as stream
  Future<Stream<QuerySnapshot>> getAllEvents() async {
    return FirebaseFirestore.instance.collection("Event").snapshots();
  }


  Future<void> updateUserProfile(String uid, Map<String, dynamic> updatedData) async {
    return await FirebaseFirestore.instance.collection("user").doc(uid).update(updatedData);
  }

  // Get signed-in user's details
  Future<Map<String, dynamic>?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection("user").doc(uid).get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }
}