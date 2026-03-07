import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../auths/login/login.dart';
import '../../auths/register/pages/pages.dart';
import '../../menus/menus.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late PageController _pageController;
  int _pageIndex = 0;
  late int _nbreSlides;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => checkLogin());
    _pageController = PageController(initialPage: 0);
    _nbreSlides = demoData.length;
  }

  void checkLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? role = pref.getString("role");
    if (role != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Container()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appWhite, appDegradOne, appDegradTwo],
            stops: [0.1, 0.2, 0.9],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  "assets/images/logo_color.png",
                  height: 86,
                  width: 199,
                ),
              ),
              Expanded(
                flex: 3,
                child: PageView.builder(
                  itemCount: demoData.length,
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _pageIndex = index;
                    });
                  },
                  itemBuilder:
                      (context, index) => TestScreenContent(
                        images: demoData[index].images,
                        titre: demoData[index].titre,
                        subTitre: demoData[index].subTitre,
                      ),
                ),
              ),
              Gap(2.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: SubmitButton(
                      AppConstants.btnRegister,
                      onPressed: () async {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: CancelButton(
                      AppConstants.btnLogin,
                      couleur: Colors.transparent,
                      onPressed: () async {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Gap(2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => MenuPage()),
                        );
                      },
                      child: Text("PASSER", style: TextStyle(color: appWhite)),
                    ),
                    Spacer(),
                    ...List.generate(
                      demoData.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: DotIndicator(isActive: index == _pageIndex),
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        if (_pageIndex + 1 < _nbreSlides) {
                          _pageController.nextPage(
                            curve: Curves.ease,
                            duration: const Duration(milliseconds: 300),
                          );
                        }
                      },
                      child: Text("SUIVANT", style: TextStyle(color: appWhite)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TestScreenContent extends StatelessWidget {
  const TestScreenContent({
    super.key,
    required this.titre,
    required this.subTitre,
    required this.images,
  });

  final String titre, subTitre, images;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Center(child: Image.asset(images))),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              titre,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appTextIndicator,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap(2.w),
            Text(
              subTitre,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appWhite,
                fontSize: 16.sp,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class Onboard {
  final String titre, subTitre, images;

  Onboard({required this.titre, required this.subTitre, required this.images});
}

final List<Onboard> demoData = [
  Onboard(
    images: "assets/intro/garde.png",
    titre: "Pharmacie de garde",
    subTitre:
        "Accédez en un clic aux pharmacies de garde disponibles dans votre commune, 24h/24.",
  ),
  Onboard(
    images: "assets/intro/prix.png",
    titre: "Fiche et prix des médicaments",
    subTitre:
        "Consultez les prix des médicaments ainsi que la notice avant de vous rendre en pharmacie",
  ),
  Onboard(
    images: "assets/intro/assurance.png",
    titre: "Assurances acceptées",
    subTitre: "Vérifiez quelles pharmacies acceptent votre couverture santé.",
  ),
  Onboard(
    images: "assets/intro/recherche.png",
    titre: "Recherche de médicaments",
    subTitre:
        "Envoyez une requête pour vérifier la disponibilité de vos médicaments "
        "dans toutes les pharmacies de Côte d’Ivoire avec une option de réservation.",
  ),
  Onboard(
    images: "assets/intro/portefeuille.png",
    titre: "Portefeuille électronique",
    subTitre:
        "Problème de jeton ? recevez votre petite monnaie directement "
        "sur votre téléphone et réutilisez la plus tard dans toutes les autres pharmacies",
  ),
  Onboard(
    images: "assets/intro/vaccination.png",
    titre: "Vaccination",
    subTitre:
        "Suivez vos calendriers vaccinaux, configurez des rappels et "
        "accédez aux prix des vaccins en un clic.",
  ),
  Onboard(
    images: "assets/intro/store.png",
    titre: "Store de produits Cosmétique",
    subTitre:
        "Achetez des produits de beauté et de bien-être en ligne et faites vous livrer.",
  ),
];

class DotIndicator extends StatelessWidget {
  const DotIndicator({super.key, this.isActive = false});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(microseconds: 300),
      height: isActive ? 2.w : 2.w,
      width: 2.w,
      decoration: BoxDecoration(
        color: isActive ? appColor : appIndicator,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
    );
  }
}
