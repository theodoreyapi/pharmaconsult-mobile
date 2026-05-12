import 'package:flutter/material.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:sizer/sizer.dart';

class RappelPage extends StatefulWidget {
  RappelPage({super.key});

  @override
  State<RappelPage> createState() => _RappelPageState();
}

class _RappelPageState extends State<RappelPage> {
  bool isDropdownOpen = false;
  String selectedOption = "Selectionnez une option";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // --- Section Rappels Automatiques ---
            _buildAutoRecallCard(),
            SizedBox(height: 16),

            // --- Section Calendrier des vaccins à venir ---
            _buildUpcomingCalendarCard(),
            SizedBox(height: 16),

            // --- État Vide (Aucun rappel) ---
            _buildEmptyState(),
            SizedBox(height: 16),

            // --- Note d'information bleue ---
            _buildInfoNote(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget 1: La carte supérieure avec le sélecteur
  Widget _buildAutoRecallCard() {
    return Container(
      padding: EdgeInsets.all(16),
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
              Icon(
                Icons.notifications_active_outlined,
                color: appColor2,
                size: 26,
              ),
              SizedBox(width: 8),
              Text(
                "Rappels Automatiques",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: appColor2,
                ),
              ),
              Spacer(),
              Icon(Icons.settings_outlined, color: Colors.grey),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "Notifications SMS et Push automatiques a J-5 et J-1",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          SizedBox(height: 16),

          // Sélecteur personnalisé
          GestureDetector(
            onTap: () => setState(() => isDropdownOpen = !isDropdownOpen),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(selectedOption, style: TextStyle(color: Colors.black54)),
                  Icon(
                    isDropdownOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          if (isDropdownOpen) ...[
            SizedBox(height: 4),
            _buildDropdownItem("Tous les profils"),
            _buildDropdownItem("Enfants uniquement"),
            _buildDropdownItem("Adultes uniquement"),
            _buildDropdownItem("Animaux uniquement"),
          ],

          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.notifications_none, color: Colors.green, size: 18),
              SizedBox(width: 8),
              Text(
                "0 rappel(s) programme(s)",
                style: TextStyle(color: Colors.green, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(String title) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedOption = title;
          isDropdownOpen = false;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 14)),
            Icon(Icons.add, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  // Widget 2: Indicateurs de statut (Urgent, Proche, Futur)
  Widget _buildUpcomingCalendarCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: appColor2, size: 22),
              SizedBox(width: 8),
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
          SizedBox(height: 16),
          _statusRow(Color(0xFFFEF2F2), Colors.red, "Urgent (0-5 jours): 0"),
          SizedBox(height: 8),
          _statusRow(
            Color(0xFFFFF7ED),
            Colors.orange,
            "Proche (6-30 jours): 0",
          ),
          SizedBox(height: 8),
          _statusRow(Color(0xFFEFF6FF), Colors.blue, "Futur (>30 jours): 0"),
        ],
      ),
    );
  }

  Widget _statusRow(Color bgColor, Color textColor, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: textColor),
          SizedBox(width: 8),
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

  // Widget 3: Zone d'état vide
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Color(0xFF059669), size: 30),
          ),
          SizedBox(height: 16),
          Text(
            "Aucun rappel programme",
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          SizedBox(height: 4),
          Text(
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: Color(0xFF2563EB), width: 4)),
      ),
      child: RichText(
        text: TextSpan(
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
