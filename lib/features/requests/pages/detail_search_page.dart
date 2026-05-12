import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaconsult/models/medicaments/medicament_model.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../models/communes/commune_model.dart';

class DetailSearchPage extends StatefulWidget {
  MedicamentsModels? medocs;

  DetailSearchPage({super.key, this.medocs});

  @override
  State<DetailSearchPage> createState() => _DetailSearchPageState();
}

class _DetailSearchPageState extends State<DetailSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<String> selectedItems = [];

  late Future<List<CommunesModels>> _futureCommunes;

  final List<CommunesModels> _selectedCities = [];

  void _addCity(CommunesModels city) {
    if (_selectedCities.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Vous pouvez sélectionner au maximum 3 communes."),
        ),
      );
      return;
    }

    if (!_selectedCities.any((c) => c.id == city.id)) {
      setState(() {
        _selectedCities.add(city);
      });
    }

    _controller.clear();
  }

  void _removeCity(CommunesModels city) {
    setState(() {
      _selectedCities.removeWhere((c) => c.id == city.id);
    });
  }

  @override
  void initState() {
    super.initState();
    _futureCommunes = fetchCagnotte();
  }

  Future<List<CommunesModels>> fetchCagnotte() async {
    final http.Response response = await http.get(
      Uri.parse(ApiUrls.getListCity),
      headers: {
        'Content-Type': 'application/json',
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appFondLogin, appWhite, appWhite],
            stops: [0.2, 0.4, .4],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3.w)),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3.w),
                          child: Image.network(
                            widget.medocs!.medicamentPicture!,
                            fit: BoxFit.fill,
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                "assets/images/medicament.jpg",
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.fill,
                              );
                            },
                          ),
                        ),
                        FloatingActionButton.small(
                          heroTag: 'Back',
                          shape: CircleBorder(),
                          backgroundColor: appWhite,
                          onPressed: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back_outlined,
                            color: appBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    widget.medocs!.name!,
                    maxLines: 2,
                    style: TextStyle(
                      color: appBlack,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.medocs!.price!,
                    style: TextStyle(
                      color: appColorRed,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    "Principe actif",
                    style: TextStyle(
                      color: appBlack,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: appColorContact,
                      borderRadius: BorderRadius.all(Radius.circular(3.w)),
                    ),
                    child: Text(
                      widget.medocs!.principeActif!,
                      style: TextStyle(
                        color: appColor2,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    "Chosissez une commune",
                    style: TextStyle(
                      color: appColor2,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: () => _showCommuneBottomSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedCities.isEmpty
                                  ? "Sélectionner une commune"
                                  : _selectedCities.map((c) => c.name).join(", "),
                              style: TextStyle(
                                color:
                                _selectedCities.isEmpty ? Colors.grey : Colors.black,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 8.w, left: 2.w, right: 2.w),
        child: SubmitButton(
          AppConstants.btnSendRequest,
          height: 6.h,
          onPressed: () async {
            List<int?> selectedIds =
                _selectedCities.map((commune) => commune.id).toList();
            requestUser(context, selectedIds);
          },
        ),
      ),
    );
  }

  void _showCommuneBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FutureBuilder<List<CommunesModels>>(
                      future: _futureCommunes,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("Aucune commune trouvée"),
                          );
                        }

                        final communes = snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Choisir une commune",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TypeAheadField<CommunesModels>(
                              suggestionsCallback: (search) async {
                                final lower = search.toLowerCase();
                                return communes.where((commune) {
                                  final notAlreadySelected = !_selectedCities
                                      .any((c) => c.id == commune.id);
                                  final matches = commune.name!
                                      .toLowerCase()
                                      .contains(lower) ||
                                      commune.description!
                                          .toLowerCase()
                                          .contains(lower);
                                  return notAlreadySelected && matches;
                                }).toList();
                              },
                              builder: (context, controller, focusNode) {
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: "Rechercher une commune",
                                    prefixIcon:
                                    const Icon(Icons.search_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                              decorationBuilder: (context, child) {
                                // ✅ permet à la liste de suggestions d’être bien visible
                                return Material(
                                  type: MaterialType.card,
                                  elevation: 8,
                                  borderRadius: BorderRadius.circular(12),
                                  child: child,
                                );
                              },
                              offset: const Offset(0, 8),
                              constraints:
                              const BoxConstraints(maxHeight: 400),
                              itemBuilder: (context, commune) {
                                return ListTile(
                                  leading: const Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.blueAccent,
                                  ),
                                  title: Text(commune.name ?? ''),
                                  subtitle: Text(
                                    commune.description ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                              onSelected: (commune) {
                                setState(() => _addCity(commune));
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: _selectedCities.length,
                                itemBuilder: (context, index) {
                                  final city = _selectedCities[index];
                                  return ListTile(
                                    title: Text(city.name ?? ''),
                                    subtitle:
                                    Text(city.description ?? ''),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.remove_circle,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() => _removeCity(city));
                                        setModalState(() {});
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> requestUser(BuildContext context, List<int?> selectedIds) async {
    // Afficher une boîte de dialogue de chargement
    showDialog(
      context: context,
      barrierDismissible: false, // Empêcher de fermer en cliquant dehors
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              const Expanded(child: Text('Veuillez patienter...')),
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
        Uri.parse(
          ApiUrls.postRequestUrl,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${TokenManager().getBearerToken()}",
        },
        body: jsonEncode({
         "medicamentId": widget.medocs!.id,
         "userName": SharedPreferencesHelper().getString('phone'),
         "communeIds": selectedIds,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pop(context);
        SnackbarHelper.showSuccess(context, "Votre demande de disponibilité "
            "pour ${widget.medocs!.name} a été transmise aux pharmacies. "
            "Vous recevrez une réponse sous peu.");

        await Future.delayed(const Duration(milliseconds: 800));

        // 🔹 Fermer plusieurs pages jusqu’à la route principale
        int count = 0;
        Navigator.of(context).popUntil((route) {
          return count++ >= 1; // Ferme 1 pages avant d'arriver sur la principale
        });

        // 🔹 Envoyer un signal de rafraîchissement à la page principale
        Navigator.pop(context, true);
      } else {
        Navigator.pop(context);
        SnackbarHelper.showError(
          context,
          "Impossible d'envoyer votre demande. Veuillez réessayer.",
        );
      }
    } catch (e) {
      Navigator.pop(context); // Fermer le dialog si une erreur survient
      SnackbarHelper.showError(context, "Erreur de connexion");
    }
  }
}
