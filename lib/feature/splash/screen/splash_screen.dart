import 'package:flutter/material.dart';
import 'dart:async';
import 'package:orbita_hackathon/core/utils/widgets/background_image.dart';
import 'package:orbita_hackathon/feature/auth/sign_up/presentation/screen/sign_up_screen.dart';
import '../../home/presentation/screen/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showLogo = false;
  bool _showTextImage = false;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      setState(() {
        _showLogo = true;
      });

      Timer(const Duration(seconds: 1), () {
        setState(() {
          _showTextImage = true;
        });

        // ✅ بعد ثانية كمان نروح للهوم بيدج
        Timer(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BackgroundImage(), // الخلفية

          // الصور مع الأنيميشن
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // اللوجو
                AnimatedOpacity(
                  opacity: _showLogo ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  child: Image.asset(
                    "assets/images/Logo.png",
                    width: 100,
                    height: 100,
                  ),
                ),

                const SizedBox(width: 5),

                // الصورة التانية
                AnimatedOpacity(
                  opacity: _showTextImage ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  child: Image.asset(
                    "assets/images/RBITA.png",
                    width: 120,
                    height: 120,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
