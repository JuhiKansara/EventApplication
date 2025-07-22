import 'package:eventbooking/services/auth.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            // Set image height to 40% of screen height
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: Image.asset(
                "images/signup.jpeg",
                fit: BoxFit.cover, // Optional: makes it fill better
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              "Unlock the Future of",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Event Booking App",
              style: TextStyle(
                color: Color(0xff6351ec),
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 30.0),
            Text(
              "Discover, book, and experience unforgettable moments effortlessly!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45, fontSize: 20.0),
            ),

            SizedBox(height: 30.0),

            GestureDetector(
              onTap: () {
                AuthMethod().signInWithGoogle(context);
              },
              child: Container(
                height: 60,
                margin: EdgeInsets.only(left: 30.0, right: 30.0),
                decoration: BoxDecoration(
                  color: Color(0xff6351ec),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "images/g.png",
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 15.0),
                    Text(
                      "Sign in with Google",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
