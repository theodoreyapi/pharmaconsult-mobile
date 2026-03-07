import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/features/auths/login/pages/login_page.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/themes/themes.dart';
import '../../../../core/widgets/widgets.dart';

class NewPasswordPage extends StatefulWidget {
  String? code;
  String? phone;

  NewPasswordPage({super.key, this.code, this.phone});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  var password = TextEditingController();
  var newPassword = TextEditingController();

  final _snackBar = const SnackBar(
    content: Text("Tous les champs sont obligatoires"),
    backgroundColor: Colors.red,
  );

  Future<void> changePassword(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              const Expanded(child: Text('Modification du mot de passe...')),
            ],
          ),
        );
      },
    );

    try {
      // Autoriser les certificats auto-signés (attention en production)
      HttpClient().badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      if (password.text != newPassword.text) {
        Navigator.pop(context);
        SnackbarHelper.showError(
          context,
          "Les mots de passe ne correspondent pas",
        );
        return;
      }

      final response = await http.post(
        Uri.parse(ApiUrls.postChangePasswordUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'otp': widget.code,
          'username': widget.phone,
          'newPassword': newPassword.text,
        }),
      );

      Navigator.pop(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackbarHelper.showSuccess(
          context,
          "Votre mot de passe a été réinitialisé avec succès. "
          "Vous pouvez vous reconnecter. ",
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );

        return;
      } else {
        SnackbarHelper.showError(
          context,
          "Impossible de modifier le mot de passe",
        );
      }
    } catch (e) {
      Navigator.pop(context);
      SnackbarHelper.showError(context, "Erreur de connexion");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Icons.password_outlined,
                                  color: appColor2,
                                  size: 28.sp,
                                ),
                              ),
                            ),

                            Gap(2.5.h),

                            /// Titre
                            Center(
                              child: Text(
                                "Nouveau mot de passe",
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
                                "Veuillez saisir un nouveau mot de passe. "
                                "Le nouveau mot de passe ne doit pas être "
                                "le même que le précédent.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14.sp,
                                  height: 1.5,
                                ),
                              ),
                            ),

                            Gap(4.h),

                            InputPassword(
                              hintText: "Nouveau mot de passe",
                              controller: password,
                              validatorMessage:
                                  "Veuillez saisir votre nouveau mot de passe",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscure = !_obscure;
                                  });
                                },
                              ),
                            ),
                            Gap(2.h),
                            InputPassword(
                              hintText: "Confirmer le mot de passe",
                              controller: newPassword,
                              validatorMessage:
                                  "Veuillez confirmer votre nouveau mot de passe",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscure = !_obscure;
                                  });
                                },
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
          AppConstants.btnContinue,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              changePassword(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(_snackBar);
            }
          },
        ),
      ),
    );
  }
}
