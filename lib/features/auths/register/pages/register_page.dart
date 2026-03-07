import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizer/sizer.dart';

// Tes imports
import '../../../../core/constants/constants.dart';
import '../../../../core/themes/themes.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../menus/menus.dart';
import '../../login/login.dart';
import '../register.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _phoneFocus = FocusNode();

  // Contrôleurs
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  bool _isPhoneFocused = false;
  bool _hasAcceptedTerms = false; // Important pour la validation
  String phoneIndicator = "";
  PhoneNumber number = PhoneNumber(isoCode: 'CI');

  @override
  void initState() {
    super.initState();
    _phoneFocus.addListener(
      () => setState(() => _isPhoneFocused = _phoneFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  // --- LOGIQUE DE VALIDATION ---
  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (!_hasAcceptedTerms) {
        SnackbarHelper.showWarning(
          context,
          "Veuillez accepter les conditions d'utilisation",
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => CreatePasswordPage(
                email: emailController.text,
                name: nameController.text,
                lastName: lastNameController.text,
                phone: phoneIndicator,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(3.h),
                    _buildTitle(),
                    Gap(3.h),

                    // Champs de saisie
                    InputText(
                      hintText: "Nom",
                      controller: nameController,
                      validatorMessage: "Le nom est requis",
                    ),
                    Gap(1.5.h),
                    InputText(
                      hintText: "Prénoms",
                      controller: lastNameController,
                      validatorMessage: "Le prénom est requis",
                    ),
                    Gap(1.5.h),
                    InputText(
                      hintText: "Adresse e-mail",
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                    ),
                    Gap(1.5.h),
                    _buildPhoneInput(),

                    Gap(3.h),
                    _buildTermsAndConditions(),
                    Gap(3.h),

                    SubmitButton(
                      AppConstants.btnSetup,
                      onPressed: _handleRegister,
                    ),

                    _buildLoginLink(),
                    Gap(4.h),
                  ],
                ),
              ),
            ),
          ),
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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.w),
          bottomRight: Radius.circular(10.w),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Image.asset("assets/images/logo_white.png", width: 60.w),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Première Connexion",
          style: TextStyle(
            color: appColor2,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        Text(
          "Rejoignez notre communauté en quelques clics",
          style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      padding: EdgeInsets.only(left: 4.w),
      decoration: BoxDecoration(
        color: appFondLogin,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isPhoneFocused ? appColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InternationalPhoneNumberInput(
              countries: const ['CI'],
              focusNode: _phoneFocus,
              onInputChanged: (n) => phoneIndicator = n.phoneNumber!,
              hintText: "Numéro WhatsApp",
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              ),
              textFieldController: phoneController,
              inputBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
          ),
          Image.asset("assets/images/whatsapp.png", width: 24),
          Gap(3.w),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Row(
      children: [
        Checkbox(
          value: _hasAcceptedTerms,
          activeColor: appColor,
          onChanged: (val) => setState(() => _hasAcceptedTerms = val!),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14.sp,
                color: appBlack,
                fontFamily: 'Poppins',
              ),
              children: [
                const TextSpan(text: "J'accepte les "),
                _linkSpan(
                  "Conditions d'utilisation",
                  () => _showModal(const ConditionPage()),
                ),
                const TextSpan(text: " et la "),
                _linkSpan(
                  "Politique de confidentialité",
                  () => _showModal(const PolicyPage()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TextSpan _linkSpan(String text, VoidCallback onTap) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: appColor,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }

  void _showModal(Widget page) {
    showBarModalBottomSheet(
      context: context,
      expand: true,
      backgroundColor: appWhite,
      builder: (context) => page,
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed:
            () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
        child: Text.rich(
          TextSpan(
            text: "Déjà inscrit ? ",
            style: TextStyle(color: Colors.grey[700]),
            children: [
              TextSpan(
                text: "Connectez-vous",
                style: TextStyle(color: appColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
