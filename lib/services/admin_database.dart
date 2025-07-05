import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDatabase {
  // Add Event
  Future<void> addEvent(Map<String, dynamic> eventData, String id) async {
    return await FirebaseFirestore.instance
        .collection("Event")
        .doc(id)
        .set(eventData);
  }

  // Get Departments
  Future<List<String>> getDepartments() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("Departments").get();

    List<String> departments =
        snapshot.docs
            .map((doc) => doc['name']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList();

    return departments;
  }

  // Add Department
  Future<void> addDepartment(String name) async {
    await FirebaseFirestore.instance.collection("Departments").add({
      "name": name,
    });
  }

  // Delete Department
  Future<void> deleteDepartmentByName(String name) async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance
            .collection("Departments")
            .where("name", isEqualTo: name)
            .get();

    for (var doc in snapshot.docs) {
      await FirebaseFirestore.instance
          .collection("Departments")
          .doc(doc.id)
          .delete();
    }
  }

  //  Get Events
  Future<List<Map<String, dynamic>>> getEvents() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("Event").get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // get user
  Future<List<Map<String, dynamic>>> getUser() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("user").get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  //  Delete Event by ID
  Future<void> deleteEventById(String id) async {
    await FirebaseFirestore.instance.collection("Event").doc(id).delete();
  }
}
