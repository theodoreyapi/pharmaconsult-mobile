import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/inputs/inputs.dart';
import '../../../models/assurances/assurance_model.dart';
import '../assures.dart';

class AssurancePage extends StatefulWidget {
  const AssurancePage({super.key});

  @override
  State<AssurancePage> createState() => _AssurancePageState();
}

class _AssurancePageState extends State<AssurancePage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  late Future<List<AssuranceModel>> _futureAssure;
  List<AssuranceModel> _allAssurances = [];
  List<AssuranceModel> _filteredAssurances = [];

  @override
  void initState() {
    super.initState();
    _futureAssure = _initData();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- LOGIQUE ---

  Future<List<AssuranceModel>> _initData() async {
    final results = await fetchAssure();
    _allAssurances = results;
    _filteredAssurances = results;
    return results;
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final q = _searchController.text.toLowerCase().trim();

      setState(() {
        _filteredAssurances =
            _allAssurances
                .where((a) => a.name!.toLowerCase().contains(q))
                .toList();
      });
    });
  }

  Future<List<AssuranceModel>> fetchAssure() async {
    try {
      final response = await http.get(
        Uri.parse(ApiUrls.getAssureUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print(ApiUrls.getAssureUrl);
      print(response.statusCode);
      debugPrint(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => AssuranceModel.fromJson(json)).toList();
      }
      throw Exception();
    } catch (e) {
      throw Exception("Erreur de connexion");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [appFondLogin, appWhite, appWhite],
            stops: [0.1, 0.4, .4],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildSearchSection(),
            Expanded(
              child: FutureBuilder<List<AssuranceModel>>(
                future: _futureAssure,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (snapshot.hasError) return _buildErrorState();

                  return _buildGrid();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPOSANTS UI ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: appFondLogin,
      title: Text(
        "Liste des Assurances",
        style: TextStyle(
          color: appBlack,
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
        ),
      ),
      centerTitle: false,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close_outlined),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: InputText(
          hintText: "Rechercher votre assurance...",
          colorFille: appWhite,
          controller: _searchController,
          prefixIcon: Icon(Icons.search_rounded, color: appColor),
          suffixIcon: IconButton(
            icon: Icon(Icons.close, color: appColor),
            onPressed: () {
              _searchController.clear();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    if (_filteredAssurances.isEmpty) {
      return const Center(
        child: Text("Aucune assurance ne correspond à votre recherche."),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: _filteredAssurances.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final assurance = _filteredAssurances[index];
        return _buildAssuranceCard(assurance);
      },
    );
  }

  Widget _buildAssuranceCard(AssuranceModel item) {
    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PharmacyAssureListPage(identifiant: item.id),
            ),
          ),
      borderRadius: BorderRadius.circular(3.w),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appWhite,
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(color: appFondLogin),
              ),
              child: Image.network(
                item.assurancePicture?.replaceAll(" ", "%20") ?? "",
                fit: BoxFit.contain,
                errorBuilder:
                    (_, __, ___) => Icon(
                      Icons.health_and_safety,
                      color: appColor,
                      size: 30,
                    ),
              ),
            ),
          ),
          Gap(1.h),
          Text(
            item.name ?? '',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: appBlack,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 40.sp, color: Colors.grey),
            Gap(2.h),
            const Text(
              "Impossible de charger les assurances.\n Vérifiez votre connexion.",
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () => setState(() => _futureAssure = _initData()),
              child: const Text("Réessayer"),
            ),
          ],
        ),
      ),
    );
  }
}
