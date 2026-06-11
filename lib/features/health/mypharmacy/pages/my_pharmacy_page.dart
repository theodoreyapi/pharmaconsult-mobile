import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaconsult/core/constants/api_urls.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/models/suivisante/pharmacy_model.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class MyPharmacyPage extends StatefulWidget {
  const MyPharmacyPage({super.key});

  @override
  State<MyPharmacyPage> createState() => _MyPharmacyPageState();
}

class _MyPharmacyPageState extends State<MyPharmacyPage> {
  late Future<PharmacyModel> _futurePharmacy;

  @override
  void initState() {
    super.initState();
    _futurePharmacy = fetchPharmacy();
  }

  Future<PharmacyModel> fetchPharmacy() async {
    final patientId = SharedPreferencesHelper().getString("patient_id") ?? "1";

    final response = await http.get(
      Uri.parse(ApiUrls.getPharmacyByPatient(patientId)),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return PharmacyModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Erreur lors de la récupération de la pharmacie');
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appDegradOne,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          'Ma pharmacie',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F3E32),
          ),
        ),
      ),
      body: FutureBuilder<PharmacyModel>(
        future: _futurePharmacy,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Aucune donnée disponible'));
          }

          final pharmacy = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Carte d'en-tête ---
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFFF1F9F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.apartment_rounded,
                            color: Color(0xFF27AE60),
                            size: 30,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pharmacy.name ?? 'Pharmacie',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F3E32),
                                ),
                              ),
                              Text(
                                pharmacy.ownerName ?? '',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  ...List.generate(
                                    5,
                                    (index) => Icon(
                                      index < (pharmacy.rating ?? 0) ? Icons.star : Icons.star_border,
                                      color: Color(0xFFF1C40F),
                                      size: 16,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.verified_user_outlined,
                                    color: Colors.grey,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    pharmacy.badge ?? 'Pharmacie principale',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
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
                  SizedBox(height: 32),

                  // --- Section Contacter ---
                  Text(
                    'Contacter',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildContactTile(
                        icon: Icons.phone_in_talk_outlined,
                        label: 'Appeler',
                        color: Color(0xFF27AE60),
                        bgColor: Color(0xFFE8F5E9),
                        onTap: () => _launchUrl('tel:${pharmacy.phone}'),
                      ),
                      SizedBox(width: 12),
                      _buildContactTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'WhatsApp',
                        color: Color(0xFF16A085),
                        bgColor: Color(0xFFE0F2F1),
                        onTap: () => _launchUrl('https://wa.me/${pharmacy.whatsapp}'),
                      ),
                      SizedBox(width: 12),
                      _buildContactTile(
                        icon: Icons.near_me_outlined,
                        label: 'Itinéraire',
                        color: Color(0xFF3498DB),
                        bgColor: Color(0xFFE3F2FD),
                        onTap: () => _launchUrl(pharmacy.gpsCoordinates ?? ''),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // --- Section Informations ---
                  Text(
                    'Informations',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          title: pharmacy.address ?? '—',
                          subtitle: pharmacy.address ?? '',
                        ),
                        Divider(height: 1, indent: 60),
                        _buildInfoRow(
                          icon: Icons.phone_outlined,
                          title: pharmacy.phone ?? '—',
                          subtitle: 'Téléphone fixe',
                        ),
                        Divider(height: 1, indent: 60),
                        _buildInfoRow(
                          icon: Icons.access_time_outlined,
                          title: 'Ouvert de ${pharmacy.openingHours} à ${pharmacy.closingHours}',
                          subtitle: 'Horaires d\'ouverture',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // --- Pied de page Map ---
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            appTextIndicator.withValues(alpha: .2),
                            appColorReserve.withValues(alpha: .1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(2.w),
                        border: Border.all(width: .5, color: Colors.grey.shade300)
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Color(0xFF27AE60),
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            pharmacy.address ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _launchUrl(pharmacy.gpsCoordinates ?? ''),
                            child: Text(
                              'Ouvrir dans Google Maps',
                              style: TextStyle(
                                color: Color(0xFF27AE60),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget pour les boutons d'action (Appeler, WhatsApp, Itinéraire)
  Widget _buildContactTile({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour les lignes d'information
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[400], size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F3E32),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
