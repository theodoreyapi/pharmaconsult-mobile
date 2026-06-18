import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaconsult/core/constants/api_urls.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/models/suivisante/traitement_model.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class TraitementPage extends StatefulWidget {
  const TraitementPage({super.key});

  @override
  State<TraitementPage> createState() => _TraitementPageState();
}

class _TraitementPageState extends State<TraitementPage> {
  late Future<TraitementModel> _futureTraitements;

  @override
  void initState() {
    super.initState();
    _futureTraitements = fetchTraitements();
  }

  Future<TraitementModel> fetchTraitements() async {
    final patientId = SharedPreferencesHelper().getString("patient_id") ?? "1";

    final response = await http.get(
      Uri.parse(ApiUrls.getListTraitement(patientId)),
      headers: {'Content-Type': 'application/json'},
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      return TraitementModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Erreur lors de la récupération des traitements');
    }
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return const Color(0xFF27AE60);
    try {
      return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF27AE60);
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'à jour':
      case 'a jour':
        return Icons.check_circle_outline;
      case 'bientôt fini':
      case 'bientot fini':
        return Icons.access_time;
      case 'en retard':
        return Icons.error_outline;
      default:
        return Icons.medication_outlined;
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mes traitements',
              style: TextStyle(
                color: Color(0xFF0F3E32),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Suivi de vos médicaments',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<TraitementModel>(
        future: _futureTraitements,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data?.traitements == null) {
            return const Center(child: Text('Aucun traitement trouvé'));
          }

          final data = snapshot.data!;
          final traitements = data.traitements!;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(left: 10, right: 10, bottom: 100, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: traitements.map((section) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(section.pathologie ?? 'Général'),
                        ... (section.medicaments ?? []).map((med) {
                          return MedicationCard(
                            name: med.name ?? 'Médicament',
                            dosage: med.dosage ?? 0,
                            deliveryDate: med.dispensedAt ?? '—',
                            delayDays: med.delayDays ?? 0,
                            status: med.status ?? '—',
                            statusColor: _parseColor(med.statusColor),
                            progress: med.progress ?? 0.0,
                            icon: _getStatusIcon(med.status),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
              ),

              // Bouton fixe en bas
              if (data.pharmacyPhone != null)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse('tel:${data.pharmacyPhone}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    icon: const Icon(Icons.phone_outlined, color: Colors.white),
                    label: const Text(
                      'Contacter ma pharmacie',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.w),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF7F8C8D),
        ),
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  final String name;
  final int dosage;
  final String deliveryDate;
  final int delayDays;
  final String status;
  final Color statusColor;
  final double progress;
  final IconData icon;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.deliveryDate,
    required this.delayDays,
    required this.status,
    required this.statusColor,
    required this.progress,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(icon, color: statusColor, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    '$dosage dose par prise',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Row(
                    children: [
                      Text(
                        'Délivré le $deliveryDate',
                        style: const TextStyle(
                          color: Color(0xFFBDC3C7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('|', style: TextStyle(color: Color(0xFFBDC3C7))),
                      const SizedBox(width: 8),
                      Text(
                        'En retard de $delayDays jours',
                        style: const TextStyle(
                          color: Color(0xFFBDC3C7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Barre de progression en bas de la carte
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFF2F2F2),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
