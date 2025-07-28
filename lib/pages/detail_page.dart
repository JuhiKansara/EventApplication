import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventbooking/services/database.dart';
import 'package:eventbooking/pages/bottomnav.dart';

class DetailPage extends StatefulWidget {
  final String eventId;
  final String image, name, location, date, detail, price;

  const DetailPage({
    super.key,
    required this.eventId,
    required this.image,
    required this.name,
    required this.location,
    required this.date,
    required this.detail,
    required this.price,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late ImageProvider eventImage;
  late Razorpay _razorpay;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userData;

  final Color backgroundColor = Color(0xFFEAF3F5);
  final Color textColor = Color(0xFF003B49);

  @override
  void initState() {
    super.initState();
    eventImage = NetworkImage(widget.image);
    _getUserData();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _getUserData() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      userData = await DatabaseMethods().getUserDetails(currentUser.uid);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  bool get isBookingAllowed {
    try {
      DateTime eventDate = DateTime.parse(widget.date);
      DateTime today = DateTime.now();
      return today.isBefore(eventDate.subtract(const Duration(days: 1)));
    } catch (e) {
      return true;
    }
  }

  Future<void> _startPayment() async {
    if (!isBookingAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Booking closed: Event is too close to be booked."),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (userData == null ||
        userData!['Phone'] == null ||
        userData!['Phone'].toString().trim().isEmpty ||
        userData!['Email'] == null ||
        userData!['Email'].toString().trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter all details before booking the event."),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final query =
          await FirebaseFirestore.instance
              .collection('user')
              .doc(currentUser.uid)
              .collection('Bookings')
              .where('eventId', isEqualTo: widget.eventId)
              .get();

      if (query.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You have already booked this event.")),
        );
        return;
      }
    }

    int amountInPaise = ((double.tryParse(widget.price) ?? 0) * 100).toInt();

    var options = {
      'key': 'rzp_test_R4oeGkFlRzMGqp',
      'amount': amountInPaise,
      'name': widget.name,
      'description': 'Booking for ${widget.name}',
      'prefill': {'contact': userData!['Phone'], 'email': userData!['Email']},
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null && userData != null) {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser.uid)
          .collection('Bookings')
          .add({
            'eventId': widget.eventId,
            'bookingTime': FieldValue.serverTimestamp(),
          });
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => BottomNav(initialTabIndex: 1)),
      (route) => false,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet selected: ${response.walletName}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder:
              (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Image(
                              image: eventImage,
                              height: MediaQuery.of(context).size.height / 2.5,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                color: Colors.black.withOpacity(0.5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          widget.date,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          widget.location,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            "About Event",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            widget.detail,
                            style: TextStyle(
                              color: textColor.withOpacity(0.9),
                              fontSize: 18.0,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Amount : ₹${widget.price}",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: isBookingAllowed ? _startPayment : null,
                                child: Container(
                                  width: 160,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color:
                                        isBookingAllowed
                                            ? textColor
                                            : Colors.grey,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      isBookingAllowed
                                          ? "Book Now"
                                          : "Booking Closed",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
