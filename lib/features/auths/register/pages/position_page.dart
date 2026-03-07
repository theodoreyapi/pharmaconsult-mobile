import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../menus/menus.dart';
import '../register.dart';

class PositionPage extends StatefulWidget {
  const PositionPage({super.key});

  @override
  State<PositionPage> createState() => _PositionPageState();
}

class _PositionPageState extends State<PositionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appFondLogin, appWhite, appWhite],
            stops: [0.2, 0.4, .4],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(child: Image.asset("assets/intro/bg.png")),
                Expanded(child: Container(color: Colors.transparent)),
              ],
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(12.h),
                    Image.asset(
                      "assets/images/position.png",
                      height: 100,
                      width: 80,
                    ),
                    Padding(
                      padding: EdgeInsets.all(5.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, ravi de vous \nrencontrer !",
                            style: TextStyle(
                              color: appColor2,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                            ),
                          ),
                          Gap(2.h),
                          Text(
                            "Définissez votre localisation pour une meilleure "
                            "expérience et trouver des pharmacies autour de vous",
                            style: TextStyle(
                              color: appTextOne,
                              fontWeight: FontWeight.normal,
                              fontSize: 16.sp,
                            ),
                          ),
                          Gap(2.h),
                          Container(
                            width: double.infinity,
                            height: 13.w,
                            decoration: BoxDecoration(
                              color: appColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(3.w),
                              ),
                            ),
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MenuPage(),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.near_me_outlined,
                                color: appWhite,
                              ),
                              label: Text(
                                "Utiliser la position actuelle",
                                style: TextStyle(
                                  color: appWhite,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17.sp,
                                ),
                              ),
                            ),
                          ),
                          Gap(2.h),
                          Text(
                            "Nous n’accédons à votre position que pendant que vous "
                            "utilisez cette incroyable application.",
                            style: TextStyle(
                              color: appTextTwo,
                              fontWeight: FontWeight.normal,
                              fontSize: 14.sp,
                            ),
                          ),
                          Gap(2.h),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChoosePage(),
                                ),
                              );
                            },
                            child: Text(
                              "ou définissez votre position manuellement",
                              style: TextStyle(
                                color: appBlack,
                                fontWeight: FontWeight.normal,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                          Gap(2.h),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MenuPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Le faire plus tard",
                              style: TextStyle(
                                color: appColor2,
                                fontWeight: FontWeight.w500,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
