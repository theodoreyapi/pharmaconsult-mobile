import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/widgets.dart';
import '../../auths/login/login.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

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

  var password = TextEditingController();
  var newPassword = TextEditingController();
  var confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appFondLogin,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_outlined),
        ),
        title: Text(
          "Mot de passe",
          style: TextStyle(
            color: appBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appFondLogin, appWhite, appWhite],
            stops: [0.2, 0.4, .4],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputPassword(
                      hintText: "Ancien mot de passe",
                      controller: password,
                      validatorMessage:
                          "Veuillez saisir votre mot de passe actuel",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        },
                      ),
                    ),
                    Gap(1.h),
                    InputPassword(
                      hintText: "Nouveau mot de passe",
                      controller: confirmPassword,
                      validatorMessage:
                          "Veuillez saisir le nouveau mot de passe",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        },
                      ),
                    ),
                    Gap(1.h),
                    InputPassword(
                      hintText: "Confirmer votre mot de passe",
                      controller: confirmPassword,
                      validatorMessage:
                          "Veuillez confirmer le nouveau mot de passe",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
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
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(3.w),
        child: SubmitButton(
          AppConstants.btnUpdate,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              changePassword(context);
            } else {
              SnackbarHelper.showError(
                context,
                "Tous les champs sont obligatoires.",
              );
            }
          },
        ),
      ),
    );
  }

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
              const Expanded(child: Text('Modification...')),
            ],
          ),
        );
      },
    );

    try {
      HttpClient().badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      final response = await http.post(
        Uri.parse(ApiUrls.postUpdatePasswordProfileUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': SharedPreferencesHelper().getString('phone')!,
          'lastPassword': password.text,
          'newPassword': newPassword.text,
        }),
      );

      if (response.statusCode == 200) {
        await SharedPreferencesHelper().clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
        );
      } else {
        Navigator.pop(context);
        SnackbarHelper.showError(
          context,
          "Impossible de modifier votre mot de passe. Veuillez réessayer.",
        );
      }
    } catch (e) {
      Navigator.pop(context);
      SnackbarHelper.showError(context, "Erreur de connexion");
    }
  }

}
