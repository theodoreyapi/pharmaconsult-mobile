import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../core/themes/themes.dart';
import '../../../core/utils/utils.dart';
import '../../auths/login/login.dart';
import '../../home/home.dart';
import '../../money/money.dart';
import '../../profiles/profiles.dart';
import '../../qr/pages/pages.dart';
import '../menus.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    QrPage(),
    MoneyPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final helper = SharedPreferencesHelper();

    return Scaffold(
      backgroundColor: appWhite,
      appBar: AppBar(
        backgroundColor: appFondLogin,
        elevation: 0,
        leading: _buildAppBarLeading(helper),
        title: Text(
          "Pharmaconsults",
          style: TextStyle(
            color: appBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
      ),
      drawer: _buildAppDrawer(context, helper),
      body: IndexedStack(index: _currentPageIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: appWhite,
        indicatorColor: appColor.withValues(alpha: 0.1),
        selectedIndex: _currentPageIndex,
        onDestinationSelected: (index) {
          final bool isLoggedIn =
              (SharedPreferencesHelper().getString("phone") ?? "").isNotEmpty;

          // Index 0 = Accueil → toujours accessible
          if (index == 0) {
            setState(() => _currentPageIndex = index);
            return;
          }

          // Index 1, 2, 3 → login si non connecté
          if (!isLoggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            );
            return;
          }

          setState(() => _currentPageIndex = index);
        },
        destinations: [
          _navItem(Icons.home_rounded, Icons.home_outlined, "Accueil", 0),
          _navItem(
            Icons.qr_code_scanner_rounded,
            Icons.qr_code_2_outlined,
            "Mon QR Code",
            1,
          ),
          _navItem(
            Icons.equalizer_rounded,
            Icons.equalizer_outlined,
            "Transactions",
            2,
          ),
          _navItem(
            Icons.person_rounded,
            Icons.person_outline_rounded,
            "Profil",
            3,
          ),
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

  Widget _buildAppBarLeading(SharedPreferencesHelper helper) {
    final String nom = helper.getString('nom') ?? "";
    final String prenom = helper.getString('prenom') ?? "";
    final String? photo = helper.getString('photo') ?? '';

    // Initiales sécurisées
    final String initiales =
        (nom.isNotEmpty && prenom.isNotEmpty)
            ? "${nom[0]}${prenom[0]}".toUpperCase()
            : "PC";

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Builder(
        builder:
            (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Hero(
                tag: 'profile_avatar',
                child: CircleAvatar(
                  backgroundColor: appIndicator,
                  backgroundImage: photo != '' ? NetworkImage(photo!) : null,
                  child:
                      photo == ''
                          ? Text(
                            initiales,
                            style: TextStyle(
                              color: appColor2,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : null,
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context, SharedPreferencesHelper helper) {
    final String nom = helper.getString('nom') ?? "";
    final String prenom = helper.getString('prenom') ?? "";
    final String? photo = helper.getString('photo') ?? "";
    final String phone =
        helper.getString('phone')?.replaceFirst("00", "+") ?? "";

    return Drawer(
      backgroundColor: appWhite,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: appFondLogin.withValues(alpha: 0.5),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: appIndicator,
                    backgroundImage: photo != '' ? NetworkImage(photo!) : null,
                    child:
                        photo == ''
                            ? Text(
                              (nom.isNotEmpty && prenom.isNotEmpty)
                                  ? "${nom[0]}${prenom[0]}".toUpperCase()
                                  : "PC",
                              style: TextStyle(
                                color: appColor2,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),
                  Spacer(),
                  Text(
                    "$nom $prenom",
                    style: TextStyle(
                      color: appBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  Text(
                    phone,
                    style: TextStyle(color: appTextTwo, fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerSectionTitle("APPLICATION"),
                _drawerTile(
                  "À propos de nous",
                  "about.svg",
                  () => _go(context, AboutPage()),
                ),
                _drawerTile(
                  "Politique de confidentialité",
                  "politique.svg",
                  () => _go(context, PolicyPage()),
                ),
                _drawerTile(
                  "Conditions d'utilisation",
                  "condition.svg",
                  () => _go(context, ConditionPage()),
                ),
                _drawerTile(
                  "Mentions légales",
                  "mention.svg",
                  () => _go(context, MentionPage()),
                ),
                Divider(indent: 20, endIndent: 20),
                _drawerSectionTitle("COMMUNAUTÉ"),
                _drawerTile("Inviter un ami", "invite.svg", _handleShare),
                _drawerTile(
                  "Suivez-nous",
                  "suivis.svg",
                  () => _go(context, const SuiviPage()),
                ),
                _drawerTile(
                  "Notez l'application",
                  "note.svg",
                  () => _go(context, const NotePage()),
                ),
                const Divider(indent: 20, endIndent: 20),
                _drawerTile(
                  "Aide",
                  "help.svg",
                  () => _go(context, const HelpPage()),
                ),
                _buildLogoutItem(context),
              ],
            ),
          ),
          _buildVersionFooter(),
        ],
      ),
    );
  }

  Widget _drawerTile(
    String title,
    String svgPath,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: SvgPicture.asset(
        "assets/svg/$svgPath",
        colorFilter: ColorFilter.mode(
          isDestructive ? Colors.red : appBlack,
          BlendMode.srcIn,
        ),
        width: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : appBlack,
          fontSize: 13.sp,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _drawerSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 15, bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
      title: Text(
        "Se déconnecter",
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () => _showLogoutDialog(context),
    );
  }

  Widget _buildVersionFooter() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? "1.0.0";
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
          color: appFondLogin,
          child: Text(
            "Version $version • Pharmaconsults",
            style: TextStyle(color: Colors.grey, fontSize: 15.sp),
          ),
        );
      },
    );
  }

  // --- LOGIQUE ---
  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _handleShare() {
    String message = """
Salut 👋

Télécharge cette application :

📱 Android :
https://play.google.com/store/apps/details?id=com.aptiotech.pharmaconsult.yapi.pharmaconsult

🍎 iPhone :
https://apps.apple.com/app/id123456789

🌐 Version web :
https://www.pharma-consults.com
""";

    SharePlus.instance.share(ShareParams(text: message));
  }

  void _showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 50,
                ),
                Gap(2.h),
                Text(
                  "Déconnexion",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                Gap(1.h),
                const Text(
                  "Êtes-vous sûr de vouloir quitter votre session ?",
                  textAlign: TextAlign.center,
                ),
                Gap(3.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Annuler"),
                      ),
                    ),
                    Gap(4.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          await SharedPreferencesHelper().clear();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                              (r) => false,
                            );
                          }
                        },
                        child: const Text(
                          "Quitter",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
