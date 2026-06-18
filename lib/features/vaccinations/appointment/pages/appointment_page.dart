import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pharmaconsult/core/constants/constants.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/models/vaccines/appointment_model.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  late Future<List<AppointmentModel>> _futureAppointments;

  // Filtre par statut (null = tous)
  String? _filterStatus = 'all';

  static const _statusFilters = [
    'all',
    'pending',
    'confirmed',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _futureAppointments = _fetchAppointments();
  }

  Future<List<AppointmentModel>> _fetchAppointments() async {
    final response = await http.get(
      Uri.parse(
        ApiUrls.getCheckByAppointmentsUrl(
          SharedPreferencesHelper().getString('identifiant')!,
        ),
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((e) => AppointmentModel.fromJson(e)).toList();
    }
    throw Exception("Erreur de chargement (${response.statusCode})");
  }

  void _refresh() {
    setState(() {
      _futureAppointments = _fetchAppointments();
    });
  }

  List<AppointmentModel> _applyFilter(List<AppointmentModel> all) {
    if (_filterStatus == 'all') return all;

    return all.where((a) => a.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          "Mes Réservations",
          style: TextStyle(
            color: appColor2,
            fontWeight: FontWeight.bold,
            fontSize: 17.sp,
          ),
        ),
        iconTheme: IconThemeData(color: appColor2),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: "Actualiser",
          ),
        ],
      ),
      body: FutureBuilder<List<AppointmentModel>>(
        future: _futureAppointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final all = snapshot.data ?? [];
          final filtered = _applyFilter(all);

          return Column(
            children: [
              // ── Filtres de statut ───────────────────────────────────
              _buildStatusFilters(all),

              // ── Compteur ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      "${filtered.length} réservation(s)",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12.sp,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Liste ───────────────────────────────────────────────
              Expanded(
                child:
                    filtered.isEmpty
                        ? _buildEmpty(all.isEmpty)
                        : RefreshIndicator(
                          onRefresh: () async => _refresh(),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder:
                                (_, i) => _AppointmentCard(
                                  appointment: filtered[i],
                                  onTap: () => _showDetail(filtered[i]),
                                ),
                          ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Filtres ───────────────────────────────────────────────────────────────

  Widget _buildStatusFilters(List<AppointmentModel> all) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              _statusFilters.map((status) {
                final count =
                    status == 'all'
                        ? all.length
                        : all.where((a) => a.status == status).length;
                final isSelected = _filterStatus == status;
                final config = _StatusConfig.of(status);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filterStatus = status),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? config.color
                                : config.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            isSelected
                                ? null
                                : Border.all(
                                  color: config.color.withValues(alpha: 0.3),
                                ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            config.label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : config.color,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : config.color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  // ── État vide ─────────────────────────────────────────────────────────────

  Widget _buildEmpty(bool noData) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              noData ? Icons.calendar_today_outlined : Icons.filter_list_off,
              size: 56,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              noData
                  ? "Aucune réservation"
                  : "Aucune réservation pour ce statut",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              noData
                  ? "Vos réservations de vaccins apparaîtront ici"
                  : "Essayez un autre filtre",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Erreur ────────────────────────────────────────────────────────────────

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              "Impossible de charger vos réservations",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text("Réessayer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: appColor2,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Détail ────────────────────────────────────────────────────────────────

  void _showDetail(AppointmentModel appt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AppointmentDetailSheet(appointment: appt),
    );
  }
}

// ─── Carte de réservation ─────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onTap;

  const _AppointmentCard({required this.appointment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final config = _StatusConfig.of(appointment.status!);
    final dateFormatted = _formatDate(appointment.appointmentDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3.w),
          border: Border(left: BorderSide(color: config.color, width: 5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ligne 1 : référence + badge statut ──────────────────
            Row(
              children: [
                Text(
                  appointment.reference ?? '—',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                    fontFamily: 'monospace',
                  ),
                ),
                const Spacer(),
                _StatusBadge(config: config),
              ],
            ),
            const SizedBox(height: 8),

            // ── Nom du vaccin ────────────────────────────────────────
            Text(
              appointment.vaccineName ?? '—',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: appColor2,
              ),
            ),
            if (appointment.description?.isNotEmpty == true) ...[
              const SizedBox(height: 2),
              Text(
                appointment.description!,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),

            // ── Infos pharmacie + date ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _infoChip(
                    icon: Icons.local_pharmacy_outlined,
                    text: appointment.pharmacyName ?? '—',
                    color: appColor2,
                  ),
                ),
                const SizedBox(width: 8),
                _infoChip(
                  icon: Icons.calendar_today_outlined,
                  text: dateFormatted,
                  color: Colors.grey.shade700,
                ),
              ],
            ),

            // ── Notes ────────────────────────────────────────────────
            if (appointment.notes?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.notes, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      appointment.notes!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Feuille de détail ────────────────────────────────────────────────────────

class _AppointmentDetailSheet extends StatelessWidget {
  final AppointmentModel appointment;

  const _AppointmentDetailSheet({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final config = _StatusConfig.of(appointment.status!);
    final dateFormatted = _formatDate(appointment.appointmentDate);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de drag
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── En-tête ──────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.vaccineName ?? '—',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: appColor2,
                        ),
                      ),
                      if (appointment.description?.isNotEmpty == true)
                        Text(
                          appointment.description!,
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StatusBadge(config: config, large: true),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              appointment.reference ?? '',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade400,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 16),

            // ── Info Importante ──────────────────────────────────────
            if (appointment.importantInfo?.isNotEmpty == true) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        appointment.importantInfo!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Section Patient ──────────────────────────────────────
            _sectionTitle("Patient"),
            const SizedBox(height: 8),
            _detailRow(
              Icons.person_outline,
              "Nom",
              appointment.patientName?.isNotEmpty == true
                  ? appointment.patientName!
                  : "Non renseigné",
            ),
            _detailRow(
              Icons.phone_outlined,
              "Téléphone",
              appointment.patientPhone ?? '—',
            ),
            if (appointment.patientEmail?.isNotEmpty == true)
              _detailRow(
                Icons.email_outlined,
                "Email",
                appointment.patientEmail!,
              ),
            const SizedBox(height: 14),

            // ── Section Rendez-vous ──────────────────────────────────
            _sectionTitle("Rendez-vous"),
            const SizedBox(height: 8),
            _detailRow(Icons.calendar_today_outlined, "Date", dateFormatted),
            if (appointment.notes?.isNotEmpty == true)
              _detailRow(Icons.notes, "Notes", appointment.notes!),
            const SizedBox(height: 14),

            // ── Section Pharmacie ────────────────────────────────────
            _sectionTitle("Pharmacie"),
            const SizedBox(height: 8),
            _detailRow(
              Icons.local_pharmacy_outlined,
              "Nom",
              appointment.pharmacyName ?? '—',
            ),
            if (appointment.address?.isNotEmpty == true)
              _detailRow(
                Icons.location_on_outlined,
                "Adresse",
                appointment.address!,
              ),
            if (appointment.openingHours?.isNotEmpty == true || appointment.closingHours?.isNotEmpty == true)
              _detailRow(
                Icons.access_time_outlined,
                "Horaires",
                "${appointment.openingHours ?? '—'} - ${appointment.closingHours ?? '—'}",
              ),

            // Boutons d'appel
            if (appointment.phoneNumber?.isNotEmpty == true ||
                appointment.whatsAppPhoneNumber?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (appointment.phoneNumber?.isNotEmpty == true)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _call(appointment.phoneNumber!),
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text("Appeler"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: appColor2,
                          side: BorderSide(color: appColor2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  if (appointment.phoneNumber?.isNotEmpty == true &&
                      appointment.whatsAppPhoneNumber?.isNotEmpty == true)
                    const SizedBox(width: 8),
                  if (appointment.whatsAppPhoneNumber?.isNotEmpty == true)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            () => _whatsapp(appointment.whatsAppPhoneNumber!),
                        icon: const Icon(Icons.chat, size: 16),
                        label: const Text("WhatsApp"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // ── Section Prix ─────────────────────────────────────────
            _sectionTitle("Prix estimatifs"),
            const SizedBox(height: 10),
            _priceBox(
              "Centre de santé public",
              _formatPublicPrice(appointment),
              const Color(0xFFE6FFFA),
              Colors.green.shade700,
              description: "Prix régulé en centre public.",
            ),
            const SizedBox(height: 12),
            
            if (appointment.equivalents != null && appointment.equivalents!.isNotEmpty) ...[
               Text(
                "En pharmacie privée",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ...appointment.equivalents!.map((eq) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _priceBox(
                  eq.name ?? 'Équivalent',
                  formatPrice(eq.price, currency: appointment.currency ?? 'FCFA'),
                  const Color(0xFFEBF4FF),
                  Colors.blue.shade700,
                  description: eq.description,
                ),
              )).toList(),
            ] else ...[
               _priceBox(
                "Pharmacie privée",
                "Non renseigné",
                const Color(0xFFEBF4FF),
                Colors.blue.shade700,
                description: "Aucun équivalent répertorié pour ce vaccin.",
              ),
            ],

            // ── Timestamps ───────────────────────────────────────────
            const SizedBox(height: 20),
            if (appointment.confirmedAt?.isNotEmpty == true)
              _detailRow(
                Icons.check_circle_outline,
                "Confirmé le",
                _formatDate(appointment.confirmedAt),
              ),
            if (appointment.cancelledAt?.isNotEmpty == true)
              _detailRow(
                Icons.cancel_outlined,
                "Annulé le",
                _formatDate(appointment.cancelledAt),
                color: Colors.red,
              ),
            _detailRow(
              Icons.schedule,
              "Créé le",
              _formatDate(appointment.createdAt),
              color: Colors.grey.shade500,
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers UI ────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
        color: appColor2,
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey.shade500),
          const SizedBox(width: 8),
          Text(
            "$label : ",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, color: color ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceBox(String label, String price, Color bgColor, Color textColor, {String? description}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          if (description?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: TextStyle(fontSize: 10.5.sp, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  // ── Actions téléphone ─────────────────────────────────────────────────────

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // ── Formatage prix ────────────────────────────────────────────────────────

  String formatPrice(dynamic value, {String currency = 'FCFA'}) {
    if (value == null) return '0 $currency';

    final number = double.tryParse(value.toString()) ?? 0;
    if (number == 0) return 'GRATUIT';

    final formatter = NumberFormat('#,##0', 'fr_FR');

    return '${formatter.format(number)} $currency';
  }

  String _formatPublicPrice(AppointmentModel a) {
    final p = a.publicPrice;

    if (p == null || p == '0' || p == '0.00' || p == '0.0') {
      return 'GRATUIT';
    }

    return formatPrice(p, currency: a.currency ?? 'FCFA');
  }
}

// ─── Badge de statut ──────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final _StatusConfig config;
  final bool large;

  const _StatusBadge({required this.config, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 5 : 3,
      ),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: large ? 14 : 11, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              fontSize: large ? 12.sp : 10.sp,
              fontWeight: FontWeight.bold,
              color: config.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Configuration des statuts ────────────────────────────────────────────────

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;

  _StatusConfig({required this.label, required this.color, required this.icon});

  static _StatusConfig of(String status) {
    switch (status) {
      case 'all':
        return _StatusConfig(
          label: 'Tous',
          color: Colors.grey,
          icon: Icons.list_alt,
        );
      case 'confirmed':
        return _StatusConfig(
          label: 'Confirmé',
          color: const Color(0xFF2E7D32),
          icon: Icons.check_circle_outline,
        );
      case 'completed':
        return _StatusConfig(
          label: 'Terminé',
          color: const Color(0xFF1565C0),
          icon: Icons.done_all,
        );
      case 'cancelled':
        return _StatusConfig(
          label: 'Annulé',
          color: const Color(0xFFC62828),
          icon: Icons.cancel_outlined,
        );
      case 'pending':
      default:
        return _StatusConfig(
          label: 'En attente',
          color: const Color(0xFFE65100),
          icon: Icons.hourglass_empty,
        );
    }
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return '—';
  try {
    final dt = DateTime.parse(raw);
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  } catch (_) {
    return raw;
  }
}
