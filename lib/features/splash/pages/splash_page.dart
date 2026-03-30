import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/themes/themes.dart';
import '../../../core/utils/utils.dart';
import '../../intro/intro.dart';
import 'auth_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double loadingValue = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      _updateLoadingProgress();
    });
  }

  _updateLoadingProgress() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (loadingValue >= 1) {
        _navigateToNextScreen();
        return;
      }
      loadingValue += 0.1;
      setState(() {});
      _updateLoadingProgress();
    });
  }

  Future<void> _navigateToNextScreen() async {
    String? nom = SharedPreferencesHelper().getString('nom');

    if (!mounted) return;

    if (nom != null && nom.isNotEmpty) {
      // Utilisateur déjà connu
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    } else {
      // Nouvel utilisateur
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const IntroPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appColor, appColor2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(child: Image.asset("assets/intro/bg.png")),
                Expanded(child: Container(color: Colors.transparent)),
              ],
            ),
            Center(
              child: Lottie.asset(
                'assets/json/logov.json',
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
