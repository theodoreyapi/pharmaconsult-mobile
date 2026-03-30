import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rating_summary/rating_summary.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/date_symbol_data_local.dart';

// Supposons que tes imports restent les mêmes
import '../../../core/constants/constants.dart';
import '../../../core/themes/app_colors.dart';
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
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _futureNotices = fetchNotices();
  }

  Future<NoticesModel> fetchNotices() async {
    final response = await http.get(
      Uri.parse(ApiUrls.getListNotice(widget.pharmacie!)),
      headers: {'Content-Type': 'application/json'},
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
      backgroundColor: const Color(0xFFF8F9FA),
      // Un gris très léger pour faire ressortir le blanc
      appBar: _buildAppBar(context),
      body: FutureBuilder<NoticesModel>(
        future: _futureNotices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              (snapshot.data!.notices?.isEmpty ?? true)) {
            return _buildEmptyState();
          }

          final data = snapshot.data!;
          final rating = data.ratingSummary;
          final notices = data.notices!;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header avec le résumé des notes
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: _buildRatingSummaryCard(rating),
                ),
              ),

              // Titre de section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  child: Text(
                    "${notices.length} Avis clients",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: appBlack.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),

              // Liste des commentaires
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildCommentCard(notices[index]),
                  childCount: notices.length,
                ),
              ),
              const SliverGap(40),
            ],
          );
        },
      ),
    );
  }

  // --- COMPOSANTS UI ---

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Avis & Commentaires",
            style: TextStyle(
              color: appBlack,
              fontWeight: FontWeight.w800,
              fontSize: 16.sp,
            ),
          ),
          Text(
            widget.name ?? "Pharmacie",
            style: TextStyle(
              color: appColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummaryCard(dynamic rating) {
    if (rating == null) return const SizedBox();
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  rating.average.toString(),
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    color: appBlack,
                  ),
                ),
                StarRating(
                  rating: (rating.average ?? 0.0).toDouble(),
                  color: Colors.orangeAccent,
                  size: 18,
                ),
                Gap(0.5.h),
                Text(
                  "${rating.counter} avis",
                  style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                ),
              ],
            ),
          ),
          const VerticalDivider(),
          Expanded(
            flex: 3,
            child: RatingSummary(
              counter: rating.counter ?? 0,
              average: (rating.average ?? 0).toDouble(),
              showAverage: false,
              color: appColor,
              counterFiveStars: rating.counterFiveStars ?? 0,
              counterFourStars: rating.counterFourStars ?? 0,
              counterThreeStars: rating.counterThreeStars ?? 0,
              counterTwoStars: rating.counterTwoStars ?? 0,
              counterOneStars: rating.counterOneStars ?? 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(dynamic notice) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: appColor.withValues(alpha: 0.1),
                backgroundImage:
                    notice.userPicture != null
                        ? NetworkImage(notice.userPicture!)
                        : null,
                child:
                    notice.userPicture == null
                        ? Icon(Icons.person, color: appColor)
                        : null,
              ),
              Gap(3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notice.userName ?? "Anonyme",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    Text(
                      formatRelativeDate(notice.dateNotice ?? ""),
                      style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const Gap(4),
                    Text(
                      "${notice.note}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(1.5.h),
          Text(
            notice.details ?? "",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          Gap(2.h),
          Text(
            "Aucun avis pour le moment",
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
