import 'package:flutter/material.dart';
import 'package:orbita_hackathon/feature/home/presentation/screen/home_page.dart';
import 'feature/auth/login/presentation/screen/login_screen.dart';
import 'feature/splash/screen/splash_screen.dart';
import 'feature/upload/presentation/screen/upload_file.dart';

void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

