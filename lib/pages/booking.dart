import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  Future<DocumentSnapshot?> getEventFromId(String eventId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('Event')
              .doc(eventId)
              .get();
      return doc.exists ? doc : null;
    } catch (e) {
      return null;
    }
  }

  bool isExpired(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now);
  }

  Future<void> _deleteBooking(
    BuildContext context,
    String bookingId,
    String userId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .collection('Bookings')
          .doc(bookingId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking deleted successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete booking: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    final userId = currentUser.uid;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 60.0),
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF3F5), Color(0xFF003B49)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Text(
              "Bookings",
              style: TextStyle(
                color: Colors.black,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15.0),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  color: Colors.white,
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('user')
                          .doc(userId)
                          .collection('Bookings')
                          .orderBy('bookingTime', descending: true)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final bookings = snapshot.data!.docs;

                    if (bookings.isEmpty) {
                      return const Center(child: Text("No bookings yet."));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        final eventId = booking['eventId'];
                        final bookingId = booking.id;

                        return FutureBuilder<DocumentSnapshot?>(
                          future: getEventFromId(eventId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();
                            final eventDoc = snapshot.data;
                            if (eventDoc == null || !eventDoc.exists) {
                              return const SizedBox();
                            }

                            final data =
                                eventDoc.data() as Map<String, dynamic>;

                            final dateStr = data['Date'];
                            DateTime? eventDate;
                            if (dateStr is String) {
                              try {
                                eventDate = DateTime.parse(dateStr);
                              } catch (_) {}
                            } else if (dateStr is Timestamp) {
                              eventDate = dateStr.toDate();
                            }

                            final expired =
                                eventDate == null ? true : isExpired(eventDate);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 20.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F7FA),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🔁 Top row: shows Event Name with icon
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.event,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          data['Name'] ?? 'Event',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (expired)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _deleteBooking(
                                            context,
                                            bookingId,
                                            userId,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: data['Image'] != null
                                            ? Image.network(
                                          data['Image'],
                                          height: 130,
                                          width: 130,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, size: 80),
                                        )
                                            : const Icon(Icons.image),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // ✅ Location with icon and normal font
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 18,
                                                  color: Colors.blue,
                                                ),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                    data['Location'] ?? 'Unknown',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_month,
                                                  size: 18,
                                                  color: Colors.blue,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  data['Date']?.toString() ?? 'N/A',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.currency_rupee_outlined,
                                                  size: 18,
                                                  color: Colors.blue,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  data['Price']?.toString() ?? '0',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}