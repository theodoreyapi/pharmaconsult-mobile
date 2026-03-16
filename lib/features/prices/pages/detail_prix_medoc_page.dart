import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sizer/sizer.dart';

import '../../../core/themes/app_colors.dart';
import '../../../models/medicaments/medicament_model.dart';
import '../prices.dart';

class DetailPrixMedocPage extends StatefulWidget {
  final MedicamentsModels? medoc; // final est préférable ici

  const DetailPrixMedocPage({super.key, this.medoc});

  @override
  State<DetailPrixMedocPage> createState() => _DetailPrixMedocPageState();
}

class _DetailPrixMedocPageState extends State<DetailPrixMedocPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.medoc == null)
      return const Scaffold(body: Center(child: Text("Erreur de données")));

    return Scaffold(
      backgroundColor: appWhite,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  Gap(3.h),
                  _buildActivePrincipleSection(),
                  Gap(3.h),
                  _buildSubstitutesButton(),
                  Gap(3.h),
                  _buildNoticeSection(),
                  const Gap(40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPOSANTS UI ---

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      elevation: 0,
      backgroundColor: appFondLogin,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: appWhite,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: appBlack),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Center(
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Hero(
              tag: 'med_${widget.medoc!.id}',
              child: Image.network(
                widget.medoc!.medicamentPicture!,
                fit: BoxFit.contain,
                errorBuilder:
                    (_, __, ___) => Image.asset("assets/images/medicament.jpg"),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.medoc!.name!.toUpperCase(),
          style: TextStyle(
            color: appBlack,
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        Gap(1.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: appColorRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "${widget.medoc!.price!} FCFA",
            style: TextStyle(
              color: appColorRed,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivePrincipleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Principe actif"),
        Gap(1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: appFondLogin,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: appColorContact),
          ),
          child: Text(
            widget.medoc!.principeActif ?? "Non spécifié",
            style: TextStyle(
              color: appColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubstitutesButton() {
    return InkWell(
      onTap:
          () => _openModal(
            SubstanceMedocPage(
              substitutes: widget.medoc!.substitutes!,
              libelle: widget.medoc!.name!,
            ),
          ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: appColor,
          borderRadius: BorderRadius.circular(3.w),
          boxShadow: [
            BoxShadow(
              color: appColor.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.swap_horiz_rounded, color: appWhite),
            Gap(3.w),
            Text(
              "Voir les substituts génériques",
              style: TextStyle(
                color: appWhite,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: appWhite, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Notice du Médicament"),
        Gap(1.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: appWhite,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: appColorDivider),
          ),
          child: Column(
            children: [
              Text(
                "Lisez attentivement ces informations avant toute utilisation. Ce guide ne remplace pas l'avis d'un professionnel de santé.",
                style: TextStyle(
                  color: appColor2,
                  fontSize: 15.sp,
                  height: 1.5,
                ),
              ),
              const Divider(height: 30),
              TextButton.icon(
                onPressed:
                    () => _openModal(
                      NoticeMedocPage(
                        notice: widget.medoc!.notice!,
                        libelle: widget.medoc!.name!,
                      ),
                    ),
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text("Lire la notice complète"),
                style: TextButton.styleFrom(foregroundColor: appColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: appBlack,
        fontSize: 13.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _openModal(Widget page) {
    showBarModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      expand: true,
      topControl: Align(
        alignment: Alignment.centerLeft,
        child: FloatingActionButton.small(
          backgroundColor: appWhite,
          shape: const CircleBorder(),
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(Icons.close, color: appBlack),
        ),
      ),
      builder: (context) => page,
    );
  }
}
