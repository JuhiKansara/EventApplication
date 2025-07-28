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
    const backgroundColor = Color(0xFFEAF3F5);
    const primaryColor = Color(0xFF003B49);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top image section
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: Image.asset("images/signup.jpeg", fit: BoxFit.cover),
            ),

            const SizedBox(height: 10.0),

            const Text(
              "Unlock the Future of",
              style: TextStyle(
                color: primaryColor,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Text(
              "Event Booking App",
              style: TextStyle(
                color: primaryColor,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30.0),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Discover, book, and experience unforgettable moments effortlessly!",
                textAlign: TextAlign.center,
                style: TextStyle(color: primaryColor, fontSize: 18.0),
              ),
            ),

            const SizedBox(height: 30.0),

            GestureDetector(
              onTap: () {
                AuthMethod().signInWithGoogle(context);
              },
              child: Container(
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 30.0),
                decoration: BoxDecoration(
                  color: primaryColor,
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
                    const SizedBox(width: 15.0),
                    const Text(
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
