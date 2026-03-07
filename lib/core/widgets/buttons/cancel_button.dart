import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../themes/themes.dart';


class CancelButton extends StatelessWidget {
  final String title;
  final Function() onPressed;
  final double? height;
  final double? width;
  final double? fontSize;
  final Color? couleur;
  final Color? textcouleur;

  const CancelButton(
      this.title, {super.key,
        required this.onPressed,
        this.height,
        this.width,
        this.fontSize,
        this.couleur,
        this.textcouleur,
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 16.w,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: couleur ?? appWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.w),
            side: BorderSide(color: appTextIndicator),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            fontSize: fontSize ?? 16.sp,
            color: textcouleur ?? appWhite,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}