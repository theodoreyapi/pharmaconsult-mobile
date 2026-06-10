import 'package:flutter/material.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:sizer/sizer.dart';

class TraitementPage extends StatefulWidget {
  const TraitementPage({super.key});

  @override
  State<TraitementPage> createState() => _TraitementPageState();
}

class _TraitementPageState extends State<TraitementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appDegradOne,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mes traitements',
              style: TextStyle(
                color: Color(0xFF0F3E32),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Suivi de vos médicaments',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 100, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Hypertension artérielle'),
                MedicationCard(
                  name: 'Amlodipine 5mg',
                  dosage: '1 comprimé le matin',
                  deliveryDate: '15 févr.',
                  delayDays: 84,
                  status: 'À jour',
                  statusColor: Color(0xFF27AE60),
                  progress: 0.8,
                  icon: Icons.check_circle_outline,
                ),
                MedicationCard(
                  name: 'Hydrochlorothiazide 25mg',
                  dosage: '1 comprimé le matin',
                  deliveryDate: '15 févr.',
                  delayDays: 84,
                  status: 'À jour',
                  statusColor: Color(0xFF27AE60),
                  progress: 0.8,
                  icon: Icons.check_circle_outline,
                ),
                SizedBox(height: 20),
                _buildSectionTitle('Diabète type 2'),
                MedicationCard(
                  name: 'Metformine 850mg',
                  dosage: '1 comprimé matin et soir',
                  deliveryDate: '20 févr.',
                  delayDays: 79,
                  status: 'Bientôt fini',
                  statusColor: Color(0xFFF39C12),
                  progress: 0.95,
                  icon: Icons.access_time,
                ),
                MedicationCard(
                  name: 'Glibenclamide 5mg',
                  dosage: '1 comprimé le matin',
                  deliveryDate: '10 janv.',
                  delayDays: 120,
                  status: 'En retard',
                  statusColor: Color(0xFFE74C3C),
                  progress: 1.0,
                  icon: Icons.error_outline,
                ),
              ],
            ),
          ),

          // Bouton fixe en bas
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.phone_outlined, color: Colors.white),
              label: Text(
                'Contacter ma pharmacie',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF27AE60),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.w),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF7F8C8D),
        ),
      ),
    );
  }
}

class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String deliveryDate;
  final int delayDays;
  final String status;
  final Color statusColor;
  final double progress;
  final IconData icon;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.deliveryDate,
    required this.delayDays,
    required this.status,
    required this.statusColor,
    required this.progress,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(icon, color: statusColor, size: 22),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.only(left: 32),
                  child: Text(
                    dosage,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
                SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.only(left: 32),
                  child: Row(
                    children: [
                      Text(
                        'Délivré le $deliveryDate',
                        style: TextStyle(
                          color: Color(0xFFBDC3C7),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('|', style: TextStyle(color: Color(0xFFBDC3C7))),
                      SizedBox(width: 8),
                      Text(
                        'En retard de $delayDays jours',
                        style: TextStyle(
                          color: Color(0xFFBDC3C7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Barre de progression en bas de la carte
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Color(0xFFF2F2F2),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }
}
