import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/constants.dart';
import 'core/utils/utils.dart';
import 'features/splash/spalsh.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SharedPreferencesHelper().init();
  await TokenManager().initTokenFromLocal();

  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    runApp(const MyApp());
  } else {
    runApp(const MyApp());
    // runApp(const MyAppNoConnection());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          supportedLocales: const [Locale('fr', '')],

          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: appColor),
            textTheme: GoogleFonts.fredokaTextTheme(),
            useMaterial3: true,
          ),
          home: SplashPage(),
        );
      },
    );
  }
}

class MyAppNoConnection extends StatefulWidget {
  const MyAppNoConnection({super.key});

  @override
  State<MyAppNoConnection> createState() => _MyAppNoConnectionState();
}

class _MyAppNoConnectionState extends State<MyAppNoConnection> {
  @override
  void initState() {
    super.initState();
    // On attend la première frame pour afficher le dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context, // ← Ici le context est bien sous MaterialApp
        barrierDismissible: false,
        builder:
            (_) => AlertDialog(
              title: const Text('Pas de connexion Internet'),
              content: const Text('Veuillez fermer l\'application.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Ferme le dialogue
                    Navigator.of(context).maybePop(); // Tente de fermer l'app
                  },
                  child: const Text('Fermer'),
                ),
              ],
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appColor),
        useMaterial3: true,
        textTheme: GoogleFonts.fredokaTextTheme(),
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'En attente de la connexion...',
                style: TextStyle(color: Colors.orangeAccent),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text("Quitter", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}