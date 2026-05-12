import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:sizer/sizer.dart';

class CalendarPage extends StatefulWidget {
  CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  String? selectedProfile; // Null = État vide, "Yapi" = Profil sélectionné

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Sélecteur de Profil ---
            _buildProfileSelector(),
            SizedBox(height: 16),

            // --- Avertissement Orange ---
            _buildWarningBox(),
            SizedBox(height: 16),

            // --- Contenu Dynamique ---
            if (selectedProfile == null)
              _buildEmptyState()
            else
              _buildCalendarContent(),

            SizedBox(height: 20),
            // --- Aide / FAQ (Seulement si profil sélectionné) ---
            if (selectedProfile != null) _buildFooterAide(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: appColor2, size: 18),
              Gap(1.w),
              Expanded(
                child: Text(
                  "Calendrier Vaccinal 2023-2024",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: appColor2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            "Calendrier officiel avec vaccins recommandés par age",
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
          Gap(2.h),
          Text(
            "Selectionner un profil",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          if (selectedProfile == null)
            GestureDetector(
              onTap: () => setState(() => selectedProfile = "Yapi - Moi-meme"),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Choisir un profil...",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFF67B04F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.check, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    selectedProfile!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () => setState(() => selectedProfile = null),
                    icon: Icon(Icons.close, color: Colors.white, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFFFF7F0),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: Colors.orange, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Calendrier susceptible de modifications",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF935116),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Ce calendrier peut etre modifie au fil des ans. "
                  "Votre medecin pourra eventuellement l'adapter a votre "
                  "situation. N'hesitez pas a discuter vaccination avec lui.",
                  style: TextStyle(color: Color(0xFF935116), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 60,
            color: Color(0xFFD1D5DB),
          ),
          SizedBox(height: 16),
          Text(
            "Selectionnez un profil pour voir son calendrier\nvaccinal",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent() {
    return Column(
      children: [
        // --- Infos Profil ---
        _buildProfileInfoCard(),
        SizedBox(height: 16),
        // --- Accordéons de vaccins ---
        _buildVaccineAgeGroup("Tous les 10 ans", "2 vaccins", "GRATUIT", [
          _buildVaccineDetail(
            "VAT (Tetanos) - Rappel",
            "Gratuit en secteur public",
            "VAT (Vaccin Anti-Tetanique)",
            "Tetanos",
            "Protection contre le tetanos, maladie infectieuse grave causee par une bacterie presente dans le sol.",
            "Oui - Rappels a 7-9 ans, 15-16 ans, puis tous les 10 ans",
          ),
          _buildVaccineDetail(
            "DTP (Diphterie-Tetanos-Polio) - Rappel",
            "Gratuit en secteur public",
            "Revaxis, Boostrix",
            "Diphterie, Tetanos, Poliomyelite",
            "Vaccin trivalent pour les rappels chez l'enfant et l'adulte.",
            "Oui - Rappels tous les 10 ans a l'age adulte",
          ),
        ], initiallyExpanded: true),
        SizedBox(height: 12),
        _buildVaccineAgeGroup("65 ans et plus", "2 vaccins", null, [
          _buildVaccineDetail(
            "Pneumocoques",
            "Gratuit en secteur public",
            "Prevenar 13",
            "Infections a pneumocoque, Meningites, Pneumonies, Otites",
            "Protection contre les infections graves causees par la bacterie pneumocoque.",
            "Oui - Doses a 2, 3, 4 et 12 mois.",
            noteImportante:
                "Pour bebes nes avant 37 semaines ou prematures: dose supplementaire recommandee a 3 mois",
          ),
        ]),
      ],
    );
  }

  Widget _buildProfileInfoCard() {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 5),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline, color: appColor2),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Yapi",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: appColor2,
                ),
              ),
              Text(
                "Categorie: Moi-meme",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                "Age: 32 ans (390 mois)",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineAgeGroup(
    String title,
    String count,
    String? tag,
    List<Widget> children, {
    bool initiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        border: Border(left: BorderSide(color: appColor2, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        shape: RoundedRectangleBorder(side: BorderSide.none),
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(width: 8),
            if (tag != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          count,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        children: children,
      ),
    );
  }

  Widget _buildVaccineDetail(
    String name,
    String status,
    String commercialName,
    String diseases,
    String description,
    String recall, {
    String? noteImportante,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.check, color: Colors.green, size: 14),
                        SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showRecallModal(name),
                icon: Icon(Icons.notifications_none, size: 16),
                label: Text("Rappel"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1B4332),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _detailField("Nom commercial:", commercialName),
          _detailField("Maladie(s) couverte(s):", diseases),
          _detailField("Description:", description),
          _detailField("Rappel necessaire:", recall),
          if (noteImportante != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFFEF9C3),
                border: Border(
                  left: BorderSide(color: Color(0xFFFACC15), width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Important:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF854D0E),
                    ),
                  ),
                  Text(
                    noteImportante,
                    style: TextStyle(fontSize: 11, color: Color(0xFF854D0E)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailField(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black87, fontSize: 13),
          children: [
            TextSpan(
              text: "$label\n",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterAide() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: Color(0xFF2563EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: Color(0xFF2563EB), size: 17.sp),
              Gap(1.w),
              Expanded(
                child: Text(
                  "Besoin d'aide ou d'informations supplementaires ?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "Consultez notre Aide/FAQ pour en savoir plus sur les vaccins et la vaccination",
            style: TextStyle(fontSize: 13.sp, color: Color(0xFF1E40AF)),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showRecallModal(String vaccineName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Configurer un rappel",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _modalField("Vaccin", vaccineName),
                _modalField("Periode", "Tous les 10 ans"),
                Text(
                  "Date du rappel",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 4),
                TextField(
                  decoration: InputDecoration(
                    hintText: "jj/mm/aaaa",
                    filled: true,
                    fillColor: Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Annuler", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1B4332),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Enregistrer",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Widget _modalField(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: TextStyle(color: Color(0xFF374151))),
          ),
        ],
      ),
    );
  }
}
