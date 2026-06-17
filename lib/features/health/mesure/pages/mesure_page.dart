import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaconsult/core/constants/constants.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/features/health/mesure/mesure.dart';
import 'package:pharmaconsult/models/suivisante/mesure_model.dart';

// ─── Modèle de données ───────────────────────────────────────────────────────

class MesureEntry {
  final String value;
  final String unit;
  final String date;
  final String statusLabel;
  final Color statusColor;
  final Color statusBg;
  final String? subtitle; // ex: "À jeun" pour glycémie

  MesureEntry({
    required this.value,
    required this.unit,
    required this.date,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBg,
    this.subtitle,
  });
}

// ─── Page principale ─────────────────────────────────────────────────────────

class MesurePage extends StatefulWidget {
  MesurePage({super.key});

  @override
  State<MesurePage> createState() => _MesurePageState();
}

class _MesurePageState extends State<MesurePage> with TickerProviderStateMixin {
  late final TabController _tabController;
  late Future<List<MesureModel>> _futureRequest;

  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _futureRequest = fetchRequest();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<MesureModel>> fetchRequest() async {
    final patientId = SharedPreferencesHelper().getString("patient_id") ?? "1";

    final http.Response response = await http.get(
      Uri.parse(
        ApiUrls.getListMesure(patientId),
      ),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(
        utf8.decode(response.bodyBytes),
      );
      if (decoded is List) {
        return decoded
            .map(
              (item) => MesureModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else if (decoded is Map<String, dynamic>) {
        return [MesureModel.fromJson(decoded)];
      } else {
        throw Exception("Format de réponse inattendu");
      }
    } else {
      throw Exception("Une erreur s'est produite");
    }
  }

  Map<String, dynamic> _getStatusColors(String? status) {
    switch (status?.toLowerCase()) {
      case 'normal':
        return {
          'label': 'Normal',
          'color': Color(0xFF27AE60),
          'bg': Color(0xFFE8F5E9),
        };
      case 'attention':
        return {
          'label': 'Attention',
          'color': Color(0xFFF39C12),
          'bg': Color(0xFFFFF2CC),
        };
      case 'élevé':
      case 'eleve':
      case 'éleve':
        return {
          'label': 'Élevé',
          'color': Color(0xFFE74C3C),
          'bg': Color(0xFFFFEAEA),
        };
      default:
        return {
          'label': status ?? '—',
          'color': Colors.grey,
          'bg': Colors.grey.shade100,
        };
    }
  }

  final List<Map<String, dynamic>> _tabs = [
    {'icon': Icons.favorite_border, 'label': 'PA'},
    {'icon': Icons.favorite_border, 'label': 'Pouls'},
    {'icon': Icons.opacity, 'label': 'Glycémie'},
    {'icon': Icons.scale_outlined, 'label': 'Poids'},
    {'icon': Icons.calculate_outlined, 'label': 'IMC'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appDegradOne,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appDegradOne,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mes mesures',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F3E32),
              ),
            ),
            Text(
              'Suivi complet',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<MesureModel>>(
        future: _futureRequest,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aucune donnée disponible"));
          }

          final data = snapshot.data!.first;
          return _buildContent(data);
        },
      ),
    );
  }

  Widget _buildContent(MesureModel data) {
    return SafeArea(
      child: Column(
        children: [
          // Tags pathologies
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  (data.pathologies ?? [])
                      .map((p) => _buildPathologyTagFromModel(p))
                      .toList(),
            ),
          ),
          SizedBox(height: 15),

          // Onglets horizontaux
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tabs.length,
              itemBuilder:
                  (_, i) =>
                      _buildTabButton(i, _tabs[i]['icon'], _tabs[i]['label']),
            ),
          ),
          SizedBox(height: 10),

          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),

                  // Carte valeur principale
                  _buildMainValueCard(data),
                  SizedBox(height: 20),

                  // Graphique
                  _buildEvolutionGraphCard(data),
                  SizedBox(height: 20),

                  // Bouton bilan
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => BilanPage()),
                        );
                      },
                      icon: Icon(
                        Icons.assignment_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Générer mon bilan de santé',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF27AE60),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Historique
                  _buildHistorySection(data),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathologyTagFromModel(Pathologies p) {
    Color bgColor = Color(0xFFFFF2CC);
    Color textColor = Color(0xFFF39C12);
    IconData icon = Icons.local_fire_department_outlined;

    if (p.code == 'HTA') {
      bgColor = Color(0xFFFFEAEA);
      textColor = Color(0xFFE74C3C);
      icon = Icons.favorite_border;
    }

    return _buildPathologyTag(p.nom ?? '', bgColor, textColor, icon);
  }

  // ── Historique selon onglet actif ───────────────────────────────────────

  Widget _buildHistorySection(MesureModel data) {
    List<Widget> rows = [];
    switch (_selectedTab) {
      case 0:
        rows =
            (data.pressionArterielle?.historyPression ?? [])
                .map((e) => _buildPaHistoryRow(e))
                .toList();
        break;
      case 1:
        rows =
            (data.frequenceCardiaque?.historyFrequence ?? [])
                .map((e) {
                  final status = _getStatusColors(e.status);
                  return _buildSimpleHistoryRow(
                    MesureEntry(
                      value: e.value?.toString() ?? '—',
                      unit: e.unit ?? 'bpm',
                      date: e.date ?? '—',
                      statusLabel: status['label'],
                      statusColor: status['color'],
                      statusBg: status['bg'],
                    ),
                    Icons.favorite_border,
                    Color(0xFFFFEAEA),
                    Color(0xFFE74C3C),
                  );
                })
                .toList();
        break;
      case 2:
        rows =
            (data.glycemie?.historyGlycemie ?? [])
                .map((e) {
                  final status = _getStatusColors(e.status);
                  return _buildSimpleHistoryRow(
                    MesureEntry(
                      value: e.value ?? '—',
                      unit: e.unit ?? 'g/L',
                      date: e.date ?? '—',
                      statusLabel: status['label'],
                      statusColor: status['color'],
                      statusBg: status['bg'],
                      subtitle:
                          e.isFasting == 1 ? 'À jeun — ${e.date}' : e.date,
                    ),
                    Icons.opacity,
                    Color(0xFFFFF2CC),
                    Color(0xFFF39C12),
                  );
                })
                .toList();
        break;
      case 3:
        rows =
            (data.poids?.historyPoids ?? [])
                .map((e) {
                  final status = _getStatusColors(e.status);
                  return _buildSimpleHistoryRow(
                    MesureEntry(
                      value: e.value ?? '—',
                      unit: e.unit ?? 'kg',
                      date: e.date ?? '—',
                      statusLabel: status['label'],
                      statusColor: status['color'],
                      statusBg: status['bg'],
                    ),
                    Icons.scale_outlined,
                    Color(0xFFF3E5F5),
                    Color(0xFF9B59B6),
                  );
                })
                .toList();
        break;
      case 4:
        rows =
            (data.imc?.historyImc ?? [])
                .map((e) {
                  final status = _getStatusColors(e.status);
                  return _buildImcHistoryRow(
                    MesureEntry(
                      value: e.value ?? '—',
                      unit: e.unit ?? 'kg/m²',
                      date: e.date ?? '—',
                      statusLabel: status['label'],
                      statusColor: status['color'],
                      statusBg: status['bg'],
                    ),
                  );
                })
                .toList();
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: 12),
        ...rows,
      ],
    );
  }

  // Ligne PA (systolique/diastolique)
  Widget _buildPaHistoryRow(HistoryPression entry) {
    final status = _getStatusColors(entry.status);
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.favorite, color: Color(0xFF27AE60), size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${entry.systolic}/${entry.diastolic} ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      'mmHg',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  entry.date ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: status['bg'],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status['label'],
              style: TextStyle(
                color: status['color'],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Ligne générique (Pouls / Poids)
  Widget _buildSimpleHistoryRow(
    MesureEntry e,
    IconData icon,
    Color iconBg,
    Color iconColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${e.value} ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      e.unit,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  e.subtitle ?? e.date,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: e.statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              e.statusLabel,
              style: TextStyle(
                color: e.statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Ligne IMC (affiche le label entre parenthèses)
  Widget _buildImcHistoryRow(MesureEntry e) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(0xFFE3F2FD),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calculate_outlined,
              color: Color(0xFF3498DB),
              size: 18,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${e.value} ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      e.unit,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (e.subtitle != null) ...[
                      SizedBox(width: 4),
                      Text(
                        '(${e.subtitle})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  e.date,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: e.statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              e.statusLabel,
              style: TextStyle(
                color: e.statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Carte valeur principale ─────────────────────────────────────────────

  Widget _buildMainValueCard(MesureModel data) {
    String value = '—';
    String unit = '';
    String date = '';
    String? statusStr;
    IconData icon = Icons.monitor_heart_outlined;
    String label = '';

    switch (_selectedTab) {
      case 0:
        value = data.pressionArterielle?.currentPression?.value ?? '—';
        unit = data.pressionArterielle?.currentPression?.unit ?? 'mmHg';
        date = data.pressionArterielle?.currentPression?.date ?? '';
        statusStr = data.pressionArterielle?.currentPression?.status;
        icon = Icons.favorite;
        label = 'Pression Artérielle';
        break;
      case 1:
        value =
            data.frequenceCardiaque?.currentFrequence?.value?.toString() ?? '—';
        unit = data.frequenceCardiaque?.currentFrequence?.unit ?? 'bpm';
        date = data.frequenceCardiaque?.currentFrequence?.date ?? '';
        statusStr = data.frequenceCardiaque?.currentFrequence?.status;
        icon = Icons.favorite_border;
        label = 'Fréquence cardiaque';
        break;
      case 2:
        value = data.glycemie?.currentGlycemie?.value ?? '—';
        unit = data.glycemie?.currentGlycemie?.unit ?? 'g/L';
        date = data.glycemie?.currentGlycemie?.date ?? '';
        statusStr = data.glycemie?.currentGlycemie?.status;
        icon = Icons.opacity;
        label = 'Glycémie à jeun';
        break;
      case 3:
        value = data.poids?.currentPoids?.value ?? '—';
        unit = data.poids?.currentPoids?.unit ?? 'kg';
        date = data.poids?.currentPoids?.date ?? '';
        statusStr = data.poids?.currentPoids?.status;
        icon = Icons.scale_outlined;
        label = 'Poids';
        break;
      case 4:
        value = data.imc?.currentImc?.value ?? '—';
        unit = data.imc?.currentImc?.unit ?? 'kg/m²';
        date = data.imc?.currentImc?.date ?? '';
        statusStr = data.imc?.currentImc?.status;
        icon = Icons.calculate_outlined;
        label = 'IMC';
        break;
    }

    final status = _getStatusColors(statusStr);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Color(0xFF27AE60), size: 18),
              ),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
              letterSpacing: -1,
            ),
          ),
          Text(
            unit,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: status['bg'],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status['label'],
              style: TextStyle(
                color: status['color'],
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            date,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Graphique d'évolution ───────────────────────────────────────────────

  Widget _buildEvolutionGraphCard(MesureModel data) {
    List<String> dates = [];
    List<LineChartBarData> lines = [];
    double minY = 0;
    double maxY = 100;
    String title = 'Évolution';

    switch (_selectedTab) {
      case 0:
        final cp = data.pressionArterielle?.chartPression;
        dates = cp?.labels ?? [];
        lines = [
          _line(cp?.systolic ?? [], Color(0xFF27AE60)),
          _line(cp?.diastolic ?? [], Color(0xFF3498DB)),
        ];
        minY = 60;
        maxY = 180;
        title = 'Évolution — Pression Artérielle';
        break;
      case 1:
        final cf = data.frequenceCardiaque?.chartFrequence;
        dates = cf?.labels ?? [];
        lines = [_line(cf?.values ?? [], Color(0xFFE74C3C))];
        minY = 40;
        maxY = 120;
        title = 'Évolution — Fréquence cardiaque';
        break;
      case 2:
        final cg = data.glycemie?.chartGlycemie;
        dates = cg?.labels ?? [];
        final values =
            cg?.values?.map((v) => double.tryParse(v) ?? 0.0).toList() ?? [];
        lines = [_line(values, Color(0xFFF39C12))];
        minY = 0;
        maxY = 3;
        title = 'Évolution — Glycémie à jeun';
        break;
      case 3:
        final cp = data.poids?.chartPoids;
        dates = cp?.labels ?? [];
        final values =
            cp?.values?.map((v) => double.tryParse(v) ?? 0.0).toList() ?? [];
        lines = [_line(values, Color(0xFF9B59B6))];
        minY = 40;
        maxY = 150;
        title = 'Évolution — Poids';
        break;
      case 4:
        final ci = data.imc?.chartImc;
        dates = ci?.labels ?? [];
        final values =
            ci?.values?.map((v) => double.tryParse(v) ?? 0.0).toList() ?? [];
        lines = [_line(values, Color(0xFF3498DB))];
        minY = 15;
        maxY = 45;
        title = 'Évolution — IMC';
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: Colors.grey.shade500, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          SizedBox(height: 25),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine:
                      (_) => FlLine(
                        color: Colors.grey.shade100,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget:
                          (value, _) => Text(
                            value.toStringAsFixed(_selectedTab >= 2 ? 1 : 0),
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                            ),
                          ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i < 0 || i >= dates.length) {
                          return SizedBox();
                        }
                        return Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            dates[i],
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (dates.isEmpty ? 5 : dates.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: lines,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  LineChartBarData _line(List<num> values, Color color) {
    return LineChartBarData(
      spots: List.generate(
        values.length,
        (i) => FlSpot(i.toDouble(), values[i].toDouble()),
      ),
      isCurved: true,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter:
            (_, __, ___, ____) => FlDotCirclePainter(
              radius: 4,
              color: Colors.white,
              strokeWidth: 2,
              strokeColor: color,
            ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.06),
      ),
    );
  }

  Widget _buildPathologyTag(
    String label,
    Color bgColor,
    Color textColor,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF27AE60) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Color(0xFF7F8C8D),
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
