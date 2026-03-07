import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/medicaments/medicament_model.dart';
import '../search.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var searchController = TextEditingController();

  List<MedicamentsModels> filteredMedicaments = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterMedicaments);
  }

  void _filterMedicaments() async {
    final query = searchController.text.trim().toLowerCase();

    if (query.length < 3) {
      setState(() {
        filteredMedicaments = [];
      });
      return;
    }

    setState(() => isLoading = true);
    try {
      final searchResults = await fetchMedicamentsBySearch(query);
      setState(() {
        filteredMedicaments = searchResults;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<MedicamentsModels>> fetchMedicamentsBySearch(String query) async {
    final http.Response response = await http.get(
      Uri.parse("${ApiUrls.getMedicamentUrl}?name=$query"),
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

      return contentList
          .map((item) => MedicamentsModels.fromJson(item))
          .toList();
    } else {
      throw Exception("Erreur lors de la recherche");
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
              "Rechercher un médicament",
              style: TextStyle(
                color: appBlack,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            Text(
              "Consulter, réserver un médicament",
              style: TextStyle(
                color: appColor2,
                fontWeight: FontWeight.w500,
                fontSize: 15.sp,
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
                    hintText: "Rechercher un médicament",
                    colorFille: appWhite,
                    keyboardType: TextInputType.text,
                    controller: searchController,
                    prefixIcon: Icon(Icons.search_outlined, color: appBlack),
                    validatorMessage: "Veuillez saisir le médicament",
                  ),
                ),
                Gap(2.h),
                Expanded(
                  child:
                      isLoading
                          ? Center(child: CircularProgressIndicator())
                          : filteredMedicaments.isEmpty
                          ? searchController.text.length < 3
                              ? Center(
                                child: Text(
                                  textAlign: TextAlign.center,
                                  "Saisissez au moins 3 caractères "
                                  "pour rechercher un médicament",
                                ),
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/question.png"),
                                  Text(
                                    "Médicament non trouvé ?",
                                    style: TextStyle(
                                      color: appColor2,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  /*Text(
                                    "Si votre produit n’est pas dans notre base "
                                    "de données, cliquez-ici et suivez "
                                    "les instructions.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: appColor2,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Gap(2.h),*/
                                  /*SubmitButton(
                                    AppConstants.btnSendClick,
                                    height: 13.w,
                                    onPressed: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => NewSearchPage(),
                                        ),
                                      );
                                    },
                                  ),*/
                                ],
                              )
                          : ListView.builder(
                            itemCount: filteredMedicaments.length,
                            itemBuilder: (context, index) {
                              final medocs = filteredMedicaments[index];
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => DetailSearchPage(
                                                medocs: medocs,
                                              ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(3.w),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(3.w),
                                                child: Container(
                                                  height: 80,
                                                  width: 80,
                                                  padding: EdgeInsets.all(4.w),
                                                  color: appTextTwo.withValues(
                                                    alpha: .3,
                                                  ),
                                                  child: Image.network(
                                                    medocs.medicamentPicture!,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Image.asset(
                                                        "assets/images/garde.png",
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    medocs.name!,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      fontSize: 17.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    "PRINCIPES ACTIF : ${medocs.principeActif!}",
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: appBlack,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    medocs.price!,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: appColorRed,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (index != filteredMedicaments.length - 1)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: Divider(
                                        color: appColorDivider,
                                        thickness: 1,
                                        height: 1,
                                      ),
                                    ),
                                ],
                              );
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
}
