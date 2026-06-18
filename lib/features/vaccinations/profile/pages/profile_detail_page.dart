import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/features/vaccinations/profile/profile.dart';
import 'package:pharmaconsult/models/vaccines/profile_model.dart';
import 'package:sizer/sizer.dart';

class ProfileDetailPage extends StatefulWidget {
  final ProfileModel profile;

  const ProfileDetailPage({super.key, required this.profile});

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  @override
  Widget build(BuildContext context) {
    final isHuman = (widget.profile.profileType ?? 'human') == 'human';
    final age = _calcAge(widget.profile.birthDate);
    final birthFmt = _formatDate(widget.profile.birthDate);
    final avatarClr = _avatarColor(widget.profile.name);
    final sub = widget.profile.activeSubscription;
    final isPaid = widget.profile.hasActiveSubscription == true;
    final vaccinsCount = widget.profile.vaccinationsCount ?? 0;
    final daysRemaining = sub?.daysRemaining ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.w),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back_ios_new, size: 4.w),
                    ),
                  ),

                  Gap(4.w),

                  Expanded(
                    child: Text(
                      'Détails du profil',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.5.w,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isPaid
                              ? const Color(0xFFF0FDF4)
                              : const Color(0xFFFEF2F2),

                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPaid
                              ? Icons.verified_outlined
                              : Icons.warning_amber_rounded,

                          size: 14,

                          color:
                              isPaid
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                        ),

                        const SizedBox(width: 4),

                        Text(
                          isPaid ? 'Actif' : 'Inactif',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                            color:
                                isPaid
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),

                child: Column(
                  children: [
                    /// CARD PROFIL
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(5.w),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.w),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          /// AVATAR
                          Container(
                            width: 18.w,
                            height: 18.w,

                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  avatarClr,
                                  avatarClr.withValues(alpha: 0.7),
                                ],
                              ),

                              shape: BoxShape.circle,
                            ),

                            child: Center(
                              child:
                                  isHuman
                                      ? Text(
                                        _initials(widget.profile.name),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.sp,
                                        ),
                                      )
                                      : Icon(
                                        Icons.pets,
                                        color: Colors.white,
                                        size: 10.w,
                                      ),
                            ),
                          ),

                          Gap(1.h),

                          /// NOM
                          Text(
                            widget.profile.name ?? '—',
                            textAlign: TextAlign.center,

                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),

                          Gap(1.h),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,

                            children: [
                              _buildBadge(
                                isHuman
                                    ? 'Humain'
                                    : (widget.profile.animalType ?? 'Animal'),

                                isHuman ? Color(0xFFE8F5E9) : Color(0xFFFFF3E0),

                                isHuman ? Color(0xFF2E7D32) : Color(0xFFE65100),
                              ),

                              if (widget.profile.gender?.isNotEmpty == true)
                                _buildBadge(
                                  widget.profile.gender == 'masculin'
                                      ? '♂ Masculin'
                                      : '♀ Féminin',

                                  widget.profile.gender == 'masculin'
                                      ? Color(0xFFEFF6FF)
                                      : Color(0xFFFDF2F8),

                                  widget.profile.gender == 'masculin'
                                      ? Color(0xFF2563EB)
                                      : Color(0xFFDB2777),
                                ),

                              if (widget.profile.relation?.isNotEmpty == true)
                                _buildBadge(
                                  widget.profile.relation!,
                                  Color(0xFFF5F3FF),
                                  Color(0xFF7C3AED),
                                ),
                            ],
                          ),

                          Gap(3.h),

                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.vaccines_outlined,
                                  title: 'Vaccins',
                                  value: '$vaccinsCount',
                                  color: Color(0xFF2E7D32),
                                ),
                              ),

                              Gap(3.w),

                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.calendar_month_outlined,
                                  title: 'Restant',
                                  value: '$daysRemaining j',
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Gap(2.h),

                    /// INFORMATIONS
                    _buildSection(
                      title: 'Informations personnelles',
                      icon: Icons.person_outline,
                      children: [
                        _buildDataRow('Date de naissance', birthFmt),
                        _buildDataRow('Âge', '$age ans'),
                        _buildDataRow('Genre', widget.profile.gender ?? '—'),
                        _buildDataRow(
                          'Voyageur fréquent',
                          widget.profile.isFrequentTraveler == true
                              ? 'Oui'
                              : 'Non',
                        ),
                      ],
                    ),
                    Gap(2.h),

                    /// ABONNEMENT
                    _buildSection(
                      title: 'Abonnement',
                      icon: Icons.credit_card_outlined,
                      children: [
                        _buildDataRow(
                          'Statut',
                          isPaid ? 'Actif' : 'Inactif',
                          valueColor:
                              isPaid
                                  ? Color(0xFF16A34A)
                                  : Color(0xFFDC2626),
                        ),

                        _buildDataRow(
                          'Montant',
                          '${sub?.amount?.toStringAsFixed(0) ?? '0'} ${sub?.currency ?? 'FCFA'}',
                        ),

                        _buildDataRow('Expire le', _formatDate(sub?.endDate)),

                        _buildDataRow(
                          'Référence',
                          sub?.paymentReference ?? '—',
                        ),
                      ],
                    ),

                    Gap(2.h),
                    _buildBillingSection(),
                    Gap(2.h),

                    /// ACTIONS
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AddVaccin(profile: widget.profile),
                                ),
                              );
                            },
                            icon: Icon(Icons.add),
                            label: Text('Ajouter vaccin'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 4.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3.w),
                              ),
                            ),
                          ),
                        ),

                        Gap(3.w),

                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => VaccinationPage(
                                        profile: widget.profile,
                                      ),
                                ),
                              );
                            },

                            icon: Icon(Icons.show_chart_outlined),

                            label: Text('Historique'),

                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black87,

                              padding: EdgeInsets.symmetric(vertical: 4.w),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3.w),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Gap(3.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: appColor),
              Gap(2.w),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
              ),
            ],
          ),
          Divider(height: 4.h, color: Colors.grey.shade100),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor,
                fontSize: 12.5.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          Gap(1.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Gap(0.5.h),
          Text(title, style: TextStyle(color: Colors.black54, fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildBillingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1E4FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.credit_card_outlined,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Facturation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A237E),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tarif par profil :',
                style: TextStyle(
                  color: const Color(0xFF1A237E),
                  fontSize: 13.sp,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '1 000 FCFA / an',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A237E),
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ce profil est facture annuellement a hauteur de 1000 FCFA par '
            'profil dans le cadre de votre abonnement.',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blue.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

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
