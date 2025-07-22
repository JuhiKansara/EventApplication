import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final userId = currentUser.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .collection('Bookings')
            .orderBy('bookingTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final bookings = snapshot.data!.docs;

          if (bookings.isEmpty) {
            return const Center(child: Text("No bookings yet."));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.blue),
                                const SizedBox(width: 5),
                                Text(
                                  booking['location'] ?? 'Unknown',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: booking['image'] != null
                                      ? Image.network(
                                          booking['image'],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image_not_supported, size: 80),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking['name'] ?? 'Event Name',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16),
                                        const SizedBox(width: 5),
                                        Text(booking['date'] ?? 'N/A'),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(Icons.currency_rupee, size: 16),
                                        const SizedBox(width: 5),
                                        Text(booking['price'] ?? '0'),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
