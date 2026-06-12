import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pharmaconsult/core/constants/api_urls.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/features/health/mesure/pages/mesure_page.dart';
import 'package:pharmaconsult/features/health/mypharmacy/pages/my_pharmacy_page.dart';
import 'package:pharmaconsult/features/health/sante/pages/campagne_sante_page.dart';
import 'package:pharmaconsult/features/health/sante/pages/conseils_sante_page.dart';
import 'package:pharmaconsult/features/health/sante/pages/notifications_page.dart';
import 'package:pharmaconsult/features/health/sociale/sociale.dart';
import 'package:pharmaconsult/features/health/traitement/pages/traitement_page.dart';
import 'package:pharmaconsult/models/suivisante/mesure_model.dart';
import 'package:sizer/sizer.dart';

class SanteDashboardData {
  final MesureModel mesure;
  final Map<String, dynamic> rappel;

  SanteDashboardData({required this.mesure, required this.rappel});
}

class SantePage extends StatefulWidget {
  SantePage({super.key});

  @override
  State<SantePage> createState() => _SantePageState();
}

class _SantePageState extends State<SantePage> {
  late Future<SanteDashboardData> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = fetchData();
  }

  Future<SanteDashboardData> fetchData() async {
    final patientId = SharedPreferencesHelper().getString("patient_id") ?? "1";

    final results = await Future.wait([
      http.get(
        Uri.parse(ApiUrls.getListMesure(patientId)),
        headers: {'Content-Type': 'application/json'},
      ),
      http.get(
        Uri.parse(ApiUrls.getRappel(patientId)),
        headers: {'Content-Type': 'application/json'},
      ),
    ]);

    MesureModel? mesure;
    Map<String, dynamic> rappel = {};

    if (results[0].statusCode == 200) {
      final decoded = json.decode(utf8.decode(results[0].bodyBytes));
      if (decoded is List && decoded.isNotEmpty) {
        mesure = MesureModel.fromJson(decoded[0]);
      } else if (decoded is Map<String, dynamic>) {
        mesure = MesureModel.fromJson(decoded);
      }
    }

    if (results[1].statusCode == 200) {
      rappel = json.decode(utf8.decode(results[1].bodyBytes));
    }

    if (mesure == null) {
      throw Exception('Erreur lors de la récupération des données');
    }

    return SanteDashboardData(mesure: mesure, rappel: rappel);
  }

  String _formatDateTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appDegradOne,
      body: FutureBuilder<SanteDashboardData>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Aucune donnée disponible'));
          }

          final dashboardData = snapshot.data!;
          final mesureData = dashboardData.mesure;
          final patient = mesureData.patient;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header (Bonjour Patient)
                  _buildHeader(patient?.nom ?? 'Utilisateur'),
                  SizedBox(height: 20),

                  // 2. Section Mon Suivi (Card principale)
                  _buildSuiviCard(dashboardData),
                  SizedBox(height: 24),

                  // 3. Section Accès Rapide
                  Text(
                    'Accès rapide',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                  SizedBox(height: 12),

                  // List des menus d'accès rapide
                  _buildMenuTile(
                    icon: Icons.timeline_rounded,
                    iconColor: Color(0xFF2ECC71),
                    bgColor: Color(0xFFE8F8F0),
                    title: 'Mes mesures',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MesurePage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.link,
                    iconColor: Color(0xFF4285F4),
                    bgColor: Color(0xFFE8F0FE),
                    title: 'Mes traitements',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TraitementPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.menu_book_rounded,
                    iconColor: Color(0xFFF39C12),
                    bgColor: Color(0xFFFEF5E7),
                    title: 'Conseils santé',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConseilsSantePage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.local_hospital_rounded,
                    iconColor: Color(0xFF9B59B6),
                    bgColor: Color(0xFFF4ECF7),
                    title: 'Ma pharmacie',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyPharmacyPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.campaign_rounded,
                    iconColor: const Color(0xFFE67E22),
                    bgColor: const Color(0xFFFDF2E9),
                    title: 'Campagnes de santé',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CampagneSantePage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuTile(
                    icon: Icons.qr_code_2_rounded,
                    iconColor: Color(0xFFE91E63),
                    bgColor: Color(0xFFFCE4EC),
                    title: 'Mon QR code',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SocialePage()),
                      );
                    },
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

  // --- Composants de l'interface ---

  Widget _buildHeader(String name) {
    String initials = '';
    if (name.isNotEmpty) {
      final parts = name.split(' ');
      if (parts.length > 1) {
        initials = (parts[0][0] + parts[1][0]).toUpperCase();
      } else {
        initials = name[0].toUpperCase();
      }
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFE2F0D9),
          child: Text(
            initials,
            style: TextStyle(
              color: Color(0xFF27AE60),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour $name',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F3E32),
                ),
              ),
              Text(
                'Pharmacie Santé Plus vous accompagne',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationsPage(),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF27AE60),
                ),
              ),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '4',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuiviCard(SanteDashboardData data) {
    final rappel = data.rappel;
    final pressure = rappel['latest_pressure'];
    final glycemia = rappel['latest_glycemia'];
    final latestRappel = rappel['latest_rappel'];

    String tensionValue = '—';
    String tensionDate = '';
    if (pressure != null) {
      tensionValue = '${pressure['systolic']}/${pressure['diastolic']}';
      tensionDate = _formatDateTime(pressure['date']);
    }

    String glycemiaValue = '—';
    String glycemiaDate = '';
    if (glycemia != null) {
      glycemiaValue = '${glycemia['value']}';
      glycemiaDate = _formatDateTime(glycemia['date']);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_border_rounded,
                color: Color(0xFF27AE60),
              ),
              SizedBox(width: 8),
              Text(
                'Mon suivi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F3E32),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (data.mesure.pathologies != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  data.mesure.pathologies!.map((p) => _buildTag(p.nom ?? '')).toList(),
            ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildIndicatorBox(
                  title: 'Dernière tension',
                  value: tensionValue,
                  subValue: tensionDate,
                  bgColor: Color(0xFFFEF5E7),
                  textColor: Color(0xFFD35400),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildIndicatorBox(
                  title: 'Dernière glycémie',
                  value: glycemiaValue,
                  subValue: glycemiaDate,
                  bgColor: Color(0xFFE8F8F5),
                  textColor: Color(0xFF16A085),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (latestRappel != null)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFFFFEAA7).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active_outlined,
                    color: Color(0xFFD35400),
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          latestRappel['message'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          latestRappel['sent_at'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD35400),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFF1F9F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF27AE60),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildIndicatorBox({
    required String title,
    required String value,
    required String subValue,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subValue,
            style: TextStyle(
              fontSize: 11,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3E50),
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
