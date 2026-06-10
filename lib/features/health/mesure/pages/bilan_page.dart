import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:sizer/sizer.dart';

class BilanPage extends StatefulWidget {
  BilanPage({super.key});

  @override
  State<BilanPage> createState() => _BilanPageState();
}

class _BilanPageState extends State<BilanPage> {
  bool isPeriodExpanded = false;

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
        child: SingleChildScrollView(
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
                        Expanded(child: _buildDateField("Du", "13/02/2026")),
                        SizedBox(width: 10),
                        Expanded(child: _buildDateField("Au", "15/03/2026")),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '20 mesures trouvées sur cette période',
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
                            "6",
                            "Normales",
                            Colors.green,
                          ),
                        ),
                        Gap(2.w),
                        Expanded(
                          child: _buildGlobalStat(
                            Icons.warning_amber_rounded,
                            "10",
                            "Attention",
                            Colors.orange,
                          ),
                        ),
                        Gap(2.w),
                        Expanded(
                          child: _buildGlobalStat(
                            Icons.highlight_off_rounded,
                            "4",
                            "Élevées",
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    _buildMultiProgressBar(),
                    SizedBox(height: 10),
                    Text(
                      '30% des mesures dans les normes',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // --- LISTE DES MESURES (EXPANSION TILES) ---
              _buildMetricTile(
                icon: Icons.favorite_border,
                title: "Pression Artérielle",
                count: "4 mesures",
                trendIcon: Icons.trending_up,
                trendColor: Colors.red,
                details: [
                  _buildDetailBox("Moy. systolique", "134", "mmHg"),
                  _buildDetailBox("Moy. diastolique", "86", "mmHg"),
                  _buildDetailBox("Dernière PA", "135/85", ""),
                  _buildDetailBox("Tendance", "Hausse", "", isTrend: true),
                ],
                footerTags: [
                  _buildStatusTag("1 normales", Colors.green),
                  _buildStatusTag("2 attention", Colors.orange),
                  _buildStatusTag("1 élevées", Colors.red),
                ],
                topColor: Colors.green,
              ),

              _buildMetricTile(
                icon: Icons.heart_broken_outlined,
                title: "Fréquence cardiaque",
                count: "4 mesures",
                trendIcon: Icons.trending_up,
                trendColor: Colors.red,
                details: [
                  _buildDetailBox("Moyenne", "81.8", "bpm"),
                  _buildDetailBox("Dernière", "78", "bpm"),
                  _buildDetailBox("Min / Max", "72 / 95", ""),
                  _buildDetailBox("Tendance", "Hausse", "", isTrend: true),
                ],
                footerTags: [
                  _buildStatusTag("3 normales", Colors.green),
                  _buildStatusTag("1 attention", Colors.orange),
                ],
                topColor: Colors.red,
              ),

              _buildMetricTile(
                icon: Icons.opacity_outlined,
                title: "Glycémie à jeun",
                count: "4 mesures",
                trendIcon: Icons.trending_up,
                trendColor: Colors.red,
                details: [
                  _buildDetailBox("Moyenne", "1.38", "g/L"),
                  _buildDetailBox("Dernière", "1.15", "g/L"),
                  _buildDetailBox("Min / Max", "1.08 / 1.85", ""),
                  _buildDetailBox("Tendance", "Hausse", "", isTrend: true),
                ],
                footerTags: [
                  _buildStatusTag("2 normales", Colors.green),
                  _buildStatusTag("1 attention", Colors.orange),
                  _buildStatusTag("1 élevées", Colors.red),
                ],
                topColor: Colors.orange,
              ),

              _buildMetricTile(
                icon: Icons.fitness_center_outlined,
                title: "Poids",
                count: "4 mesures",
                trendIcon: Icons.trending_down,
                trendColor: Colors.green,
                details: [
                  _buildDetailBox("Moyenne", "83.4", "kg"),
                  _buildDetailBox("Dernière", "82.5", "kg"),
                  _buildDetailBox("Min / Max", "82.5 / 84.2", ""),
                  _buildDetailBox("Tendance", "Baisse", "", isTrend: false),
                ],
                footerTags: [
                  _buildStatusTag("0 normales", Colors.green),
                  _buildStatusTag("3 attention", Colors.orange),
                  _buildStatusTag("1 élevées", Colors.red),
                ],
                topColor: Colors.deepPurple,
              ),

              _buildMetricTile(
                icon: Icons.calculate_outlined,
                title: "IMC",
                count: "4 mesures",
                trendIcon: Icons.trending_down,
                trendColor: Colors.green,
                details: [
                  _buildDetailBox("Moyenne", "30.63", "kg/m²"),
                  _buildDetailBox("Dernière", "30.3", "kg/m²"),
                  _buildDetailBox("Min / Max", "30.3 / 30.9", ""),
                  _buildDetailBox("Tendance", "Baisse", "", isTrend: false),
                ],
                footerTags: [
                  _buildStatusTag("0 normales", Colors.green),
                  _buildStatusTag("3 attention", Colors.orange),
                  _buildStatusTag("1 élevées", Colors.red),
                ],
                topColor: Colors.blue,
              ),

              SizedBox(height: 30),

              // --- BOUTONS D'ACTION ---
              _buildActionButton(
                label: "Télécharger le PDF",
                icon: Icons.file_download_outlined,
                color: Color(0xFF27AE60),
                isOutlined: false,
              ),
              SizedBox(height: 12),
              _buildActionButton(
                label: "Partager le bilan",
                icon: Icons.share_outlined,
                color: Color(0xFF27AE60),
                isOutlined: true,
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
        ),
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

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
                _buildPeriodTag("14 jours", active: true),
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

  Widget _buildPeriodTag(String label, {bool active = false}) {
    return Container(
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

  Widget _buildMultiProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            Expanded(flex: 3, child: Container(color: Colors.green)),
            Expanded(flex: 5, child: Container(color: Colors.orange)),
            Expanded(flex: 2, child: Container(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String title,
    required String count,
    required IconData trendIcon,
    required Color trendColor,
    required Color topColor,
    required List<Widget> details,
    required List<Widget> footerTags,
  }) {
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
              if (isTrend) ...[
                SizedBox(width: 5),
                Icon(Icons.trending_up, color: Colors.red, size: 14),
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
                onPressed: () {},
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
                onPressed: () {},
              ),
    );
  }
}
