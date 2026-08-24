import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/models/abonnements/abonnement_model.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../menus/menus.dart';
import '../../mobiles/mobiles.dart';

class ConfirmationPage extends StatefulWidget {
  AbonnementModel? abonnement;

  ConfirmationPage({super.key, this.abonnement});

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  @override
  Widget build(BuildContext context) {
    double wallet = SharedPreferencesHelper().getDouble('wallet') ?? 0.0;
    double price = (widget.abonnement!.price ?? 0.0).toDouble();

    bool hasEnoughMoney = wallet >= price;

    return Scaffold(
      backgroundColor: appWhite,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Achat de Pass",
                style: TextStyle(
                  color: appBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              Text(
                hasEnoughMoney
                    ? "Solde Patient Suffisant"
                    : "Solde Patient Insuffisant",
                style: TextStyle(
                  color: appBlack,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gap(1.h),

              // Wallet affichage conditionnel
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color:
                      hasEnoughMoney
                          ? appIndicator
                          : Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.all(Radius.circular(3.w)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: hasEnoughMoney ? appColor : Colors.red,
                    ),
                    SizedBox(
                      height: 24,
                      child: VerticalDivider(
                        color: hasEnoughMoney ? appColor : Colors.red,
                        thickness: 2,
                        width: 10,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: wallet.toStringAsFixed(2),
                            style: TextStyle(
                              color: hasEnoughMoney ? appColor : Colors.red,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: " f",
                            style: TextStyle(
                              color: hasEnoughMoney ? appColor : Colors.red,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Gap(2.h),
              Text(
                widget.abonnement!.libelle!,
                style: TextStyle(
                  color: appBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              Text(
                "${widget.abonnement!.price} f",
                style: TextStyle(color: appBlack, fontSize: 15.sp),
              ),
              Gap(2.h),
              Text(
                "Validité",
                style: TextStyle(
                  color: appBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              Text(
                "${widget.abonnement!.duration} jour(s)",
                style: TextStyle(color: appBlack, fontSize: 15.sp),
              ),
              Gap(2.h),
              Text(
                "Avantages",
                style: TextStyle(
                  color: appBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              Text(
                widget.abonnement!.description!,
                style: TextStyle(color: appBlack, fontSize: 15.sp),
              ),
              Gap(2.h),

              // Message conditionnel
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: appColorContact,
                  borderRadius: BorderRadius.all(Radius.circular(3.w)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: appBlack),
                    Gap(2.w),
                    Expanded(
                      child: Text(
                        hasEnoughMoney
                            ? "Cliquez sur le bouton « Confirmer » pour finaliser votre achat."
                            : "Veuillez recharger votre compte pour continuer.",
                        style: TextStyle(color: appBlack, fontSize: 15.sp),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(2.h),
              // Bouton conditionnel
              SubmitButton(
                hasEnoughMoney ? "Confirmer" : "Recharger mon compte",
                fontSize: 18.sp,
                height: 6.h,
                onPressed: () async {
                  if (hasEnoughMoney) {
                    // Achat
                    confirmPass(context);
                  } else {
                    // Rediriger vers recharge
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MobileAmountPage(),
                      ),
                    );
                  }
                },
              ),
              if (Platform.isIOS) ...[
                Gap(1.h),
                SubmitButton(
                  "S'abonner avec Apple",
                  fontSize: 18.sp,
                  height: 6.h,
                  couleur: Colors.black,
                  onPressed: () async {
                    simulateAppleIAP(context);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> simulateAppleIAP(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.apple, size: 60, color: Colors.black),
              Gap(2.h),
              Text(
                "Apple Pay",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              Gap(1.h),
              const Text(
                "Confirmation du paiement In-App Purchase...",
                textAlign: TextAlign.center,
              ),
              Gap(3.h),
              const CircularProgressIndicator(color: Colors.black),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 3));

    if (context.mounted) {
      Navigator.pop(context); // Ferme la simulation Apple
      confirmPass(context); // Procède à l'activation de l'abonnement
    }
  }

  Future<void> confirmPass(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              const Expanded(child: Text('Abonnement encours...')),
            ],
          ),
        );
      },
    );

    try {
      HttpClient().badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      final response = await http.post(
        Uri.parse(ApiUrls.postSubscribeUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': SharedPreferencesHelper().getString("phone"),
          'forfaitId': widget.abonnement!.id,
          'description': widget.abonnement!.description,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        SnackbarHelper.showSuccess(
          context,
          "Votre abonnement au service ${widget.abonnement!.libelle} "
          "(Validité : ${widget.abonnement!.duration}) "
          "est actif et en cours d’utilisation.",
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MenuPage()),
          (route) => false,
        );
      } else {
        Navigator.pop(context);
        SnackbarHelper.showError(
          context,
          "Impossible d'effectuer un achat. Veuillez réessayer.",
        );
      }
    } catch (e) {
      Navigator.pop(context);
      SnackbarHelper.showError(context, "Erreur de connexion $e");
    }
  }
}
