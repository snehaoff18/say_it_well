import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

FirebaseAuth auth = FirebaseAuth.instance;

// Sign In with Email and Password
Future<User?> signInWithEmail(
  BuildContext context,
  String email,
  String password,
) async {
  try {
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(e.toString())));
    return null;
  }
}

// Sign Out
Future<void> signOut(BuildContext context) async {
  await auth.signOut();
}

// Check if User is Signed In
User? getCurrentUser() {
  return auth.currentUser;
}
