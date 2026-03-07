import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sizer/sizer.dart';

import '../../../core/themes/app_colors.dart';

class NoticeMedocPage extends StatefulWidget {
  String? notice;
  String? libelle;

  NoticeMedocPage({super.key, this.notice, this.libelle});

  @override
  State<NoticeMedocPage> createState() => _NoticeMedocPageState();
}

class _NoticeMedocPageState extends State<NoticeMedocPage> {
  String cleanHtml(String html) {
    html = html.replaceAll(RegExp(r'<span[^>]*>'), '');
    html = html.replaceAll('</span>', '');
    html = html.replaceAll(RegExp(r'style="[^"]*"'), '');
    return html;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appWhite,
        title: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notice du Medicament",
                style: TextStyle(
                  color: appBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              Text(
                widget.libelle!,
                style: TextStyle(
                  color: appColor2,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child:  Html(
              data: cleanHtml(widget.notice! ?? ''),
            ),
          ),
        ),
      ),
    );
  }
}
