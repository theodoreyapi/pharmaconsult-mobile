import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/buttons/buttons.dart';
import '../../../../core/widgets/inputs/inputs.dart';
import '../../forgot/forgot.dart';
import '../../login/login.dart';

class CreatePasswordPage extends StatefulWidget {
  final String? email;
  final String? name;
  final String? lastName;
  final String? phone;

  const CreatePasswordPage({
    super.key,
    this.email,
    this.name,
    this.lastName,
    this.phone,
  });

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // --- LOGIQUE D'INSCRIPTION ---
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérification manuelle supplémentaire pour la sécurité
    if (_passwordController.text != _confirmController.text) {
      SnackbarHelper.showError(
        context,
        "Les mots de passe ne sont pas identiques",
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final formattedPhone = widget.phone!.replaceFirst("+", "00");

      final response = await http.post(
        Uri.parse(ApiUrls.postRegisterUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': formattedPhone,
          'email': widget.email,
          'phoneNumber': formattedPhone,
          'firstName': widget.name,
          'lastName': widget.lastName,
          'typeUser': "PATIENT",
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        await _generateAndRedirectOtp(formattedPhone);
      } else if (response.statusCode == 409) {
        SnackbarHelper.showError(context, "Ce compte existe déjà.");
      } else {
        SnackbarHelper.showError(
          context,
          "Une erreur est survenue lors de l'inscription.",
        );
      }
    } catch (e) {
      SnackbarHelper.showError(context, "Erreur de connexion réseau.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generateAndRedirectOtp(String phone) async {
    try {
      final otpResponse = await http.post(
        Uri.parse(ApiUrls.postGenerateOtpUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usernameOrEmail': phone,
          'otpCode': "",
          'method': "sms",
        }),
      );

      if (otpResponse.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CodeOtpPage(phone: phone)),
        );
        SnackbarHelper.showSuccess(
          context,
          "Compte créé ! Veuillez valider le code reçu.",
        );
      } else {
        // Compte créé mais OTP échoué -> Login
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
        SnackbarHelper.showWarning(
          context,
          "Compte créé, connectez-vous pour valider votre accès.",
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 7.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(4.h),
                        _buildTitle(),
                        Gap(5.h),

                        _buildPasswordField(
                          label: "Nouveau mot de passe",
                          controller: _passwordController,
                        ),
                        Gap(2.h),
                        _buildPasswordField(
                          label: "Confirmer le mot de passe",
                          controller: _confirmController,
                          isConfirmation: true,
                        ),

                        Gap(8.h),
                        SizedBox(
                          width: double.infinity,
                          child: SubmitButton(
                            "Sécuriser mon compte",
                            onPressed: _handleRegister,
                          ),
                        ),
                        Gap(4.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  // --- COMPOSANTS UI ---

  Widget _buildHeader() {
    return Container(
      height: 25.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: appColor2,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25.w)),
      ),
      child: SafeArea(
        child: Center(
          child: Hero(
            tag: 'app_logo',
            child: Image.asset("assets/images/logo_white.png", width: 55.w),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sécurisez votre compte",
          style: TextStyle(
            color: appColor2,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        Gap(1.h),
        Text(
          "Choisissez un mot de passe robuste pour protéger vos données de santé.",
          style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    bool isConfirmation = false,
  }) {
    return InputPassword(
      hintText: label,
      controller: controller,
      validatorMessage:
          isConfirmation
              ? "Veuillez confirmer le mot de passe"
              : "Le mot de passe est obligatoire",
      // Optionnel : ajouter une règle de longueur ici
      suffixIcon: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          color: appColor2,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black45,
      child: const Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
