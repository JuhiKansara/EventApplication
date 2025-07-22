import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventbooking/services/admin_database.dart';
import 'package:flutter/material.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  // -------- COLORS & GRADIENT (copied from ManageDepartment) ----------
  static const List<Color> kGradient = [
    Color(0xffe3e6ff),
    Color(0xfff1f3ff),
    Colors.white,
  ];
  static const Color kPrimary = Color(0xff6351ec);

  // -------- DATA ------------------------------------------------------
  final AdminDatabase adminDb = AdminDatabase();
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> departmentList = [];
  String selectedDepartment = 'All';
  bool isLoading = true;

  // -------- LIFECYCLE -------------------------------------------------
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final departments = await adminDb.getDepartments(); // Firestore
    final users = await adminDb.getUser();              // Firestore
    setState(() {
      departmentList = ['All', ...departments];
      allUsers       = users;
      filteredUsers  = users;
      isLoading      = false;
    });
  }

  void filterUsersByDepartment(String department) {
    setState(() {
      selectedDepartment = department;
      if (department == 'All') {
        filteredUsers = allUsers;
      } else {
        filteredUsers = allUsers
            .where((u) => (u['Department'] ?? '')
            .toLowerCase() == department.toLowerCase())
            .toList();
      }
    });
  }

  Future<void> toggleBlockStatus(String userId, bool isBlocked) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .update({'isBlocked': !isBlocked});
    fetchData(); // refresh
  }

  // -------- BUILD -----------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: kGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // -------- TOP BAR (matches ManageDepartment) --------------
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: kPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Manage Users',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // -------- FILTER DROPDOWN ---------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Filter by Department',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedDepartment,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder()),
                        items: departmentList
                            .map(
                              (dept) => DropdownMenuItem<String>(
                            value: dept,
                            child: Text(dept),
                          ),
                        )
                            .toList(),
                        onChanged: (val) =>
                            filterUsersByDepartment(val ?? 'All'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // -------- USER LIST BOX -----------------------------------
              Expanded(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F9FC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredUsers.isEmpty
                      ? const Center(child: Text('No users found.'))
                      : ListView.separated(
                    itemCount: filteredUsers.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isBlocked = user['isBlocked'] ?? false;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            // ---- USER DETAILS -------------
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['Name'] ?? 'No Name',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(user['Email'] ?? 'No Email'),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Department: '
                                        '${user['Department'] ?? 'N/A'}',
                                  ),
                                ],
                              ),
                            ),
                            // ---- BLOCK / UNBLOCK BUTTON ----
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isBlocked
                                    ? Colors.green
                                    : Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => toggleBlockStatus(
                                  user['id'], isBlocked),
                              child: Text(
                                  isBlocked ? 'Unblock' : 'Block'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
