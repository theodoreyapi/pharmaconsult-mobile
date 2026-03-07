import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';
import '../../../core/widgets/widgets.dart';

class CommunePage extends StatefulWidget {
  const CommunePage({super.key});

  @override
  State<CommunePage> createState() => _CommunePageState();
}

class Communes {
  final int id;
  final String name;

  Communes({
    required this.id,
    required this.name,
  });
}

class _CommunePageState extends State<CommunePage> {
  var searchController = TextEditingController();
  bool isLoading = false;

  final List<Communes> allCommuness = [
    Communes(id: 1, name: "Abobo"),
    Communes(id: 2, name: "Adjamé"),
    Communes(id: 3, name: "Attécoubé"),
    Communes(id: 4, name: "Cocody"),
    Communes(id: 5, name: "Koumassi"),
    Communes(id: 6, name: "Marcory"),
    Communes(id: 7, name: "Plateau"),
    Communes(id: 8, name: "Port-Bouët"),
    Communes(id: 9, name: "Treichville"),
    Communes(id: 10, name: "Yopougon"),
    Communes(id: 11, name: "Bingerville"),
    Communes(id: 12, name: "Songon"),
    Communes(id: 13, name: "Anyama"),
  ];

  List<Communes> filteredCommuness = [];
  List<Communes> selectedCommuness = [];

  @override
  void initState() {
    super.initState();
    loadCommunes();
    searchController.addListener(_filterCommuness);
  }

  void loadCommunes() {
    setState(() {
      isLoading = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        filteredCommuness = List.from(allCommuness);
        isLoading = false;
      });
    });
  }

  void _filterCommuness() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredCommuness =
          allCommuness.where((Communes) {
            return Communes.name.toLowerCase().contains(query);
          }).toList();
    });
  }

  void _onCommunesChecked(bool? value, Communes Communes) {
    setState(() {
      if (value == true) {
        if (selectedCommuness.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text("Vous pouvez sélectionner au maximum 3 Communess."),
            ),
          );
        } else {
          selectedCommuness.add(Communes);
        }
      } else {
        selectedCommuness.removeWhere((c) => c.id == Communes.id);
      }
    });
  }

  bool _isCommunesSelected(Communes Communes) {
    return selectedCommuness.any((c) => c.id == Communes.id);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Communes")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputText(
                hintText: "Saisissez la Communes",
                colorFille: appWhite,
                keyboardType: TextInputType.text,
                controller: searchController,
                prefixIcon: Icon(Icons.search_outlined, color: appBlack),
                validatorMessage: "Veuillez saisir la Communes",
              ),
              Text(
                "Sélectionnez maximum 3 Communess (${selectedCommuness.length}/3) "
                "${selectedCommuness.map((e) => e.name).join(', ')}",
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              Expanded(
                child:
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : filteredCommuness.isEmpty
                        ? Center(child: Text("Pas de Communes disponible"))
                        : ListView.builder(
                          itemCount: filteredCommuness.length,
                          itemBuilder: (context, index) {
                            final contact = filteredCommuness[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 1.w),
                              decoration: BoxDecoration(
                                color: appWhite,
                                border: Border.all(
                                  color: appColor.withValues(alpha: .12),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(3.w),
                              ),
                              child: CheckboxListTile(
                                title: Text(contact.name),
                                value: _isCommunesSelected(contact),
                                onChanged: (value) {
                                  _onCommunesChecked(value, contact);
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                secondary: Icon(
                                  Icons.location_on_sharp,
                                  color: appColor,
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: appColor,
        onPressed: loadCommunes,
        child: Icon(Icons.refresh, color: appWhite),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SubmitButton(AppConstants.btnDemand, onPressed: () async {}),
      ),
    );
  }
}
