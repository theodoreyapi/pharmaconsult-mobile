import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaconsult/core/constants/api_urls.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/models/suivisante/planning_model.dart';
import 'package:pharmaconsult/models/suivisante/rendez_vous_model.dart';
import 'package:sizer/sizer.dart';

class RendezVousPage extends StatefulWidget {
  const RendezVousPage({super.key});

  @override
  State<RendezVousPage> createState() => _RendezVousPageState();
}

class _RendezVousPageState extends State<RendezVousPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<Map<String, dynamic>> _futureData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _futureData = fetchData();
  }

  Future<Map<String, dynamic>> fetchData() async {
    final patientId = SharedPreferencesHelper().getString("patient_id") ?? "";

    final results = await Future.wait([
      http.get(
        Uri.parse(ApiUrls.getListPlanning(patientId)),
        headers: {'Content-Type': 'application/json'},
      ),
      http.get(
        Uri.parse(ApiUrls.getListRendezVous(patientId)),
        headers: {'Content-Type': 'application/json'},
      ),
    ]);

    List<PlanningModel> plannings = [];
    List<RendezVousModel> rendezVous = [];

    if (results[0].statusCode == 200) {
      final decoded = json.decode(utf8.decode(results[0].bodyBytes));
      if (decoded['success'] == true) {
        plannings = (decoded['data'] as List)
            .map((e) => PlanningModel.fromJson(e))
            .toList();
      }
    }

    if (results[1].statusCode == 200) {
      final decoded = json.decode(utf8.decode(results[1].bodyBytes));
      if (decoded['success'] == true) {
        rendezVous = (decoded['data'] as List)
            .map((e) => RendezVousModel.fromJson(e))
            .toList();
      }
    }

    return {
      'plannings': plannings,
      'rendezVous': rendezVous,
    };
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
        title: const Text(
          'Mon agenda santé',
          style: TextStyle(
            color: Color(0xFF0F3E32),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF27AE60),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF27AE60),
          tabs: const [
            Tab(text: 'Plannings'),
            Tab(text: 'À venir'),
            Tab(text: 'Manqués'),
            Tab(text: 'Effectués'),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final plannings = snapshot.data!['plannings'] as List<PlanningModel>;
          final allRdv = snapshot.data!['rendezVous'] as List<RendezVousModel>;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPlanningList(plannings),
              _buildRdvList(allRdv.where((e) => e.status == 'ATTENTE').toList()),
              _buildRdvList(allRdv.where((e) => e.status == 'MANQUE').toList()),
              _buildRdvList(allRdv.where((e) => e.status == 'EFFECTUE').toList()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRdvList(List<RendezVousModel> rdvs) {
    if (rdvs.isEmpty) {
      return const Center(child: Text('Aucun rendez-vous'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rdvs.length,
      itemBuilder: (context, index) {
        final rdv = rdvs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    rdv.dateLabel ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(rdv.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      rdv.statusLabel ?? '',
                      style: TextStyle(
                        color: _getStatusColor(rdv.status),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    rdv.heure ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  if (rdv.isRecurrent == true) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.refresh, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    const Text(
                      'Récurrent',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (rdv.mesuresTypes ?? [])
                    .map((m) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F9F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            m.label ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF27AE60),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlanningList(List<PlanningModel> plannings) {
    if (plannings.isEmpty) {
      return const Center(child: Text('Aucun planning configuré'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plannings.length,
      itemBuilder: (context, index) {
        final planning = plannings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2F0D9), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.event_note, color: Color(0xFF27AE60)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          planning.frequencyLabel ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Jours : ${planning.jours?.join(', ')} à ${planning.heure}',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Mesures à prendre :',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: (planning.mesuresTypes ?? [])
                    .map((m) => Chip(
                          label: Text(m.label ?? '',
                              style: const TextStyle(fontSize: 11)),
                          backgroundColor: const Color(0xFFF1F9F6),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
              if (planning.notes != null && planning.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    planning.notes!,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'ATTENTE':
        return Colors.orange;
      case 'MANQUE':
        return Colors.red;
      case 'EFFECTUE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
