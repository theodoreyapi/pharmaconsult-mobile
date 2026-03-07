import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/widgets.dart';

class BasicPage extends StatefulWidget {
  const BasicPage({super.key});

  @override
  State<BasicPage> createState() => _BasicPageState();
}

class _BasicPageState extends State<BasicPage> {
  final _formKeyBasic = GlobalKey<FormState>();

  var email = TextEditingController();
  var name = TextEditingController();
  var lastName = TextEditingController();

  @override
  void initState() {
    super.initState();
    email.text = SharedPreferencesHelper().getString('email')!;
    name.text = SharedPreferencesHelper().getString('nom')!;
    lastName.text = SharedPreferencesHelper().getString('prenom')!;
  }

  @override
  void dispose() {
    super.dispose();
  }

  String phoneIndicator = "";
  String initialCountry = 'CI';
  PhoneNumber number = PhoneNumber(isoCode: 'CI');

  final _snackBar = const SnackBar(
    content: Text("Tous les champs sont obligatoires"),
    backgroundColor: Colors.red,
  );

  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }

    // Appelle la fonction d’envoi de l’image
    await updatePictureUser(context, _image!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appFondLogin,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_outlined),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Profil",
              style: TextStyle(
                color: appBlack,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            Text(
              "Informations personnelles",
              style: TextStyle(
                color: appColor2,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
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
            stops: [0.2, 0.4, .4],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKeyBasic,
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        fit: StackFit.loose,
                        clipBehavior: Clip.hardEdge,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blue[100],
                            backgroundImage:
                            _image != null
                                ? FileImage(_image!)
                                : SharedPreferencesHelper().getString(
                              'photo',
                            ) !=
                                null
                                ? NetworkImage(
                              SharedPreferencesHelper().getString(
                                'photo',
                              )!,
                            )
                                : null,
                            child:
                            _image == null &&
                                SharedPreferencesHelper().getString(
                                  'photo',
                                ) ==
                                    null
                                    ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.blue,
                                    )
                                    : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: appColor2,
                              child: IconButton(
                                onPressed: _pickImage,
                                icon: Icon(
                                  Icons.image,
                                  size: 20,
                                  color: appWhite,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(2.h),
                    Center(
                      child: Text(
                        "Mettre à jour votre Photo de profil",
                        style: TextStyle(
                          color: appColor2,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Gap(2.h),
                    Text(
                      "Nom",
                      style: TextStyle(
                        color: appTextTwo,
                        fontWeight: FontWeight.normal,
                        fontSize: 16.sp,
                      ),
                    ),
                    InputText(
                      hintText: "Nom",
                      colorFille: Colors.transparent,
                      keyboardType: TextInputType.text,
                      controller: name,
                      validatorMessage: "Veuillez saisir votre nom",
                    ),
                    Gap(1.h),
                    Text(
                      "Prénoms",
                      style: TextStyle(
                        color: appTextTwo,
                        fontWeight: FontWeight.normal,
                        fontSize: 16.sp,
                      ),
                    ),
                    InputText(
                      hintText: "Prénom",
                      colorFille: Colors.transparent,
                      keyboardType: TextInputType.text,
                      controller: lastName,
                      validatorMessage: "Veuillez saisir votre prénom",
                    ),
                    Gap(1.h),
                    Text(
                      "Email",
                      style: TextStyle(
                        color: appTextTwo,
                        fontWeight: FontWeight.normal,
                        fontSize: 16.sp,
                      ),
                    ),
                    InputText(
                      colorFille: Colors.transparent,
                      hintText: "Adresse e-mail",
                      keyboardType: TextInputType.text,
                      controller: email,
                      validatorMessage: "Veuillez saisir votre email",
                    ),
                    Gap(1.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: appColorCard,
                        borderRadius: BorderRadius.circular(3.w),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Numéro de Téléphone",
                            style: TextStyle(
                              color: appTextTwo,
                              fontWeight: FontWeight.normal,
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            SharedPreferencesHelper()
                                .getString('phone')!
                                .replaceFirst('00', '+'),
                            style: TextStyle(
                              color: appBlack,
                              fontWeight: FontWeight.w500,
                              fontSize: 18.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(4.w),
        child: SubmitButton(
          AppConstants.btnUpdate,
          onPressed: () async {
            if (_formKeyBasic.currentState!.validate()) {
              updateInfoUser(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(_snackBar);
            }
          },
        ),
      ),
    );
  }

  Future<void> updateInfoUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              const Expanded(child: Text('Modification...')),
            ],
          ),
        );
      },
    );

    try {
      HttpClient().badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      final response = await http.put(
        Uri.parse(ApiUrls.putUpdateProfileUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': SharedPreferencesHelper().getString('phone')!,
          'email': email.text,
          'firstName': name.text,
          'lastName': lastName.text,
        }),
      );

      if (response.statusCode == 200) {
        SharedPreferencesHelper().saveString('nom', name.text);
        SharedPreferencesHelper().saveString('prenom', lastName.text);
        SharedPreferencesHelper().saveString('email', email.text);

        Navigator.pop(context);
        SnackbarHelper.showSuccess(
          context,
          "Vos informations ont été modifiées avec succès.",
        );
      } else if (response.statusCode == 409) {
        Navigator.pop(context);
        SnackbarHelper.showError(
          context,
          "Le nouveau adresse email que vous avez saissir est déjà utilisé.",
        );
      } else {
        Navigator.pop(context);
        SnackbarHelper.showError(
          context,
          "Impossible de modifier vos informations. Veuillez réessayer.",
        );
      }
    } catch (e) {
      Navigator.pop(context);
      SnackbarHelper.showError(context, "Erreur de connexion");
    }
  }

  Future<void> updatePictureUser(BuildContext context, File imageFile) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Veuillez patienter...')),
            ],
          ),
        );
      },
    );

    try {
      HttpClient().badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      final uri = Uri.parse(ApiUrls.putUpdatePictureProfileUrl);
      final request = http.MultipartRequest('PUT', uri);

      // Ajoute les champs nécessaires
      request.fields['userName'] = SharedPreferencesHelper().getString('phone')!;

      // Ajoute le fichier image
      request.files.add(await http.MultipartFile.fromPath(
        'userPicture',
        imageFile.path,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final imageUrl = response.body.trim(); // Nettoie les espaces s’il y en a

        SharedPreferencesHelper().saveString('photo', imageUrl);

        SnackbarHelper.showSuccess(
          context,
          "Votre photo a été modifiée avec succès.",
        );
      } else {
        SnackbarHelper.showError(
          context,
          "Impossible de modifier votre photo. Veuillez réessayer.",
        );
      }
    } catch (e) {
      Navigator.pop(context);
      SnackbarHelper.showError(context, "Erreur de connexion $e");
    }
  }

}
