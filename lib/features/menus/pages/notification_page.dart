import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/themes/app_colors.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appFondLogin,
        elevation: 0,
        title: Text(
          "Notifications",
          style: TextStyle(
            color: appBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appFondLogin, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            children: [],
          ),
        ),
      )),
    );
  }
}
