import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/features/health/mesure/mesure.dart';

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

class _MesurePageState extends State<MesurePage> {
  int _selectedTab = 0;

  // ── Données mockées par onglet ──────────────────────────────────────────

  // PA : [systolique, diastolique]
  final List<Map<String, dynamic>> _paHistory = [
    {
      'sys': 135,
      'dia': 85,
      'date': '11 mars 2026',
      'label': 'Attention',
      'color': Color(0xFFF39C12),
      'bg': Color(0xFFFFF2CC),
    },
    {
      'sys': 128,
      'dia': 82,
      'date': '4 mars 2026',
      'label': 'Normal',
      'color': Color(0xFF27AE60),
      'bg': Color(0xFFE8F5E9),
    },
    {
      'sys': 142,
      'dia': 92,
      'date': '25 févr. 2026',
      'label': 'Élevé',
      'color': Color(0xFFE74C3C),
      'bg': Color(0xFFFFEAEA),
    },
    {
      'sys': 130,
      'dia': 84,
      'date': '18 févr. 2026',
      'label': 'Attention',
      'color': Color(0xFFF39C12),
      'bg': Color(0xFFFFF2CC),
    },
    {
      'sys': 126,
      'dia': 80,
      'date': '11 févr. 2026',
      'label': 'Normal',
      'color': Color(0xFF27AE60),
      'bg': Color(0xFFE8F5E9),
    },
    {
      'sys': 138,
      'dia': 88,
      'date': '4 févr. 2026',
      'label': 'Attention',
      'color': Color(0xFFF39C12),
      'bg': Color(0xFFFFF2CC),
    },
  ];

  // Pouls bpm
  final List<MesureEntry> _poulsHistory = [
    MesureEntry(
      value: '78',
      unit: 'bpm',
      date: '11 mars 2026',
      statusLabel: 'Normal',
      statusColor: Color(0xFF27AE60),
      statusBg: Color(0xFFE8F5E9),
    ),
    MesureEntry(
      value: '82',
      unit: 'bpm',
      date: '4 mars 2026',
      statusLabel: 'Normal',
      statusColor: Color(0xFF27AE60),
      statusBg: Color(0xFFE8F5E9),
    ),
    MesureEntry(
      value: '95',
      unit: 'bpm',
      date: '25 févr. 2026',
      statusLabel: 'Attention',
      statusColor: Color(0xFFF39C12),
      statusBg: Color(0xFFFFF2CC),
    ),
    MesureEntry(
      value: '72',
      unit: 'bpm',
      date: '18 févr. 2026',
      statusLabel: 'Normal',
      statusColor: Color(0xFF27AE60),
      statusBg: Color(0xFFE8F5E9),
    ),
    MesureEntry(
      value: '105',
      unit: 'bpm',
      date: '11 févr. 2026',
      statusLabel: 'Élevé',
      statusColor: Color(0xFFE74C3C),
      statusBg: Color(0xFFFFEAEA),
    ),
    MesureEntry(
      value: '80',
      unit: 'bpm',
      date: '4 févr. 2026',
      statusLabel: 'Normal',
      statusColor: Color(0xFF27AE60),
      statusBg: Color(0xFFE8F5E9),
    ),
  ];

  // Glycémie g/L
  final List<MesureEntry> _glycHistory = [
    MesureEntry(
      value: '1.15',
      unit: 'g/L',
      date: '10 mars 2026',
      statusLabel: 'Normal',
      statusColor: Color(0xFF27AE60),
      statusBg: Color(0xFFE8F5E9),
      subtitle: 'À jeun — 10 mars 2026',
    ),
    MesureEntry(
      value: '1.42',
      unit: 'g/L',
      date: '3 mars 2026',
      statusLabel: 'Attention',
      statusColor: Color(0xFFF39C12),
      statusBg: Color(0xFFFFF2CC),
      subtitle: 'À jeun — 3 mars 2026',
    ),
    MesureEntry(
      value: '1.85',
      unit: 'g/L',
      date: '24 févr. 2026',
      statusLabel: 'Élevé',
      statusColor: Color(0xFFE74C3C),
      statusBg: Color(0xFFFFEAEA),
      subtitle: 'À jeun — 24 févr. 2026',
    ),
    MesureEntry(
      value: '1.08',
      unit: 'g/L',
      date: '17 févr. 2026',
      statusLabel: 'Normal',
      statusColor: Color(0xFF27AE60),
      statusBg: Color(0xFFE8F5E9),
      subtitle: 'À jeun — 17 févr. 2026',
    ),
    MesureEntry(
      value: '1.52',
      unit: 'g/L',
      date: '10 févr. 2026',
      statusLabel: 'Élevé',
      statusColor: Color(0xFFE74C3C),
      statusBg: Color(0xFFFFEAEA),
      subtitle: 'À jeun — 10 févr. 2026',
    ),
    MesureEntry(
      value: '1.20',
      unit: 'g/L',
      date: '3 févr. 2026',
      statusLabel: 'Normal',
      statusColor: Color(0xFF27AE60),
      statusBg: Color(0xFFE8F5E9),
      subtitle: 'À jeun — 3 févr. 2026',
    ),
  ];

