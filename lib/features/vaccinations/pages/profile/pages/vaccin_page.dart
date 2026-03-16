import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:sizer/sizer.dart';

import '../../../vaccins.dart';

class VaccinPage extends StatefulWidget {
  const VaccinPage({super.key});

  @override
  State<VaccinPage> createState() => _VaccinPageState();
}

class _VaccinPageState extends State<VaccinPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(2.h),
            Text(
              'Profils Santé',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D5A27),
              ),
            ),
            Gap(2.w),

            // Bannière d'information améliorée
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E7),
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: Color(0xFFFBC02D), width: 5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFFBC02D)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Information importante',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF856404),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Chaque profil santé est facturé. Un abonnement '
                          'mensuel vous permet de suivre la santé vaccinale '
                          'de chaque membre enregistré (humain ou animal).',
                          style: TextStyle(
                            color: Color(0xFF856404),
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Gap(2.h),
            // Bouton Créer avec dégradé
            Container(
              width: double.infinity,
              height: 12.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.w),
                color: appColor,
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  showBarModalBottomSheet(
                    isDismissible: false,
                    enableDrag: false,
                    expand: true,

                    context: context,
                    builder: (context) => NewProfileSheet(),
                  );
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Créer un nouveau profil santé',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            Gap(2.h),
            // Zone Empty State
            Container(
              padding: EdgeInsets.all(5.w),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.person_outlined,
                    size: 80,
                    color: Color(0xFFBDC3C7),
                  ),
                  Gap(1.h),
                  Text(
                    'Aucun profil santé',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Gap(1.h),
                  Text(
                    'Créez votre premier profil pour commencer',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 15.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
