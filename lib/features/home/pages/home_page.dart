import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pharmaconsult/features/auths/login/login.dart';
import 'package:pharmaconsult/features/notification_overlay.dart';
import 'package:pharmaconsult/models/publicities/publicities_model.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';
import '../../../core/utils/utils.dart';
import '../../../models/abonnements/subscription_model.dart';
import '../../assurances/assures.dart';
import '../../gardes/gardes.dart';
import '../../mobiles/mobiles.dart';
import '../../prices/pages/pages.dart';
import '../../qr/qr.dart';
import '../../requests/search.dart';
import '../../vaccinations/vaccins.dart';
import '../home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  late Future<List<PublicitiesModel>> _publicitiesFuture;
  late Future<List<Subscription>> _fetchSubscriptions;

  bool _isVisible = false;

  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  WalletService walletService = WalletService();
  double wallet = 0;

  @override
  void initState() {
    super.initState();

    // Charger les publicités UNE SEULE FOIS
    _publicitiesFuture = fetchRequest();
    _fetchSubscriptions = fetchSubscriptions();

    final phone = SharedPreferencesHelper().getString("phone");
    if (phone != null && phone.isNotEmpty) {
      walletService.startListening((newAmount) {
        setState(() {
          wallet = newAmount;
          SharedPreferencesHelper().saveDouble("wallet", wallet);
        });
      });
    }

    _pageController = PageController();
    setupNotifications();
  }

  void _startAutoSlide(int itemCount) {
    _timer?.cancel(); // pour éviter plusieurs timers en même temps

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_pageController.hasClients || itemCount == 0) return;

      int nextPage = _currentPage + 1;
      if (nextPage >= itemCount) {
        nextPage = 0; // 🔁 retour au début
      }

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      setState(() {
        _currentPage = nextPage;
      });
    });
  }

  void setupNotifications() async {
    final phone = SharedPreferencesHelper().getString("phone");
    if (phone == null || phone.isEmpty) return;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token;

      if (Platform.isAndroid) {
        token = await messaging.getToken();
      } else if (Platform.isIOS) {
        String? apnsToken;
        int retry = 0;
        while (apnsToken == null && retry < 10) {
          apnsToken = await messaging.getAPNSToken();
          await Future.delayed(const Duration(milliseconds: 300));
          retry++;
        }
        if (apnsToken != null) {
          token = await messaging.getToken();
        }
      }

      await sendTokenToBackend(token);
    }

    // ✅ Foreground — afficher le banner overlay
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null && mounted) {
        NotificationOverlay.show(
          context,
          title: notification.title ?? 'Notification',
          body: notification.body ?? '',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Gérer la navigation si besoin
    });
  }

  Future<List<PublicitiesModel>> fetchRequest() async {
    final http.Response response = await http.get(
      Uri.parse(ApiUrls.getAdsUrl),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(
        utf8.decode(response.bodyBytes),
      );

      List<PublicitiesModel> publicites =
          jsonResponse
              .map(
                (item) =>
                    PublicitiesModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
      return publicites;
    } else {
      throw Exception("Une erreur s'est produite");
    }
  }

  Future<List<Subscription>> fetchSubscriptions() async {
    final phone = SharedPreferencesHelper().getString("phone");

    // Si pas connecté, retourner une liste vide sans appel API
    if (phone == null || phone.isEmpty) return [];

    final response = await http.get(
      Uri.parse(ApiUrls.getCheckAllSubscribeUrl(phone)),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((item) => Subscription.fromJson(item)).toList();
    } else {
      throw Exception("Impossible de charger les abonnements");
    }
  }

  bool isModuleActive(List<Subscription> subs, String libelle) {
    final now = DateTime.now();
    try {
      final sub = subs.firstWhere((s) => s.moduleDto!.libelle == libelle);
      return sub.validUntil!.isAfter(now) && sub.status == "active";
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    walletService.stopListening();
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn =
        (SharedPreferencesHelper().getString("phone") ?? "").isNotEmpty;

    double wallet = SharedPreferencesHelper().getDouble('wallet') ?? 0.0;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appFondLogin, appWhite, appWhite],
            stops: [0.2, 0.4, .4],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(2.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoggedIn) ...[
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [appColor, appColorVertJaune],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(3.w)),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            trailing: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QrScannePage(),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.qr_code_scanner_outlined,
                                color: appWhite,
                                size: 12.w,
                              ),
                            ),
                            title: Text(
                              "Compte principal",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: appWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                            subtitle: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isVisible = !_isVisible;
                                });
                              },
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              _isVisible
                                                  ? wallet.toStringAsFixed(2)
                                                  : "****",
                                          style: TextStyle(
                                            color: appWhite,
                                            fontSize: 22.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "F",
                                          style: TextStyle(
                                            color: appWhite,
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    WidgetSpan(child: SizedBox(width: 4.w)),
                                    WidgetSpan(
                                      child: Icon(
                                        _isVisible
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: appWhite,
                                        size: 5.w,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            indent: 4.w,
                            endIndent: 4.w,
                            color: appFondLogin,
                          ),
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    horizontalTitleGap: 5.0,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => MobileBenefPage(),
                                        ),
                                      );
                                    },
                                    leading: CircleAvatar(
                                      radius: 4.w,
                                      backgroundColor: appIndicator,
                                      child: Icon(
                                        Icons.swap_horiz_outlined,
                                        color: appBlack,
                                        size: 5.w,
                                      ),
                                    ),
                                    title: Text(
                                      "TRANSFERER DE LA MONNAIE",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: appTextTree,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ),
                                ),
                                VerticalDivider(color: appFondLogin),
                                Expanded(
                                  child: ListTile(
                                    horizontalTitleGap: 5.0,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => MobileAmountPage(),
                                        ),
                                      );
                                    },
                                    leading: CircleAvatar(
                                      radius: 4.w,
                                      backgroundColor: appIndicator,
                                      child: Icon(
                                        Icons.account_balance_wallet_outlined,
                                        color: appColor,
                                        size: 5.w,
                                      ),
                                    ),
                                    title: Text(
                                      "RECHARGER MON COMPTE",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: appTextTree,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Services",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: appBlack,
                          ),
                        ),
                      ],
                    ),
                  ],
                  Gap(1.h),
                  FutureBuilder<List<PublicitiesModel>>(
                    future: _publicitiesFuture,
                    builder: (context, adsSnapshot) {
                      final bool hasAds =
                          adsSnapshot.hasData && adsSnapshot.data!.isNotEmpty;

                      return FutureBuilder<List<Subscription>>(
                        future: _fetchSubscriptions,
                        builder: (context, subsSnapshot) {
                          final List<Subscription> subs =
                              subsSnapshot.data ?? [];

                          final services = [
                            _ServiceItem(
                              title: "Pharmacie \nde garde",
                              assetPath: "assets/svg/pharmacy.svg",
                              argument: "Pharmacie de garde",
                              page: PharmacyPage(),
                              isDisabled: false,
                            ),
                            _ServiceItem(
                              title: "Fiche et prix\nde médicament",
                              assetPath: "assets/svg/medoc.svg",
                              argument: "Fiche et prix",
                              page: PrixPage(),
                              isDisabled:
                                  !isModuleActive(subs, "Fiche et prix"),
                            ),
                            _ServiceItem(
                              title: "Assurances",
                              assetPath: "assets/svg/assure.svg",
                              argument: "Assurances",
                              page: AssurancePage(),
                              isDisabled: !isModuleActive(subs, "Assurances"),
                            ),
                            _ServiceItem(
                              title: "Vaccination",
                              assetPath: "assets/svg/vaccin.svg",
                              argument: "Vaccination",
                              page: MenuVacciPage(),
                              isDisabled: !isModuleActive(subs, "Vaccination"),
                            ),
                          ];

                          // 📌 GRIDVIEW si pas de publicités
                          if (!hasAds) {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.7,
                                  ),
                              itemCount: services.length,
                              itemBuilder: (context, index) {
                                final s = services[index];
                                return _buildServiceItem(
                                  context,
                                  s.title,
                                  s.assetPath,
                                  s.argument,
                                  s.page,
                                  isDisabled: s.isDisabled,
                                  isLoggedIn: isLoggedIn,
                                );
                              },
                            );
                          }

                          // 📌 LISTVIEW horizontal si publicités présentes
                          return SizedBox(
                            height: 150,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: services.length,
                              separatorBuilder: (_, __) => Gap(3.w),
                              itemBuilder: (context, index) {
                                final s = services[index];
                                return _buildServiceItem(
                                  context,
                                  s.title,
                                  s.assetPath,
                                  s.argument,
                                  s.page,
                                  isDisabled: s.isDisabled,
                                  isLoggedIn: isLoggedIn,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  Gap(2.h),
                  SizedBox(
                    height: 150,
                    child: FutureBuilder<List<PublicitiesModel>>(
                      future: _publicitiesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Impossible d'avoir les publicités. "
                              "Verifiez votre internet. Si le probleme "
                              "persiste veuillez contacter PHARMACONSULTS",
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return SizedBox.shrink();
                        }

                        final publicities = snapshot.data!;

                        _startAutoSlide(publicities.length);

                        return PageView.builder(
                          controller: _pageController,
                          itemCount: publicities.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final publicity = publicities[index];

                            return GestureDetector(
                              onTap: () {
                                if (publicity.lien != null &&
                                    publicity.lien!.isNotEmpty) {
                                  launchUrl(
                                    Uri.parse(publicity.lien!),
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 1.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade200,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    publicity.image ?? "",
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 50,
                                            ),
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context,
    String title,
    String assetPath,
    String argument,
    Widget pageToOpen, {
    bool isDisabled = false,
    bool isLoggedIn = true, // 👈 nouveau paramètre
  }) {
    return InkWell(
      onTap: () async {
        // ✅ Cas 1 : Pharmacie de garde — toujours accessible
        if (argument == "Pharmacie de garde") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => pageToOpen),
          );
          return;
        }

        // ✅ Cas 2 : Pas connecté → page de connexion
        if (!isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
          return;
        }

        // ✅ Cas 3 : Connecté mais abonnement inactif → AbonnementPage
        if (isDisabled) {
          showBarModalBottomSheet(
            isDismissible: false,
            enableDrag: false,
            expand: true,
            topControl: Align(
              alignment: Alignment.centerLeft,
              child: FloatingActionButton.small(
                backgroundColor: appWhite,
                shape: const CircleBorder(),
                onPressed: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, color: appBlack),
              ),
            ),
            context: context,
            builder:
                (context) => AbonnementPage(title: title, argument: argument),
          );
          return;
        }

        // ✅ Cas 4 : Connecté + abonnement actif → vérification live
        final username = SharedPreferencesHelper().getString("phone");
        if (username == null || username.isEmpty) return;

        final url = Uri.parse(
          "${ApiUrls.getCheckByModuleSubscribeUrl(username)}/$argument",
        );

        try {
          final response = await http.get(
            url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer ${TokenManager().getBearerToken()}",
            },
          );

          if (response.statusCode == 200) {
            final isValid = response.body.toLowerCase() == "true";

            if (isValid) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => pageToOpen),
              );
            } else {
              showBarModalBottomSheet(
                isDismissible: false,
                enableDrag: false,
                expand: true,
                topControl: Align(
                  alignment: Alignment.centerLeft,
                  child: FloatingActionButton.small(
                    backgroundColor: appWhite,
                    shape: const CircleBorder(),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, color: appBlack),
                  ),
                ),
                context: context,
                builder:
                    (context) =>
                        AbonnementPage(title: title, argument: argument),
              );
            }
          } else {
            SnackbarHelper.showError(context, "Erreur serveur");
          }
        } catch (e) {
          SnackbarHelper.showError(context, "Erreur de connexion");
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 100,
            width: 100,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              // 🎨 Grisé seulement si connecté + abonnement inactif
              color:
                  (isDisabled && isLoggedIn)
                      ? Colors.grey.withValues(alpha: 0.4)
                      : appColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.all(Radius.circular(3.w)),
            ),
            child: SvgPicture.asset(
              assetPath,
              colorFilter:
                  (isDisabled && isLoggedIn)
                      ? ColorFilter.mode(Colors.grey, BlendMode.saturation)
                      : null,
            ),
          ),
          Gap(1.h),
          Text(
            title,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: (isDisabled && isLoggedIn) ? Colors.grey : appBlack,
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendTokenToBackend(String? token) async {
    final username = SharedPreferencesHelper().getString("phone");
    if (username == null || username.isEmpty) return;

    final response = await http.post(
      Uri.parse(ApiUrls.postNotificationUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userName': username, 'token': token}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
    } else {}
  }
}

class _ServiceItem {
  final String title;
  final String assetPath;
  final String argument;
  final Widget page;
  final bool isDisabled;

  _ServiceItem({
    required this.title,
    required this.assetPath,
    required this.argument,
    required this.page,
    required this.isDisabled,
  });
}
