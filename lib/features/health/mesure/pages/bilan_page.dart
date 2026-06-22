import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:pharmaconsult/core/constants/constants.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/models/suivisante/bilan_model.dart';
import 'package:pharmaconsult/core/utils/pdf_bilan_service.dart';
import 'package:pharmaconsult/models/suivisante/mesure_model.dart' as mesure;
import 'package:pharmaconsult/models/suivisante/traitement_model.dart' as tr;
import 'package:sizer/sizer.dart';

class BilanPage extends StatefulWidget {
  const BilanPage({super.key});

  @override
  State<BilanPage> createState() => _BilanPageState();
}

class _BilanPageState extends State<BilanPage> {
  bool isPeriodExpanded = false;
  late Future<Map<String, dynamic>> _futureData;
  String _selectedPeriod = "14 jours";
  String _startDate = "";
  String _endDate = "";

  @override
  void initState() {
    super.initState();
    _calculateDates("14 jours");
    _futureData = _fetchAllData();
  }

  Future<Map<String, dynamic>> _fetchAllData() async {
    final patientId = SharedPreferencesHelper().getString("patient_id") ?? "";

    final results = await Future.wait([
      fetchBilan(patientId),
      fetchPatientAndPathologies(patientId),
      fetchTraitements(patientId),
    ]);

    return {
      'bilan': results[0] as BilanModel,
      'mesures': results[1] as mesure.MesureModel?,
      'traitements': results[2] as tr.TraitementModel?,
    };
  }

