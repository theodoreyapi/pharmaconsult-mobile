import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../../../core/themes/themes.dart';
import '../../../core/utils/utils.dart';
import '../../mobiles/mobiles.dart';

class QrScannePage extends StatefulWidget {
  const QrScannePage({super.key});

  @override
  State<QrScannePage> createState() => _QrScannePageState();
}

class _QrScannePageState extends State<QrScannePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  final player = AudioPlayer();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
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
  void dispose() {
    controller?.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appFondLogin,
      appBar: AppBar(backgroundColor: appFondLogin),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: appWhite,
                overlayColor: Colors.grey.shade500.withValues(alpha: 0.6),
                borderRadius: 2,
                borderLength: 30,
                borderWidth: 10,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(child: Text('Mettez la caméra sur le QR code')),
          ),
        ],
      ),
    );
  }
}
