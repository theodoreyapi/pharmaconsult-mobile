import 'package:flutter/material.dart';
import 'package:pharmaconsult/features/vaccinations/appointment/appointment.dart';

import '../../../../core/themes/app_colors.dart';
import '../../pages/pages.dart';

class MenuVacciPage extends StatefulWidget {
  MenuVacciPage({super.key});

  @override
  State<MenuVacciPage> createState() => _MenuVacciPageState();
}

class _MenuVacciPageState extends State<MenuVacciPage> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    VaccinPage(),
    CalendarPage(),
    PricePage(),
    RappelPage(),
    HelpsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: Colors.black87),
        ),
        title: Text(
          'Vaccination',
          style: TextStyle(color: appColor2, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AppointmentPage()),
              );
            },
            icon: Icon(Icons.event_note_outlined, color: Colors.black87),
          ),
        ],
      ),
      body: IndexedStack(index: _currentPageIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: appWhite,
        indicatorColor: appColor.withValues(alpha: 0.1),
        selectedIndex: _currentPageIndex,
        onDestinationSelected:
            (index) => setState(() => _currentPageIndex = index),
        destinations: [
          _navItem(Icons.group, Icons.group_outlined, "Profils", 0),
          _navItem(
            Icons.calendar_month,
            Icons.calendar_month_outlined,
            "Calendrier",
            1,
          ),
          _navItem(Icons.attach_money, Icons.attach_money_outlined, "Prix", 2),
          _navItem(
            Icons.notifications_none,
            Icons.notifications_active_outlined,
            "Rappels",
            3,
          ),
          _navItem(Icons.help_outline, Icons.help_outlined, "Aide", 4),
        ],
      ),
    );
  }

  NavigationDestination _navItem(
    IconData activeIcon,
    IconData icon,
    String label,
    int index,
  ) {
    return NavigationDestination(
      icon: Icon(icon, color: appBlack),
      selectedIcon: Icon(activeIcon, color: appColor),
      label: label,
    );
  }
}
