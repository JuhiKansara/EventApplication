// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';


// void main() {
//   runApp(const MaterialApp(home: ScanAndPayPage()));
// }

// class ScanAndPayPage extends StatefulWidget {
//   const ScanAndPayPage({super.key});

//   @override
//   State<ScanAndPayPage> createState() => _ScanAndPayPageState();
// }

// class _ScanAndPayPageState extends State<ScanAndPayPage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController upiController = TextEditingController();
//   final TextEditingController amountController = TextEditingController();

//   String upiUri = '';

//   void generateUpiQR() {
//     final name = nameController.text.trim();
//     final upi = upiController.text.trim();
//     final amount = amountController.text.trim();

//     if (name.isEmpty || upi.isEmpty || amount.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Fill all fields')));
//       return;
//     }

//     setState(() {
//       upiUri =
//           'upi://pay?pa=$upi&pn=$name&am=$amount&cu=INR'; // UPI payment link
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Flutter Web: Scan & Pay")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: 'Payee Name'),
//             ),
//             TextField(
//               controller: upiController,
//               decoration: const InputDecoration(labelText: 'Payee UPI ID'),
//             ),
//             TextField(
//               controller: amountController,
//               decoration: const InputDecoration(labelText: 'Amount'),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: generateUpiQR,
//               child: const Text("Generate QR"),
//             ),
//             const SizedBox(height: 20),
//             if (upiUri.isNotEmpty) ...[
//               const Text(
//                 "Scan with GPay / PhonePe",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(height: 10),
//               QrImageView(data: upiUri, version: QrVersions.auto, size: 220.0),
//               const SizedBox(height: 10),
//               Text(upiUri, textAlign: TextAlign.center),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }







import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:device_apps/device_apps.dart';

//final String upiUri = "upi://pay?pa=your@upi&pn=YourName&am=1.00&cu=INR";
// final String gPayPackage = "com.google.android.apps.nbu.paisa.user";
// final String gPayPlayStoreUrl =
//     "https://play.google.com/store/apps/details?id=$gPayPackage";

class Payment extends StatefulWidget {
  final String name;
  final String upiId;
  final String amount;

  const Payment({
    super.key,
    required this.name,
    required this.upiId,
    required this.amount,
  });

  @override
  State<Payment> createState() => _ScanAndPayPageState();
}

class _ScanAndPayPageState extends State<Payment> {
  late String upiUri;

  @override
  void initState() {
    super.initState();
    generateUpiQR();

    // Show popup after a small delay to allow screen to build
    Future.delayed(Duration(milliseconds: 500), () {
      showPaymentDialog();
    });
  }

  void generateUpiQR() {
    upiUri =
        'upi://pay?pa=${widget.upiId}&pn=${widget.name}&am=${widget.amount}&cu=INR';
  }

  void showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Make Payment"),
        content: const Text("Do you want to pay using Google Pay or other UPI app?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close dialog
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              launchUpiUri();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  // void showPaymentDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text("Make Payment"),
  //           content: const Text(
  //             "Do you want to pay using Google Pay or other UPI app?",
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(),
  //               child: const Text("No"),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop();
  //                 launchGPayOrRedirect(context);
  //               },
  //               child: const Text("Yes"),
  //             ),
  //           ],
  //         ),
  //   );
  // }

  void launchUpiUri() async {
    final uri = Uri.parse(upiUri);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No UPI app found to handle the request")),
      );
    }
  }

  // void launchGPayOrRedirect(BuildContext context) async {
  //   bool isInstalled = await DeviceApps.isAppInstalled(gPayPackage);
  //   final uri = Uri.parse(upiUri);

  //   if (isInstalled) {
  //     if (await canLaunchUrl(uri)) {
  //       await launchUrl(uri, mode: LaunchMode.externalApplication);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Unable to launch UPI link.")),
  //       );
  //     }
  //   } else {
  //     final playStoreUri = Uri.parse(gPayPlayStoreUrl);
  //     if (await canLaunchUrl(playStoreUri)) {
  //       await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Cannot open Play Store.")),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      appBar: AppBar(title: const Text("Scan & Pay")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              "Scan the QR to pay",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            QrImageView(data: upiUri, version: QrVersions.auto, size: 250.0),
            const SizedBox(height: 20),
            SelectableText(
              upiUri,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