  Future<mesure.MesureModel?> fetchPatientAndPathologies(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiUrls.getListMesure(patientId)),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded is List && decoded.isNotEmpty) {
          return mesure.MesureModel.fromJson(decoded[0]);
        } else if (decoded is Map<String, dynamic>) {
          return mesure.MesureModel.fromJson(decoded);
        }
      }
    } catch (_) {}
    return null;
  }

  Future<tr.TraitementModel?> fetchTraitements(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiUrls.getListTraitement(patientId)),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return tr.TraitementModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes)),
        );
      }
    } catch (_) {}
    return null;
  }

  void _calculateDates(String period) {
    DateTime now = DateTime.now();
    DateTime start;

    switch (period) {
      case "7 jours":
        start = now.subtract(const Duration(days: 7));
        break;
      case "14 jours":
        start = now.subtract(const Duration(days: 14));
        break;
      case "1 mois":
        start = DateTime(now.year, now.month - 1, now.day);
        break;
      case "3 mois":
        start = DateTime(now.year, now.month - 3, now.day);
        break;
      case "6 mois":
        start = DateTime(now.year, now.month - 6, now.day);
        break;
      default:
        start = now.subtract(const Duration(days: 14));
    }

    _startDate = DateFormat('yyyy-MM-dd').format(start);
    _endDate = DateFormat('yyyy-MM-dd').format(now);
  }

  Future<BilanModel> fetchBilan(String patientId) async {
    final response = await http.get(
      Uri.parse(ApiUrls.getListBilan(patientId, _startDate, _endDate)),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return BilanModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Erreur lors de la récupération du bilan');
    }
  }

  void _onPeriodSelected(String period) {
    setState(() {
      _selectedPeriod = period;
      _calculateDates(period);
      _futureData = _fetchAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appDegradOne,
      appBar: AppBar(
        leading: _buildCircularButton(Icons.arrow_back),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mon bilan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F3E32),
              ),
            ),
            Text(
              'Générez votre résumé de santé',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('Aucune donnée disponible'));
            }

            final data = snapshot.data!['bilan'] as BilanModel;
            final patientData =
                snapshot.data!['mesures'] as mesure.MesureModel?;
            final traitements =
                snapshot.data!['traitements'] as tr.TraitementModel?;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION: CHOISIR LA PERIODE ---
                  _buildSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: Color(0xFF27AE60),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Choisir la période',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F3E32),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        _buildPeriodSelector(),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateField(
                                "Du",
                                data.periode?.startDate ?? "—",
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _buildDateField(
                                "Au",
                                data.periode?.endDate ?? "—",
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          '${data.periode?.totalMesures ?? 0} mesures trouvées sur cette période',
                          style: TextStyle(
                            color: Color(0xFF27AE60),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // --- SECTION: RESUME GLOBAL ---
                  _buildSectionCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  color: Color(0xFF27AE60),
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Résumé global',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F3E32),
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.keyboard_arrow_up, color: Colors.grey),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: _buildGlobalStat(
                                Icons.check_circle_outline,
                                "${data.resumeGlobal?.normales ?? 0}",
                                "Normales",
                                Colors.green,
                              ),
                            ),
                            Gap(2.w),
                            Expanded(
                              child: _buildGlobalStat(
                                Icons.warning_amber_rounded,
                                "${data.resumeGlobal?.attention ?? 0}",
                                "Attention",
                                Colors.orange,
                              ),
                            ),
                            Gap(2.w),
                            Expanded(
                              child: _buildGlobalStat(
                                Icons.highlight_off_rounded,
                                "${data.resumeGlobal?.elevees ?? 0}",
                                "Élevées",
                                Colors.red,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 25),
                        _buildMultiProgressBar(data.resumeGlobal),
                        SizedBox(height: 10),
                        Text(
                          '${_calculateNormalPercentage(data.resumeGlobal)}% des mesures dans les normes',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // --- LISTE DES MESURES ---
                  if (data.pressionArterielle != null)
                    _buildMetricTile(
                      icon: Icons.favorite_border,
                      title: "Pression Artérielle",
                      count: "${data.pressionArterielle!.count} mesures",
                      trend: data.pressionArterielle!.trend,
                      details: [
                        _buildDetailBox(
                          "Moy. systolique",
                          "${data.pressionArterielle!.averageSystolic}",
                          "mmHg",
                        ),
                        _buildDetailBox(
                          "Moy. diastolique",
                          "${data.pressionArterielle!.averageDiastolic}",
                          "mmHg",
                        ),
                        _buildDetailBox(
                          "Dernière PA",
                          data.pressionArterielle!.lastMeasure ?? "—",
                          "",
                        ),
                        _buildDetailBox(
                          "Tendance",
                          data.pressionArterielle!.trend ?? "Stable",
                          "",
                          isTrend: true,
                        ),
                      ],
                      footerTags: _buildStatusTags(
                        data.pressionArterielle!.status,
                      ),
                      topColor: Colors.green,
                    ),

                  if (data.frequenceCardiaque != null)
                    _buildMetricTile(
                      icon: Icons.heart_broken_outlined,
                      title: "Fréquence cardiaque",
                      count: "${data.frequenceCardiaque!.count} mesures",
                      trend: data.frequenceCardiaque!.trend,
                      details: [
                        _buildDetailBox(
                          "Moyenne",
                          "${data.frequenceCardiaque!.average}",
                          "bpm",
                        ),
                        _buildDetailBox(
                          "Dernière",
                          "${data.frequenceCardiaque!.last}",
                          "bpm",
                        ),
                        _buildDetailBox(
                          "Min / Max",
                          "${data.frequenceCardiaque!.min} / ${data.frequenceCardiaque!.max}",
                          "",
                        ),
                        _buildDetailBox(
                          "Tendance",
                          data.frequenceCardiaque!.trend ?? "Stable",
                          "",
                          isTrend: true,
                        ),
                      ],
                      footerTags: _buildStatusTags(
                        data.frequenceCardiaque!.status,
                      ),
                      topColor: Colors.red,
                    ),

                  if (data.glycemie != null)
                    _buildMetricTile(
                      icon: Icons.opacity_outlined,
                      title: "Glycémie à jeun",
                      count: "${data.glycemie!.count} mesures",
                      trend: data.glycemie!.trend,
                      details: [
                        _buildDetailBox(
                          "Moyenne",
                          "${data.glycemie!.average}",
                          "g/L",
                        ),
                        _buildDetailBox(
                          "Dernière",
                          data.glycemie!.last ?? "—",
                          "g/L",
                        ),
                        _buildDetailBox(
                          "Min / Max",
                          "${data.glycemie!.min} / ${data.glycemie!.max}",
                          "",
                        ),
                        _buildDetailBox(
                          "Tendance",
                          data.glycemie!.trend ?? "Stable",
                          "",
                          isTrend: true,
                        ),
                      ],
                      footerTags: _buildStatusTags(data.glycemie!.status),
                      topColor: Colors.orange,
                    ),

                  if (data.poids != null)
                    _buildMetricTile(
                      icon: Icons.fitness_center_outlined,
                      title: "Poids",
                      count: "${data.poids!.count} mesures",
                      trend: data.poids!.trend,
                      details: [
                        _buildDetailBox(
                          "Moyenne",
                          "${data.poids!.average}",
                          "kg",
                        ),
                        _buildDetailBox(
                          "Dernière",
                          data.poids!.last ?? "—",
                          "kg",
                        ),
                        _buildDetailBox(
                          "Min / Max",
                          "${data.poids!.min} / ${data.poids!.max}",
                          "",
                        ),
                        _buildDetailBox(
                          "Tendance",
                          data.poids!.trend ?? "Stable",
                          "",
                          isTrend: true,
                        ),
                      ],
                      footerTags: _buildStatusTags(data.poids!.status),
                      topColor: Colors.deepPurple,
                    ),

                  if (data.imc != null)
                    _buildMetricTile(
                      icon: Icons.calculate_outlined,
                      title: "IMC",
                      count: "${data.imc!.count} mesures",
                      trend: data.imc!.trend,
                      details: [
                        _buildDetailBox(
                          "Moyenne",
                          "${data.imc!.average}",
                          "kg/m²",
                        ),
                        _buildDetailBox(
                          "Dernière",
                          data.imc!.last ?? "—",
                          "kg/m²",
                        ),
                        _buildDetailBox(
                          "Min / Max",
                          "${data.imc!.min} / ${data.imc!.max}",
                          "",
                        ),
                        _buildDetailBox(
                          "Tendance",
                          data.imc!.trend ?? "Stable",
                          "",
                          isTrend: true,
                        ),
                      ],
                      footerTags: _buildStatusTags(data.imc!.status),
                      topColor: Colors.blue,
                    ),

                  SizedBox(height: 30),

                  // --- BOUTONS D'ACTION ---
                  _buildActionButton(
                    label: "Télécharger le PDF",
                    icon: Icons.file_download_outlined,
                    color: Color(0xFF27AE60),
                    isOutlined: false,
                    onPressed:
                        () => PdfBilanService.generateAndShareBilan(
                          bilan: data,
                          patient: patientData?.patient,
                          pathologies: patientData?.pathologies,
                          traitements: traitements,
                        ),
                  ),
                  SizedBox(height: 12),
                  _buildActionButton(
                    label: "Partager le bilan",
                    icon: Icons.share_outlined,
                    color: Color(0xFF27AE60),
                    isOutlined: true,
                    onPressed:
                        () => PdfBilanService.generateAndShareBilan(
                          bilan: data,
                          patient: patientData?.patient,
                          pathologies: patientData?.pathologies,
                          traitements: traitements,
                        ),
                  ),

                  SizedBox(height: 20),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Ce bilan est généré automatiquement à partir de vos mesures en pharmacie. Il ne remplace pas une consultation médicale.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

  int _calculateNormalPercentage(ResumeGlobal? resume) {
    if (resume == null) return 0;
    int total =
        (resume.normales ?? 0) +
        (resume.attention ?? 0) +
        (resume.elevees ?? 0);
    if (total == 0) return 0;
    return ((resume.normales ?? 0) / total * 100).round();
  }

  List<Widget> _buildStatusTags(ResumeGlobal? status) {
    if (status == null) return [];
    return [
      _buildStatusTag("${status.normales ?? 0} normales", Colors.green),
      _buildStatusTag("${status.attention ?? 0} attention", Colors.orange),
      _buildStatusTag("${status.elevees ?? 0} élevées", Colors.red),
    ];
  }

  Widget _buildCircularButton(IconData icon) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        margin: EdgeInsets.all(2.w),
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: Color(0xFF0F3E32)),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDateField(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey)),
        SizedBox(height: 5),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFFF8F9F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return GestureDetector(
      onTap: () => setState(() => isPeriodExpanded = !isPeriodExpanded),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFFF1F9F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFF27AE60).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Périodes rapides',
                  style: TextStyle(
                    color: Color(0xFF27AE60),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  isPeriodExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Color(0xFF27AE60),
                ),
              ],
            ),
          ),
          if (isPeriodExpanded) ...[
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPeriodTag("7 jours"),
                _buildPeriodTag("14 jours"),
                _buildPeriodTag("1 mois"),
                _buildPeriodTag("3 mois"),
                _buildPeriodTag("6 mois"),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodTag(String label) {
    bool active = _selectedPeriod == label;
    return GestureDetector(
      onTap: () => _onPeriodSelected(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Color(0xFF27AE60) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalStat(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiProgressBar(ResumeGlobal? resume) {
    int normales = resume?.normales ?? 0;
    int attention = resume?.attention ?? 0;
    int elevees = resume?.elevees ?? 0;
    int total = normales + attention + elevees;
    if (total == 0) total = 1; // Avoid division by zero

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            Expanded(flex: normales, child: Container(color: Colors.green)),
            Expanded(flex: attention, child: Container(color: Colors.orange)),
            Expanded(flex: elevees, child: Container(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String title,
    required String count,
    required String? trend,
    required Color topColor,
    required List<Widget> details,
    required List<Widget> footerTags,
  }) {
    IconData trendIcon = Icons.trending_flat;
    Color trendColor = Colors.grey;
    if (trend?.toLowerCase() == "hausse") {
      trendIcon = Icons.trending_up;
      trendColor = Colors.red;
    } else if (trend?.toLowerCase() == "baisse") {
      trendIcon = Icons.trending_down;
      trendColor = Colors.green;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2.w),
        border: Border(top: BorderSide(color: topColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: topColor.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: topColor, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F3E32),
            ),
          ),
          subtitle: Text(
            count,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: SizedBox(
            width: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(trendIcon, color: trendColor, size: 16),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  Divider(height: 1),
                  SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: details,
                  ),
                  SizedBox(height: 15),
                  Row(children: footerTags),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBox(
    String label,
    String value,
    String unit, {
    bool isTrend = false,
  }) {
    IconData? trendIcon;
    Color trendColor = Colors.grey;
    if (isTrend) {
      if (value.toLowerCase() == "hausse") {
        trendIcon = Icons.trending_up;
        trendColor = Colors.red;
      } else if (value.toLowerCase() == "baisse") {
        trendIcon = Icons.trending_down;
        trendColor = Colors.green;
      } else {
        trendIcon = Icons.trending_flat;
      }
    }

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey)),
          SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              if (unit.isNotEmpty)
                Text(
                  " $unit",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              if (isTrend && trendIcon != null) ...[
                SizedBox(width: 5),
                Icon(trendIcon, color: trendColor, size: 14),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String label, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isOutlined,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child:
          isOutlined
              ? OutlinedButton.icon(
                icon: Icon(icon, size: 20),
                label: Text(
                  label,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onPressed ?? () {},
              )
              : ElevatedButton.icon(
                icon: Icon(icon, size: 20, color: Colors.white),
                label: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onPressed ?? () {},
              ),
    );
  }
}
