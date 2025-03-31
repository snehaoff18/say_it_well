import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:say_it_well/logging/login.dart';
import 'package:say_it_well/logging/forgot_password.dart';
import 'package:say_it_well/splash_screen.dart'; // Import the Splash Screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Say It Well',
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash', // Set Splash Screen as the initial route
      routes: {
        '/splash': (context) => const SplashScreen(), // Splash Screen
        '/sign-in': (context) => const SignInWidget(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}