  // Poids kg
  final List<MesureEntry> _poidsHistory = [
    MesureEntry(
      value: '82.5',
      unit: 'kg',
      date: '10 mars 2026',
      statusLabel: 'Attention',
      statusColor: Color(0xFFF39C12),
      statusBg: Color(0xFFFFF2CC),
    ),
    MesureEntry(
      value: '83.0',
      unit: 'kg',
      date: '3 mars 2026',
      statusLabel: 'Attention',
      statusColor: Color(0xFFF39C12),
      statusBg: Color(0xFFFFF2CC),
    ),
    MesureEntry(
      value: '84.2',
      unit: 'kg',
      date: '24 févr. 2026',
      statusLabel: 'Élevé',
      statusColor: Color(0xFFE74C3C),
      statusBg: Color(0xFFFFEAEA),
    ),
    MesureEntry(
      value: '83.8',
      unit: 'kg',
      date: '17 févr. 2026',
      statusLabel: 'Attention',
      statusColor: Color(0xFFF39C12),
      statusBg: Color(0xFFFFF2CC),
    ),
    MesureEntry(
      value: '83.5',
      unit: 'kg',
      date: '10 févr. 2026',
      statusLabel: 'Attention',
      statusColor: Color(0xFFF39C12),
      statusBg: Color(0xFFFFF2CC),
    ),
    MesureEntry(
      value: '84.0',
      unit: 'kg',
      date: '3 févr. 2026',
      statusLabel: 'Attention',
      statusColor: Color(0xFFF39C12),
      statusBg: Color(0xFFFFF2CC),
    ),
  ];

  // IMC kg/m²
  final List<MesureEntry> _imcHistory = [
    MesureEntry(
      value: '30.3',
      unit: 'kg/m²',
      date: '10 mars 2026',
      statusLabel: 'Attention',
      statusColor: Color(0xFFF39C12),
      statusBg: Color(0xFFFFF2CC),
      subtitle: 'Obésité',
    ),
    MesureEntry(
      value: '30.5',
      unit: 'kg/m²',
      date: '3 mars 2026',
      statusLabel: 'Attention',
      statusColor: Color(0xFFF39C12),
      statusBg: Color(0xFFFFF2CC),
      subtitle: 'Obésité',
    ),
    MesureEntry(
      value: '30.9',
      unit: 'kg/m²',
      date: '24 févr. 2026',
      statusLabel: 'Élevé',
      statusColor: Color(0xFFE74C3C),
      statusBg: Color(0xFFFFEAEA),
      subtitle: 'Obésité',
    ),
    MesureEntry(
      value: '30.8',
      unit: 'kg/m²',
      date: '17 févr. 2026',
      statusLabel: 'Attention',
      statusColor: Color(0xFFF39C12),
      statusBg: Color(0xFFFFF2CC),
      subtitle: 'Obésité',
    ),
    MesureEntry(
      value: '30.7',
      unit: 'kg/m²',
      date: '10 févr. 2026',
      statusLabel: 'Attention',
      statusColor: Color(0xFFF39C12),
      statusBg: Color(0xFFFFF2CC),
      subtitle: 'Obésité',
    ),
    MesureEntry(
      value: '30.9',
      unit: 'kg/m²',
      date: '3 févr. 2026',
      statusLabel: 'Élevé',
      statusColor: Color(0xFFE74C3C),
      statusBg: Color(0xFFFFEAEA),
      subtitle: 'Obésité',
    ),
  ];

