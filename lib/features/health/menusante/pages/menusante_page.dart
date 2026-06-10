import 'package:flutter/material.dart';
import 'package:pharmaconsult/features/health/health.dart';

class MenusantePage extends StatefulWidget {
  MenusantePage({super.key});

  @override
  State<MenusantePage> createState() => _MenusantePageState();
}

class _MenusantePageState extends State<MenusantePage> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    SantePage(),
    MesurePage(),
    TraitementPage(),
    MyPharmacyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentPageIndex, children: _pages),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SocialePage()),
          );
        },
        backgroundColor: Color(0xFF27AE60),
        shape: CircleBorder(),
        child: Icon(Icons.qr_code_outlined, color: Colors.white, size: 30),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.home_outlined, 'Accueil', 0),
              _buildBottomNavItem(Icons.show_chart_rounded, 'Mesures', 1),

              SizedBox(width: 40),

              _buildBottomNavItem(Icons.healing_outlined, 'Traitements', 2),
              _buildBottomNavItem(Icons.apartment_rounded, 'Pharmacie', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final bool isActive = _currentPageIndex == index;

    final color = isActive ? Color(0xFF27AE60) : Colors.grey;

    return InkWell(
      onTap: () {
        setState(() {
          _currentPageIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
