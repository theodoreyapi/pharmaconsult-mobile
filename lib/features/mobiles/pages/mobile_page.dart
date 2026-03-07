import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:gap/gap.dart';

import '../../../../../../core/themes/app_colors.dart';
import '../mobiles.dart';

class MobilePage extends StatefulWidget {
  final String? montant;

  const MobilePage({super.key, this.montant});

  @override
  State<MobilePage> createState() => _MobilePageState();
}

class _MobilePageState extends State<MobilePage> {
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
                    onTap: () => _navigateToAmount(),
                  ),
                  _buildOperatorTile(
                    logo: "orange.png",
                    name: "Orange Money",
                    fee: "0% - Frais Opérateur",
                    onTap: () => _navigateToAmount(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  void _navigateToAmount() {}
}
