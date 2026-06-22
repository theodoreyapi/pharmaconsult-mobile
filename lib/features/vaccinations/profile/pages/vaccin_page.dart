import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pharmaconsult/core/constants/constants.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/features/vaccinations/profile/profile.dart';
import 'package:pharmaconsult/models/vaccines/profile_model.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class VaccinPage extends StatefulWidget {
  const VaccinPage({super.key});

  @override
  State<VaccinPage> createState() => _VaccinPageState();
}

class _VaccinPageState extends State<VaccinPage> {
  List<ProfileModel> _allProfile = [];
  List<ProfileModel> _filteredProfiles = [];

  late Future<List<ProfileModel>> _futureProfile;

  @override
  void initState() {
    super.initState();
    _futureProfile = _fetchInitialData();
  }

  Future<List<ProfileModel>> _fetchInitialData() async {
    final response = await http.get(
      Uri.parse(
        ApiUrls.getListProfile(
          SharedPreferencesHelper().getString("identifiant")!,
        ),
      ),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      _allProfile = List<ProfileModel>.from(
        data.map((e) => ProfileModel.fromJson(e)),
      );
      _filteredProfiles = _allProfile;
      return _allProfile;
    }
    throw Exception("Erreur de chargement");
  }

  void _refresh() {
    setState(() {
      _futureProfile = _fetchInitialData();
    });
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleProfileTap(ProfileModel profile) async {
    final bool isPaid = profile.hasActiveSubscription ?? false;

    if (isPaid) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileDetailPage(profile: profile),
        ),
      );
    } else {
      _showReabonnementDialog(profile);
    }
  }

  void _showReabonnementDialog(ProfileModel profile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Abonnement inactif'),
          ],
        ),
        content: Text(
          'L\'abonnement pour le profil de ${profile.name} est inactif ou a expiré. '
          'Souhaitez-vous vous réabonner pour accéder aux détails ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('NON', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _initiateRenewal(profile);
            },
            child: const Text('OUI'),
          ),
        ],
      ),
    );
  }

  Future<void> _initiateRenewal(ProfileModel profile) async {
    try {
      final identifiant = SharedPreferencesHelper().getString("identifiant")!;
      final response = await http.get(
        Uri.parse(ApiUrls.getAbonnementByProfileUser(profile.idProfile!, identifiant)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final url = data['rechargement_url'];
        if (url != null) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          _showSnack('URL de paiement introuvable.', isError: true);
        }
      } else {
        _showSnack('Erreur lors de l\'initiation du paiement.', isError: true);
      }
    } catch (e) {
      debugPrint("Error renewal: $e");
      _showSnack('Erreur réseau. Veuillez réessayer.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profils Santé',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D5A27),
              ),
            ),
            Gap(2.w),

            // Bannière d'information améliorée
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E7),
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: Color(0xFFFBC02D), width: 3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFFFBC02D),
                    size: 14.sp,
                  ),
                  Gap(2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Information importante',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF856404),
                            fontSize: 14.sp,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Chaque profil santé est facturé. Un abonnement '
                          'mensuel vous permet de suivre la santé vaccinale '
                          'de chaque membre enregistré (humain ou animal).',
                          style: TextStyle(
                            color: const Color(0xFF856404),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Gap(1.h),
            // Bouton Créer avec dégradé
            Container(
              width: double.infinity,
              height: 12.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.w),
                color: appColor,
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await showBarModalBottomSheet(
                    isDismissible: false,
                    enableDrag: false,
                    expand: true,
                    context: context,
                    builder: (context) => const NewProfileSheet(),
                  );
                  if (result == true) _refresh();
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Créer un nouveau profil santé',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
              ),
            ),
            Gap(1.h),
            Expanded(
              child: FutureBuilder<List<ProfileModel>>(
                future: _futureProfile,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (snapshot.hasError) return _buildErrorState();

                  return buildProfileListView(
                    profiles: snapshot.data ?? [],
                    context: context,
                    onEdit: (profile) async {
                      final result = await showBarModalBottomSheet(
                        isDismissible: false,
                        enableDrag: false,
                        expand: true,
                        context: context,
                        builder: (context) => NewProfileSheet(profile: profile),
                      );
                      if (result == true) _refresh();
                    },
                    onTap: (profile) => _handleProfileTap(profile),
                    onDelete: (ctx, profile) async {
                      try {
                        final response = await http.delete(
                          Uri.parse(ApiUrls.deleteProfile(profile.idProfile!)),
                          headers: {'Accept': 'application/json'},
                        );
                        if (response.statusCode == 200) {
                          _showSnack('Profil supprimé avec succès.');
                          _refresh();
                        } else {
                          _showSnack(
                            'Erreur lors de la suppression.',
                            isError: true,
                          );
                        }
                      } catch (_) {
                        _showSnack('Erreur réseau.', isError: true);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: appColor,
        onPressed: _refresh,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget buildProfileListView({
    required List<ProfileModel> profiles,
    required void Function(ProfileModel) onEdit,
    required void Function(ProfileModel) onTap,
    required void Function(BuildContext, ProfileModel) onDelete,
    required BuildContext context,
  }) {
    if (profiles.isEmpty) return buildEmptyState();

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: profiles.length,
      separatorBuilder: (_, __) => Gap(1.6.h),
      itemBuilder:
          (ctx, i) => ProfileCard(
            profile: profiles[i],
            onEdit: () => onEdit(profiles[i]),
            onTap: () => onTap(profiles[i]),
            onDelete: () => showDeleteConfirmation(ctx, profiles[i], onDelete),
          ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "Une erreur est survenue lors de la récupération des profils."
          "\n\nContactez le support si cela persiste.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}

/// "1993-11-09T00:00:00.000000Z" → "09 Nov. 1993"
String _formatDate(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  try {
    final dt = DateTime.parse(iso).toLocal();
    const months = [
      '',
      'Jan.',
      'Fév.',
      'Mar.',
      'Avr.',
      'Mai',
      'Juin',
      'Juil.',
      'Aoû.',
      'Sep.',
      'Oct.',
      'Nov.',
      'Déc.',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month]} ${dt.year}';
  } catch (_) {
    return iso;
  }
}

/// Calcule l'âge en années depuis une date ISO
int _calcAge(String? iso) {
  if (iso == null || iso.isEmpty) return 0;
  try {
    final birth = DateTime.parse(iso).toLocal();
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  } catch (_) {
    return 0;
  }
}

/// Initiales pour l'avatar (max 2 caractères)
String _initials(String? name) {
  if (name == null || name.trim().isEmpty) return '?';
  final parts = name.trim().split(' ');
  if (parts.length >= 2) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  return name[0].toUpperCase();
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar couleur basé sur l'initiale
// ─────────────────────────────────────────────────────────────────────────────

Color _avatarColor(String? name) {
  const palette = [
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFF6A1B9A),
    Color(0xFFE65100),
    Color(0xFF00695C),
    Color(0xFFC62828),
    Color(0xFF4527A0),
    Color(0xFF283593),
  ];
  if (name == null || name.isEmpty) return palette[0];
  return palette[name.codeUnitAt(0) % palette.length];
}

// ─────────────────────────────────────────────────────────────────────────────
// Liste vide
// ─────────────────────────────────────────────────────────────────────────────

Widget buildEmptyState() {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 6.w),
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4.w),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: const Color(0xFFF0FFF4),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_add_alt_1_outlined,
            size: 10.w,
            color: appColor2,
          ),
        ),
        Gap(2.h),
        Text(
          'Aucun profil santé',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Gap(0.8.h),
        Text(
          'Créez votre premier profil pour\ncommencer à suivre vos vaccinations',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black45, fontSize: 13.sp, height: 1.5),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte de profil — version premium
// ─────────────────────────────────────────────────────────────────────────────

class ProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHuman = (profile.profileType ?? 'human') == 'human';
    final age = _calcAge(profile.birthDate);
    final birthFmt = _formatDate(profile.birthDate);
    final avatarClr = _avatarColor(profile.name);
    final sub = profile.activeSubscription;
    final subPaid = profile.hasActiveSubscription;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête avec avatar + nom + actions ─────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 3.5.w, 3.w, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  _Avatar(
                    initials: _initials(profile.name),
                    color: avatarClr,
                    isAnimal: !isHuman,
                    animalType: profile.animalType,
                  ),
                  Gap(3.w),

                  // Nom + badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gap(0.5.w),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                profile.name ?? '—',
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A2E),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Gap(2.w),
                            _TypeBadge(
                              isHuman: isHuman,
                              animalType: profile.animalType,
                            ),
                          ],
                        ),
                        Gap(1.w),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (isHuman && profile.relation?.isNotEmpty == true)
                              _Chip(
                                label: profile.relation!,
                                bg: const Color(0xFFF5F3FF),
                                fg: const Color(0xFF7C3AED),
                                icon: Icons.people_outline,
                              ),
                            if (profile.gender?.isNotEmpty == true)
                              _Chip(
                                label:
                                    profile.gender == 'masculin'
                                        ? '♂ Masculin'
                                        : '♀ Féminin',
                                bg:
                                    profile.gender == 'masculin'
                                        ? const Color(0xFFEFF6FF)
                                        : const Color(0xFFFDF2F8),
                                fg:
                                    profile.gender == 'masculin'
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFFDB2777),
                              ),
                            if (profile.isFrequentTraveler!)
                              _Chip(
                                label: 'Voyageur',
                                bg: const Color(0xFFFFFBEB),
                                fg: const Color(0xFFD97706),
                                icon: Icons.flight_outlined,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Boutons modifier / supprimer
                  Column(
                    children: [
                      _ActionBtn(
                        label: 'Modifier',
                        icon: Icons.edit_outlined,
                        bg: const Color(0xFFEFF6FF),
                        fg: const Color(0xFF2563EB),
                        onTap: onEdit,
                      ),
                      Gap(1.5.w),
                      _ActionBtn(
                        label: 'Supprimer',
                        icon: Icons.delete_outline,
                        bg: const Color(0xFFFEF2F2),
                        fg: const Color(0xFFDC2626),
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Ligne de séparation ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.5.w),
              child: Divider(height: 1, color: Colors.grey.shade100),
            ),

            // ── Infos : naissance + vaccins ──────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  _InfoTile(
                    icon: Icons.cake_outlined,
                    label: 'Naissance',
                    value: '$birthFmt${age > 0 ? '  ($age ans)' : ''}',
                  ),
                  _VerticalDivider(),
                  _InfoTile(
                    icon: Icons.vaccines_outlined,
                    label: 'Vaccinations',
                    value:
                        '${profile.vaccinationsCount} '
                        'enregistrée${profile.vaccinationsCount! > 1 ? 's' : ''}',
                    valueColor:
                        profile.vaccinationsCount! > 0
                            ? const Color(0xFF2E7D32)
                            : Colors.grey.shade500,
                  ),
                ],
              ),
            ),

            // ── Bandeau abonnement ───────────────────────────────────────
            Gap(2.5.w),
            _SubscriptionBanner(subscription: sub, isPaid: subPaid!),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String initials;
  final Color color;
  final bool isAnimal;
  final String? animalType;

  const _Avatar({
    required this.initials,
    required this.color,
    this.isAnimal = false,
    this.animalType,
  });

  IconData get _animalIcon {
    switch (animalType?.toLowerCase()) {
      case 'chien':
        return Icons.pets;
      case 'chat':
        return Icons.pest_control;
      case 'oiseau':
        return Icons.air;
      default:
        return Icons.cruelty_free;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.w,
      height: 13.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child:
            isAnimal
                ? Icon(_animalIcon, color: Colors.white, size: 6.w)
                : Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge type (Humain / Animal)
// ─────────────────────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final bool isHuman;
  final String? animalType;

  const _TypeBadge({required this.isHuman, this.animalType});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isHuman ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isHuman ? Icons.person_outline : Icons.pets,
            size: 11,
            color: isHuman ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
          ),
          const SizedBox(width: 3),
          Text(
            isHuman ? 'Humain' : (animalType ?? 'Animal'),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color:
                  isHuman ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip générique
// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;

  const _Chip({
    required this.label,
    required this.bg,
    required this.fg,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bouton d'action (Modifier / Supprimer)
// ─────────────────────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 22.w,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tuile d'info (icône + label + valeur)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade400),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 6.w,
      margin: EdgeInsets.symmetric(horizontal: 3.w),
      color: Colors.grey.shade200,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bandeau abonnement (en bas de la carte)
// ─────────────────────────────────────────────────────────────────────────────

class _SubscriptionBanner extends StatelessWidget {
  final ActiveSubscription? subscription;
  final bool isPaid;

  const _SubscriptionBanner({this.subscription, required this.isPaid});

  @override
  Widget build(BuildContext context) {
    // Couleurs selon le statut
    final Color bg;
    final Color fg;
    final IconData icon;
    final String label;
    final String? detail;

    if (!isPaid) {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFDC2626);
      icon = Icons.warning_amber_rounded;
      label = 'Abonnement inactif';
      detail = 'Régularisez pour accéder à toutes les fonctionnalités';
    } else if (subscription?.isGracious == true) {
      bg = const Color(0xFFF0FDF4);
      fg = const Color(0xFF16A34A);
      icon = Icons.card_giftcard_outlined;
      label = 'Offert — Premier profil gratuit';
      final days = subscription?.daysRemaining ?? 0;
      final exp = _formatDate(subscription?.endDate);
      detail = 'Expire le $exp ($days j. restants)';
    } else {
      bg = const Color(0xFFF0FDF4);
      fg = const Color(0xFF16A34A);
      icon = Icons.verified_outlined;
      final amount = subscription?.amount?.toStringAsFixed(0) ?? '2000';
      label = 'Abonné · $amount ${subscription?.currency ?? 'FCFA'}/an';
      final days = subscription?.daysRemaining ?? 0;
      final exp = _formatDate(subscription?.endDate);
      detail = 'Expire le $exp ($days j. restants)';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.5.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: fg.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog de suppression
// ─────────────────────────────────────────────────────────────────────────────

void showDeleteConfirmation(
  BuildContext context,
  ProfileModel profile,
  void Function(BuildContext, ProfileModel) onConfirm,
) {
  showDialog(
    context: context,
    builder:
        (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.w),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_forever_outlined,
                    color: Color(0xFFDC2626),
                    size: 36,
                  ),
                ),
                Gap(2.h),

                Text(
                  'Supprimer le profil ?',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B4332),
                  ),
                ),
                Gap(1.h),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13.sp,
                      height: 1.6,
                    ),
                    children: [
                      const TextSpan(
                        text: 'Voulez-vous vraiment supprimer le profil de ',
                      ),
                      TextSpan(
                        text: '${profile.name} ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const TextSpan(
                        text:
                            '?\nCette action est irréversible et supprimera tout son historique vaccinal.',
                      ),
                    ],
                  ),
                ),
                Gap(3.h),

                Row(
                  children: [
                    // Annuler
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.w),
                          ),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Gap(3.w),

                    // Supprimer
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onConfirm(context, profile);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.w),
                          ),
                        ),
                        child: const Text(
                          'Supprimer',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
  );
}
