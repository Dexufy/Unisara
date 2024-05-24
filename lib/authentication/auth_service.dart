import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookLogin _facebookLogin = FacebookLogin();

  // Method to handle Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Check if user canceled the sign-in process
      if (googleUser == null) {
        return null;
      }

      // Obtain the authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Use the obtained authentication details to sign in with Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase using the obtained credential
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      // Return the user from Firebase authentication
      return userCredential.user;
    } catch (error) {
      print("Error occurred during Google Sign-In: $error");
      // Handle error gracefully
      return null;
    }
  }

  // Method to handle Facebook Sign-In
  Future<User?> signInWithFacebook() async {
    try {
      // Trigger Facebook Sign-In process
      final FacebookLoginResult result = await _facebookLogin.logIn(permissions: [
        FacebookPermission.publicProfile,
        FacebookPermission.email,
      ]);

      // Check if Facebook sign-in was successful
      if (result.status == FacebookLoginStatus.success) {
        // Obtain the access token from the result
        final FacebookAccessToken accessToken = result.accessToken!;

        // Use the obtained access token to sign in with Firebase
        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.token);

        // Sign in with Firebase using the obtained credential
        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

        // Return the user from Firebase authentication
        return userCredential.user;
      } else {
        // Handle Facebook sign-in failure
        print('Facebook sign-in failed: ${result.status}');
        return null;
      }
    } catch (error) {
      // Handle other errors that may occur during Facebook sign-in
      print("Error occurred during Facebook Sign-In: $error");
      return null;
    }
  }

  // Method to sign out
  Future<void> signOut() async {
    // Sign out from Firebase
    await _firebaseAuth.signOut();
    
    // Sign out from Google
    await _googleSignIn.signOut();

    // Sign out from Facebook
    await _facebookLogin.logOut();
  }
}
