import 'package:flutter/material.dart';
import 'package:pharmaconsult/core/themes/themes.dart';

class SantePage extends StatefulWidget {
  SantePage({super.key});

  @override
  State<SantePage> createState() => _SantePageState();
}

class _SantePageState extends State<SantePage> {
  @override
  Widget build(key) {
    return Scaffold(
      backgroundColor: appDegradOne,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Bonjour Aminata)
              _buildHeader(),
              SizedBox(height: 20),

              // 2. Section Mon Suivi (Card principale)
              _buildSuiviCard(),
              SizedBox(height: 24),

              // 3. Section Accès Rapide
              Text(
                'Accès rapide',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A5568),
                ),
              ),
              SizedBox(height: 12),

              // List des menus d'accès rapide
              _buildMenuTile(
                icon: Icons.timeline_rounded,
                iconColor: Color(0xFF2ECC71),
                bgColor: Color(0xFFE8F8F0),
                title: 'Mes mesures',
                onTap: () {},
              ),
              _buildMenuTile(
                icon: Icons.link,
                iconColor: Color(0xFF4285F4),
                bgColor: Color(0xFFE8F0FE),
                title: 'Mes traitements',
                onTap: () {},
              ),
              _buildMenuTile(
                icon: Icons.menu_book_rounded,
                iconColor: Color(0xFFF39C12),
                bgColor: Color(0xFFFEF5E7),
                title: 'Conseils santé',
                onTap: () {},
              ),
              _buildMenuTile(
                icon: Icons.local_hospital_rounded,
                iconColor: Color(0xFF9B59B6),
                bgColor: Color(0xFFF4ECF7),
                title: 'Ma pharmacie',
                onTap: () {},
              ),
              _buildMenuTile(
                icon: Icons.qr_code_2_rounded,
                iconColor: Color(0xFFE91E63),
                bgColor: Color(0xFFFCE4EC),
                title: 'Mon QR code',
                onTap: () {},
              ),
              SizedBox(height: 40), // Espace pour ne pas être caché par la barre
            ],
          ),
        ),
      ),
    );
  }

  // --- Composants de l'interface ---

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFE2F0D9),
          child: Text(
            'AK',
            style: TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour Aminata',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F3E32)),
              ),
              Text(
                'Pharmacie Santé Plus vous accompagne',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_none_rounded, color: Color(0xFF27AE60)),
            ),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text('4', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildSuiviCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_border_rounded, color: Color(0xFF27AE60)),
              SizedBox(width: 8),
              Text(
                'Mon suivi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F3E32)),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildTag('Hypertension artérielle'),
              SizedBox(width: 8),
              _buildTag('Diabète type 2'),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildIndicatorBox(
                  title: 'Dernière tension',
                  value: '135/85',
                  subValue: '11 mars',
                  bgColor: Color(0xFFFEF5E7),
                  textColor: Color(0xFFD35400),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildIndicatorBox(
                  title: 'Dernière glycémie',
                  value: '1.15 g/L',
                  subValue: '10 mars',
                  bgColor: Color(0xFFE8F8F5),
                  textColor: Color(0xFF16A085),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFFFEAA7).withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_active_outlined, color: Color(0xFFD35400), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Renouvellement Amlodipine prévu',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF7F8C8D)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '15 mars 2026',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD35400)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFF1F9F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: Color(0xFF27AE60), fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildIndicatorBox({
    required String title,
    required String value,
    required String subValue,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.8))),
          SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
          SizedBox(height: 4),
          Text(subValue, style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF2C3E50)),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
