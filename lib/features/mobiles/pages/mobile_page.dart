import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaconsult/core/constants/constants.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/features/menus/menus.dart';
import 'package:pharmaconsult/nav.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class MobilePage extends StatefulWidget {
  final String? montant;

  const MobilePage({super.key, this.montant});

  @override
  State<MobilePage> createState() => _MobilePageState();
}

// ✅ with WidgetsBindingObserver obligatoire
class _MobilePageState extends State<MobilePage> with WidgetsBindingObserver {
  bool _waitingForReturn = false;
  StreamSubscription<Uri>? _linkSubscription; // 👈
  final _appLinks = AppLinks(); // 👈

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks(); // 👈
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel(); // 👈
    super.dispose();
  }

  void _initDeepLinks() {
    // Écouter les deep links entrants
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (!mounted) return;

      // pharmaconsults://payment/success
      if (uri.scheme == 'pharmaconsults' &&
          uri.host == 'payment' &&
          uri.pathSegments.contains('success')) {
        _waitingForReturn = false;
        Navigator.of(context).popUntil((route) => route.isFirst);
        SnackbarHelper.showSuccess(context, "Rechargement approuvé");
      }

      // pharmaconsults://payment/error (optionnel)
      if (uri.scheme == 'pharmaconsults' &&
          uri.host == 'payment' &&
          uri.pathSegments.contains('error')) {
        _waitingForReturn = false;

        SnackbarHelper.showError(context, "Rechargement échoué");
      }
    });
  }

  // ✅ @override obligatoire
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _waitingForReturn) {
      _waitingForReturn = false;

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      appBar: AppBar(
        title: Text(
          "Moyen de rechargement",
          style: TextStyle(
            color: appBlack,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        backgroundColor: appWhite,
        elevation: 0,
        leading: BackButton(color: appBlack),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Text(
                "Choisissez votre opérateur mobile",
                style: TextStyle(fontSize: 15.sp, color: Colors.grey[600]),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                children: [
                  _buildOperatorTile(
                    logo: "wave.png",
                    name: "Wave",
                    fee: "0% - Frais Opérateur",
                    onTap: () => payWithWave(),
                  ),
                  _buildOperatorTile(
                    logo: "orange.png",
                    name: "Orange Money",
                    fee: "0% - Frais Opérateur",
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => PlaceholderScreen(title: "Orange Money"),
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> payWithWave() async {
    try {
      final response = await http.post(
        Uri.parse(ApiUrls.postIntialUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': SharedPreferencesHelper().getString('phone'),
          'deposit_amount': widget.montant,
          'payment_method': 'wave',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final url = data['rechargement_url'];

        // ✅ Flag activé AVANT launchUrl
        setState(() => _waitingForReturn = true);

        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Paiement échoué')),
        );
      }
    } catch (e) {
      setState(() => _waitingForReturn = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erreur réseau')));
    }
  }
}

// Widget réutilisable pour les opérateurs
Widget _buildOperatorTile({
  required String logo,
  required String name,
  required String fee,
  required VoidCallback onTap,
}) {
  return Container(
    margin: EdgeInsets.only(bottom: 1.5.h),
    decoration: BoxDecoration(
      color: appWhite,
      borderRadius: BorderRadius.circular(3.w),
      border: Border.all(color: appColor.withValues(alpha: 0.3)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: ClipOval(
          child: Image.asset("assets/images/$logo", fit: BoxFit.cover),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(
          color: appBlack,
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        fee,
        style: TextStyle(
          color: appColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: appColor,
        size: 18,
      ),
    ),
  );
}
