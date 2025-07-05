import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eventbooking/pages/booking.dart';
import 'package:eventbooking/pages/home.dart';
import 'package:eventbooking/pages/profile.dart'; // ✅ Make sure this path is correct

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const Home(),
      const Booking(),
      const ProfilePage(), // ✅ Use this only if ProfilePage is defined correctly
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: pages[currentTabIndex],
      bottomNavigationBar: SafeArea(
        top: false,
        child: CurvedNavigationBar(
          height: 65,
          backgroundColor: Colors.white,
          color: Colors.black,
          animationDuration: const Duration(milliseconds: 300),
          index: currentTabIndex,
          onTap: (int index) {
            setState(() {
              currentTabIndex = index;
            });
          },
          items: const [
            Icon(Icons.home_outlined, color: Colors.white, size: 30.0),
            Icon(Icons.book, color: Colors.white, size: 30.0),
            Icon(Icons.person_outline, color: Colors.white, size: 30.0),
          ],
        ),
      ),
    );
  }
}
