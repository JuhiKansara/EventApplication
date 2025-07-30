import 'dart:async';

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
  List<String> allEventNames = [];
  List<String> departments = [];
  String? selectedDepartment;

  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  OverlayEntry? suggestionOverlay;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _searchFocus = FocusNode();

  String? userName;
  String? userDepartment;

  @override
  void initState() {
    super.initState();
    loadEventData();
    loadDepartments();
    loadUserData();
    cleanUpExpiredEvents();
    scheduleDailyCleanup();
  }

  @override
  void dispose() {
    hideSuggestionsOverlay();
    searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

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

  Future<void> loadEventData() async {
    eventStream = await DatabaseMethods().getAllEvents();
    eventStream!.listen((event) async {
      List<String> names = [];
      DateTime today = DateTime.now();
      DateTime todayOnly = DateTime(today.year, today.month, today.day);

      for (var doc in event.docs) {
        String eventDateStr = doc["Date"] ?? "";
        if (eventDateStr.isNotEmpty) {
          DateTime eventDate = DateTime.parse(eventDateStr);
          DateTime eventOnlyDate = DateTime(
            eventDate.year,
            eventDate.month,
            eventDate.day,
          );

          if (eventOnlyDate.isBefore(todayOnly)) {
            await FirebaseFirestore.instance
                .collection('Event')
                .doc(doc.id)
                .delete();

            var booking =
                await FirebaseFirestore.instance
                    .collection('Bookings')
                    .where('eventId', isEqualTo: doc.id)
                    .get();

            for (var booking in booking.docs) {
              await FirebaseFirestore.instance
                  .collection('Bookings')
                  .doc(booking.id)
                  .delete();
            }

            continue;
          }
        }

        names.add(doc["Name"].toString());
      }

      setState(() {
        allEventNames = names;
      });
    });

    setState(() {});
  }

  Future<void> loadDepartments() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Departments').get();
    final deptNames =
        snapshot.docs.map((doc) => doc['name'].toString()).toList();
    setState(() {
      departments = deptNames;
    });
  }

  List<String> getSuggestions(String query) {
    return allEventNames
        .where((name) => name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void showSuggestionsOverlay() {
    hideSuggestionsOverlay();

    final overlay = Overlay.of(context);
    final suggestions = getSuggestions(searchQuery);
    if (suggestions.isEmpty || overlay == null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            width: MediaQuery.of(context).size.width - 40,
            left: 20,
            top: offset.dy + 140,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, 50),
              child: Material(
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: suggestions.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        title: Text(
                          suggestions[index],
                          style: TextStyle(color: Color(0xFF003B49)),
                        ),
                        onTap: () {
                          setState(() {
                            searchController.text = suggestions[index];
                            searchQuery = suggestions[index];
                          });
                          hideSuggestionsOverlay();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
    );

    suggestionOverlay = overlayEntry;
    overlay.insert(overlayEntry);
  }

  void hideSuggestionsOverlay() {
    suggestionOverlay?.remove();
    suggestionOverlay = null;
  }

  Widget allEvents() {
    return StreamBuilder(
      stream: eventStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
          return Container(
            width: double.infinity,
            color: const Color(0xE6EDEEEC),
            alignment: Alignment.center,
            height: 150,
            child: const Text(
              "No events found.",
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
          );
        }

        DateTime today = DateTime.now();
        DateTime todayOnly = DateTime(today.year, today.month, today.day);

        List<DocumentSnapshot> filteredEvents =
            snapshot.data.docs.where((doc) {
          String name = (doc["Name"] ?? "").toString().toLowerCase();
          bool matchesSearch = name.contains(searchQuery.toLowerCase());

          String dateStr = doc["Date"] ?? "";
          if (dateStr.isEmpty) return false;

          DateTime eventDate = DateTime.tryParse(dateStr) ?? DateTime(2000);
          DateTime eventOnlyDate = DateTime(
            eventDate.year,
            eventDate.month,
            eventDate.day,
          );
          if (eventOnlyDate.isBefore(todayOnly)) return false;

          if (selectedDepartment != null && selectedDepartment!.isNotEmpty) {
            List docDepartments = doc["Departments"] ?? [];
            return matchesSearch &&
                docDepartments.contains(selectedDepartment);
          }

          return matchesSearch;
        }).toList();

        if (filteredEvents.isEmpty) {
          return Container(
            width: double.infinity,
            color: const Color(0xFFEAF3F5),
            alignment: Alignment.center,
            height: 300,
            child: const Text(
              "No matching events found.",
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            DocumentSnapshot ds = filteredEvents[index];
            return buildEventCard(ds);
          },
        );
      },
    );
  }

  Widget buildEventCard(DocumentSnapshot ds) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imagePath = ds["Image"] ?? "";
    final date = DateFormat(
      'MMM dd',
    ).format(DateTime.parse(ds["Date"] ?? "2000-01-01"));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DetailPage(
                  eventId: ds.id,
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
      child: Container(
        margin: EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imagePath,
                height: 150,
                width: screenWidth,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    width: screenWidth,
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: Text("Image not available"),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ds["Name"] ?? "",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003B49),
                        ),
                      ),
                      Text(
                        "₹ ${ds["Price"] ?? "Free"}",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(date, style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ds["Location"] ?? "",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> cleanUpExpiredEvents() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final querySnapshot =
        await FirebaseFirestore.instance.collection('Event').get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      DateTime? eventDate;

      if (data['Date'] is Timestamp) {
        eventDate = (data['Date'] as Timestamp).toDate();
      } else if (data['Date'] is String) {
        try {
          eventDate = DateTime.parse(data['Date']);
        } catch (e) {
          continue;
        }
      }

      if (eventDate != null) {
        final eventOnlyDate = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
        );

        if (eventOnlyDate.isBefore(today)) {
          await FirebaseFirestore.instance
              .collection('Event')
              .doc(doc.id)
              .delete();

          final bookings =
              await FirebaseFirestore.instance
                  .collection('Bookings')
                  .where('eventId', isEqualTo: doc.id)
                  .get();

          for (var booking in bookings.docs) {
            await FirebaseFirestore.instance
                .collection('Bookings')
                .doc(booking.id)
                .delete();
          }
        }
      }
    }
  }

  void scheduleDailyCleanup() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = nextMidnight.difference(now);

    Future.delayed(durationUntilMidnight, () async {
      await cleanUpExpiredEvents();
      scheduleDailyCleanup();
    });
  }

  Widget buildSmallCard(String title) {
    bool isSelected =
        selectedDepartment == title ||
        (title == "All Events" && selectedDepartment == null);
    final isAllEvents = title == "All Events";

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDepartment = isAllEvents ? null : title;
        });
      },
      child: Container(
        width: isAllEvents ? 120 : 100,
        height: 45,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF003B49) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Color(0xFF003B49),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFEAF3F5), // ← Updated solid background
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003B49),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          userName ?? '',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF003B49),
                          ),
                        ),
                        if (userDepartment != null &&
                            userDepartment!.isNotEmpty)
                          Text(
                            "Department: $userDepartment",
                            style: TextStyle(
                              color: Color(0xFF003B49),
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                CompositedTransformTarget(
                  link: _layerLink,
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Color(0xFF003B49)),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            focusNode: _searchFocus,
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                              if (value.isNotEmpty) {
                                showSuggestionsOverlay();
                              } else {
                                hideSuggestionsOverlay();
                              }
                            },
                            onTap: () {
                              if (searchController.text.isNotEmpty) {
                                showSuggestionsOverlay();
                              }
                            },
                            style: TextStyle(color: Color(0xFF003B49)),
                            decoration: InputDecoration(
                              hintText: "Search for events...",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                searchController.clear();
                                searchQuery = '';
                              });
                              hideSuggestionsOverlay();
                            },
                            child: Icon(Icons.close, color: Color(0xFF003B49)),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "Departments",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF003B49),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  height: 45,
                  child:
                      departments.isEmpty
                          ? Center(child: Text("No departments found"))
                          : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: departments.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0)
                                return buildSmallCard("All Events");
                              return buildSmallCard(departments[index - 1]);
                            },
                          ),
                ),
                SizedBox(height: 30),
                Text(
                  "Upcoming Events",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003B49),
                  ),
                ),
                SizedBox(height: 20),
                allEvents(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
