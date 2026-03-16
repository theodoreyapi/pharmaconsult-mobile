import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/constants.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../models/demandes/demande_model.dart';
import '../../../models/demandes/reservation_model.dart';
import '../search.dart';

class DemandePage extends StatefulWidget {
  const DemandePage({super.key});

  @override
  State<DemandePage> createState() => _DemandePageState();
}

class _DemandePageState extends State<DemandePage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late Future<List<DemandeModel>> _futureRequest;
  List<DemandeModel> allRequests = [];
  late Future<List<ReservationModel>> _futureReserve;
  List<ReservationModel> allReserves = [];

  @override
  void initState() {
    super.initState();
    _futureRequest = fetchRequest();
    _futureReserve = fetchReserve();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<DemandeModel>> fetchRequest() async {
    final http.Response response = await http.get(
      Uri.parse(
        "${ApiUrls.getRequestUrl}${SharedPreferencesHelper().getString('phone')}",
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${TokenManager().getBearerToken()}",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(
        utf8.decode(response.bodyBytes),
      );

      List<DemandeModel> communes =
          jsonResponse
              .map(
                (item) => DemandeModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      return communes;
    } else {
      throw Exception("Une erreur s'est produite");
    }
  }

  Future<List<ReservationModel>> fetchReserve() async {
    final http.Response response = await http.get(
      Uri.parse(
        "${ApiUrls.getReserveRequestUrl}${SharedPreferencesHelper().getString('phone')}",
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${TokenManager().getBearerToken()}",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(
        utf8.decode(response.bodyBytes),
      );

      List<ReservationModel> communes =
          jsonResponse
              .map(
                (item) =>
                    ReservationModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      return communes;
    } else {
      throw Exception("Une erreur s'est produite");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appFondLogin,
        title: Text(
          "Liste des recherches",
          style: TextStyle(
            color: appBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_outlined),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appFondLogin, appWhite, appWhite],
            stops: [0.1, 0.4, .4],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 26,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      tabAlignment: TabAlignment.start,
                      controller: _tabController,
                      indicatorColor: Colors.transparent,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.w),
                        color: appColor2,
                      ),
                      labelColor: appWhite,
                      indicatorSize: TabBarIndicatorSize.tab,
                      unselectedLabelColor: Colors.black,
                      isScrollable: true,
                      tabs: <Widget>[
                        // Tab(text: "Tout"),
                        Tab(text: "Demande sans reponse"),
                        Tab(text: "Demande repondue"),
                        Tab(text: "Médicament réservé"),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // buildRequestList(filtre: "TOUT"),
                      // Onglet 1 : EN_ATTENTE
                      buildRequestList(filtre: "EN_ATTENTE"),
                      // Onglet 2 : VALIDE
                      buildRequestList(filtre: "VALIDE"),
                      // Onglet 3 : RESERVE
                      buildReserveList(filtre: "RESERVE"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 8.w),
        child: SubmitButton(
          AppConstants.btnNewSearch,
          height: 13.w,
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            ).then((refresh) {
              if (refresh == true) {
                reloadAll();
              }
            });
          },
        ),
      ),
    );
  }

  void reloadAll() {
    setState(() {
      _futureRequest = fetchRequest();
      _futureReserve = fetchReserve();
    });
  }

  Widget buildRequestList({required String filtre}) {
    return FutureBuilder<List<DemandeModel>>(
      future: _futureRequest,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Impossible d'avoir la liste des recherches. "
              "Verifiez votre internet. Si le probleme "
              "persiste veuillez contacter PHARMACONSULTS",
              textAlign: TextAlign.center,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Aucune donnée disponible"));
        }

        allRequests = snapshot.data!;

        // Appliquer le filtre
        List<DemandeModel> filteredRequests =
            filtre == "TOUT"
                ? allRequests
                : allRequests.where((req) => req.status == filtre).toList();

        // 🔹 Trier les demandes par date (plus récentes en premier)
        filteredRequests.sort((a, b) {
          final dateA = DateTime.parse(a.dateCreate!);
          final dateB = DateTime.parse(b.dateCreate!);
          return dateB.compareTo(dateA);
        });

        if (filteredRequests.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/research.png"),
              Text(
                "Liste de recherche vide",
                style: TextStyle(
                  color: appColor2,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          itemCount: filteredRequests.length,
          itemBuilder: (context, index) {
            final contact = filteredRequests[index];

            DateTime dateReserve = DateTime.parse(contact.dateCreate!);
            String formattedDate = DateFormat(
              "dd MMMM yyyy 'à' HH:mm",
              'fr_FR',
            ).format(dateReserve);

            return Container(
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color:
                    contact.status == "EN_ATTENTE"
                        ? appColorRedFond
                        : contact.status == "VALIDE"
                        ? appColorOrangeFond
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color:
                          contact.status == "EN_ATTENTE"
                              ? appColorRed
                              : contact.status == "VALIDE"
                              ? appColorOrange
                              : Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(3.w),
                        topRight: Radius.circular(3.w),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Icon(
                          contact.status == "EN_ATTENTE"
                              ? Icons.hourglass_empty
                              : contact.status == "VALIDE"
                              ? Icons.check_circle
                              : Icons.medical_services, // ou null si tu veux pas d'icône
                          color: appWhite,
                          size: 18.sp, // adapte selon ton design
                        ),
                        Gap(2.w), // espace entre icône et texte
                        Text(
                          contact.status == "EN_ATTENTE"
                              ? "DEMANDE SANS RÉPONSE"
                              : contact.status == "VALIDE"
                              ? "DEMANDE RÉPONDUE"
                              : "MÉDICAMENT RÉSERVÉ", // ou vide si tu préfères
                          style: TextStyle(
                            color: appWhite,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.medicament!.name!,
                          style: TextStyle(
                            color: appBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 17.sp,
                          ),
                        ),
                        Gap(1.h),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: appBlack,
                            fontWeight: FontWeight.w500,
                            fontSize: 13.sp,
                          ),
                        ),
                        if (contact.status == "EN_ATTENTE") ...[
                          Gap(1.h),
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: Colors.yellow[50],
                              borderRadius: BorderRadius.circular(3.w),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: appBlack,
                                  fontWeight: FontWeight.normal,
                                ),
                                children: [
                                  TextSpan(
                                    text: "⚠️️ INFORMATIONS \n",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        "Si aucune pharmacie n’a répondu à votre "
                                        "requête sous 24 heures, nous vous "
                                        "invitons à la renouveler dans une autre commune.",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (contact.status == "VALIDE") ...[
                          Gap(1.h),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ResponsePharmacyPage(
                                        medoc: contact.medicament!.name!,
                                        medocId: contact.medicament!.id!,
                                        pharmacie: contact.requestId!,
                                      ),
                                ),
                              );
                            },
                            child: Text(
                              "Voir la liste des Pharmacies",
                              style: TextStyle(
                                color: appColorOrangeText,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildReserveList({required String filtre}) {
    return FutureBuilder<List<ReservationModel>>(
      future: _futureReserve,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Impossible d'avoir la liste des recherches. "
              "Verifiez votre internet. Si le probleme "
              "persiste veuillez contacter PHARMACONSULTS",
              textAlign: TextAlign.center,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("Aucune donnée disponible"));
        }

        allReserves = snapshot.data!;

        // Appliquer le filtre
        List<ReservationModel> filteredRequests =
            filtre == "TOUT"
                ? allReserves
                : allReserves.where((req) => req.status == filtre).toList();

        filteredRequests.sort((a, b) {
          final dateA = DateTime.parse(a.dateReservation!);
          final dateB = DateTime.parse(b.dateReservation!);
          return dateB.compareTo(dateA);
        });

        if (filteredRequests.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/research.png"),
              Text(
                "Liste de recherche vide",
                style: TextStyle(
                  color: appColor2,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          itemCount: filteredRequests.length,
          itemBuilder: (context, index) {
            final contact = filteredRequests[index];

            DateTime dateReserve = DateTime.parse(contact.dateReservation!);
            DateTime dateExpire = DateTime.parse(contact.expirationDate!);

            String formattedDateReserve = DateFormat(
              "dd MMMM yyyy 'à' HH:mm",
              'fr_FR',
            ).format(dateReserve);
            String formattedDateExpiration = DateFormat(
              "dd MMMM yyyy 'à' HH:mm",
              'fr_FR',
            ).format(dateExpire);

            return Container(
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: appFondLogin,
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: appColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(3.w),
                        topRight: Radius.circular(3.w),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        Icon(
                          Icons.medical_services,
                          color: appWhite,
                          size: 18.sp,
                        ),
                        Gap(2.w),
                        Text(
                          "MÉDICAMENT RÉSERVÉ",
                          style: TextStyle(
                            color: appWhite,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.medicament!.name!,
                          style: TextStyle(
                            color: appBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 17.sp,
                          ),
                        ),
                        Gap(1.h),
                        Text(
                          "Date de réservation : $formattedDateExpiration",
                          style: TextStyle(
                            color: appBlack,
                            fontWeight: FontWeight.w500,
                            fontSize: 13.sp,
                          ),
                        ),
                        Text(
                          "Date d'expiration : $formattedDateReserve",
                          style: TextStyle(
                            color: appBlack,
                            fontWeight: FontWeight.w500,
                            fontSize: 13.sp,
                          ),
                        ),
                        Gap(1.h),
                        Container(
                          decoration: BoxDecoration(
                            color: appColorDivider,
                            borderRadius: BorderRadius.circular(3.w),
                          ),
                          child: ListTile(
                            horizontalTitleGap: 3.0,
                            leading: Container(
                              alignment: Alignment.topCenter,
                              // Aligner en haut
                              width: 20,
                              padding: EdgeInsets.only(top: 3.2.w),
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: appWhite,
                                child: Icon(
                                  Icons.add,
                                  color: appColor,
                                  size: 15,
                                ),
                              ),
                            ),
                            title: Text(
                              contact.pharmacy!.name!,
                              style: TextStyle(
                                color: appBlack,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              "${contact.pharmacy!.commune!.name!} - "
                              "${contact.pharmacy!.address!}",
                              style: TextStyle(
                                color: appColor2,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: InkWell(
                              onTap: () async {
                                if (await canLaunchUrl(
                                  Uri.parse(contact.pharmacy!.gpsCoordinates!),
                                )) {
                                  await launchUrl(
                                    Uri.parse(
                                      contact.pharmacy!.gpsCoordinates!,
                                    ),
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  throw 'Impossible d\'ouvrir Google Maps';
                                }
                              },
                              child: Image.asset(
                                "assets/images/map.png",
                                height: 2.5.h,
                              ),
                            ),
                          ),
                        ),
                        Gap(2.h),
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.yellow[50],
                            borderRadius: BorderRadius.circular(3.w),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: appBlack,
                                fontWeight: FontWeight.normal,
                              ),
                              children: [
                                TextSpan(
                                  text: "⚠️ ATTENTION ! \n",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      "Vous avez réservé ${contact.medicament!.name!} "
                                      "de la ${contact.pharmacy!.name!}. ",
                                ),
                                TextSpan(
                                  text:
                                      "Vous avez 24heures pour vous "
                                      "rendre à la pharmacie afin "
                                      "que le produit vous soit dispensé. "
                                      "Passé ce délai le produit ne "
                                      "vous sera plus réservé.",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
