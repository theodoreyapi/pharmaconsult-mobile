import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/themes/themes.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/medicaments/medicament_model.dart';
import '../prices.dart';

class PrixPage extends StatefulWidget {
  const PrixPage({super.key});

  @override
  State<PrixPage> createState() => _PrixPageState();
}

class _PrixPageState extends State<PrixPage> {
  final TextEditingController _searchController = TextEditingController();

  List<MedicamentsModels> _allMedicaments = [];
  List<MedicamentsModels> _filteredMedicaments = [];

  bool _isSearching = false;
  Timer? _debounce;
  late Future<List<MedicamentsModels>> _futureMedicaments;

  @override
  void initState() {
    super.initState();
    _futureMedicaments = _fetchInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- LOGIQUE DE RECHERCHE ---

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      final text = query.trim().toLowerCase();

      if (text.isEmpty) {
        setState(() {
          _filteredMedicaments = _allMedicaments;
          _isSearching = false;
        });
        return;
      }

      setState(() => _isSearching = true);

      try {
        // Si moins de 3 caractères, on filtre en local pour la rapidité
        if (text.length < 3) {
          setState(() {
            _filteredMedicaments =
                _allMedicaments
                    .where((m) => m.name!.toLowerCase().contains(text))
                    .toList();
            _isSearching = false;
          });
        } else {
          // Sinon on interroge l'API
          final results = await _apiSearch(text);
          setState(() {
            _filteredMedicaments = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        setState(() => _isSearching = false);
      }
    });
  }

  // --- APPELS API ---

  Future<List<MedicamentsModels>> _fetchInitialData() async {
    final response = await http.get(
      Uri.parse(ApiUrls.getMedicamentUrl),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print(ApiUrls.getMedicamentUrl);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List content = data['content'];
      _allMedicaments =
          content.map((e) => MedicamentsModels.fromJson(e)).toList();
      _filteredMedicaments = _allMedicaments;
      return _allMedicaments;
    }
    throw Exception("Erreur de chargement");
  }

  Future<List<MedicamentsModels>> _apiSearch(String query) async {
    final response = await http.get(
      Uri.parse("${ApiUrls.getMedicamentUrl}?name=$query"),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List content = data['content'];
      return content.map((e) => MedicamentsModels.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appWhite,
      appBar: _buildAppBar(),
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
        child: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: FutureBuilder<List<MedicamentsModels>>(
                future: _futureMedicaments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (snapshot.hasError) return _buildErrorState();

                  return _isSearching
                      ? const Center(
                        child: CircularProgressIndicator.adaptive(),
                      )
                      : _buildListView();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: appColor,
        onPressed:
            () => setState(() => _futureMedicaments = _fetchInitialData()),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  // --- WIDGETS UI ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: appFondLogin,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Liste des Medicaments",
            style: TextStyle(
              color: appBlack,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          Text(
            "Liste, Prix et Notice des Médicaments",
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
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Rechercher un médicament...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: appWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    if (_filteredMedicaments.isEmpty) {
      return Center(
        child: Text(
          "Aucun médicament trouvé",
          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(4.w),
      itemCount: _filteredMedicaments.length,
      separatorBuilder: (_, __) => const Divider(height: 25),
      itemBuilder: (context, index) {
        final med = _filteredMedicaments[index];
        return _buildMedCard(med);
      },
    );
  }

  Widget _buildMedCard(MedicamentsModels med) {
    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailPrixMedocPage(medoc: med)),
          ),
      child: Row(
        children: [
          // Image avec placeholder
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: appFondLogin,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  med.medicamentPicture != null
                      ? Image.network(
                        med.medicamentPicture!,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, __, ___) =>
                                Image.asset("assets/images/medicament.jpg"),
                      )
                      : Image.asset("assets/images/medicament.jpg"),
            ),
          ),
          Gap(4.w),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name ?? "Inconnu",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: appBlack,
                  ),
                ),
                Gap(0.5.h),
                Text(
                  "${med.price} FCFA",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: appColorRed,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          "Une erreur est survenue lors de la récupération des prix."
          "\n\nContactez le support si cela persiste.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
