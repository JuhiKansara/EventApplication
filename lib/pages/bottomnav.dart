import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eventbooking/pages/booking.dart';
import 'package:eventbooking/pages/home.dart';
import 'package:eventbooking/pages/profile.dart';

class BottomNav extends StatefulWidget {
  final int initialTabIndex;
  const BottomNav({super.key, this.initialTabIndex = 0});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late int currentTabIndex;   

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    currentTabIndex = widget.initialTabIndex;
    pages = [
      const Home(),
      const BookingPage(),
      const ProfilePage(),
    ];
  }

  Future<bool> _onWillPop() async {
    if (currentTabIndex != 0) {
      setState(() {
        currentTabIndex = 0; // Go back to home tab
      });
      return false; // Prevent app exit
    }
    return true; // Allow app exit if already on home
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
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
      ),
    );
  }
}