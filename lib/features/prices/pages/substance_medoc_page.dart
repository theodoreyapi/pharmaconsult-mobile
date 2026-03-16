import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pharmaconsult/models/medicaments/medicament_model.dart';
import 'package:sizer/sizer.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/inputs/inputs.dart';

class SubstanceMedocPage extends StatefulWidget {
  List<Substitutes>? substitutes;
  String? libelle;

  SubstanceMedocPage({super.key, this.substitutes, this.libelle});

  @override
  State<SubstanceMedocPage> createState() => _SubstanceMedocPageState();
}

class _SubstanceMedocPageState extends State<SubstanceMedocPage> {
  var searchController = TextEditingController();
  bool isLoading = false;

  List<Substitutes> filteredAssurancesss = [];

  @override
  void initState() {
    super.initState();
    loadAssurancess();
    searchController.addListener(_filterAssurancesss);
  }

  void loadAssurancess() {
    setState(() {
      isLoading = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        filteredAssurancesss = List.from(widget.substitutes!);
        isLoading = false;
      });
    });
  }

  void _filterAssurancesss() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredAssurancesss =
          widget.substitutes!.where((Substitutes) {
            return Substitutes.substitutName!.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appWhite,
        title: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Liste des substituts",
                style: TextStyle(
                  color: appBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              Text(
                widget.libelle!,
                style: TextStyle(
                  color: appColor2,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              InputText(
                hintText: "Rechercher un substitut",
                colorFille: appWhite,
                keyboardType: TextInputType.text,
                controller: searchController,
                prefixIcon: Icon(Icons.search_outlined, color: appBlack),
                validatorMessage: "Veuillez saisir l'assurance",
              ),
              Gap(2.h),
              Expanded(
                child:
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : filteredAssurancesss.isEmpty
                        ? Center(child: Text("Pas de substitut disponible"))
                        : ListView.builder(
                          itemCount: filteredAssurancesss.length,
                          itemBuilder: (context, index) {
                            final medocs = filteredAssurancesss[index];
                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3.w),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
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
                                                  medocs.substitutImageId!,
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
                                                  medocs.substitutName!,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 17.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  medocs.substitutPrice!,
                                                  maxLines: 1,
                                                  textHeightBehavior:
                                                      TextHeightBehavior(
                                                        applyHeightToFirstAscent:
                                                            false,
                                                        applyHeightToLastDescent:
                                                            false,
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    height: 1,
                                                    fontWeight: FontWeight.bold,
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
                                if (index != filteredAssurancesss.length - 1)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4.0,
                                      bottom: 4.0,
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
    );
  }
}
