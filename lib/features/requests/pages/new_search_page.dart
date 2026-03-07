import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/inputs/inputs.dart';
import '../../../models/communes/commune_model.dart';

class NewSearchPage extends StatefulWidget {
  const NewSearchPage({super.key});

  @override
  State<NewSearchPage> createState() => _NewSearchPageState();
}

class _NewSearchPageState extends State<NewSearchPage> {
  final _formKey = GlobalKey<FormState>();
  var searchController = TextEditingController();
  var comment = TextEditingController();

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

  int _currentStep = 0;

  final ImagePicker _picker = ImagePicker();
  final List<File> _images = [];

  // Ouvrir la caméra
  Future<void> _pickFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  // Ouvrir la galerie (plusieurs images possibles)
  Future<void> _pickFromGallery() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  // Supprimer une image
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
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
          child: Form(
            key: _formKey,
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              elevation: 0,
              onStepContinue: () async {
                if (_currentStep < 1) {
                  setState(() => _currentStep += 1);
                } else {
                  if (_formKey.currentState!.validate()) {
                    // createAdventure(context);
                  } else {
                    SnackbarHelper.showError(
                      context,
                      "Tous les champs sont obligatoires",
                    );
                  }
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                }
              },
              steps: [
                Step(
                  title: Text(""),
                  isActive: _currentStep >= 0,
                  state:
                      _currentStep > 0 ? StepState.complete : StepState.indexed,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Renseigner le nom de votre médicament",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          color: appBlack,
                        ),
                      ),
                      Gap(1.h),
                      InputText(
                        hintText: "Exemple : Paracetamol",
                        colorFille: appWhite,
                        keyboardType: TextInputType.text,
                        controller: searchController,
                        validatorMessage: "Veuillez saisir le médicament",
                      ),
                      Gap(2.h),
                      Text(
                        "Ou Importer votre image",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          color: appBlack,
                        ),
                      ),
                      Gap(1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: _pickFromCamera,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: appFondLogin,
                                    borderRadius: BorderRadius.circular(3.w),
                                  ),
                                  child: Image.asset(
                                    "assets/images/camera.png",
                                    height: 20.w,
                                    width: 20.w,
                                  ),
                                ),
                                Text(
                                  "Photo",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15.sp,
                                    color: appBlack,
                                  ),
                                ),
                                Gap(1.h),
                              ],
                            ),
                          ),
                          Text(
                            "ou",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18.sp,
                              color: appBlack,
                            ),
                          ),
                          InkWell(
                            onTap: _pickFromGallery,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: appFondLogin,
                                    borderRadius: BorderRadius.circular(3.w),
                                  ),
                                  child: Image.asset(
                                    "assets/images/gallery.png",
                                    height: 20.w,
                                    width: 20.w,
                                  ),
                                ),
                                Text(
                                  "Galerie",
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15.sp,
                                    color: appBlack,
                                  ),
                                ),
                                Gap(1.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Gap(2.h),

                      /// Affichage des images choisies
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(_images.length, (index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _images[index],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.88,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: Text(""),
                  isActive: _currentStep >= 1,
                  state:
                      _currentStep > 1 ? StepState.complete : StepState.indexed,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Choisissez au maximum 3 communes.",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: appBlack,
                        ),
                      ),
                      Gap(1.h),
                      TypeAheadField<CommunesModels>(
                        suggestionsCallback: (search) async {
                          final communes = await _futureCommunes;

                          return communes.where((commune) {
                            final lower = search.toLowerCase();
                            final notAlreadySelected =
                                !_selectedCities.any((c) => c.id == commune.id);
                            final matchesSearch =
                                commune.name!.toLowerCase().contains(lower) ||
                                commune.description!.toLowerCase().contains(
                                  lower,
                                );

                            return notAlreadySelected && matchesSearch;
                          }).toList();
                        },
                        builder: (context, controller, focusNode) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.transparent,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(3.w),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.5),
                                  spreadRadius: .1,
                                  blurRadius: 8,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              enabled: _selectedCities.length < 3,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(3.w),
                                  borderSide: BorderSide.none,
                                ),
                                fillColor: appWhite,
                                filled: true,
                                hintText:
                                    _selectedCities.length < 3
                                        ? "Entrer une commune"
                                        : "Limite de 3 atteinte",
                              ),
                            ),
                          );
                        },
                        itemBuilder: (context, CommunesModels commune) {
                          return ListTile(
                            title: Text(commune.name!),
                            subtitle: Text(commune.description!),
                            trailing: Icon(Icons.add_circle, color: appColor),
                          );
                        },
                        onSelected: (CommunesModels commune) {
                          _addCity(commune);
                        },
                      ),
                      Gap(2.h),
                      _selectedCities.isNotEmpty
                          ? SizedBox(
                            height: 300,
                            child: ListView.builder(
                              itemCount: _selectedCities.length,
                              itemBuilder: (context, index) {
                                final city = _selectedCities[index];
                                return ListTile(
                                  title: Text(city.name!),
                                  subtitle: Text(city.description!),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeCity(city),
                                  ),
                                );
                              },
                            ),
                          )
                          : SizedBox.shrink(),
                      Text(
                        "Laissez nous un commentaire",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: appBlack,
                        ),
                      ),
                      InputText(
                        hintText: "Ajouter un commentaire facultatif",
                        keyboardType: TextInputType.text,
                        controller: comment,
                        maxLines: 5,
                      ),
                    ],
                  ),
                ),
              ],
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Row(
                    children: [
                      if (_currentStep > 0) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: details.onStepCancel,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 1.6.h),
                              side: BorderSide(color: appColor, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3.w),
                              ),
                            ),
                            child: Text(
                              "Précédent",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                color: appColor,
                              ),
                            ),
                          ),
                        ),
                        Gap(2.w),
                      ],
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appColor,
                            padding: EdgeInsets.symmetric(vertical: 1.6.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.w),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentStep >= 1
                                ? "Soumettre une demande"
                                : "Suivant",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: appWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
