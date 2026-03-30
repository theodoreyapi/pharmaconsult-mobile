import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/pharmacies/pharmacie_model.dart';
import '../gardes.dart';

class PharmacyListPage extends StatefulWidget {
  int? identifiant;
  String? libelle;

  PharmacyListPage({super.key, this.identifiant, this.libelle});

  @override
  State<PharmacyListPage> createState() => _PharmacyListPageState();
}

class _PharmacyListPageState extends State<PharmacyListPage> {
  var searchController = TextEditingController();

  List<PharmaciesModels> allPharmacies = [];
  List<PharmaciesModels> filteredPharmacies = [];
  bool isLoading = false;
  late Future<List<PharmaciesModels>> _futurePharmacies;

  String afficheOne = "";
  String afficheTwo = "";

  @override
  void initState() {
    super.initState();
    _futurePharmacies = fetchGarde();
    searchController.addListener(_filterPharmacies);
  }

  void _filterPharmacies() async {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredPharmacies =
          allPharmacies
              .where((commune) => commune.name!.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<PharmaciesModels>> fetchGarde() async {
    final http.Response response = await http.get(
      Uri.parse(ApiUrls.getListDate),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> contentList = json.decode(
        utf8.decode(response.bodyBytes),
      );

      try {
        if (contentList.isNotEmpty) {
          afficheOne = contentList[0]["date_debut"];
          afficheTwo = contentList[0]["date_fin"];
        }

        _futurePharmacies = fetchPharmacie();

        return await fetchPharmacie();
      } catch (e) {
        throw Exception("Erreur lors de la conversion JSON: $e");
      }
    } else {
      throw Exception("Une erreur s'est produite");
    }
  }

  Future<List<PharmaciesModels>> fetchPharmacie() async {
    final http.Response response = await http.get(
      Uri.parse(ApiUrls.getListPharmaByCity(widget.identifiant!)),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> contentList = json.decode(
        utf8.decode(response.bodyBytes),
      );

      try {
        List<PharmaciesModels> pharmacies =
            contentList
                .map(
                  (item) =>
                      PharmaciesModels.fromJson(item as Map<String, dynamic>),
                )
                .toList();
        return pharmacies;
      } catch (e) {
        throw Exception("Erreur lors de la conversion JSON $e");
      }
    } else {
      throw Exception("Une erreur s'est produite");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appFondLogin,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pharmacies de garde",
              style: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.bold,
                color: appBlack,
              ),
            ),
            Text(
              "Pharmacies disponibles - ${widget.libelle}",
              maxLines: 1,
              style: TextStyle(fontSize: 14.sp, color: appColor2),
            ),
          ],
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
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: appWhite,
                    borderRadius: BorderRadius.circular(3.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Rechercher une pharmacie...",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: appColor),
                      suffixIcon:
                          searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  searchController.clear();
                                  _filterPharmacies();
                                },
                              )
                              : null,
                    ),
                  ),
                ),
                Gap(1.h),
                Expanded(
                  child: FutureBuilder<List<PharmaciesModels>>(
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
                        // Appliquer filtre si champ recherche non vide
                        filteredPharmacies =
                            searchController.text.isEmpty
                                ? allPharmacies
                                : allPharmacies
                                    .where(
                                      (commune) =>
                                          commune.name!.toLowerCase().contains(
                                            searchController.text.toLowerCase(),
                                          ),
                                    )
                                    .toList();

                        if (filteredPharmacies.isEmpty) {
                          return Center(
                            child: Text("Pas de pharmacie disponible"),
                          );
                        }

                        DateTime parsedDate = DateFormat(
                          "yyyy-MM-dd HH:mm:ss",
                        ).parse(afficheOne);
                        DateTime parsedDateTwo = DateFormat(
                          "yyyy-MM-dd HH:mm:ss",
                        ).parse(afficheTwo);

                        return Column(
                          children: [
                            _buildDateBanner(parsedDate, parsedDateTwo),
                            Gap(2.h),
                            Expanded(
                              child: ListView.builder(
                                itemCount: filteredPharmacies.length,
                                itemBuilder: (context, index) {
                                  final pharmacy = filteredPharmacies[index];
                                  return _buildPharmacyCard(pharmacy);
                                },
                              ),
                            ),
                          ],
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

  Widget _buildDateBanner(DateTime start, DateTime end) {
    return Container(
      padding: EdgeInsets.all(3.w),
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: appColorBlue.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14.w),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: appColorBlue),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              "Garde du ${DateFormat('EEE d MMM', 'fr_FR').format(start)} "
              "au ${DateFormat('EEE d MMM yyyy', 'fr_FR').format(end)}",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: appColorBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyCard(PharmaciesModels pharmacy) {
    return InkWell(
      borderRadius: BorderRadius.circular(3.w),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPharmacysPage(pharmacy: pharmacy),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: appWhite,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 18.w,
                height: 18.w,
                color: appFondLogin,
                child: Image.network(
                  pharmacy.facadeImage ?? "",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/images/pharmacy.jpg",
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),

            SizedBox(width: 4.w),

            /// INFOS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pharmacy.name ?? "",
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: appBlack,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    pharmacy.address ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.sp, color: appColor2),
                  ),
                ],
              ),
            ),

            /// ARROW
            Container(
              decoration: BoxDecoration(
                color: appColor.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPharmacysPage(pharmacy: pharmacy),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
