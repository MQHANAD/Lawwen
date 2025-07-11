import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class AuthService {
  Future<void> signup({
    required String email,
    required String password,
    required String name,            // 👈 Add this
    required BuildContext context,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 👇 Set display name
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload(); // optional but recommended

      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = "This email is already registered.";
          break;
        case 'invalid-email':
          message = "The email address is not valid.";
          break;
        case 'operation-not-allowed':
          message = "Email/password accounts are not enabled.";
          break;
        case 'weak-password':
          message = "Your password is too weak.";
          break;
        default:
          message = "An unknown error occurred. (${e.code})";
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
    } catch (e) {
      debugPrint('Signup failed: $e'); // optional logging
    }
  }


  Future<void> signIn(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      await Future.delayed(const Duration(seconds: 1));
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'invalid-email':
          message = "That email address is invalid.";
          break;
        case 'user-disabled':
          message = "This account has been disabled.";
          break;
        case 'user-not-found':
          message = "No account found with that email.";
          break;
        case 'wrong-password':
          message = "Incorrect password.";
          break;
        case 'too-many-requests':
          message = "Too many attempts. Try again later.";
          break;
        case 'operation-not-allowed':
          message = "Email sign-in is not enabled.";
          break;
        default:
          message = "An unknown error occurred. (${e.code})";
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );
    } catch (e) {}
  }

  Future<void> signout({required BuildContext context}) async {
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => MainScreen()));
  }

  Future<void> passwordless({
    required String email,
    required BuildContext context,
  }) async {
    try {
      final ActionCodeSettings acs = ActionCodeSettings(
        url:
            'https://lawwen.page.link/jdF1', // ✅ your dynamic link domain or Firebase Hosting
        handleCodeInApp: true,
        androidPackageName: 'com.example.swe463project',
        androidInstallApp: true,
        androidMinimumVersion: '21',
        iOSBundleId: 'com.example.swe463project', // ✅ match your iOS bundle
      );

      await FirebaseAuth.instance.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: acs,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('emailForSignIn', email);

      Fluttertoast.showToast(
        msg: "Verification link sent! Check your email.",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error sending verification email: ${e.toString()}",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
