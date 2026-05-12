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
  AppointmentPage({super.key});

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
      backgroundColor: Color(0xFFF1F5F1),
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
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: "Actualiser",
          ),
        ],
      ),
      body: FutureBuilder<List<AppointmentModel>>(
        future: _futureAppointments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12),
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  padding: EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filterStatus = status),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
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
                          SizedBox(width: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
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
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              noData ? Icons.calendar_today_outlined : Icons.filter_list_off,
              size: 56,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16),
            Text(
              noData
                  ? "Aucune réservation"
                  : "Aucune réservation pour ce statut",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              noData
                  ? "Vos réservations de vaccins apparaîtront ici"
                  : "Essayez un autre filtre",
              style: TextStyle(color: Colors.grey, fontSize: 13),
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
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 56, color: Colors.grey.shade400),
            SizedBox(height: 12),
            Text(
              "Impossible de charger vos réservations",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: Icon(Icons.refresh),
              label: Text("Réessayer"),
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

  _AppointmentCard({required this.appointment, required this.onTap});

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
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(14),
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
                Spacer(),
                _StatusBadge(config: config),
              ],
            ),
            SizedBox(height: 8),

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
              SizedBox(height: 2),
              Text(
                appointment.description!,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 10),

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
                SizedBox(width: 8),
                _infoChip(
                  icon: Icons.calendar_today_outlined,
                  text: dateFormatted,
                  color: Colors.grey.shade700,
                ),
              ],
            ),

            // ── Notes ────────────────────────────────────────────────
            if (appointment.notes?.isNotEmpty == true) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.notes, size: 14, color: Colors.grey.shade400),
                  SizedBox(width: 4),
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
        SizedBox(width: 4),
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

  _AppointmentDetailSheet({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final config = _StatusConfig.of(appointment.status!);
    final dateFormatted = _formatDate(appointment.appointmentDate);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de drag
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20),
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
                SizedBox(width: 12),
                _StatusBadge(config: config, large: true),
              ],
            ),
            SizedBox(height: 4),
            Text(
              appointment.reference ?? '',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade400,
                fontFamily: 'monospace',
              ),
            ),
            SizedBox(height: 16),

            // ── Section Patient ──────────────────────────────────────
            _sectionTitle("Patient"),
            SizedBox(height: 8),
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
            SizedBox(height: 14),

            // ── Section Rendez-vous ──────────────────────────────────
            _sectionTitle("Rendez-vous"),
            SizedBox(height: 8),
            _detailRow(Icons.calendar_today_outlined, "Date", dateFormatted),
            if (appointment.notes?.isNotEmpty == true)
              _detailRow(Icons.notes, "Notes", appointment.notes!),
            SizedBox(height: 14),

            // ── Section Pharmacie ────────────────────────────────────
            _sectionTitle("Pharmacie"),
            SizedBox(height: 8),
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
            if (appointment.openingHours?.isNotEmpty == true)
              _detailRow(
                Icons.access_time_outlined,
                "Horaires",
                appointment.openingHours!,
              ),

            // Boutons d'appel
            if (appointment.phoneNumber?.isNotEmpty == true ||
                appointment.whatsAppPhoneNumber?.isNotEmpty == true) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  if (appointment.phoneNumber?.isNotEmpty == true)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _call(appointment.phoneNumber!),
                        icon: Icon(Icons.phone, size: 16),
                        label: Text("Appeler"),
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
                    SizedBox(width: 8),
                  if (appointment.whatsAppPhoneNumber?.isNotEmpty == true)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            () => _whatsapp(appointment.whatsAppPhoneNumber!),
                        icon: Icon(Icons.chat, size: 16),
                        label: Text("WhatsApp"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF25D366),
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

            SizedBox(height: 14),

            // ── Section Prix ─────────────────────────────────────────
            _sectionTitle("Prix estimatifs"),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _priceBox(
                    "Centre Public",
                    _formatPublicPrice(appointment),
                    Color(0xFFE6FFFA),
                    Colors.green,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _priceBox(
                    "Centre Privé",
                    _formatPrivatePrice(appointment),
                    Color(0xFFEBF4FF),
                    Colors.blue,
                  ),
                ),
              ],
            ),

            // ── Timestamps ───────────────────────────────────────────
            SizedBox(height: 14),
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
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey.shade500),
          SizedBox(width: 8),
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

  Widget _priceBox(String label, String price, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 2),
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

    final formatter = NumberFormat('#,##0', 'fr_FR');

    return '${formatter.format(number)} $currency';
  }

  String _formatPublicPrice(AppointmentModel a) {
    final p = a.publicPrice;

    if (p == null || p == '0' || p == '0.00') {
      return 'GRATUIT';
    }

    return formatPrice(p, currency: a.currency ?? 'FCFA');
  }

  String _formatPrivatePrice(AppointmentModel a) {
    final min = a.privatePriceMin;
    final max = a.privatePriceMax;
    final cur = a.currency ?? 'FCFA';

    if (min == null && max == null) return 'N/A';

    if (min == null) {
      return formatPrice(max, currency: cur);
    }

    if (max == null) {
      return formatPrice(min, currency: cur);
    }

    return '${formatPrice(min, currency: cur)} - ${formatPrice(max, currency: cur)}';
  }
}

// ─── Badge de statut ──────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final _StatusConfig config;
  final bool large;

  _StatusBadge({required this.config, this.large = false});

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
          SizedBox(width: 4),
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
          color: Color(0xFF2E7D32),
          icon: Icons.check_circle_outline,
        );
      case 'completed':
        return _StatusConfig(
          label: 'Terminé',
          color: Color(0xFF1565C0),
          icon: Icons.done_all,
        );
      case 'cancelled':
        return _StatusConfig(
          label: 'Annulé',
          color: Color(0xFFC62828),
          icon: Icons.cancel_outlined,
        );
      case 'pending':
      default:
        return _StatusConfig(
          label: 'En attente',
          color: Color(0xFFE65100),
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
