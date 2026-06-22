import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaconsult/core/constants/api_urls.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/models/suivisante/campagne_model.dart';

import '../../../../core/utils/utils.dart';

class CampagneSantePage extends StatefulWidget {
  const CampagneSantePage({super.key});

  @override
  State<CampagneSantePage> createState() => _CampagneSantePageState();
}

class _CampagneSantePageState extends State<CampagneSantePage> {
  late Future<List<CampagneModel>> _futureCampagnes;

  @override
  void initState() {
    super.initState();
    _futureCampagnes = fetchCampagnes();
  }

  Future<List<CampagneModel>> fetchCampagnes() async {
    int patientPharmacie = SharedPreferencesHelper().getInt("pharmacieId")!;

    final response = await http.get(
      Uri.parse(ApiUrls.getCampagne(patientPharmacie)),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(
        utf8.decode(response.bodyBytes),
      );
      return decoded.map((json) => CampagneModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des campagnes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appDegradOne,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF27AE60)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Campagnes de santé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F3E32),
              ),
            ),
            Text(
              'Informations et actions de prévention',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<CampagneModel>>(
        future: _futureCampagnes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune campagne disponible'));
          }

          final campagnes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: campagnes.length,
            itemBuilder: (context, index) {
              final campagne = campagnes[index];
              return _buildCampagneCard(campagne);
            },
          );
        },
      ),
    );
  }

  Widget _buildCampagneCard(CampagneModel campagne) {
    Color statusColor;
    switch (campagne.status?.toUpperCase()) {
      case 'PLANIFIE':
        statusColor = Colors.blue;
        break;
      case 'EN_COURS':
        statusColor = Colors.green;
        break;
      case 'TERMINE':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header color bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        campagne.status ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      campagne.scheduledAt ?? '',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  campagne.name ?? '',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  campagne.description ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.local_hospital_outlined,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        campagne.pharmacyName ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ),
                    if (campagne.pathologieName != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F9F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          campagne.pathologieName!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF27AE60),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
