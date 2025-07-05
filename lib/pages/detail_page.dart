import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:eventbooking/pages/payment.dart';

class DetailPage extends StatefulWidget {
  String image, name, location, date, detail, price;
  DetailPage({
    required this.date,
    required this.detail,
    required this.image,
    required this.location,
    required this.name,
    required this.price,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  PaletteColor? dominantColor;
  bool isImageDark = true;

  // ✅ Define ImageProvider once
  late ImageProvider eventImage;

  @override
  void initState() {
    super.initState();
    eventImage = NetworkImage(widget.image); // ✅ Use dynamic image
    _updatePalette();
  }

  Future<void> _updatePalette() async {
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
      eventImage,
    );
    setState(() {
      dominantColor =
          generator.dominantColor ?? PaletteColor(Colors.black45, 100);
      isImageDark = dominantColor!.color.computeLuminance() < 0.5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        bottom: true,
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
                            // Positioned(
                            //   top: 16,
                            //   left: 16,
                            //   child: GestureDetector(
                            //     onTap: () {
                            //       Navigator.pop(context);
                            //     },
                            //     child: Container(
                            //       padding: EdgeInsets.all(8),
                            //       decoration: BoxDecoration(
                            //         color: Colors.white,
                            //         borderRadius: BorderRadius.circular(30),
                            //       ),
                            //       child: Icon(
                            //         Icons.arrow_back_ios_new_outlined,
                            //         color: Colors.black,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                color: (dominantColor?.color ?? Colors.black45)
                                    .withOpacity(0.7),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.name!,
                                      style: TextStyle(
                                        color:
                                            isImageDark
                                                ? Colors.white
                                                : Colors.black,
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          color:
                                              isImageDark
                                                  ? Colors.white
                                                  : Colors.black,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          widget.date,
                                          style: TextStyle(
                                            color:
                                                isImageDark
                                                    ? Colors.white70
                                                    : Colors.black54,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        Icon(
                                          Icons.location_on_outlined,
                                          color:
                                              isImageDark
                                                  ? Colors.white
                                                  : Colors.black,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          widget.location,
                                          style: TextStyle(
                                            color:
                                                isImageDark
                                                    ? Colors.white70
                                                    : Colors.black54,
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
                        SizedBox(height: 20.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            "About Event",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            widget.detail,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18.0,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Amount : \₹" + widget.price,
                                style: TextStyle(
                                  color: Color(0xff6351ec),
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => Payment(
                                            name: widget.name,
                                            upiId:
                                                "juhikansara03@oksbi", // ← Replace with actual UPI ID
                                            amount: widget.price,
                                          ),
                                    ),
                                  );
                                },
                                // width: 160,
                                // height: 50,
                                // decoration: BoxDecoration(
                                //   color: Color(0xff6351ec),
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                                // child: GestureDetector(
                                //   onTap: () => {},
                                //   child: Center(
                                //     child: Text(
                                //       "Book Now",
                                //       style: TextStyle(
                                //         color: Colors.white,
                                //         fontSize: 18.0,
                                //         fontWeight: FontWeight.bold,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                child: Container(
                                  width: 160,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Color(0xff6351ec),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Book Now",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                              ),),),
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













// import 'package:flutter/material.dart';
// import 'package:palette_generator/palette_generator.dart';
// import 'package:eventbooking/pages/payment.dart';

// class DetailPage extends StatefulWidget {
//   // const DetailPage({super.key});
//   String image, name, location, date, detail, price;
//   DetailPage({
//     required this.date,
//     required this.detail,
//     required this.image,
//     required this.location,
//     required this.name,
//     required this.price,
//   });

//   @override
//   State<DetailPage> createState() => _DetailPageState();
// }

// class _DetailPageState extends State<DetailPage> {
//   PaletteColor? dominantColor;
//   bool isImageDark = true;

//   // ✅ Define ImageProvider once
//   final ImageProvider eventImage = AssetImage("images/Hackathon.jpg");

//   @override
//   void initState() {
//     super.initState();
//     _updatePalette();
//   }

//   Future<void> _updatePalette() async {
//     final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
//       eventImage,
//     );
//     setState(() {
//       dominantColor =
//           generator.dominantColor ?? PaletteColor(Colors.black45, 100);
//       isImageDark = dominantColor!.color.computeLuminance() < 0.5;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       body: SafeArea(
//         bottom: true,
//         child: LayoutBuilder(
//           builder:
//               (context, constraints) => SingleChildScrollView(
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                   child: IntrinsicHeight(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Stack(
//                           children: [
//                             Image(
//                               image: eventImage,
//                               height: MediaQuery.of(context).size.height / 2.5,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                             ),

//                             // Positioned(
//                             //   top: 16,
//                             //   left: 16,
//                             //   child: GestureDetector(
//                             //     onTap: () {
//                             //       Navigator.pop(context);
//                             //     },
//                             //     child: Container(
//                             //       padding: EdgeInsets.all(8),
//                             //       decoration: BoxDecoration(
//                             //         color: Colors.white,
//                             //         borderRadius: BorderRadius.circular(30),
//                             //       ),
//                             //       child: Icon(
//                             //         Icons.arrow_back_ios_new_outlined,
//                             //         color: Colors.black,
//                             //       ),
//                             //     ),
//                             //   ),
//                             // ),
//                             Positioned(
//                               bottom: 0,
//                               left: 0,
//                               right: 0,
//                               child: Container(
//                                 padding: EdgeInsets.all(16.0),
//                                 color: (dominantColor?.color ?? Colors.black45)
//                                     .withOpacity(0.7),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       widget.name!,
//                                       style: TextStyle(
//                                         color:
//                                             isImageDark
//                                                 ? Colors.white
//                                                 : Colors.black,
//                                         fontSize: 25.0,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     SizedBox(height: 8),
//                                     Row(
//                                       children: [
//                                         Icon(
//                                           Icons.calendar_month,
//                                           color:
//                                               isImageDark
//                                                   ? Colors.white
//                                                   : Colors.black,
//                                           size: 20,
//                                         ),
//                                         SizedBox(width: 8),
//                                         Text(
//                                           widget.date,
//                                           style: TextStyle(
//                                             color:
//                                                 isImageDark
//                                                     ? Colors.white70
//                                                     : Colors.black54,
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                         SizedBox(width: 20),
//                                         Icon(
//                                           Icons.location_on_outlined,
//                                           color:
//                                               isImageDark
//                                                   ? Colors.white
//                                                   : Colors.black,
//                                           size: 20,
//                                         ),
//                                         SizedBox(width: 8),
//                                         Text(
//                                           widget.location,
//                                           style: TextStyle(
//                                             color:
//                                                 isImageDark
//                                                     ? Colors.white70
//                                                     : Colors.black54,
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 20.0),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                           child: Text(
//                             "About Event",
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 25.0,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 16.0),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                           child: Text(
//                             widget.detail,
//                             style: TextStyle(
//                               color: Colors.black87,
//                               fontSize: 18.0,
//                               height: 1.4,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                         Spacer(),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 20.0,
//                             vertical: 16,
//                           ),
//                           child: Row(
//                             children: [
//                               Text(
//                                 "Amount : \₹" + widget.price,
//                                 style: TextStyle(
//                                   color: Color(0xff6351ec),
//                                   fontSize: 20.0,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Spacer(),
//                               GestureDetector(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder:
//                                           (context) => Payment(
//                                             name: widget.name,
//                                             upiId:
//                                                 "juhikansara03@oksbi", // ← Replace with actual UPI ID
//                                             amount: widget.price,
//                                           ),
//                                     ),
//                                   );
//                                 },
//                                 child: Container(
//                                   width: 160,
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                     color: Color(0xff6351ec),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       "Book Now",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 18.0,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//         ),
//       ),
//     );
//   }
// }