  // ── Labels des onglets ──────────────────────────────────────────────────

  final List<Map<String, dynamic>> _tabs = [
    {'icon': Icons.favorite_border, 'label': 'PA'},
    {'icon': Icons.favorite_border, 'label': 'Pouls'},
    {'icon': Icons.opacity, 'label': 'Glycémie'},
    {'icon': Icons.scale_outlined, 'label': 'Poids'},
    {'icon': Icons.calculate_outlined, 'label': 'IMC'},
  ];

  // ── Données graphique par onglet ────────────────────────────────────────

  List<String> get _chartDates => [
    '04 févr.',
    '11 févr.',
    '18 févr.',
    '25 févr.',
    '04 mars',
    '11 mars',
  ];

  List<LineChartBarData> get _chartLines {
    switch (_selectedTab) {
      case 0: // PA
        return [
          _line([140, 126, 130, 142, 128, 135], Color(0xFF27AE60)),
          _line([88, 80, 84, 92, 82, 85], Color(0xFF3498DB)),
        ];
      case 1: // Pouls
        return [
          _line([80, 105, 72, 95, 82, 78], Color(0xFFE74C3C)),
        ];
      case 2: // Glycémie ×100 pour affichage
        return [
          _line([1.20, 1.52, 1.08, 1.85, 1.42, 1.15], Color(0xFFF39C12)),
        ];
      case 3: // Poids
        return [
          _line([84.0, 83.5, 83.8, 84.2, 83.0, 82.5], Color(0xFF9B59B6)),
        ];
      case 4: // IMC
        return [
          _line([30.9, 30.7, 30.8, 30.9, 30.5, 30.3], Color(0xFF3498DB)),
        ];
      default:
        return [];
    }
  }

  double get _chartMinY {
    switch (_selectedTab) {
      case 0:
        return 60;
      case 1:
        return 0;
      case 2:
        return 0;
      case 3:
        return 70;
      case 4:
        return 25;
      default:
        return 0;
    }
  }

  double get _chartMaxY {
    switch (_selectedTab) {
      case 0:
        return 160;
      case 1:
        return 120;
      case 2:
        return 3;
      case 3:
        return 100;
      case 4:
        return 40;
      default:
        return 100;
    }
  }

  String get _chartTitle {
    switch (_selectedTab) {
      case 0:
        return 'Évolution — Pression Artérielle';
      case 1:
        return 'Évolution — Fréquence cardiaque';
      case 2:
        return 'Évolution — Glycémie à jeun';
      case 3:
        return 'Évolution — Poids';
      case 4:
        return 'Évolution — IMC';
      default:
        return 'Évolution';
    }
  }

  // ── Dernière valeur affichée sur la carte principale ────────────────────

  String get _mainValue {
    switch (_selectedTab) {
      case 0:
        return '135/85';
      case 1:
        return '78';
      case 2:
        return '1.15';
      case 3:
        return '82.5';
      case 4:
        return '30.3';
      default:
        return '—';
    }
  }

  String get _mainUnit {
    switch (_selectedTab) {
      case 0:
        return 'mmHg';
      case 1:
        return 'bpm';
      case 2:
        return 'g/L';
      case 3:
        return 'kg';
      case 4:
        return 'kg/m²';
      default:
        return '';
    }
  }

  String get _mainDate {
    switch (_selectedTab) {
      case 0:
        return '11 mars 2026';
      case 1:
        return '11 mars 2026';
      case 2:
        return '10 mars 2026';
      case 3:
        return '10 mars 2026';
      case 4:
        return '10 mars 2026';
      default:
        return '';
    }
  }

