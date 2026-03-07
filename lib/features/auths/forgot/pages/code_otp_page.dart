import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/themes/themes.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/widgets.dart';
import '../../login/login.dart';

class CodeOtpPage extends StatefulWidget {
  final String? phone;

  const CodeOtpPage({super.key, this.phone});

  @override
  State<CodeOtpPage> createState() => _CodeOtpPageState();
}

class _CodeOtpPageState extends State<CodeOtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();

  bool _isLoading = false;
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  // --- LOGIQUE DU TIMER ---
  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  // --- VERIFICATION ---
  Future<void> _verifyOtp() async {
    if (_pinController.text.length < 4)
      return; // Adapter selon la longueur de votre OTP

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiUrls.postValidateOtpUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usernameOrEmail': widget.phone!.replaceFirst("+", "00"),
          'otpCode': _pinController.text,
          'method': "sms",
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        SnackbarHelper.showSuccess(context, "Compte vérifié avec succès !");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      } else {
        SnackbarHelper.showError(context, "Code OTP incorrect ou expiré.");
      }
    } catch (e) {
      SnackbarHelper.showError(context, "Erreur de connexion.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Thème personnalisé pour Pinput
    final defaultPinTheme = PinTheme(
      width: 65,
      height: 65,
      textStyle: TextStyle(
        fontSize: 22.sp,
        color: appColor,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: appFondLogin,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: appColor, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: appWhite,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(4.h),
                    _buildHeader(),
                    Gap(6.h),
                    _buildTitle(),
                    Gap(5.h),

                    Center(
                      child: Pinput(
                        length: 4,
                        // Modifiez à 6 si nécessaire
                        controller: _pinController,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        hapticFeedbackType: HapticFeedbackType.mediumImpact,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        onCompleted:
                            (pin) => _verifyOtp(), // Auto-submit à la fin
                      ),
                    ),

                    Gap(5.h),
                    _buildTimerSection(),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // --- COMPOSANTS UI ---

  Widget _buildHeader() {
    return Image.asset("assets/images/logo_color.png", width: 45.w);
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Vérification",
          style: TextStyle(
            color: appColor2,
            fontWeight: FontWeight.bold,
            fontSize: 22.sp,
          ),
        ),
        Gap(1.h),
        Text.rich(
          TextSpan(
            text: "Entrez le code envoyé au ",
            style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
            children: [
              TextSpan(
                text: widget.phone ?? "",
                style: TextStyle(color: appColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerSection() {
    return Center(
      child: Column(
        children: [
          Text(
            _secondsRemaining > 0
                ? "Expire dans 00:${_secondsRemaining.toString().padLeft(2, '0')}"
                : "Le code a expiré",
            style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
          ),
          TextButton(
            onPressed:
                _canResend
                    ? () {
                      // Appeler votre API de renvoi ici
                      _startTimer();
                      _pinController.clear();
                    }
                    : null,
            child: Text(
              "Renvoyer le code",
              style: TextStyle(
                color: _canResend ? appColor : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.all(6.w).copyWith(bottom: 4.h),
      decoration: BoxDecoration(color: appWhite),
      child: SubmitButton(
        AppConstants.btnProceed,
        onPressed: () {
          if (_pinController.text.length >= 4) {
            _verifyOtp();
          }
        },
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black26,
      child: const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
