import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/themes/app_colors.dart';

class SuiviPage extends StatefulWidget {
  const SuiviPage({super.key});

  @override
  State<SuiviPage> createState() => _SuiviPageState();
}

class _SuiviPageState extends State<SuiviPage> {
  // Fonction utilitaire pour lancer des URLs (Web, Tel, Mail)
  Future<void> _openUrl(String url, {LaunchMode mode = LaunchMode.externalApplication}) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: mode)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'ouvrir le lien")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      appBar: AppBar(
        backgroundColor: appFondLogin,
        elevation: 0,
        title: Text(
          "Suivez-nous",
          style: TextStyle(color: appBlack, fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_outlined, color: appBlack),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appFondLogin, appWhite, appWhite],
            stops: const [0.1, 0.4, 0.4],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            child: Column(
              children: [
                _buildSocialHeader(),
                Gap(4.h),
                _buildContactSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialHeader() {
    return Column(
      children: [
        Icon(Icons.auto_awesome, color: appColor, size: 40),
        Gap(2.h),
        Text(
          "Restez connectés !",
          textAlign: TextAlign.center,
          style: TextStyle(color: appBlack, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        Gap(1.5.h),
        Text(
          "Suivez l'actualité de PharmaConsults sur les réseaux sociaux et rejoignez notre communauté.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[700], fontSize: 14.sp, height: 1.4),
        ),
        Gap(3.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIcon("facebook.png", "https://web.facebook.com/PharmaConsults"),
            Gap(5.w),
            _socialIcon("linkedin.png", "https://ci.linkedin.com/company/pharmaconsults-expertise"),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(String asset, String url) {
    return InkWell(
      onTap: () => _openUrl(url),
      borderRadius: BorderRadius.circular(3.w),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: appWhite,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Image.asset("assets/icons/$asset", width: 35, height: 35),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: appWhite,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: appFondLogin, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nos coordonnées",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: appColor)),
          const Divider(),
          _contactTile(Icons.phone_in_talk_outlined, "+225 27 22 25 25 47", "tel:+2252722252547"),
          _contactTile(Icons.email_outlined, "infos@pharma-consults.com", "mailto:infos@pharma-consults.com"),
          _contactTile(Icons.location_on_outlined, "537, Rue D29 – Abidjan, CI", "https://maps.app.goo.gl/ocT3CSpohLaj6nX78"),
        ],
      ),
    );
  }

  Widget _contactTile(IconData icon, String text, String? actionUrl) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: appColor2, size: 22),
      title: Text(text, style: TextStyle(fontSize: 14.sp, color: appBlack)),
      onTap: actionUrl != null ? () => _openUrl(actionUrl, mode: LaunchMode.platformDefault) : null,
      trailing: actionUrl != null ? const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey) : null,
    );
  }
}