import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:login_rive_animation/firebase_options.dart';
import 'package:login_rive_animation/screens/login_screen.dart';

Future<void> main() async {
  // Required before any plugin call (Firebase) happens ahead of runApp.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen()
    );
  }
}
