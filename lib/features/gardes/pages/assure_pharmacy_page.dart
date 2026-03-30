import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pharmaconsult/models/pharmacies/pharmacie_model.dart';
import 'package:sizer/sizer.dart';

import '../../../core/themes/app_colors.dart';
import '../../../core/widgets/inputs/inputs.dart';

class AssurePharmacyPage extends StatefulWidget {
  final List<Assurances>? assurances;
  const AssurePharmacyPage({super.key, this.assurances});

  @override
  State<AssurePharmacyPage> createState() => _AssurePharmacyPageState();
}

class _AssurePharmacyPageState extends State<AssurePharmacyPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Assurances> _filteredAssurances = [];

  @override
  void initState() {
    super.initState();
    // Initialisation directe sans délai pour plus de fluidité
    _filteredAssurances = widget.assurances ?? [];
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAssurances = widget.assurances?.where((assurance) {
        return assurance.name!.toLowerCase().contains(query);
      }).toList() ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBox(),
            Expanded(
              child: _filteredAssurances.isEmpty
                  ? _buildEmptyState()
                  : _buildGrid(),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPOSANTS UI ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: appWhite,
      elevation: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Assurances partenaires",
              style: TextStyle(
                color: appBlack,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            Text(
              "${widget.assurances?.length ?? 0} assurances acceptées",
              style: TextStyle(
                color: appColor2,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: InputText(
        hintText: "Rechercher une assurance...",
        colorFille: appFondLogin,
        controller: _searchController,
        prefixIcon: Icon(Icons.search, color: appColor),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: _filteredAssurances.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Réduit à 3 pour une meilleure lisibilité des noms
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final item = _filteredAssurances[index];
        return _buildAssuranceCard(item);
      },
    );
  }

  Widget _buildAssuranceCard(Assurances item) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: appWhite,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(color: appColorDivider.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.network(
                item.assurancePicture ?? "",
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.health_and_safety_outlined, color: appColor, size: 30),
              ),
            ),
          ),
        ),
        Gap(1.h),
        Text(
          item.name ?? "Inconnue",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: appBlack,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 40.sp, color: Colors.grey[300]),
          Gap(2.h),
          Text(
            "Aucune assurance trouvée",
            style: TextStyle(color: Colors.grey, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}