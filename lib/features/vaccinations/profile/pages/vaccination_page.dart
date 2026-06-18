import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaconsult/core/constants/constants.dart';
import 'package:pharmaconsult/core/themes/app_colors.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/models/vaccines/profile_model.dart';
import 'package:sizer/sizer.dart';

class VaccinationPage extends StatefulWidget {
  final ProfileModel profile;

  const VaccinationPage({super.key, required this.profile});

  @override
  State<VaccinationPage> createState() => _VaccinationPageState();
}

class _VaccinationPageState extends State<VaccinationPage> {
  late Future<List<VaccinationModel>> _futureVaccinations;

  @override
  void initState() {
    super.initState();
    _futureVaccinations = _fetchVaccinations();
  }

  Future<List<VaccinationModel>> _fetchVaccinations() async {
    final response = await http.get(
      Uri.parse(
        ApiUrls.getListVaccinationByProfile(
          widget.profile.idProfile!,
          SharedPreferencesHelper().getString('identifiant')!,
        ),
      ),

      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = json.decode(utf8.decode(response.bodyBytes));

      final List data = body['data'] ?? [];

      return data.map((e) => VaccinationModel.fromJson(e)).toList();
    }

    throw Exception("Erreur lors du chargement");
  }

  @override
  Widget build(BuildContext context) {
    final isHuman = (widget.profile.profileType ?? 'human') == 'human';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAF7),
        elevation: 0,

        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
        ),

        titleSpacing: 0,

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Historique vaccinal",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 17.sp,
              ),
            ),

            Text(
              widget.profile.name ?? '',
              style: TextStyle(
                color: appColor,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ),

      body: FutureBuilder<List<VaccinationModel>>(
        future: _futureVaccinations,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final vaccinations = snapshot.data ?? [];

          return RefreshIndicator(
            color: appColor,

            onRefresh: () async {
              final future = _fetchVaccinations();

              setState(() {
                _futureVaccinations = future;
              });

              await future;
            },

            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),

              padding: EdgeInsets.all(5.w),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ───────────────── HEADER ─────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [appColor, appColor.withValues(alpha: 0.82)],
                      ),

                      borderRadius: BorderRadius.circular(3.w),
                    ),

                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,

                          backgroundColor: Colors.white.withValues(alpha: 0.18),

                          child: Icon(
                            isHuman ? Icons.person : Icons.pets,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),

                        Gap(4.w),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                widget.profile.name ?? 'Profil',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.sp,
                                ),
                              ),

                              Gap(0.6.h),

                              Text(
                                "${vaccinations.length} vaccination(s) enregistrée(s)",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Gap(3.h),

                  // ───────────────── EMPTY ─────────────────
                  if (vaccinations.isEmpty) _buildEmptyState(),

                  // ───────────────── LIST ─────────────────
                  if (vaccinations.isNotEmpty)
                    ...vaccinations.map((vaccination) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 2.h),

                        child: _VaccinationCard(vaccination: vaccination),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 50),

            Gap(2.h),

            Text(
              "Impossible de charger l'historique vaccinal.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),

            Gap(2.h),

            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _futureVaccinations = _fetchVaccinations();
                });
              },

              icon: const Icon(Icons.refresh),

              label: const Text("Réessayer"),

              style: ElevatedButton.styleFrom(
                backgroundColor: appColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.w),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Container(
            width: 24.w,
            height: 24.w,

            decoration: BoxDecoration(
              color: appColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),

            child: Icon(Icons.vaccines_outlined, color: appColor, size: 42),
          ),

          Gap(2.h),

          Text(
            "Aucune vaccination",
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
          ),

          Gap(1.h),

          Text(
            "Aucun vaccin n’a encore été enregistré pour ce profil.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              height: 1.5,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _VaccinationCard extends StatelessWidget {
  final VaccinationModel vaccination;

  const _VaccinationCard({required this.vaccination});

  @override
  Widget build(BuildContext context) {
    final hasReminder = vaccination.nextReminderDate != null;

    final isPublic = vaccination.centerType == 'public';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.w),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // ───────────────── TOP ─────────────────
          Padding(
            padding: EdgeInsets.all(4.w),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Container(
                  width: 14.w,
                  height: 14.w,

                  decoration: BoxDecoration(
                    color: appColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.w),
                  ),

                  child: Icon(
                    Icons.vaccines_outlined,
                    color: appColor,
                    size: 30,
                  ),
                ),

                Gap(4.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        vaccination.vaccineName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),

                      Gap(0.8.h),

                      if (vaccination.vaccine?.description != null)
                        Text(
                          vaccination.vaccine?.description ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            height: 1.5,
                            fontSize: 11.sp,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          // ───────────────── INFOS ─────────────────
          Padding(
            padding: EdgeInsets.all(4.w),

            child: Column(
              children: [
                _infoRow(
                  icon: Icons.event_outlined,
                  label: "Date vaccination",
                  value: _formatDate(vaccination.vaccinationDate),
                ),

                Gap(1.6.h),

                if (hasReminder)
                  _infoRow(
                    icon: Icons.notifications_active_outlined,
                    label: "Prochain rappel",
                    value: _formatDate(vaccination.nextReminderDate),
                    valueColor: const Color(0xFFE65100),
                  ),

                if (hasReminder) Gap(1.6.h),

                _infoRow(
                  icon: Icons.local_hospital_outlined,
                  label: "Centre",
                  value: vaccination.centerName ?? "Non renseigné",
                ),

                Gap(1.6.h),

                Row(
                  children: [
                    _badge(
                      icon:
                          isPublic
                              ? Icons.account_balance
                              : Icons.local_hospital,
                      label: isPublic ? "Public" : "Privé",
                      bg:
                          isPublic
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFEFF6FF),
                      fg:
                          isPublic
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF2563EB),
                    ),

                    Gap(2.w),

                    if (vaccination.certificateImage != null)
                      _badge(
                        icon: Icons.image_outlined,
                        label: "Certificat",
                        bg: const Color(0xFFFFF8E1),
                        fg: const Color(0xFFF57F17),
                      ),
                  ],
                ),

                if (vaccination.notes != null &&
                    vaccination.notes!.trim().isNotEmpty) ...[
                  Gap(2.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.5.w),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),

                      borderRadius: BorderRadius.circular(4.w),
                    ),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Icon(
                          Icons.notes_outlined,
                          color: Colors.grey.shade600,
                          size: 18,
                        ),

                        Gap(3.w),

                        Expanded(
                          child: Text(
                            vaccination.notes!,
                            style: TextStyle(
                              height: 1.5,
                              color: Colors.grey.shade700,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),

        Gap(3.w),

        Expanded(
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5.sp),
          ),
        ),

        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
            fontSize: 11.5.sp,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────

  Widget _badge({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),

      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),

          Gap(1.w),

          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────

class VaccinationModel {
  int? idVaccination;
  int? profileId;
  int? vaccineId;

  String? vaccineNameFree;
  String? vaccinationDate;
  String? nextReminderDate;

  String? centerType;
  String? centerName;

  String? certificateImage;
  String? notes;

  VaccineModel? vaccine;

  VaccinationModel({
    this.idVaccination,
    this.profileId,
    this.vaccineId,
    this.vaccineNameFree,
    this.vaccinationDate,
    this.nextReminderDate,
    this.centerType,
    this.centerName,
    this.certificateImage,
    this.notes,
    this.vaccine,
  });

  factory VaccinationModel.fromJson(Map<String, dynamic> json) {
    return VaccinationModel(
      idVaccination: json['id_vaccination'],
      profileId: json['profile_id'],
      vaccineId: json['vaccine_id'],

      vaccineNameFree: json['vaccine_name_free'],

      vaccinationDate: json['vaccination_date'],

      nextReminderDate: json['next_reminder_date'],

      centerType: json['center_type'],
      centerName: json['center_name'],

      certificateImage: json['certificate_image'],

      notes: json['notes'],

      vaccine:
          json['vaccine'] != null
              ? VaccineModel.fromJson(json['vaccine'])
              : null,
    );
  }

  String get vaccineName {
    if (vaccine?.name != null && vaccine!.name!.trim().isNotEmpty) {
      return vaccine!.name!;
    }

    return vaccineNameFree ?? 'Vaccin non renseigné';
  }
}

// ─────────────────────────────────────────────────────────────

class VaccineModel {
  int? idVaccine;

  String? name;
  String? description;
  String? recommendedAge;
  String? recallPeriod;

  VaccineModel({
    this.idVaccine,
    this.name,
    this.description,
    this.recommendedAge,
    this.recallPeriod,
  });

  factory VaccineModel.fromJson(Map<String, dynamic> json) {
    return VaccineModel(
      idVaccine: json['id_vaccine'],
      name: json['name'],
      description: json['description'],
      recommendedAge: json['recommended_age'],
      recallPeriod: json['recall_period'],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────

String _formatDate(String? iso) {
  if (iso == null || iso.isEmpty) {
    return '—';
  }

  try {
    final dt = DateTime.parse(iso);

    const months = [
      '',
      'Jan.',
      'Fév.',
      'Mars',
      'Avr.',
      'Mai',
      'Juin',
      'Juil.',
      'Août',
      'Sep.',
      'Oct.',
      'Nov.',
      'Déc.',
    ];

    return '${dt.day.toString().padLeft(2, '0')} '
        '${months[dt.month]} '
        '${dt.year}';
  } catch (_) {
    return iso;
  }
}
