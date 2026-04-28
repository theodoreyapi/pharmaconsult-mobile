import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaconsult/features/auths/forgot/pages/new_password_page.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/themes/themes.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/widgets.dart';

class CodeOtpPasswordPage extends StatefulWidget {
  String? phone;

  CodeOtpPasswordPage({super.key, this.phone});

  @override
  State<CodeOtpPasswordPage> createState() => _CodeOtpPasswordPageState();
}

class _CodeOtpPasswordPageState extends State<CodeOtpPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String? otp;

  var login = TextEditingController();
  var password = TextEditingController();

  final _snackBar = const SnackBar(
    content: Text("Tous les champs sont obligatoires"),
    backgroundColor: Colors.red,
  );

  late final SmsRetriever smsRetriever;
  late final TextEditingController pinController;

  @override
  void initState() {
    super.initState();
    pinController = TextEditingController();
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  bool isEmail(String input) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input);
  }

  Future<void> verifyUser(BuildContext context) async {
    // Afficher une boîte de dialogue de chargement
    showDialog(
      context: context,
      barrierDismissible: false, // Empêcher de fermer en cliquant dehors
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              const Expanded(child: Text('Vérification...')),
            ],
          ),
        );
      },
    );

    try {

      String username = widget.phone ?? "";

      // ✅ Si ce n’est PAS un email → format téléphone
      if (!isEmail(username)) {
        username = username.replaceFirst("+", "00");
      }

      // Autoriser les certificats auto-signés (attention en production)
      HttpClient().badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      final response = await http.post(
        Uri.parse(ApiUrls.postValidateOtpUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'otpCode': otp,
        }),
      );

      Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackbarHelper.showSuccess(context, "Code vérifié avec succès");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => NewPasswordPage(code: otp, phone: widget.phone),
          ),
        );
      } else {
        SnackbarHelper.showError(context, "Code OTP invalide");
      }
    } catch (e) {
      Navigator.pop(context); // Fermer le dialog si une erreur survient
      SnackbarHelper.showError(context, "Erreur de connexion");
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 70,
      height: 70,
      textStyle: TextStyle(fontSize: 25.sp, color: appColor),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: appColor),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: appColor),
      borderRadius: BorderRadius.circular(3.w),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(color: appFondLogin),
    );

    return Scaffold(
      backgroundColor: appWhite,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appColor2, appFondLogin, appWhite],
            stops: const [0.0, 0.25, 0.6],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Gap(3.h),

                  /// Logo
                  Center(
                    child: Image.asset(
                      "assets/images/logo_color.png",
                      width: 45.w,
                    ),
                  ),

                  Gap(4.h),

                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: appWhite,
                        borderRadius: BorderRadius.circular(3.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /// Icon
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: appFondLogin,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.onetwothree_outlined,
                                  color: appColor2,
                                  size: 28.sp,
                                ),
                              ),
                            ),

                            Gap(2.5.h),

                            /// Titre
                            Center(
                              child: Text(
                                "Code OTP",
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.bold,
                                  color: appColor2,
                                ),
                              ),
                            ),

                            Gap(1.h),

                            /// Description
                            Center(
                              child: Text(
                                "Un code OTP à été envoyé au ${widget.phone}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14.sp,
                                  height: 1.5,
                                ),
                              ),
                            ),

                            Gap(4.h),

                            Pinput(
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: focusedPinTheme,
                              submittedPinTheme: submittedPinTheme,
                              controller: pinController,
                              pinputAutovalidateMode:
                                  PinputAutovalidateMode.disabled,
                              hapticFeedbackType: HapticFeedbackType.lightImpact,
                              showCursor: true,
                              onCompleted: (pin) {
                                otp = pin;
                              },
                              onChanged: (value) {},
                            ),
                            Gap(4.h),
                            Text(
                              "Delai de validité 01:00",
                              style: TextStyle(
                                color: appBlack,
                                fontWeight: FontWeight.normal,
                                fontSize: 16.sp,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "Renvoyer",
                                style: TextStyle(
                                  color: appColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: appWhite,
        padding: EdgeInsets.only(left: 3.w, right: 3.w, bottom: 5.h),
        child: SubmitButton(
          AppConstants.btnProceed,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          NewPasswordPage(code: otp, phone: widget.phone),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(_snackBar);
            }
          },
        ),
      ),
    );
  }
}
