import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';
import '../../../core/utils/utils.dart';
import '../../../models/communes/commune_model.dart';
import '../gardes.dart';

class PharmacyPage extends StatefulWidget {
  const PharmacyPage({super.key});

  @override
  State<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage> {
  var searchController = TextEditingController();

  List<CommunesModels> allCommunes = [];
  List<CommunesModels> filteredCommunes = [];
  late Future<List<CommunesModels>> _futureCommunes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _futureCommunes = fetchCagnotte();
    searchController.addListener(_filterCommunes);
  }

  void _filterCommunes() async {
    final query = searchController.text.toLowerCase();
    if (query.length < 3) {
      setState(() {
        filteredCommunes =
            allCommunes
                .where(
                  (medicament) =>
                      medicament.name!.toLowerCase().contains(query),
                )
                .toList();
      });
    } else {
      setState(() => isLoading = true);
      try {
        final searchResults = await fetchCommuneBySearch(query);
        setState(() {
          filteredCommunes = searchResults;
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
       }
    }
  }

  void _refreshData() {
    setState(() {
      _futureCommunes = fetchCagnotte();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<CommunesModels>> fetchCommuneBySearch(String query) async {
    final http.Response response = await http.get(
      Uri.parse("${ApiUrls.getListCity}?name=$query"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${TokenManager().getBearerToken()}",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(
        utf8.decode(response.bodyBytes),
      );
      final List<dynamic> contentList = jsonResponse['content'];

      return contentList.map((item) => CommunesModels.fromJson(item)).toList();
    } else {
      throw Exception("Erreur lors de la recherche");
    }
  }

  Future<List<CommunesModels>> fetchCagnotte() async {
    final http.Response response = await http.get(
      Uri.parse(ApiUrls.getListCity),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${TokenManager().getBearerToken()}",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(
        utf8.decode(response.bodyBytes),
      );

      final List<dynamic> contentList = jsonResponse['content'];

      List<CommunesModels> communes =
          contentList
              .map(
                (item) => CommunesModels.fromJson(item as Map<String, dynamic>),
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
              "Choisissez votre commune",
              style: TextStyle(
                fontSize: 14.sp,
                color: appColor2,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appFondLogin, appWhite, appWhite],
            stops: [0.11, 0.15, .3],
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
                      hintText: "Rechercher une commune...",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: appColor),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          searchController.clear();
                          _filterCommunes();
                        },
                      )
                          : null,
                    ),
                  ),
                ),
                Gap(2.h),
                Expanded(
                  child: FutureBuilder<List<CommunesModels>>(
                    future: _futureCommunes,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Impossible d'avoir la liste des pharmacies. "
                            "Verifiez votre internet. Si le probleme "
                            "persiste veuillez contactez PHARMACONSULTS",
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      if (snapshot.hasData) {
                        allCommunes = snapshot.data!;
                        // Appliquer filtre si champ recherche non vide
                        filteredCommunes =
                            filteredCommunes.isEmpty &&
                                    searchController.text.isEmpty
                                ? allCommunes
                                : filteredCommunes;

                        filteredCommunes.sort(
                          (a, b) => a.name!.toLowerCase().compareTo(
                            b.name!.toLowerCase(),
                          ),
                        );

                        if (filteredCommunes.isEmpty) {
                          return Center(
                            child: Text("Pas de commune disponible"),
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredCommunes.length,
                          itemBuilder: (context, index) {
                            final commune = filteredCommunes[index];
                            return _buildCommuneCard(commune);
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

  Widget _buildCommuneCard(CommunesModels commune) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.8.h),
      decoration: BoxDecoration(
        color: appFondLogin,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 1.h,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PharmacyListPage(
                identifiant: commune.id,
                libelle: commune.name,
              ),
            ),
          );
        },
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: appColor.withValues(alpha:0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_pharmacy,
            color: appColor,
          ),
        ),
        title: Text(
          commune.name ?? "",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: appBlack,
          ),
        ),
        subtitle: Text(
          "Voir les pharmacies disponibles",
          style: TextStyle(
            fontSize: 13.sp,
            color: appColor2,
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: appColor.withValues(alpha:.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PharmacyListPage(
                    identifiant: commune.id,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
