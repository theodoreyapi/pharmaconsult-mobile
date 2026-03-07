import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pharmaconsult/core/themes/app_colors.dart';

import '../../menus/menus.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication _authService = LocalAuthentication();
  bool _isAuthenticating = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _authenticateUser();
  }

  Future<void> _authenticateUser() async {
    setState(() {
      _isAuthenticating = true;
      _message = 'Authentification en cours...';
    });

    try {
      // Vérifier si l’appareil supporte l’auth locale
      bool canCheck = await _authService.canCheckBiometrics;
      bool isSupported = await _authService.isDeviceSupported();

      if (!canCheck || !isSupported) {
        setState(() {
          _message = 'Biométrie non disponible → accès direct';
          _isAuthenticating = false;
        });
       // _navigateToHome();
        return;
      }

      // Vérifier les types de biométrie disponibles
      List<BiometricType> availableBiometrics =
      await _authService.getAvailableBiometrics();

      // Lancer l’authentification
      bool isAuthenticated = await _authService.authenticate(
        localizedReason: "Veuillez vous authentifier pour accéder à l'application",
        options: const AuthenticationOptions(
          biometricOnly: false, // si false → peut aussi utiliser PIN/code
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (isAuthenticated) {
        _navigateToHome();
      } else {
        setState(() {
          _message = 'Authentification échouée';
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = "Erreur d’authentification: $e";
        _isAuthenticating = false;
      });
      // En cas d’erreur, on laisse entrer
     // _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MenuPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [appColor, appColor2],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fingerprint,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 40),
              const Text(
                'Authentification',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              if (_isAuthenticating)
                const CircularProgressIndicator(color: Colors.white)
              else
                ElevatedButton.icon(
                  onPressed: _authenticateUser,
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
