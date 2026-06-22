import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaconsult/core/constants/constants.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/models/vaccines/profile_model.dart';
import 'package:sizer/sizer.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  ProfileModel? selectedProfile;
  List<ProfileModel> _profiles = [];
  List<dynamic>? _calendarData;
  Map<String, dynamic>? _apiProfileInfo;
  bool _isLoadingProfiles = false;
  bool _isLoadingCalendar = false;

  @override
  void initState() {
    super.initState();
    _fetchProfiles();
  }

  Future<void> _fetchProfiles() async {
    setState(() => _isLoadingProfiles = true);
    try {
      final id = SharedPreferencesHelper().getString("identifiant")!;
      final response = await http.get(
        Uri.parse(ApiUrls.getListProfile(id)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _profiles = data.map((e) => ProfileModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching profiles: $e");
    } finally {
      setState(() => _isLoadingProfiles = false);
    }
  }

  Future<void> _fetchCalendar(ProfileModel profile) async {
    setState(() {
      selectedProfile = profile;
      _isLoadingCalendar = true;
      _calendarData = null;
      _apiProfileInfo = null;
    });

    try {
      final response = await http.get(
        Uri.parse(ApiUrls.getCalendarByProfile(profile.idProfile!)),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint("Response code: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _calendarData = data['data'];
          _apiProfileInfo = data['profile'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching calendar: $e");
    } finally {
      setState(() => _isLoadingCalendar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Sélecteur de Profil ---
            _buildProfileSelector(),
            const SizedBox(height: 16),

            // --- Avertissement Orange ---
            _buildWarningBox(),
            const SizedBox(height: 16),

            // --- Contenu Dynamique ---
            if (selectedProfile == null)
              _buildEmptyState()
            else if (_isLoadingCalendar)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_calendarData == null || _calendarData!.isEmpty)
              _buildNoDataState()
            else
              _buildCalendarContent(),

            const SizedBox(height: 20),
            // --- Aide / FAQ (Seulement si profil sélectionné) ---
            if (selectedProfile != null) _buildFooterAide(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
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
                  "Calendrier Vaccinal",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: appColor2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Calendrier officiel avec vaccins recommandés par âge",
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
          Gap(2.h),
          const Text(
            "Selectionner un profil",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (selectedProfile == null)
            _isLoadingProfiles
                ? const LinearProgressIndicator()
                : _buildProfileDropdown()
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF67B04F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "${selectedProfile!.name} - ${selectedProfile!.relation ?? selectedProfile!.animalType ?? ''}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => setState(() {
                      selectedProfile = null;
                      _calendarData = null;
                    }),
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileDropdown() {
    return GestureDetector(
      onTap: () => _showProfilePicker(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Choisir un profil...",
              style: TextStyle(color: Colors.grey),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showProfilePicker() {
    final activeProfiles = _profiles.where((p) => p.hasActiveSubscription == true).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choisir un profil",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              if (activeProfiles.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    "Aucun profil avec abonnement actif trouvé. "
                    "Veuillez activer un profil dans l'onglet Profils.",
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: activeProfiles.length,
                    itemBuilder: (context, index) {
                      final p = activeProfiles[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: appColor.withValues(alpha: 0.1),
                          child: Icon(
                            p.profileType == 'human'
                                ? Icons.person
                                : Icons.pets,
                            color: appColor,
                            size: 20,
                          ),
                        ),
                        title: Text(p.name ?? 'Sans nom'),
                        subtitle: Text(p.relation ?? p.animalType ?? ''),
                        onTap: () {
                          Navigator.pop(context);
                          _fetchCalendar(p);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F0),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: Colors.orange, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Calendrier susceptible de modifications",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF935116),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Ce calendrier peut être modifié au fil des ans. "
                  "Votre médecin pourra éventuellement l'adapter à votre "
                  "situation. N'hésitez pas à discuter vaccination avec lui.",
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
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 60,
            color: Color(0xFFD1D5DB),
          ),
          SizedBox(height: 16),
          Text(
            "Sélectionnez un profil pour voir son calendrier\nvaccinal",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 50, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Aucune recommandation vaccinale trouvée pour ce profil.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
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
        const SizedBox(height: 16),
        // --- Accordéons de vaccins ---
        ...(_calendarData!.map((group) {
          final vaccines = group['vaccines'] as List;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildVaccineAgeGroup(
              group['age_group'],
              "${group['count']} vaccin(s)",
              null,
              vaccines.map((v) {
                final schedule = v['schedule'];
                return _buildVaccineDetail(
                  v['id_vaccine'],
                  v['name'] ?? '',
                  "Recommandé",
                  v['equivalents']?.isNotEmpty == true
                      ? (v['equivalents'] as List)
                          .map((e) => e['name'])
                          .join(", ")
                      : "—",
                  v['protected_against'] ?? v['targeted_disease'] ?? '—',
                  v['description'] ?? '—',
                  schedule['is_booster'] == true
                      ? "Rappel tous les ${schedule['booster_every_months']} mois"
                      : "Dose unique ou série initiale",
                  noteImportante: schedule['important_note'],
                );
              }).toList(),
              initiallyExpanded: _calendarData!.indexOf(group) == 0,
            ),
          );
        })),
      ],
    );
  }

  Widget _buildProfileInfoCard() {
    final ageMonths = _apiProfileInfo?['real_age'] ?? 0;

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
          Icon(
            selectedProfile!.profileType == 'human' ? Icons.person_outline : Icons.pets,
            color: appColor2,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedProfile!.name ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: appColor2,
                ),
              ),
              Text(
                "Catégorie: ${selectedProfile!.relation ?? selectedProfile!.animalType ?? ''}",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                "Âge : $ageMonths",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
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
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (tag != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
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
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        children: children,
      ),
    );
  }

  Widget _buildVaccineDetail(
    int? idVaccine,
    String name,
    String status,
    String commercialName,
    String diseases,
    String description,
    String recall, {
    String? noteImportante,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.check, color: Colors.green, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: const TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showRecallModal(idVaccine, name, recall),
                icon: const Icon(Icons.notifications_none, size: 16),
                label: const Text("Rappel"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B4332),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _detailField("Nom commercial:", commercialName),
          _detailField("Maladie(s) couverte(s):", diseases),
          _detailField("Description:", description),
          _detailField("Rappel nécessaire:", recall),
          if (noteImportante != null && noteImportante.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF9C3),
                border: Border(
                  left: BorderSide(color: Color(0xFFFACC15), width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Important:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF854D0E),
                    ),
                  ),
                  Text(
                    noteImportante,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF854D0E)),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 13),
          children: [
            TextSpan(
              text: "$label\n",
              style: const TextStyle(
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: const Color(0xFF2563EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: const Color(0xFF2563EB), size: 17.sp),
              Gap(1.w),
              Expanded(
                child: Text(
                  "Besoin d'aide ou d'informations supplémentaires ?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Consultez notre Aide/FAQ pour en savoir plus sur les vaccins et la vaccination",
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF1E40AF)),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _showRecallModal(int? idVaccine, String vaccineName, String recallInfo) {
    final TextEditingController dateController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  "Configurer un rappel",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _modalField("Vaccin", vaccineName),
                    _modalField("Période", recallInfo),
                    const Text(
                      "Date du rappel",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: dateController,
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now().add(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDate = picked;
                            dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Cliquer pour choisir",
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        suffixIcon: const Icon(Icons.calendar_today, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
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
                    child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: selectedDate == null ? null : () => _saveReminder(idVaccine, vaccineName, selectedDate!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B4332),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Enregistrer",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            }
          ),
    );
  }

  Future<void> _saveReminder(int? idVaccine, String vaccineName, DateTime date) async {
    // Fermer le modal
    Navigator.pop(context);

    setState(() => _isLoadingCalendar = true);

    try {
      final userId = SharedPreferencesHelper().getString('identifiant') ?? "";
      
      final body = {
        'profile_id': selectedProfile!.idProfile,
        'next_reminder_date': "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",

        'center_type': "",
        'center_name': "",
        'notes': "",
        'id_user': userId,
        'vaccine_id': idVaccine,
        'vaccine_name_free': idVaccine == null ? vaccineName : null,
      };

      final response = await http.post(
        Uri.parse(ApiUrls.postRemindersByProfile),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );
      print(body);

      final data = json.decode(utf8.decode(response.bodyBytes));

      debugPrint("Response: $data");

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Rappel enregistré avec succès"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? "Erreur lors de l'enregistrement"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Une erreur réseau est survenue"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingCalendar = false);
    }
  }

  Widget _modalField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: const TextStyle(color: Color(0xFF374151))),
          ),
        ],
      ),
    );
  }
}
