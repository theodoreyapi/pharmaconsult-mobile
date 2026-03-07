import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/pharmacies/pharmacie_model.dart';
import '../assures.dart';

class PharmacyAssureListPage extends StatefulWidget {
  int? identifiant;

  PharmacyAssureListPage({super.key, this.identifiant});

  @override
  State<PharmacyAssureListPage> createState() => _PharmacyAssureListPageState();
}

class _PharmacyAssureListPageState extends State<PharmacyAssureListPage> {
  var searchController = TextEditingController();

  List<PharmaciesModels> allPharmacies = [];
  List<PharmaciesModels> filteredPharmacies = [];
  bool isLoading = false;
  late Future<List<PharmaciesModels>> _futurePharmacies;

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
                (pharmacie) =>
                    pharmacie.name!.toLowerCase().contains(query) ||
                    pharmacie.commune!.name!.toLowerCase().contains(query),
              )
              .toList();
    });
  }

  void _refreshData() {
    setState(() {
      _futurePharmacies = fetchPharmacie();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<PharmaciesModels>> fetchPharmacie() async {
    await TokenManager().refreshTokenIfExpired();
    final http.Response response = await http.get(
      Uri.parse(
        "${ApiUrls.getPharmaAssureUrl}${widget.identifiant}/pharmacies",
      ),
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
        List<PharmaciesModels> pharmacies =
            contentList
                .map(
                  (item) =>
                      PharmaciesModels.fromJson(item as Map<String, dynamic>),
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
        title: Text(
          "Liste des Pharmacies",
          style: TextStyle(
            color: appBlack,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
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
                      suffixIcon: searchController.text.isNotEmpty
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
                Gap(2.h),
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
                            "Pas de pharmacie disponible pour cette assurance",
                          ),
                        );
                      }

                      if (snapshot.hasData) {
                        allPharmacies = snapshot.data!;
                        filteredPharmacies =
                            searchController.text.isEmpty
                                ? allPharmacies
                                : allPharmacies
                                    .where(
                                      (commune) =>
                                          commune.name!.toLowerCase().contains(
                                            searchController.text.toLowerCase(),
                                          ) ||
                                          commune.commune!.name!
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

                        return ListView.builder(
                          itemCount: filteredPharmacies.length,
                          itemBuilder: (context, index) {
                            final pharmacy = filteredPharmacies[index];
                            return _buildAssurPharmaCard(pharmacy);
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
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: appColor,
        elevation: 6,
        onPressed: _refreshData,
        child: Icon(Icons.refresh, color: Colors.white,),
      ),
    );
  }

  Widget _buildAssurPharmaCard(PharmaciesModels pharmacyAssure) {
    return InkWell(
      borderRadius: BorderRadius.circular(3.w),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                DetailPharmacyAssurePage(
                  pharmacy: pharmacyAssure,
                ),
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
                  pharmacyAssure.facadeImage ?? "",
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
                    pharmacyAssure.name ?? "",
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: appBlack,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    pharmacyAssure.address ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: appColor2,
                    ),
                  ),
                  Gap(1.h),
                  Text(
                    pharmacyAssure.commune!.name!
                        .toUpperCase(),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: appColorReserve,
                    ),
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
                      builder:
                          (context) =>
                          DetailPharmacyAssurePage(
                            pharmacy: pharmacyAssure,
                          ),
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
