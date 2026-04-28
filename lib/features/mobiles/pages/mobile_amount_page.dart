import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import '../../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/widgets.dart';
import '../../menus/menus.dart';
import '../mobiles.dart';

class MobileAmountPage extends StatefulWidget {
  String? phoneNumber;
  String? type;

  MobileAmountPage({super.key, this.phoneNumber, this.type});

  @override
  State<MobileAmountPage> createState() => _MobileAmountPageState();
}

class _MobileAmountPageState extends State<MobileAmountPage> {
  var amount = TextEditingController();
  String? firstName = "";
  String? lastName = "";
  String? phoneNumbers = "";
  String? role = "";

  String formatPhoneNumber(
    String phoneNumber, {
    String defaultPrefix = "00225",
  }) {
    // 1️⃣ Nettoyer les espaces, tirets, points, etc.
    String cleaned = phoneNumber.replaceAll(RegExp(r'\s+|-|\.|\(|\)'), '');

    // 2️⃣ Supprimer les indicatifs connus (ex: +225, 00225, +33, etc.)
    cleaned = cleaned.replaceAll(RegExp(r'^(\+|00)?(225|33|229|223)'), '');

    // 3️⃣ Supprimer les zéros en trop au début (ex: 00225 → 0)
    //cleaned = cleaned.replaceAll(RegExp(r'^0+'), '');

    // 4️⃣ Ajouter le préfixe par défaut si manquant
    if (!cleaned.startsWith(defaultPrefix) && !cleaned.startsWith("00")) {
      cleaned = defaultPrefix + cleaned;
    }

    return cleaned;
  }

  double wallet = 0.0;
  double remaining = 0.0;

  @override
  void initState() {
    super.initState();
    // Récupère ton solde initial depuis SharedPreferences
    wallet = SharedPreferencesHelper().getDouble("wallet") ?? 0.0;
    remaining = wallet;

    // Écoute la saisie en temps réel
    amount.addListener(_updateRemaining);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUser();
    });
  }

  void _updateRemaining() {
    final entered = double.tryParse(amount.text) ?? 0.0;
    setState(() {
      remaining = wallet - entered;
    });
  }

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  Future<void> _checkUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Expanded(child: Text('Patientez...')),
          ],
        ),
      ),
    );

    try {
      final input = widget.phoneNumber ?? '';
      final username = input.contains('@')
          ? input
          : formatPhoneNumber(input);

      final url = Uri.parse(ApiUrls.getCheckUserUrl(username));

      final res = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (mounted) Navigator.pop(context); // fermer le loader

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));

        setState(() {
          firstName   = data["firstName"];
          lastName    = data["lastName"];
          role        = data["role"];
          phoneNumbers = data["phoneNumber"];
        });

      } else if (res.statusCode == 404) {
        // Utilisateur non trouvé
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucun compte trouvé pour cet identifiant")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur serveur (${res.statusCode})")),
        );
      }

    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de connexion")),
      );
    }
  }

  String _buildTransferText(
    String? role,
    String? phoneNumbers,
    String? firstName,
    String? lastName,
  ) {
    switch (role) {
      case "PHARMACIEN":
        return "Transfert vers \n${firstName ?? ''} ${lastName ?? ''}";
      case "PATIENT":
        return "Transfert vers \n${firstName ?? ''} ${lastName ?? ''}\n${phoneNumbers ?? ''}";
      default:
        return "Transfert vers \n${phoneNumbers ?? ''}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: appWhite, title: Text("Montant")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.type == "trans") ...[
                Text(
                  _buildTransferText(
                    role,
                    widget.phoneNumber,
                    firstName,
                    lastName,
                  ),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: appBlack,
                  ),
                ),
              ],
              InputText(
                hintText: "0",
                keyboardType: TextInputType.number,
                controller: amount,
                suffixIcon: Text("FCFA"),
                validatorMessage: "Veuillez saisir le montant",
              ),
              if (widget.type == "trans") ...[
                Gap(.5.h),
                Text(
                  "Mon solde : ${wallet.toStringAsFixed(0)} F",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Gap(.5.h),
                Text(
                  "Reste après saisie : ${remaining.toStringAsFixed(0)} F",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: remaining < 0 ? Colors.red : Colors.green,
                  ),
                ),
              ],
              Gap(2.h),
              SubmitButton(
                widget.type == "trans"
                    ? AppConstants.btnTrans
                    : "Recharger mon compte",
                fontSize: 18.sp,
                onPressed: () async {
                  if (widget.type == "trans") {
                    transactionUser(context);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MobilePage(montant: amount.text),
                      ),
                    );
                  }
                },
              ),
              Gap(2.h),
              if (widget.type != "trans") ...[
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: appColorOrangeText.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(3.w),
                    border: Border.all(color: appColorOrangeText, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: appColorOrangeText),
                      Gap(2.w),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Information",
                              style: TextStyle(
                                color: appColorOrangeText,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                            Gap(1.w),
                            Text(
                              "Si votre compte n’est pas recharge jusqu’a 24h. "
                              "Veuillez contacter le service Pharmaconsults",
                              style: TextStyle(
                                color: appColorOrangeText,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> transactionUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              const Expanded(child: Text('Transfert encours...')),
            ],
          ),
        );
      },
    );

    try {
      HttpClient().badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      final response = await http.post(
        Uri.parse(ApiUrls.postSendMoneyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderUsername': SharedPreferencesHelper().getString("phone"),
          'receiverUsername':
              widget.phoneNumber!.contains('@')
                  ? widget.phoneNumber!
                  : formatPhoneNumber(widget.phoneNumber!),
          'amount': amount.text,
          'dateTransfered': "",
        }),
      );

      if (response.statusCode == 201) {
        final codeOtp = await http.get(
          Uri.parse(
            "${ApiUrls.getCheckWalletUrl}${SharedPreferencesHelper().getString('phone')}",
          ),
          headers: {'Content-Type': 'application/json'},
        );

        if (codeOtp.statusCode == 200) {
          Navigator.pop(context);

          final data = jsonDecode(codeOtp.body);
          final newAmount = (data["amount"] as num?)?.toDouble() ?? 0.0;

          SnackbarHelper.showSuccess(
            context,
            "Vous avez transféré ${amount.text} FCFA à ${widget.phoneNumber}.\n"
            "Votre nouveau solde : $newAmount",
          );

          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          Navigator.pop(context);
          SnackbarHelper.showWarning(
            context,
            "Transfert effectué avec succès, probleme lors de "
            "l'actualisation de votre compte",
          );

          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else if (response.statusCode == 400) {
        Navigator.pop(context);
        SnackbarHelper.showError(context, response.body);
      } else {
        Navigator.pop(context);
        SnackbarHelper.showError(
          context,
          "Transaction échouée. Vérifiez votre solde ou votre connexion.",
        );
      }
    } catch (e) {
      Navigator.pop(context);
      SnackbarHelper.showError(context, "Erreur de connexion");
    }
  }
}
