import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaconsult/core/constants/constants.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:sizer/sizer.dart';

class RappelPage extends StatefulWidget {
  const RappelPage({super.key});

  @override
  State<RappelPage> createState() => _RappelPageState();
}

class _RappelPageState extends State<RappelPage> {
  bool isDropdownOpen = false;
  String selectedOptionLabel = "Tous les profils";
  String selectedCategory = "all";

  late Future<Map<String, dynamic>> _futureReminders;

  final List<Map<String, String>> _categories = [
    {"label": "Tous les profils", "value": "all"},
    {"label": "Enfants uniquement", "value": "children"},
    {"label": "Adultes uniquement", "value": "adults"},
    {"label": "Animaux uniquement", "value": "animals"},
  ];

  @override
  void initState() {
    super.initState();
    _refreshReminders();
  }

  void _refreshReminders() {
    setState(() {
      _futureReminders = _fetchReminders();
    });
  }

  Future<Map<String, dynamic>> _fetchReminders() async {
    final identifiant = SharedPreferencesHelper().getString('identifiant') ?? "";
    final response = await http.get(
      Uri.parse("${ApiUrls.getRemindersByIdentifiant(identifiant)}?category=$selectedCategory"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("Erreur lors du chargement des rappels");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureReminders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }

          final data = snapshot.data!;
          final counts = data['counts'] ?? {'urgent': 0, 'proche': 0, 'futur': 0};
          final nextDose = data['next_dose'];
          final reminders = data['data'] as List<dynamic>;

          return RefreshIndicator(
            onRefresh: () async => _refreshReminders(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Section Rappels Automatiques / Filtre ---
                  _buildAutoRecallCard(reminders.length),
                  const SizedBox(height: 16),

                  if (reminders.isNotEmpty) ...[
                    // --- Prochaine dose à administrer ---
                    if (nextDose != null) ...[
                      _buildNextDoseCard(nextDose),
                      const SizedBox(height: 16),
                    ],

                    // --- Section Calendrier des vaccins à venir (Indicateurs) ---
                    _buildUpcomingCalendarCard(counts),
                    const SizedBox(height: 16),

                    // --- Liste des rappels groupés ---
                    _buildRemindersSection(reminders),
                  ] else ...[
                    // --- État Vide ---
                    _buildEmptyState(),
                  ],

                  const SizedBox(height: 16),
                  // --- Note d'information bleue ---
                  _buildInfoNote(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget 1: La carte supérieure avec le sélecteur
  Widget _buildAutoRecallCard(int totalReminders) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Icon(Icons.notifications_active_outlined, color: appColor2, size: 26),
              const SizedBox(width: 8),
              Text(
                "Rappels Automatiques",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: appColor2,
                ),
              ),
              const Spacer(),
              const Icon(Icons.settings_outlined, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Notifications SMS et Push automatiques a J-5 et J-1",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Sélecteur personnalisé
          GestureDetector(
            onTap: () => setState(() => isDropdownOpen = !isDropdownOpen),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(selectedOptionLabel, style: const TextStyle(color: Colors.black54)),
                  Icon(
                    isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          if (isDropdownOpen) ...[
            const SizedBox(height: 4),
            ..._categories.map((cat) => _buildDropdownItem(cat['label']!, cat['value']!)),
          ],

          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.notifications_none, color: totalReminders > 0 ? Colors.green : Colors.grey, size: 18),
              const SizedBox(width: 8),
              Text(
                "$totalReminders rappel(s) programme(s)",
                style: TextStyle(color: totalReminders > 0 ? Colors.green : Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(String title, String value) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedOptionLabel = title;
          selectedCategory = value;
          isDropdownOpen = false;
        });
        _refreshReminders();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            const Icon(Icons.add, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  // Widget 1.5: Prochaine dose à administrer (Image 1)
  Widget _buildNextDoseCard(Map<String, dynamic> nextDose) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD1FAE5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF059669), size: 20),
              const SizedBox(width: 8),
              const Text(
                "Prochaine dose a administrer",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF065F46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nextDose['vaccine_name'] ?? '—',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Pour: ${nextDose['profile']['name']}",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Dans ${nextDose['days_left']} jours",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Date: ${nextDose['next_reminder_date_label']}",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget 2: Indicateurs de statut (Urgent, Proche, Futur)
  Widget _buildUpcomingCalendarCard(Map<String, dynamic> counts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Icon(Icons.calendar_today_outlined, color: appColor2, size: 22),
              const SizedBox(width: 8),
              Text(
                "Calendrier des vaccins a venir",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: appColor2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _statusRow(const Color(0xFFFEF2F2), Colors.red, "Urgent (0-5 jours): ${counts['urgent']}"),
          const SizedBox(height: 8),
          _statusRow(const Color(0xFFFFF7ED), Colors.orange, "Proche (6-30 jours): ${counts['proche']}"),
          const SizedBox(height: 8),
          _statusRow(const Color(0xFFEFF6FF), Colors.blue, "Futur (>30 jours): ${counts['futur']}"),
        ],
      ),
    );
  }

  Widget _statusRow(Color bgColor, Color textColor, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // Widget 3: Liste des rappels groupés (Image 1 & 2)
  Widget _buildRemindersSection(List<dynamic> reminders) {
    // On pourrait grouper par urgence ici, mais le JSON semble déjà contenir toutes les données triées.
    // L'image montre "Rappels futurs (> 30 jours)". On peut adapter le titre dynamiquement.
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_month, color: Color(0xFF2563EB), size: 20),
            const SizedBox(width: 8),
            const Text(
              "Tous les rappels", // Ou filtrer par urgence
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...reminders.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildReminderExpansionTile(r),
        )),
      ],
    );
  }

  Widget _buildReminderExpansionTile(Map<String, dynamic> r) {
    final urgencyColor = _getUrgencyColor(r['urgency']);
    final isAnimal = r['profile']['profile_type'] == 'animal';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: urgencyColor.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: urgencyColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.calendar_today, color: urgencyColor, size: 20),
        ),
        title: Text(
          r['vaccine_name'] ?? '—',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isAnimal ? Icons.pets : Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(r['profile']['name'], style: const TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
            Text("Dans ${r['days_left']} jour(s)", style: const TextStyle(fontSize: 13, color: Colors.black54)),
            Text(r['next_reminder_date'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                const Text("Details du rappel", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                const SizedBox(height: 12),
                _detailInfoItem("Date complete", r['next_reminder_date_label']),
                _detailInfoItem("Lieu prevu", r['center_name'] ?? "Non spécifié"),
                _detailInfoItem("Type de profil", "${isAnimal ? 'Animal' : 'Humain'} - ${r['profile']['relation'] ?? r['profile']['animal_type']}"),
/*const SizedBox(height: 16),
                const Text("Tester les notifications", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text("Simuler SMS"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.smartphone),
                    label: const Text("Simuler Push"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailInfoItem(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
        ],
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'urgent': return Colors.red;
      case 'proche': return Colors.orange;
      case 'futur': return Colors.blue;
      default: return Colors.grey;
    }
  }

  // Widget 3 (Old): Zone d'état vide
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Color(0xFF059669), size: 30),
          ),
          const SizedBox(height: 16),
          const Text(
            "Aucun rappel programme",
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 4),
          const Text(
            "Tous les vaccins sont a jour !",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Widget 4: Note d'information bleue au bas
  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: Color(0xFF2563EB), width: 4)),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(color: Color(0xFF1E40AF), fontSize: 13),
          children: [
            TextSpan(
              text: "Notifications automatiques: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text:
                  "Vous recevrez des rappels par SMS et notification push a "
                  "J-5 et J-1 avant chaque vaccination. "
                  "Gerez vos preferences dans les parametres.",
            ),
          ],
        ),
      ),
    );
  }
}
