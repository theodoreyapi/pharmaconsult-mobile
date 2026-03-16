import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:rating_summary/rating_summary.dart';
import 'package:sizer/sizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/utils/utils.dart';
import '../../../models/pharmacies/notice_model.dart';

class CommentPharmacyPage extends StatefulWidget {
  final int? pharmacie;
  final String? name;

  const CommentPharmacyPage({super.key, this.pharmacie, this.name});

  @override
  State<CommentPharmacyPage> createState() => _CommentPharmacyPageState();
}

class _CommentPharmacyPageState extends State<CommentPharmacyPage> {
  late Future<NoticesModel> _futureNotices;

  @override
  void initState() {
    super.initState();
    _futureNotices = fetchNotices();
  }

  Future<NoticesModel> fetchNotices() async {
    await TokenManager().refreshTokenIfExpired();

    final response = await http.get(
      Uri.parse("${ApiUrls.getListNotice}${widget.pharmacie}"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${TokenManager().getBearerToken()}",
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      return NoticesModel.fromJson(jsonData);
    } else {
      throw Exception("Erreur serveur");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: appWhite,
        iconTheme: IconThemeData(color: appBlack),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Commentaires",
              style: TextStyle(
                color: appBlack,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            Text(
              widget.name ?? "",
              style: TextStyle(
                color: appColor2,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),

      body: FutureBuilder<NoticesModel>(
        future: _futureNotices,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text("Aucun commentaire disponible"),
            );
          }

          final data = snapshot.data!;
          final rating = data.ratingSummary;
          final notices = data.notices ?? [];

          return Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [

                /// ⭐ SECTION NOTE
                if (rating != null)
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: appWhite,
                      borderRadius: BorderRadius.circular(3.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Row(
                      children: [

                        /// moyenne
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                rating.average.toString(),
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                  color: appColor,
                                ),
                              ),
                              Text(
                                "sur 5",
                                style: TextStyle(
                                  color: appColor2,
                                  fontSize: 14.sp,
                                ),
                              )
                            ],
                          ),
                        ),

                        /// résumé
                        Expanded(
                          flex: 2,
                          child: RatingSummary(
                            color: appColor,
                            thickness: 6,
                            counter: rating.counter ?? 0,
                            showAverage: false,
                            counterFiveStars: rating.counterFiveStars ?? 0,
                            counterFourStars: rating.counterFourStars ?? 0,
                            counterThreeStars: rating.counterThreeStars ?? 0,
                            counterTwoStars: rating.counterTwoStars ?? 0,
                            counterOneStars: rating.counterOneStars ?? 0,
                          ),
                        ),
                      ],
                    ),
                  ),

                Gap(3.h),

                /// LISTE COMMENTAIRES
                Expanded(
                  child: ListView.builder(
                    itemCount: notices.length,
                    itemBuilder: (context, index) {

                      final notice = notices[index];

                      return Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: appWhite,
                          borderRadius: BorderRadius.circular(3.w),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .05),
                              blurRadius: 8,
                            )
                          ],
                        ),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// avatar
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: NetworkImage(
                                notice.userPicture ?? "",
                              ),
                              onBackgroundImageError: (_, __) {},
                              child: notice.userPicture == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),

                            Gap(3.w),

                            /// contenu
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  /// nom + date
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        notice.userName ?? "",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.sp,
                                        ),
                                      ),

                                      Text(
                                        notice.dateNotice ?? "",
                                        style: TextStyle(
                                          color: appTextTwo,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Gap(.5.h),

                                  /// étoiles
                                  StarRating(
                                    size: 14,
                                    rating: (notice.note ?? 0).toDouble(),
                                    color: Colors.orange,
                                  ),

                                  Gap(1.h),

                                  /// commentaire
                                  Text(
                                    notice.details ?? "",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: appBlack,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}