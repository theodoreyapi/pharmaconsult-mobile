import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pharmaconsult/features/home/pages/pages.dart';
import 'package:rating_summary/rating_summary.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/buttons/buttons.dart';
import '../../../core/widgets/inputs/inputs.dart';
import '../../../models/pharmacies/pharmacie_model.dart';
import '../gardes.dart';

class DetailPharmacysPage extends StatefulWidget {
  PharmaciesModels? pharmacy;

  DetailPharmacysPage({super.key, this.pharmacy});

  @override
  State<DetailPharmacysPage> createState() => _DetailPharmacysPageState();
}

class _DetailPharmacysPageState extends State<DetailPharmacysPage> {
  var login = TextEditingController();
  double rating = 0;

  String formatRelativeDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date.replaceAll(' ', 'T'));
      Duration diff = DateTime.now().difference(parsedDate);

      if (diff.inMinutes < 60) {
        return "Il y a ${diff.inMinutes} min";
      } else if (diff.inHours < 24) {
        return "Il y a ${diff.inHours} h";
      } else if (diff.inDays < 7) {
        return "Il y a ${diff.inDays} j";
      } else {
        return DateFormat('d MMM yyyy', 'fr_FR').format(parsedDate);
      }
    } catch (e) {
      return date;
    }
  }

  @override
  void dispose() {
    login.dispose();
    super.dispose();
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
              widget.pharmacy!.name!,
              maxLines: 2,
              style: TextStyle(
                color: appBlack,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.pharmacy!.notices != null) ...[
                  StarRating(
                    rating:
                        (widget.pharmacy!.notices!.ratingSummary!.average!).toDouble(),
                    color: Colors.orange,
                    size: 13,
                  ),
                  Text(
                    widget.pharmacy!.notices!.ratingSummary!.counter.toString(),
                    style: TextStyle(
                      color: appColor2,
                      fontWeight: FontWeight.normal,
                      fontSize: 15.sp,
                    ),
                  ),
                ] else
                  Text(
                    "Aucune note",
                    style: TextStyle(
                      color: appColor2,
                      fontWeight: FontWeight.normal,
                      fontSize: 14.sp,
                    ),
                  ),
              ],
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [appFondLogin, appWhite],
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3.w),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        widget.pharmacy!.facadeImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Image.asset(
                            "assets/images/pharmacy.jpg",
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                  Gap(1.h),
                  Container(
                    decoration: BoxDecoration(
                      color: appTextTree,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.5),
                          spreadRadius: .1,
                          blurRadius: 8,
                          offset: Offset(0, 5),
                        ),
                      ],
                      borderRadius: BorderRadius.all(Radius.circular(3.w)),
                    ),
                    child: ListTile(
                      title: Align(
                        alignment: Alignment.centerLeft,
                        child: IntrinsicWidth(
                          child: Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: appFondLogin,
                              borderRadius: BorderRadius.all(
                                Radius.circular(3.w),
                              ),
                            ),
                            child: Text(
                              widget.pharmacy!.commune!.name!.toUpperCase(),
                              style: TextStyle(
                                color: appColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      subtitle: Text(
                        widget.pharmacy!.address!,
                        style: TextStyle(
                          color: appColor2,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      trailing: InkWell(
                        onTap: () async {
                          final uri = Uri.parse(
                            widget.pharmacy!.gpsCoordinates!,
                          );
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: Image.asset("assets/images/map.png"),
                      ),
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    "Nom du pharmacien",
                    style: TextStyle(
                      color: appBlack,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.pharmacy!.ownerName!,
                    style: TextStyle(
                      color: appColor2,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    "Numéro de Téléphone",
                    style: TextStyle(
                      color: appBlack,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () async {
                          final cleanNumber = widget
                              .pharmacy!
                              .whatsAppPhoneNumber!
                              .replaceAll(RegExp(r'[+\s]'), '');

                          final uri = Uri.parse(
                            "https://wa.me/225$cleanNumber",
                          );

                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            final webUrl =
                                "https://web.whatsapp.com/send?phone=225${widget.pharmacy!.whatsAppPhoneNumber}";
                            if (await canLaunchUrl(Uri.parse(webUrl))) {
                              await launchUrl(Uri.parse(webUrl));
                            } else {
                              throw "Impossible d'ouvrir WhatsApp";
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: appColorContact,
                            borderRadius: BorderRadius.all(
                              Radius.circular(3.w),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset("assets/images/whatsapp.png"),
                              Gap(2.w),
                              Text(
                                widget.pharmacy!.whatsAppPhoneNumber!,
                                style: TextStyle(
                                  color: appColor2,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gap(4.w),
                      InkWell(
                        onTap: () async {
                          final uri = Uri(
                            scheme: "tel",
                            path: widget.pharmacy!.phoneNumber,
                          );

                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: appColorContact,
                            borderRadius: BorderRadius.all(
                              Radius.circular(3.w),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset("assets/images/phone.png"),
                              Gap(2.w),
                              Text(
                                widget.pharmacy!.phoneNumber!,
                                style: TextStyle(
                                  color: appColor2,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(2.h),
                  Text(
                    "Liste de moyens de paiement",
                    style: TextStyle(
                      color: appBlack,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children:
                        widget.pharmacy?.paymentMethods?.isNotEmpty == true
                            ? widget.pharmacy!.paymentMethods!.map((mode) {
                              return Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: appWhite,
                                  border: Border.all(color: appColorContact),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(3.w),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 8.w,
                                      child: Image.network(
                                        mode.paymentMethodPicture!,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Icon(
                                            Icons.wallet_outlined,
                                            color: appColor,
                                          );
                                        },
                                      ),
                                    ),
                                    Gap(2.w),
                                    Text(
                                      mode.name ?? '',
                                      style: TextStyle(
                                        color: appTextTwo,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList()
                            : [
                              Text(
                                "Aucun moyen de paiement disponible",
                                style: TextStyle(color: appTextTwo),
                              ),
                            ],
                  ),
                  Gap(2.h),
                  Container(
                    decoration: BoxDecoration(
                      color: appColor,
                      borderRadius: BorderRadius.all(Radius.circular(3.w)),
                    ),
                    child: ListTile(
                      onTap: () async {
                        // Vérification live via l'API
                        final username = SharedPreferencesHelper().getString(
                          "phone",
                        ); // ton numéro
                        final url = Uri.parse(
                          "${ApiUrls.getCheckByModuleSubscribeUrl(username!)}/Assurances",
                        );

                        try {
                          final response = await http.get(
                            url,
                            headers: {
                              "Content-Type": "application/json",
                              "Authorization":
                                  "Bearer ${TokenManager().getBearerToken()}",
                            },
                          );

                          if (response.statusCode == 200) {
                            final isValid =
                                response.body.toLowerCase() == "true";

                            if (isValid) {
                              showBarModalBottomSheet(
                                isDismissible: false,
                                enableDrag: false,
                                expand: true,
                                topControl: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FloatingActionButton.small(
                                    backgroundColor: appWhite,
                                    shape: CircleBorder(),
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: Icon(Icons.close, color: appBlack),
                                  ),
                                ),
                                context: context,
                                builder:
                                    (context) => AssurePharmacyPage(
                                      assurances: widget.pharmacy!.assurances!,
                                    ),
                              );
                            } else {
                              showBarModalBottomSheet(
                                isDismissible: false,
                                enableDrag: false,
                                expand: true,
                                topControl: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FloatingActionButton.small(
                                    backgroundColor: appWhite,
                                    shape: const CircleBorder(),
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: Icon(Icons.close, color: appBlack),
                                  ),
                                ),
                                context: context,
                                builder:
                                    (context) => AbonnementPage(
                                      title: "Assurances",
                                      argument: "Assurances",
                                    ),
                              );
                            }
                          } else {
                            SnackbarHelper.showError(context, "Erreur serveur");
                          }
                        } catch (e) {
                          SnackbarHelper.showError(
                            context,
                            "Erreur de connexion",
                          );
                        }
                      },
                      title: Text(
                        "Liste des Assurances acceptées",
                        style: TextStyle(
                          color: appWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      trailing: Icon(
                        Icons.visibility_outlined,
                        color: appWhite,
                      ),
                    ),
                  ),
                  Gap(2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Commentaires",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: appBlack,
                        ),
                      ),
                      InkWell(
                        onTap:
                            () => showBarModalBottomSheet(
                              expand: true,
                              isDismissible: false,
                              enableDrag: false,
                              topControl: Align(
                                alignment: Alignment.centerLeft,
                                child: FloatingActionButton.small(
                                  heroTag: 'comment',
                                  backgroundColor: appWhite,
                                  shape: CircleBorder(),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Icon(Icons.close, color: appBlack),
                                ),
                              ),
                              context: context,
                              builder:
                                  (context) => CommentPharmacyPage(
                                    pharmacie: widget.pharmacy!.id,
                                    name: widget.pharmacy!.name,
                                  ),
                            ),
                        child: Text(
                          "Voir tout >",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: appColor2,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.pharmacy!.notices?.notices?.isNotEmpty ==
                      true) ...[
                    ListTile(
                      leading: CircleAvatar(
                        child: Image.network(
                          widget.pharmacy!.notices!.notices!.first.userPicture!,
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person);
                          },
                        ),
                      ),
                      title: Text(
                        widget.pharmacy!.notices!.notices!.first.userName!,
                      ),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              StarRating(
                                size: 10,
                                rating:
                                    (widget
                                            .pharmacy!
                                            .notices!
                                            .notices!
                                            .first
                                            .note!)
                                        .toDouble(),
                                color: Colors.orange,
                              ),
                              Gap(2.w),
                              Text(
                                formatRelativeDate(widget
                                    .pharmacy!
                                    .notices!
                                    .notices!
                                    .first
                                    .dateNotice ?? "")
                                ,
                                style: TextStyle(
                                  color: appTextTwo,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            widget.pharmacy!.notices!.notices!.first.details!,
                            style: TextStyle(
                              color: appBlack,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gap(2.h),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.13,
                            decoration: BoxDecoration(
                              color: appWhite,
                              border: Border.all(color: appColor),
                              borderRadius: BorderRadius.all(
                                Radius.circular(2.w),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  widget
                                      .pharmacy!
                                      .notices!
                                      .ratingSummary!
                                      .average
                                      .toString(),
                                  style: TextStyle(
                                    color: appColor2,
                                    fontSize: 25.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "sur 5",
                                  style: TextStyle(
                                    color: appBlack,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Gap(2.w),
                        Expanded(
                          flex: 2,
                          child: RatingSummary(
                            color: appColor,
                            thickness: 6,
                            counter:
                                widget
                                    .pharmacy!
                                    .notices!
                                    .ratingSummary!
                                    .counter!,
                            showAverage: false,
                            counterFiveStars:
                                widget
                                    .pharmacy!
                                    .notices!
                                    .ratingSummary!
                                    .counterFiveStars!,
                            counterFourStars:
                                widget
                                    .pharmacy!
                                    .notices!
                                    .ratingSummary!
                                    .counterFourStars!,
                            counterThreeStars:
                                widget
                                    .pharmacy!
                                    .notices!
                                    .ratingSummary!
                                    .counterThreeStars!,
                            counterTwoStars:
                                widget
                                    .pharmacy!
                                    .notices!
                                    .ratingSummary!
                                    .counterTwoStars!,
                            counterOneStars:
                                widget
                                    .pharmacy!
                                    .notices!
                                    .ratingSummary!
                                    .counterOneStars!,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text("Aucun commentaire disponible"),
                  ],
                  Gap(3.h),
                  Text(
                    "Laissez nous un commentaire",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: appBlack,
                    ),
                  ),
                  InputText(
                    hintText: "Ecrire un commentaire...",
                    keyboardType: TextInputType.text,
                    controller: login,
                    maxLines: 5,
                    validatorMessage: "Veuillez ecrire quelque chose",
                  ),
                  Gap(2.h),
                  StarRating(
                    rating: rating,
                    borderColor: appColor2,
                    color: appColor,
                    size: 25,
                    onRatingChanged:
                        (rating) => setState(() {
                          this.rating = rating;
                        }),
                  ),
                  Gap(2.h),
                  SubmitButton(
                    AppConstants.btnSendComment,
                    onPressed: () async {
                      if (login.text.isNotEmpty) {
                        sendComment(context);
                      } else {
                        SnackbarHelper.showError(
                          context,
                          "Vous devez ecrire quelque chose avant d'envoyer.",
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendComment(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
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
      HttpClient().badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

      final response = await http.post(
        Uri.parse(ApiUrls.postAddNotice),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${TokenManager().getBearerToken()}",
        },
        body: jsonEncode({
          'note': rating.toInt(),
          'userName': SharedPreferencesHelper().getString('phone'),
          'details': login.text,
          'pharmacyId': widget.pharmacy!.id,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
        SnackbarHelper.showSuccess(
          context,
          "Merci pour votre avis sur "
          "${widget.pharmacy!.name} !",
        );
      } else {
        Navigator.pop(context);
        SnackbarHelper.showError(
          context,
          "Impossible d'envoyer votre commentaire. Veuillez réessayer.",
        );
      }
    } catch (e) {
      Navigator.pop(context); // Fermer le dialog si une erreur survient
      SnackbarHelper.showError(context, "Erreur de connexion");
    }
  }
}
