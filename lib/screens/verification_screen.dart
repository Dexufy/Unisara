import 'package:flutter/material.dart';

class VerificationScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  VerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 41.3),
                Image.asset(
                  'assets/logoInvert.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 10.0),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst); // Go back to the login screen
                  },
                  child: Text(
                    'Back to Login',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
