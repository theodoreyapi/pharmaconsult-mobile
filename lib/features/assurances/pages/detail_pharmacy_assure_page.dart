import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:gap/gap.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/themes/app_colors.dart';
import '../../../models/pharmacies/pharmacie_model.dart';

class DetailPharmacyAssurePage extends StatefulWidget {
  PharmaciesModels? pharmacy;

  DetailPharmacyAssurePage({super.key, this.pharmacy});

  @override
  State<DetailPharmacyAssurePage> createState() =>
      _DetailPharmacyAssurePageState();
}

class _DetailPharmacyAssurePageState extends State<DetailPharmacyAssurePage> {
  var login = TextEditingController();
  double rating = 0;

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
                        (widget.pharmacy!.notices!.ratingSummary!.average!).toDouble() ?? 0,
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3.w),
                    child: Image.network(
                      widget.pharmacy!.facadeImage!,
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/img_pharmacie.png",
                          fit: BoxFit.fill,
                        );
                      },
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
                          if (await canLaunchUrl(
                            Uri.parse(widget.pharmacy!.gpsCoordinates!),
                          )) {
                            await launchUrl(
                              Uri.parse(widget.pharmacy!.gpsCoordinates!),
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            throw 'Impossible d\'ouvrir Google Maps';
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
                          final whatsappUrl = "https://wa.me/225$cleanNumber";

                          if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                            await launchUrl(
                              Uri.parse(whatsappUrl),
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
                        onTap: () {
                          launchUrl(
                            Uri.parse("tel:${widget.pharmacy!.phoneNumber}"),
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
                                        height: 5.w,
                                        width: 5.w,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
