import 'package:eventbooking/admin/ManageDepartment.dart';
import 'package:eventbooking/admin/AddEvent.dart';
import 'package:eventbooking/admin/ManageUsersPage.dart';
import 'package:eventbooking/admin/manage_events.dart';
import 'package:eventbooking/services/auth.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  static const List<Color> kGradient = [
    Color(0xffe3e6ff),
    Color(0xfff1f3ff),
    Colors.white,
  ];

  static const Color kCardColor = Colors.white;
  static const Color kPrimary = Color(0xff6351ec);

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
              const SizedBox(height: 20),
              const Text(
                "Admin Dashboard",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: kPrimary,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F9FC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          children: [
                            buildSquareCard(
                              context,
                              title: "Add Event",
                              icon: Icons.event,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddEvent(),
                                ),
                              ),
                            ),
                            buildSquareCard(
                              context,
                              title: "Manage Department",
                              icon: Icons.apartment,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ManageDepartment(),
                                ),
                              ),
                            ),
                            buildSquareCard(
                              context,
                              title: "Manage Events",
                              icon: Icons.manage_search,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ManageEventsPage(),
                                ),
                              ),
                            ),
                            buildSquareCard(
                              context,
                              title: "Manage Users",
                              icon: Icons.people_alt,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ManageUsersPage(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Logout Button
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => AuthMethod().signOut(context),
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            elevation: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSquareCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: kPrimary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
