import 'package:flutter/material.dart';
import '../authentication/auth_service.dart'; 

class UserProfilePage extends StatelessWidget {
  final AuthService authService = AuthService(); // Initialize AuthService

  // Method to handle sign-out
  Future<void> _signOut(BuildContext context) async {
    try {
      await authService.signOut(); // Call the sign-out method from AuthService
      Navigator.of(context)
          .popUntil((route) => route.isFirst); // Pop the settings page
    } catch (e) {
      print("Error occurred during sign-out: $e");
      // Handle error gracefully
    }
  }

  final String avatarUrl;
  final String userName;
  final String userEmail;

  UserProfilePage(
      {required this.avatarUrl,
      required this.userName,
      required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            SizedBox(height: 20),
            Text(
              userName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              userEmail,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
          
              },
              child: Text('Edit Profile'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _signOut(context); // Call the sign-out method
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}



