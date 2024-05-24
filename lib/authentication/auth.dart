import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/model/login_or_register.dart';
import '../screens/chat_screen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Check if authentication state is loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show loading indicator
          }

          // user is logged in
          if (snapshot.hasData) {
            if (snapshot.data!.emailVerified) {
              // If email is verified, navigate to ChatScreen
              return ChatScreen();
            } else {
              // If email is not verified, navigate to VerificationScreen
              return LoginOrRegisterPage();
            }
          }

          // user is NOT logged in
          else {
            return PopScope(
              // Prevent popping out of LoginOrRegisterPage
              canPop: false,
              child: LoginOrRegisterPage(),
            );
          }
        },
      ),
    );
  }
}
