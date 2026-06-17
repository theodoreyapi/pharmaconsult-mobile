import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pharmaconsult/core/constants/api_urls.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/models/suivisante/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<NotificationModel>> _futureNotifications;

  @override
  void initState() {
    super.initState();
    _futureNotifications = fetchNotifications();
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    final patientId = SharedPreferencesHelper().getString("patient_id") ?? "1";

    final response = await http.get(
      Uri.parse(ApiUrls.getNotification(patientId)),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded.isNotEmpty && decoded[0]['data'] != null) {
        final List<dynamic> data = decoded[0]['data'];
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      return [];
    } else {
      throw Exception('Erreur lors de la récupération des notifications');
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final DateTime dt = DateTime.parse(dateStr);
      final DateTime now = DateTime.now();
      final Duration diff = now.difference(dt);

      if (diff.inDays == 0) {
        return "Aujourd'hui à ${DateFormat('HH:mm').format(dt)}";
      } else if (diff.inDays == 1) {
        return "Hier à ${DateFormat('HH:mm').format(dt)}";
      } else {
        return DateFormat('dd/MM/yyyy HH:mm').format(dt);
      }
    } catch (_) {
      return dateStr;
    }
  }

  Map<String, dynamic> _getStyle(NotificationModel notif) {
    final type = notif.type?.toUpperCase();
    final notifType = notif.notificationType?.toUpperCase();

    if (type == 'MESURE' || (notif.message?.toLowerCase().contains('mesure') ?? false)) {
      return {
        'icon': Icons.timeline_rounded,
        'color': Color(0xFF27AE60),
        'bg': Color(0xFFE8F8F0),
        'title': 'Nouvelle mesure',
      };
    } else if (type == 'RENOUVELLEMENT' || (notif.message?.toLowerCase().contains('renouvellement') ?? false)) {
      return {
        'icon': Icons.access_time_rounded,
        'color': Color(0xFFF39C12),
        'bg': Color(0xFFFEF5E7),
        'title': 'Renouvellement',
      };
    } else if (type == 'CONSEIL') {
      return {
        'icon': Icons.info_outline_rounded,
        'color': Color(0xFF9B59B6),
        'bg': Color(0xFFF4ECF7),
        'title': 'Conseil santé',
      };
    } else if (type == 'CAMPAGNE') {
      return {
        'icon': Icons.campaign_outlined,
        'color': Color(0xFFE91E63),
        'bg': Color(0xFFFCE4EC),
        'title': 'Campagne',
      };
    } else if (notifType == 'RAPPEL' || type == 'PERSONNALISE') {
      return {
        'icon': Icons.notifications_active_outlined,
        'color': Color(0xFF4285F4),
        'bg': Color(0xFFE8F0FE),
        'title': 'Rappel',
      };
    } else {
      return {
        'icon': Icons.info_outline,
        'color': Colors.blueGrey,
        'bg': Colors.blueGrey.shade50,
        'title': 'Information',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appDegradOne,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Color(0xFF27AE60)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F3E32),
              ),
            ),
            FutureBuilder<List<NotificationModel>>(
              future: _futureNotifications,
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return Text(
                  count > 0 ? '$count nouvelle(s) notification(s)' : 'Toutes les notifications sont lues',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _futureNotifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucune notification pour le moment'));
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final style = _getStyle(notif);
              return _buildNotificationCard(
                title: style['title'],
                description: notif.message ?? '',
                time: _formatDate(notif.createdAt),
                icon: style['icon'],
                iconColor: style['color'],
                iconBg: style['bg'],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String description,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            time,
                            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                          ),
                          Text(
                            'Voir >',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF27AE60),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.delete_outline, size: 18, color: Colors.grey),
            label: Text('Supprimer', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
