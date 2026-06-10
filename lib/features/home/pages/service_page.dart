import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pharmaconsult/features/health/health.dart';
import 'package:sizer/sizer.dart';

import '../../../core/themes/themes.dart';
import '../../assurances/assures.dart';
import '../../gardes/gardes.dart';
import '../../prices/prices.dart';
import '../../requests/search.dart';
import '../../vaccinations/vaccins.dart';
import '../home.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final List<Map<String, dynamic>> _services = [
    {
      'title': "Pharmacie \nde garde",
      'assetPath': "assets/svg/pharmacy.svg",
      'argument': "Pharmacie de garde",
      'page': PharmacyPage(),
    },
    {
      'title': "Fiche et prix\nde médicament",
      'assetPath': "assets/svg/medoc.svg",
      'argument': "Fiche et prix",
      'page': PrixPage(),
      'isDisabled': false,
    },
    {
      'title': "Assurances",
      'assetPath': "assets/svg/assure.svg",
      'argument': "Assurances",
      'page': AssurancePage(),
      'isDisabled': false,
    },
    {
      'title': "Recherche de\nmédicament",
      'assetPath': "assets/svg/search.svg",
      'argument': "Recherche medicament",
      'page': DemandePage(),
      'isDisabled': false,
    },
    {
      'title': "Vaccination",
      'assetPath': "assets/svg/vaccin.svg",
      'argument': "Vaccination",
      'page': VaccinPage(),
      'isDisabled': true,
    },
    {
      'title': "Suivi santé",
      'assetPath': "assets/svg/vaccin.svg",
      'argument': "Suivi sante",
      'page': SantePage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appFondLogin,
        elevation: 0,
        title: Text(
          "Services",
          style: TextStyle(
            color: appBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appFondLogin, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: GridView.builder(
              itemCount: _services.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 3.w,
                crossAxisSpacing: 3.w,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final service = _services[index];
                return _buildServiceItem(
                  context,
                  service['title'],
                  service['assetPath'],
                  service['argument'],
                  service['page'],
                  isDisabled: service['isDisabled'] ?? false,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem(
      BuildContext context,
      String title,
      String assetPath,
      String argument,
      Widget pageToOpen, {
        bool isDisabled = false,
      }) {
    return InkWell(
      onTap: () {
        if (isDisabled) {
          showBarModalBottomSheet(
            isDismissible: false,
            enableDrag: false,
            expand: true,
            topControl: Align(
              alignment: Alignment.centerLeft,
              child: FloatingActionButton.small(
                backgroundColor: Colors.white,
                shape: CircleBorder(),
                onPressed: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, color: appBlack),
              ),
            ),
            context: context,
            builder: (context) => AbonnementPage(title: title, argument: argument),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pageToOpen),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.blue.withValues(alpha: 0.2),
      child: Ink(
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isDisabled
                    ? Colors.grey.withValues(alpha: 0.3)
                    : appColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SvgPicture.asset(
                assetPath,
                colorFilter: isDisabled
                    ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                    : null,
              ),
            ),
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDisabled ? Colors.grey : appBlack,
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
