import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/inputs/inputs.dart';
import '../../../models/demandes/request_pharmacy_model.dart';

class ResponsePharmacyPage extends StatefulWidget {
  String? medoc;
  int? pharmacie;
  int? medocId;

  ResponsePharmacyPage({super.key, this.medoc, this.pharmacie, this.medocId});

  @override
  State<ResponsePharmacyPage> createState() => _ResponsePharmacyPageState();
}

class _ResponsePharmacyPageState extends State<ResponsePharmacyPage> {
  var searchController = TextEditingController();

  List<RequestPharmacy> allPharmacies = [];
  List<RequestPharmacy> filteredPharmacies = [];
  bool isLoading = false;
  late Future<List<RequestPharmacy>> _futurePharmacies;

  @override
  void initState() {
    super.initState();
    _futurePharmacies = fetchPharmacie();
    searchController.addListener(_filterPharmacies);
  }

  void _filterPharmacies() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredPharmacies =
          allPharmacies
              .where(
                (commune) =>
                    commune.pharmacy!.name!.toLowerCase().contains(query) ||
                    commune.pharmacy!.commune!.name!.toLowerCase().contains(
                      query,
                    ),
              )
              .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _futurePharmacies = fetchPharmacie();
    });
  }

  Future<List<RequestPharmacy>> fetchPharmacie() async {
    await TokenManager().refreshTokenIfExpired();
    final http.Response response = await http.get(
      Uri.parse("${ApiUrls.getRequestPharmacyUrl}${widget.pharmacie}"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${TokenManager().getBearerToken()}",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> contentList = json.decode(
        utf8.decode(response.bodyBytes),
      );

      try {
        List<RequestPharmacy> pharmacies =
            contentList
                .map(
                  (item) =>
                      RequestPharmacy.fromJson(item as Map<String, dynamic>),
                )
                .toList();
        return pharmacies;
      } catch (e) {
        throw Exception("Erreur lors de la conversion JSON");
      }
    } else {
      throw Exception("Une erreur s'est produite");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appFondLogin,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Liste des Pharmacies disposant de",
              style: TextStyle(
                color: appBlack,
                fontWeight: FontWeight.bold,
                fontSize: 17.sp,
              ),
            ),
            Text(
              widget.medoc!,
              style: TextStyle(
                color: appColor2,
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
        centerTitle: false,
        titleSpacing: 0,
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
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        spreadRadius: .1,
                        blurRadius: 8,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: InputText(
                    hintText: "Saisissez la pharmacie ou commune",
                    colorFille: appWhite,
                    keyboardType: TextInputType.text,
                    controller: searchController,
                    prefixIcon: Icon(Icons.search_outlined, color: appBlack),
                    validatorMessage: "Veuillez saisir la commune",
                  ),
                ),
                Gap(2.h),
                Expanded(
                  child: FutureBuilder<List<RequestPharmacy>>(
                    future: _futurePharmacies,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Pas de pharmacie disponible pour cette commune",
                          ),
                        );
                      }

                      if (snapshot.hasData) {

                        allPharmacies = snapshot.data!;

                        // Avant ton ListView, filtre les pharmacies
                        List filteredPharmacies = allPharmacies
                            .where((p) => p.status == "VALIDE" || p.status == "RESERVE")
                            .toList();

                        // Appliquer filtre si champ recherche non vide
                        filteredPharmacies =
                            searchController.text.isEmpty
                                ? filteredPharmacies
                                : filteredPharmacies
                                    .where(
                                      (commune) =>
                                          commune.pharmacy!.commune!.name!
                                              .toLowerCase()
                                              .contains(
                                                searchController.text
                                                    .toLowerCase(),
                                              ) ||
                                          commune.pharmacy!.commune!.name!
                                              .toLowerCase()
                                              .contains(
                                                searchController.text
                                                    .toLowerCase(),
                                              ),
                                    )
                                    .toList();

                        if (filteredPharmacies.isEmpty) {
                          return Center(
                            child: Text("Pas de pharmacie disponible"),
                          );
                        }

                        bool hasValidReservation = filteredPharmacies.any(
                              (p) => p.status == "RESERVE",
                        );

                        return ListView.builder(
                          itemCount: filteredPharmacies.length,
                          itemBuilder: (context, index) {
                            final contact = filteredPharmacies[index];
                            final isReserved = contact.status == "RESERVE"; // tu gardes ta logique

                            return Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(3.w),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(3.w),
                                            child: Container(
                                              height: 87,
                                              width: 87,
                                              padding: EdgeInsets.all(4.w),
                                              color: appFondLogin,
                                              child: (contact.pharmacy?.facadeImage != null &&
                                                  contact.pharmacy!.facadeImage!.isNotEmpty)
                                                  ? Image.network(
                                                contact.pharmacy!.facadeImage!,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Image.asset("assets/images/pharmacy.png");
                                                },
                                              )
                                                  : Image.asset("assets/images/pharmacy.png"),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                contact.pharmacy?.name ?? "Pharmacie inconnue",
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontSize: 17.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                contact.pharmacy?.address ?? "Adresse non disponible",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: appColor2,
                                                ),
                                              ),
                                              Gap(1.h),
                                              Text(
                                                (contact.pharmacy?.commune?.name ??
                                                    "Commune non disponible")
                                                    .toUpperCase(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: appColorReserve,
                                                ),
                                              ),
                                              Gap(1.h),
                                              GestureDetector(
                                                onTap: (hasValidReservation && !isReserved)
                                                    ? null
                                                    : () {
                                                  if (contact.pharmacy != null &&
                                                      !hasValidReservation) {
                                                    sendRequestUser(
                                                      context,
                                                      contact.pharmacy!.id,
                                                      contact.requestId!,
                                                    );
                                                  } else {
                                                    SnackbarHelper.showWarning(
                                                      context,
                                                      "Réservation impossible.",
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: isReserved
                                                        ? appColorReserve
                                                        : hasValidReservation
                                                        ? Colors.grey
                                                        : appColor,
                                                    borderRadius: BorderRadius.circular(2.w),
                                                  ),
                                                  padding: EdgeInsets.all(1.5.w),
                                                  child: Text(
                                                    isReserved
                                                        ? "RESERVATION EFFECTUÉE"
                                                        : "RESERVATION",
                                                    style: TextStyle(
                                                      color: appWhite,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (index != filteredPharmacies.length - 1)
                                  Divider(
                                    color: appColorDivider,
                                    thickness: 1,
                                    height: 1,
                                  ),
                              ],
                            );
                          },
                        );
                      }
                      return Center(child: Text("Aucune donnée disponible"));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendRequestUser(BuildContext context, int? id, requestId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              const Expanded(child: Text('Réservation encours...')),
            ],
          ),
        );
      },
    );

    try {
      // Autoriser les certificats auto-signés (attention en production)
      HttpClient().badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      final response = await http.post(
        Uri.parse(ApiUrls.postSendRequestUrl),
        headers: {'Content-Type': 'application/json'},

        body: jsonEncode({
          'requestId': widget.pharmacie,
          'pharmacyId': id,
          'medicamentId': widget.medocId,
          'userName': SharedPreferencesHelper().getString('phone'),
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 60,
                    ),
                    Gap(1.h),
                    Text(
                      "✅ Réservation confirmée",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Gap(1.h),
                    Text(
                      "Votre réservation a été prise en charge.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                    ),
                    Gap(2.h),
                    Text(
                      "Vous avez 24 heures pour vous rendre à la pharmacie afin que "
                      "le produit vous soit dispensé.\n\n"
                      "Passé ce délai, le produit ne vous sera plus réservé.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: appColorBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gap(2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: appBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.w),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _refreshData();
                          },
                          child: Text("Fermer"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.w),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _refreshData();
                          },
                          child: Text("OK"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        Navigator.pop(context);
        SnackbarHelper.showError(context, "Identifiants incorrects");
      }
    } catch (e) {
      Navigator.pop(context);
      SnackbarHelper.showError(context, "Erreur de connexion");
    }
  }
}
