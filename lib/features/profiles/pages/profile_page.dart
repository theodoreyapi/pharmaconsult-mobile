import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pharmaconsult/core/constants/constants.dart';
import 'package:pharmaconsult/core/widgets/widgets.dart';
import 'package:sizer/sizer.dart';

import '../../../core/themes/themes.dart';
import '../../../core/utils/utils.dart';
import '../../auths/login/login.dart';
import '../profiles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: ClipOval(
                        child: Image.network(
                          SharedPreferencesHelper().getString('photo')!,
                          height: 12.h,
                          width: 12.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/images/pc_logo.png",
                              height: 12.h,
                              width: 12.h,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    Gap(2.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${SharedPreferencesHelper().getString('nom')!}"
                            " ${SharedPreferencesHelper().getString('prenom')!}",
                            style: TextStyle(
                              color: appBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                          ),
                          Text(
                            SharedPreferencesHelper().getString('email')!,
                            style: TextStyle(
                              color: appColor2,
                              fontWeight: FontWeight.w500,
                              fontSize: 15.sp,
                            ),
                          ),
                          Text(
                            SharedPreferencesHelper()
                                .getString('phone')!
                                .replaceFirst('00', '+'),
                            style: TextStyle(
                              color: appColor2,
                              fontWeight: FontWeight.w500,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(2.w),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BasicPage()),
                        );
                      },
                      icon: Image.asset("assets/images/edit.png"),
                    ),
                  ],
                ),
                Divider(),
                Gap(2.h),
                Expanded(
                  child: ListView(
                    children: [
                      Text(
                        "Changer mon mot de passe",
                        style: TextStyle(
                          color: appBlack,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Mot de passe",
                        style: TextStyle(
                          color: appColor2,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "*****************",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14.sp,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PasswordPage(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: appColorNavigation,
                              child: Icon(
                                Icons.navigate_next_outlined,
                                color: appWhite,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap(2.h),
                      Text(
                        "Supprimer mon compte",
                        style: TextStyle(
                          color: appColorRed,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Compte",
                        style: TextStyle(
                          color: appColor2,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Toutes vos données seront supprimées",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14.sp,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet<void>(
                                context: context,
                                backgroundColor: appWhite,
                                builder: (BuildContext context) {
                                  return SizedBox(
                                    height: 300,
                                    child: Padding(
                                      padding: EdgeInsets.all(4.w),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                            "Êtes-vous sûr de vouloir supprimer votre compte ?",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: appBlack,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Gap(2.h),
                                          Container(
                                            padding: EdgeInsets.all(2.w),
                                            decoration: BoxDecoration(
                                              color: appColorRed.withValues(
                                                alpha: .1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(3.w),
                                            ),
                                            child: ListTile(
                                              leading: Icon(
                                                Icons.info_outline,
                                                color: appColorRed,
                                              ),
                                              title: Text(
                                                "Cette action est irrévocable",
                                                style: TextStyle(
                                                  color: appColorRed,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Gap(2.h),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SubmitButton(
                                                  AppConstants.btnNo,
                                                  height: 10.w,
                                                  fontSize: 15.sp,
                                                  couleur: Colors.red,
                                                  textcouleur: appWhite,
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                child: SubmitButton(
                                                  AppConstants.btnYes,
                                                  height: 10.w,
                                                  fontSize: 15.sp,
                                                  textcouleur: appWhite,
                                                  onPressed: () async {
                                                    await SharedPreferencesHelper()
                                                        .clear();
                                                    Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                const LoginPage(),
                                                      ),
                                                      (route) => false,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: appColorNavigation,
                              child: Icon(
                                Icons.navigate_next_outlined,
                                color: appWhite,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
