import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/buttons/buttons.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  // Fonction pour rediriger vers le Store
  Future<void> _rateApp() async {
    final String url =
        Platform.isAndroid
            ? "https://play.google.com/store/apps/details?id=com.aptiotech.pharmaconsult.yapi.pharmaconsult"
            : "https://apps.apple.com/app/id123456789"; // Remplace par ton ID Apple

    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      _showSnackBar("Impossible d'ouvrir le store");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      appBar: AppBar(
        backgroundColor: appFondLogin,
        elevation: 0,
        title: Text(
          "Noter l’application",
          style: TextStyle(
            color: appBlack,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_outlined, color: appBlack),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appFondLogin, appWhite, appWhite],
            stops: const [0.1, 0.4, 0.4],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                children: [
                  Gap(10.h),
                  Lottie.asset(
                    'assets/json/ratings.json',
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  Gap(4.h),
                  Text(
                    "Votre avis compte !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: appBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    "Merci d’avoir choisi PharmaConsults. Dites-nous ce que "
                    "vous aimez ou comment nous améliorer.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 15.sp,
                      height: 1.5,
                    ),
                  ),
                  Gap(5.h),
                  SubmitButton(
                    height: 55,
                    AppConstants.btnEvaluation,
                    onPressed: _rateApp,
                  ),
                  Gap(1.5.h),
                  SubmitButton(
                    height: 55,
                    AppConstants.btnFeedBack,
                    couleur: appColorBlue,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
