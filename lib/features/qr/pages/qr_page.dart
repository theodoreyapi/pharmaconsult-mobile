import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/utils/utils.dart';
import '../../mobiles/mobiles.dart';

class QrPage extends StatefulWidget {
  const QrPage({super.key});

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> with TickerProviderStateMixin {
  late final TabController _tabController;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  final player = AudioPlayer();

  @override
  void reassemble() {
    super.reassemble();

    if (controller != null) {
      if (Platform.isAndroid) {
        controller!.pauseCamera();
      } else if (Platform.isIOS) {
        controller!.resumeCamera();
      }
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream.listen((scanData) async {
      try {
        await controller.pauseCamera();

        final code = scanData.code?.trim();

        if (code == null || code.isEmpty) {
          throw Exception("Code vide");
        }

        final decryptedValue = CryptoHelper.decryptData(code);

        await player.play(AssetSource('sounds/beep.mp3'));

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MobileAmountPage(
              phoneNumber: decryptedValue,
              type: "trans",
            ),
          ),
        ).then((_) async {
          await controller.resumeCamera();
          setState(() {
            result = null;
          });
        });

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("QR Code invalide ou corrompu"),
              backgroundColor: Colors.red,
            ),
          );
        }

        // Attendre un peu avant de relancer la caméra
        await Future.delayed(const Duration(seconds: 2));
        await controller.resumeCamera();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    controller?.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appFondLogin, appWhite, appWhite],
            stops: [0.1, 0.4, .4],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 40,
                margin: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: appColorDivider,
                  borderRadius: BorderRadius.circular(6.w),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.w),
                      color: appColor2,
                    ),
                    labelColor: appWhite,
                    indicatorSize: TabBarIndicatorSize.tab,
                    unselectedLabelColor: Colors.black,
                    tabs: <Widget>[
                      Tab(text: "Mon QR code"),
                      Tab(text: "Scanner QR code"),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 10.w,
                        right: 10.w,
                        top: 10.w,
                        bottom: 10.w,
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(3.w),
                        margin: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6.w)),
                          image: DecorationImage(
                            image: AssetImage('assets/images/fondqr.png'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              appColorDivider.withValues(alpha: 0.6),
                              BlendMode.srcOver,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: appWhite,
                              borderRadius: BorderRadius.all(
                                Radius.circular(6.w),
                              ),
                            ),
                            child: QrImageView(
                              data: CryptoHelper.encryptData(
                                SharedPreferencesHelper().getString('phone')!,
                              ),
                              backgroundColor: appWhite,
                              version: QrVersions.auto,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: QRView(
                            key: qrKey,
                            onQRViewCreated: _onQRViewCreated,
                            overlay: QrScannerOverlayShape(
                              borderColor: appWhite,
                              overlayColor: Colors.grey.shade500.withValues(
                                alpha: 0.6,
                              ),
                              borderRadius: 2,
                              borderLength: 30,
                              borderWidth: 10,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Text('Mettez la caméra sur le QR code'),
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
    );
  }
}
