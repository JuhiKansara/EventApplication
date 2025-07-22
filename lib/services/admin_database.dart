import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Add Event
  Future<void> addEvent(Map<String, dynamic> eventData, String id) async {
    return await _firestore.collection("Event").doc(id).set(eventData);
  }

  // 🔹 Get Departments
  Future<List<String>> getDepartments() async {
    QuerySnapshot snapshot = await _firestore.collection("Departments").get();

    List<String> departments = snapshot.docs
        .map((doc) => doc['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    return departments;
  }

  // 🔹 Add Department
  Future<void> addDepartment(String name) async {
    await _firestore.collection("Departments").add({
      "name": name,
    });
  }

  // 🔹 Delete Department by Name
  Future<void> deleteDepartmentByName(String name) async {
    QuerySnapshot snapshot = await _firestore
        .collection("Departments")
        .where("name", isEqualTo: name)
        .get();

    for (var doc in snapshot.docs) {
      await _firestore.collection("Departments").doc(doc.id).delete();
    }
  }

  // 🔹 Get Events
  Future<List<Map<String, dynamic>>> getEvents() async {
    QuerySnapshot snapshot = await _firestore.collection("Event").get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      data['Department'] = data['Department'] ?? data['College'] ?? '';
      return data;
    }).toList();
  }

  // 🔹 Get Users
  Future<List<Map<String, dynamic>>> getUser() async {
    QuerySnapshot snapshot = await _firestore.collection("user").get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // 🔹 Delete Event by ID
  Future<void> deleteEventById(String id) async {
    await _firestore.collection("Event").doc(id).delete();
  }

  // 🔹 Book Event for a User
  Future<void> bookEvent(String userId, Map<String, dynamic> eventData) async {
    await _firestore
        .collection('user')
        .doc(userId)
        .collection('Bookings')
        .add({
          ...eventData,
          'bookingTime': FieldValue.serverTimestamp(),
        });
  }
}
