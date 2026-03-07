import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/themes/themes.dart';

class QrViewPage extends StatefulWidget {
  const QrViewPage({super.key});

  @override
  State<QrViewPage> createState() => _QrViewPageState();
}

class _QrViewPageState extends State<QrViewPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 10.w,
            right: 10.w,
            top: 20.w,
            bottom: 20.w,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(3.w),
            margin: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: appFondLogin,
              borderRadius: BorderRadius.all(Radius.circular(3.w)),
            ),
            child: Center(
              child: QrImageView(
                data: 'This QR code has an embedded image as well',
                backgroundColor: appWhite,
                version: QrVersions.auto,
                size: 250,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
