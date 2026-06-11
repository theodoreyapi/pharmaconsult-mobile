import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

class SocialePage extends StatefulWidget {
  SocialePage({super.key});

  @override
  State<SocialePage> createState() => _SocialePageState();
}

class _SocialePageState extends State<SocialePage> {
  final ScreenshotController screenshotController = ScreenshotController();

  String? patientName;
  String? patientPhone;
  String? patientCmu;
  String initials = "—";

  @override
  void initState() {
    super.initState();
    _loadPatientInfo();
  }

  void _loadPatientInfo() {
    final prefs = SharedPreferencesHelper();
    final firstName = prefs.getString("patient_first_name") ?? "";
    final lastName = prefs.getString("patient_last_name") ?? "";
    patientName = "$firstName $lastName".trim();
    if (patientName!.isEmpty) patientName = "Patient";

    patientPhone = prefs.getString("patient_phone_number") ?? "Non renseigné";
    patientCmu = prefs.getString("patient_cmu") ?? "0000000000000";

    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      initials = "";
      if (firstName.isNotEmpty) initials += firstName[0];
      if (lastName.isNotEmpty) initials += lastName[0];
      initials = initials.toUpperCase();
    }
    setState(() {});
  }

  Future<void> _shareQrCode() async {
    final image = await screenshotController.capture();
    if (image != null) {
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/qr_code.png').create();
      await imagePath.writeAsBytes(image);

      final params = ShareParams(
        text: 'Mon QR Code PharmaConsults',
        files: [XFile(imagePath.path)],
      );

      await SharePlus.instance.share(params);
    }
  }

  Future<void> _saveQrCode() async {
    final image = await screenshotController.capture();
    if (image != null) {
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/qr_code.png').create();
      await imagePath.writeAsBytes(image);

      await Gal.putImage(imagePath.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("QR Code enregistré dans la galerie")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appDegradOne,
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Color(0xFF0F3E32)),
          ),
        ),
        title: Text(
          'Mon QR code',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F3E32),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // --- Carte Principale (Capturée pour partage) ---
              Screenshot(
                controller: screenshotController,
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar avec initiales
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFFE2F0D9),
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF27AE60),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Nom et téléphone
                      Text(
                        patientName ?? '—',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F3E32),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        patientPhone ?? '—',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                      SizedBox(height: 30),

                      // QR Code
                      Container(
                        height: 250,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: QrImageView(
                          data: patientCmu ?? "0000",
                          backgroundColor: appWhite,
                          version: QrVersions.auto,
                        ),
                      ),
                      SizedBox(height: 30),

                      // Texte d'explication
                      Text(
                        'Présentez ce code dans une pharmacie affiliée pour '
                        'accéder à votre dossier de suivi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Champ de code identifiant
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8F9F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          patientCmu ?? '—',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black38,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareQrCode,
                      icon: Icon(Icons.share_outlined, size: 18),
                      label: Text('Partager'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saveQrCode,
                      icon: Icon(Icons.download_outlined, size: 18),
                      label: Text('Enregistrer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF27AE60),
                        side: BorderSide(color: Color(0xFF27AE60)),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // --- Footer Disclaimer ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Ce QR code ne contient aucune donnée médicale. Il permet uniquement d\'identifier votre dossier de manière sécurisée.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    height: 1.4,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
