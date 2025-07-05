import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventbooking/pages/detail_page.dart';
import 'package:eventbooking/services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Stream? eventStream;
  String? userName;
  String? userDepartment;

  @override
  void initState() {
    super.initState();
    loadEventData();
    loadUserData();
  }

  // 🔥 Load user info from Firestore
  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final data = await DatabaseMethods().getUserDetails(uid);
      if (data != null) {
        setState(() {
          userName = data['Name'] ?? 'User';
          userDepartment = data['Department'] ?? '';
        });
      }
    }
  }

  // 🔥 Load all event data
  Future<void> loadEventData() async {
    eventStream = await DatabaseMethods().getAllEvents();
    setState(() {});
  }

  Widget allEvents() {
    return StreamBuilder(
      stream: eventStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return Center(child: Text("No events found."));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = snapshot.data.docs[index];
            return buildEventCard(ds);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 10.0),
        width: screenWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe3e6ff), Color(0xfff1f3ff), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, ${userName ?? ''}",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  if (userDepartment != null && userDepartment!.isNotEmpty)
                    Text(
                      "Department: $userDepartment",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  SizedBox(height: 10),

                  StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("Event").snapshots(),
                    builder: (context, snapshot) {
                      int count = 0;
                      if (snapshot.hasData && snapshot.data != null) {
                        count = snapshot.data!.docs.length;
                      }

                      return Text(
                        "Explore $count opportunities to engage, learn, and grow.",
                        style: TextStyle(
                          color: Color(0xff6351ec),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 20),
                  Container(
                    height: 55,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: "Search an Event",
                        border: InputBorder.none,
                        isCollapsed: true,
                        suffixIcon: Icon(Icons.search_outlined),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 136,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        buildSmallCard("images/ai.png", "AI"),
                        buildSmallCard("images/hacker.png", "Hacking"),
                        buildSmallCard("images/java.png", "Java"),
                        buildSmallCard("images/php.png", "PHP"),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Upcoming Event",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "See all",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  allEvents(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSmallCard(String imagePath, String title) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          SizedBox(height: 10),
          Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget buildEventCard(DocumentSnapshot ds) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imagePath = ds["Image"] ?? "";
    final date = DateFormat('MMM, dd').format(DateTime.parse(ds["Date"] ?? "2000-01-01"));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              date: ds["Date"],
              detail: ds["Detail"],
              image: ds["Image"],
              location: ds["Location"],
              name: ds["Name"],
              price: ds["Price"],
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imagePath,
                  height: 200,
                  width: screenWidth,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: screenWidth,
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: Text(
                        "Image not found",
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  width: 50,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      date,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ds["Name"] ?? "No Title",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                ds["Price"] ?? "Free",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff6351ec),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.location_on, size: 20),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  ds["Location"] ?? "Unknown",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}