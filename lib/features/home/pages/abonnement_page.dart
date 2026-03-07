import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/utils/utils.dart';
import '../../../models/abonnements/abonnement_model.dart';
import '../home.dart';

class AbonnementPage extends StatefulWidget {
  String? argument;
  String? title;

  AbonnementPage({super.key, this.argument, this.title});

  @override
  State<AbonnementPage> createState() => _AbonnementPageState();
}

class _AbonnementPageState extends State<AbonnementPage> {
  bool isLoading = false;
  late Future<List<AbonnementModel>> _futureAssure;
  List<AbonnementModel> allAssure = [];

  @override
  void initState() {
    super.initState();
    _futureAssure = fetchAssure();
  }

  Future<List<AbonnementModel>> fetchAssure() async {
    final http.Response response = await http.get(
      Uri.parse(
        "${ApiUrls.getForfaitUrl}${widget.argument!.replaceAll(" ", "%20")}",
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
        List<AbonnementModel> communes =
            contentList
                .map(
                  (item) =>
                      AbonnementModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();

        return communes;
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
      backgroundColor: appWhite,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/abonnement.png"),
              Text(
                "Souscrivez à un pass et profitez D’un accès total au service",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              Text(
                widget.title!.replaceAll("\n", " "),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appColor2,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp,
                ),
              ),
              Gap(2.h),
              Expanded(
                child: FutureBuilder<List<AbonnementModel>>(
                  future: _futureAssure,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Pas de forfait disponible"));
                    }

                    if (snapshot.hasData) {
                      allAssure = snapshot.data!;

                      if (allAssure.isEmpty) {
                        return Center(child: Text("Pas de forfait disponible"));
                      }

                      // Trouver l’index du PASS avec le prix maximum
                      final int recommendedIndex = allAssure.indexWhere(
                        (a) =>
                            a.price ==
                            allAssure
                                .map((e) => e.price)
                                .reduce((a, b) => a! > b! ? a : b),
                      );

                      return GridView.builder(
                        itemCount: allAssure.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.85,
                            ),
                        itemBuilder: (context, index) {
                          final abonne = allAssure[index];

                          final isRecommended = index == recommendedIndex;

                          return GestureDetector(
                            onTap: () {
                              showBarModalBottomSheet(
                                isDismissible: false,
                                enableDrag: false,
                                expand: true,
                                topControl: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FloatingActionButton.small(
                                    heroTag: "paie",
                                    backgroundColor: appWhite,
                                    shape: CircleBorder(),
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: Icon(Icons.close, color: appBlack),
                                  ),
                                ),
                                context: context,
                                builder: (context) => ConfirmationPage(abonnement: abonne),
                              );
                            },
                            child: Container(
                              padding:
                                  isRecommended
                                      ? EdgeInsets.all(1.w)
                                      : EdgeInsets.zero,
                              decoration:
                                  isRecommended
                                      ? BoxDecoration(
                                        border: Border.all(
                                          color: appColor,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          3.w,
                                        ),
                                      )
                                      : null,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: appColorContact,
                                        borderRadius: BorderRadius.circular(
                                          3.w,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 3.w,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isRecommended
                                                      ? appColorVertJaune
                                                      : appColor,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(3.w),
                                                topRight: Radius.circular(3.w),
                                              ),
                                            ),
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  abonne.libelle!,
                                                  style: TextStyle(
                                                    color: appWhite,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  "${abonne.duration} Jour(s)",
                                                  style: TextStyle(
                                                    color: appWhite,
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Gap(1.h),
                                              ],
                                            ),
                                          ),
                                          Center(
                                            child: Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "${abonne.price}",
                                                    style: TextStyle(
                                                      color: appColor2,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 25.sp,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: "F",
                                                    style: TextStyle(
                                                      color: appColor2,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 18.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                      ),
                                                  child: Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        WidgetSpan(
                                                          child: Icon(
                                                            Icons.outbound_outlined,
                                                            size: 15.sp,
                                                            color: appBlack,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              abonne.description ??
                                                              "",
                                                          style: TextStyle(
                                                            color: appBlack,
                                                            fontSize: 12.sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  isRecommended
                                      ? Text(
                                        "PASS RECOMMANDÉ",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: appBlack,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15.sp,
                                        ),
                                      )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            ),
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
    );
  }
}
