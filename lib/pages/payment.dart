// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'booking.dart';
//
// class PaymentPage extends StatefulWidget {
//   final String amount;
//   final String eventName;
//   final String eventLocation;
//   final String eventDate;
//   final String imageUrl;
//
//   const PaymentPage({
//     Key? key,
//     required this.amount,
//     required this.eventName,
//     required this.eventLocation,
//     required this.eventDate,
//     required this.imageUrl,
//   }) : super(key: key);
//
//   @override
//   State<PaymentPage> createState() => _PaymentPageState();
// }
//
// class _PaymentPageState extends State<PaymentPage> {
//   late Razorpay _razorpay;
//
//   @override
//   void initState() {
//     super.initState();
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }
//
//   void _startPayment() {
//     int amountInPaise = ((double.tryParse(widget.amount) ?? 0) * 100).toInt();
//
//     var options = {
//       'key': 'rzp_test_R4oeGkFlRzMGqp',
//       'amount': amountInPaise,
//       'name': widget.eventName,
//       'description': 'Booking for ${widget.eventName}',
//       'prefill': {
//         'contact': '9499673327',
//         'email': 'example@gmail.com',
//       },
//       'external': {
//         'wallets': ['paytm'],
//       }
//     };
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       debugPrint('Error: $e');
//     }
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     await FirebaseFirestore.instance.collection('bookings').add({
//       'eventName': widget.eventName,
//       'location': widget.eventLocation,
//       'date': widget.eventDate,
//       'amount': int.tryParse(widget.amount) ?? 0,
//       'timestamp': FieldValue.serverTimestamp(),
//       'userPhone': '9499673327',
//       'imageUrl': widget.imageUrl,
//     });
//
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const BookingPage()),
//     );
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     debugPrint('Payment failed: ${response.message}');
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     debugPrint('External Wallet selected: ${response.walletName}');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Payment')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _startPayment,
//           child: const Text('Pay Now'),
//         ),
//       ),
//     );
//   }
// }