import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sizer/sizer.dart';

// Tes imports existants conservés
import '../../../../core/constants/constants.dart';
import '../../../../core/themes/themes.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../menus/menus.dart';
import '../../forgot/forgot.dart';
import '../../register/pages/pages.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();

  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscure = true;
  bool _isEmail = false;
  bool _isFocused = false;
  bool _isLoading = false; // Pour un feedback plus fluide

  String phoneIndicator = "";
  PhoneNumber number = PhoneNumber(isoCode: 'CI');

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(
      () => setState(() => _isFocused = _focusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // --- LOGIQUE DE SAUVEGARDE ---
  Future<void> _saveUserSession(Map<String, dynamic> data) async {
    final user = data['user'];
    final prefs = SharedPreferencesHelper();

    await Future.wait([
      prefs.saveString('bearerToken', data['token']['token']),
      prefs.saveString('password', passwordController.text),
      prefs.saveString('lastRefreshTime', DateTime.now().toIso8601String()),
      prefs.saveString('identifiant', user['id'].toString()),
      prefs.saveString('username', user['username']),
      prefs.saveString('email', user['email']),
      prefs.saveString('nom', user['firstName']),
      prefs.saveString('prenom', user['lastName']),
      prefs.saveString('phone', user['phoneNumber']),
      prefs.saveString('pays', user['userDetails']['country'] ?? ''),
      prefs.saveDouble('wallet', (user['wallet']['amount'] ?? 0).toDouble()),
      prefs.saveInteger('walletId', user['wallet']['id'] ?? 0),
      prefs.saveString('photo', user['userDetails']['profilePicture']),
      prefs.saveString('about', user['userDetails']['aboutMe'] ?? ''),
      prefs.saveString(
        'subscriptions',
        jsonEncode(user['subscriptions'] ?? []),
      ),
    ]);
  }

  // --- CONNEXION ---
  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Note: Le badCertificateCallback devrait idéalement être géré au niveau global du client HTTP
      final response = await http.post(
        Uri.parse(ApiUrls.postLoginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username':
              _isEmail
                  ? loginController.text
                  : phoneIndicator.replaceFirst("+", "00"),
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data['user']['active'] == "ACTIVE" ||
            data['user']['role'] == "PATIENT") {
          await _saveUserSession(data);
          if (!mounted) return;

          SnackbarHelper.showSuccess(context, "Heureux de vous revoir !");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MenuPage()),
            (route) => false,
          );
        } else {
          SnackbarHelper.showError(context, "Accès restreint à ce compte.");
        }
      } else if (response.statusCode == 423) {
        // Redirection OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => CodeOtpPage(
                  phone:
                      _isEmail
                          ? loginController.text
                          : phoneIndicator.replaceFirst("+", "00"),
                ),
          ),
        );
      } else {
        SnackbarHelper.showError(context, "Identifiants incorrects.");
      }
    } catch (e) {
      SnackbarHelper.showError(
        context,
        "Erreur réseau. Vérifiez votre connexion.",
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      body: Stack(
        // Utilisation de Stack pour le loader personnalisé
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildHeader(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(4.h),
                        _buildWelcomeText(),
                        Gap(4.h),
                        _buildLoginField(),
                        _buildSwitchTypeButton(),
                        Gap(1.h),
                        _buildPasswordField(),
                        _buildForgotPassword(),
                        Gap(6.h),
                        _buildSubmitButton(),
                        _buildRegisterLink(),
                        Gap(4.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  // --- WIDGETS DE COMPOSANTS (Plus propre) ---

  Widget _buildHeader() {
    return Container(
      height: 28.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: appColor2,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.w)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 8.w, top: 2.h),
          child: Hero(
            // Animation fluide si le logo est ailleurs
            tag: 'app_logo',
            child: Image.asset(
              "assets/images/logo_white.png",
              width: 50.w,
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Heureux de vous revoir",
          style: TextStyle(
            color: appColor2,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        Text(
          "Renseignez vos informations pour continuer",
          style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
        ),
      ],
    );
  }

  Widget _buildLoginField() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child:
          _isEmail
              ? InputText(
                hintText: "Adresse e-mail",
                controller: loginController,
                validatorMessage: "Email requis",
              )
              : Container(
                decoration: BoxDecoration(
                  color: appFondLogin,
                  borderRadius: BorderRadius.circular(3.w),
                  border: Border.all(
                    color: _isFocused ? appColor : Colors.transparent,
                  ),
                ),
                child: InternationalPhoneNumberInput(
                  countries: const ['CI'],
                  focusNode: _focusNode,
                  onInputChanged: (n) => phoneIndicator = n.phoneNumber!,
                  hintText: "Numéro WhatsApp",
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  ),
                  textFieldController: loginController,
                  inputBorder: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
    );
  }

  Widget _buildSwitchTypeButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed:
            () => setState(() {
              _isEmail = !_isEmail;
              loginController.clear();
            }),
        child: Text(
          _isEmail ? "Utiliser mon numéro" : "Utiliser mon e-mail",
          style: TextStyle(
            color: appColorBlue,
            fontStyle: FontStyle.italic,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return InputPassword(
      hintText: "Mot de passe",
      controller: passwordController,
      suffixIcon: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          color: appColor2,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
      validatorMessage: '',
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPage()),
            ),
        child: Text(
          "Mot de passe oublié ?",
          style: TextStyle(color: appColor2, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: SubmitButton(AppConstants.btnLogin, onPressed: handleLogin),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: TextButton(
        onPressed:
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            ),
        child: Text.rich(
          TextSpan(
            text: "Nouveau ici ? ",
            style: TextStyle(color: Colors.grey[700]),
            children: [
              TextSpan(
                text: "Créez un compte",
                style: TextStyle(color: appColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
