import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/themes/themes.dart';
import '../../../../core/widgets/widgets.dart';
import '../forgot.dart';

class ForgotPage extends StatefulWidget {
  const ForgotPage({super.key});

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEmail = true;

  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  var login = TextEditingController();
  var password = TextEditingController();

  final _snackBar = const SnackBar(
    content: Text("Tous les champs sont obligatoires"),
    backgroundColor: Colors.red,
  );

  String phoneIndicator = "";
  String initialCountry = 'CI';
  PhoneNumber number = PhoneNumber(isoCode: 'CI');

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

                  /// Carte centrale
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
                          )
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
                                  Icons.lock_reset_rounded,
                                  color: appColor2,
                                  size: 28.sp,
                                ),
                              ),
                            ),

                            Gap(2.5.h),

                            /// Titre
                            Center(
                              child: Text(
                                "Mot de passe oublié",
                                style: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.bold,
                                  color: appColor2,
                                ),
                              ),
                            ),

                            Gap(1.h),

                            /// Description
                            Text(
                              "Entrez votre adresse e-mail ou numéro de téléphone associé à votre compte. "
                                  "Nous vous enverrons un code OTP pour réinitialiser votre mot de passe.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14.sp,
                                height: 1.5,
                              ),
                            ),

                            Gap(4.h),

                            /// Champ email / phone
                            _isEmail
                                ? InputText(
                              hintText: "Adresse e-mail",
                              controller: login,
                              validatorMessage:
                              "Veuillez saisir votre email",
                            )
                                : Container(
                              padding: EdgeInsets.only(left: 4.w),
                              decoration: BoxDecoration(
                                color: appFondLogin,
                                borderRadius: BorderRadius.circular(3.w),
                                border: Border.all(
                                  color: _isFocused
                                      ? appColor
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: InternationalPhoneNumberInput(
                                focusNode: _focusNode,
                                onInputChanged: (PhoneNumber number) {
                                  phoneIndicator = number.phoneNumber!;
                                },
                                errorMessage: "Numéro invalide",
                                hintText: "Numéro de téléphone",
                                selectorConfig: const SelectorConfig(
                                  selectorType:
                                  PhoneInputSelectorType.BOTTOM_SHEET,
                                ),
                                initialValue: number,
                                textFieldController: login,
                                inputBorder: const OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),

                            Gap(1.h),

                            /// Switch email / phone
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isEmail = !_isEmail;
                                    login.clear();
                                  });
                                },
                                child: Text(
                                  _isEmail
                                      ? "Utiliser un numéro"
                                      : "Utiliser une adresse e-mail",
                                  style: TextStyle(
                                    color: appColorBlue,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),

                            Gap(3.h),

                            /// Bouton
                            SizedBox(
                              width: double.infinity,
                              height: 6.h,
                              child: SubmitButton(
                                AppConstants.btnPassword,
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    verifCode(context);
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(_snackBar);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Gap(2.h)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isEmail(String input) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(input);
  }

  Future<void> verifCode(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Veuillez patienter...')),
            ],
          ),
        );
      },
    );

    try {
      String username =
      phoneIndicator.isEmpty ? login.text.trim() : phoneIndicator;

      // ✅ Détection dynamique email / phone
      final String channel = isEmail(username) ? "email" : "whatsapp";

      // ✅ format téléphone uniquement si ce n'est pas email
      if (!isEmail(username)) {
        username = username.replaceFirst("+", "00");
      }

      final response = await http.post(
        Uri.parse(ApiUrls.postGenerateOtpUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'channel': channel, // ✅ conforme backend
        }),
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CodeOtpPasswordPage(phone: username),
          ),
        );

        SnackbarHelper.showSuccess(
          context,
          "Code OTP envoyé via $channel",
        );
      } else {
        SnackbarHelper.showWarning(
          context,
          "Impossible d'envoyer le code OTP. Veuillez réessayer.",
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      SnackbarHelper.showError(
        context,
        "Erreur de connexion",
      );
    }
  }
}