  Map<String, dynamic> get _mainStatus {
    switch (_selectedTab) {
      case 0:
        return {
          'label': 'Attention',
          'color': Color(0xFFF39C12),
          'bg': Color(0xFFFFF2CC),
        };
      case 1:
        return {
          'label': 'Normal',
          'color': Color(0xFF27AE60),
          'bg': Color(0xFFE8F5E9),
        };
      case 2:
        return {
          'label': 'Normal',
          'color': Color(0xFF27AE60),
          'bg': Color(0xFFE8F5E9),
        };
      case 3:
        return {
          'label': 'Attention',
          'color': Color(0xFFF39C12),
          'bg': Color(0xFFFFF2CC),
        };
      case 4:
        return {
          'label': 'Attention',
          'color': Color(0xFFF39C12),
          'bg': Color(0xFFFFF2CC),
        };
      default:
        return {'label': '—', 'color': Colors.grey, 'bg': Colors.grey.shade100};
    }
  }

  IconData get _mainIcon {
    switch (_selectedTab) {
      case 0:
        return Icons.favorite;
      case 1:
        return Icons.favorite_border;
      case 2:
        return Icons.opacity;
      case 3:
        return Icons.scale_outlined;
      case 4:
        return Icons.calculate_outlined;
      default:
        return Icons.monitor_heart_outlined;
    }
  }

  String get _mainLabel {
    switch (_selectedTab) {
      case 0:
        return 'Pression Artérielle';
      case 1:
        return 'Fréquence cardiaque';
      case 2:
        return 'Glycémie à jeun';
      case 3:
        return 'Poids';
      case 4:
        return 'IMC';
      default:
        return '';
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

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
              'Suivi complet — Hypertension & Diabète',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tags pathologies
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildPathologyTag(
                    'Hypertension',
                    Color(0xFFFFEAEA),
                    Color(0xFFE74C3C),
                    Icons.favorite_border,
                  ),
                  SizedBox(width: 10),
                  _buildPathologyTag(
                    'Diabète',
                    Color(0xFFFFF2CC),
                    Color(0xFFF39C12),
                    Icons.local_fire_department_outlined,
                  ),
                ],
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
                    _buildMainValueCard(),
                    SizedBox(height: 20),

                    // Graphique
                    _buildEvolutionGraphCard(),
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
                    _buildHistorySection(),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Historique selon onglet actif ───────────────────────────────────────

  Widget _buildHistorySection() {
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
        if (_selectedTab == 0) ..._paHistory.map((e) => _buildPaHistoryRow(e)),
        if (_selectedTab == 1)
          ..._poulsHistory.map(
            (e) => _buildSimpleHistoryRow(
              e,
              Icons.favorite_border,
              Color(0xFFFFEAEA),
              Color(0xFFE74C3C),
            ),
          ),
        if (_selectedTab == 2)
          ..._glycHistory.map(
            (e) => _buildSimpleHistoryRow(
              e,
              Icons.opacity,
              Color(0xFFFFF2CC),
              Color(0xFFF39C12),
            ),
          ),
        if (_selectedTab == 3)
          ..._poidsHistory.map(
            (e) => _buildSimpleHistoryRow(
              e,
              Icons.scale_outlined,
              Color(0xFFF3E5F5),
              Color(0xFF9B59B6),
            ),
          ),
        if (_selectedTab == 4)
          ..._imcHistory.map((e) => _buildImcHistoryRow(e)),
      ],
    );
  }

  // Ligne PA (systolique/diastolique)
  Widget _buildPaHistoryRow(Map<String, dynamic> entry) {
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
            child: Icon(Icons.favorite, color: Color(0xFF27AE60), size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${entry['sys']}/${entry['dia']} ',
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
                  entry['date'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: entry['bg'],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              entry['label'],
              style: TextStyle(
                color: entry['color'],
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

  Widget _buildMainValueCard() {
    final status = _mainStatus;
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
                child: Icon(_mainIcon, color: Color(0xFF27AE60), size: 18),
              ),
              SizedBox(width: 8),
              Text(
                _mainLabel,
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
            _mainValue,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
              letterSpacing: -1,
            ),
          ),
          Text(
            _mainUnit,
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
            _mainDate,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Graphique d'évolution ───────────────────────────────────────────────

  Widget _buildEvolutionGraphCard() {
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
                _chartTitle,
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
                        if (i < 0 || i >= _chartDates.length) return SizedBox();
                        return Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            _chartDates[i],
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
                maxX: 5,
                minY: _chartMinY,
                maxY: _chartMaxY,
                lineBarsData: _chartLines,
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
