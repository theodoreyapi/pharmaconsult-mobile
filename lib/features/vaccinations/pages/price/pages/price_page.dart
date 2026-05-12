import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pharmaconsult/core/constants/constants.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/models/communes/commune_model.dart';
import 'package:pharmaconsult/models/pharmacies/pharmacie_model.dart';
import 'package:pharmaconsult/models/vaccines/categorie_model.dart';
import 'package:pharmaconsult/models/vaccines/vaccine_model.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/utils/utils.dart';

// ─── Page principale ──────────────────────────────────────────────────────────

class PricePage extends StatefulWidget {
  PricePage({super.key});

  @override
  State<PricePage> createState() => _PricePageState();
}

class _PricePageState extends State<PricePage> {
  // ── Contrôleurs & état ────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();

  List<VaccineModel> _allVaccines = [];
  List<VaccineModel> _filteredVaccines = [];
  List<CategorieModel> _categories = [];

  bool _isSearching = false;
  Timer? _debounce;

  late Future<void> _futureInit;
  CategorieModel? _selectedCategory; // null = "Tous les vaccins"
  bool _hasInteracted = false; // true après premier filtre ou recherche

  // ── Cycle de vie ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _futureInit = _fetchInitialData();
    _searchController.addListener(
      () => _onSearchChanged(_searchController.text),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Appels API ────────────────────────────────────────────────────────────

  Future<void> _fetchInitialData() async {
    await Future.wait([_fetchVaccines(), _fetchCategories()]);
    // _filteredVaccines reste vide : rien affiché tant que l'utilisateur
    // n'a pas choisi une catégorie ou saisi une recherche
  }

  Future<void> _fetchVaccines() async {
    final response = await http.get(
      Uri.parse(ApiUrls.getVaccine),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List body = json.decode(utf8.decode(response.bodyBytes));
      _allVaccines = body.map((e) => VaccineModel.fromJson(e)).toList();
    } else {
      throw Exception(
        "Erreur de chargement des vaccins (${response.statusCode})",
      );
    }
  }

  Future<void> _fetchCategories() async {
    final response = await http.get(
      Uri.parse(ApiUrls.getCategories),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List body = json.decode(utf8.decode(response.bodyBytes));
      // Exclure dès le parsing toute catégorie "Tous les vaccins"
      // (peu importe la casse) : on l'ajoute manuellement en dur
      _categories =
          body
              .map((e) => CategorieModel.fromJson(e))
              .where(
                (c) =>
                    (c.name?.toLowerCase().trim() ?? '') != 'tous les vaccins',
              )
              .toList();
    }
  }

  /// Recherche API combinée : texte + catégorie
  Future<List<VaccineModel>> _apiSearch(
    String query,
    String? categorySlug,
  ) async {
    final params = <String, String>{
      if (query.isNotEmpty) 'search': query,
      if (categorySlug != null && categorySlug.isNotEmpty)
        'category': categorySlug,
    };

    final uri = Uri.parse(ApiUrls.getVaccine).replace(queryParameters: params);
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List body = json.decode(utf8.decode(response.bodyBytes));
      return body.map((e) => VaccineModel.fromJson(e)).toList();
    }
    return [];
  }

  // ── Logique de filtrage ───────────────────────────────────────────────────

  /// Appelé à chaque frappe dans le champ de recherche (avec debounce)
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(Duration(milliseconds: 500), () {
      _applyFilter(searchText: query.trim());
    });
  }

  /// Appelé au clic sur une catégorie (immédiat, sans debounce)
  void _selectCategory(CategorieModel? cat) {
    setState(() => _selectedCategory = cat);
    _applyFilter(searchText: _searchController.text.trim(), immediate: true);
  }

  /// Point d'entrée unique pour tout filtrage (recherche + catégorie)
  Future<void> _applyFilter({
    required String searchText,
    bool immediate = false,
  }) async {
    final text = searchText.toLowerCase();
    final categorySlug = _selectedCategory?.slug;
    final hasText = text.isNotEmpty;
    final hasCategory = _selectedCategory != null;
    _hasInteracted = true;

    // Cas 1 : rien de sélectionné → remettre la liste complète
    if (!hasText && !hasCategory) {
      setState(() {
        _filteredVaccines = List.from(_allVaccines);
        _isSearching = false;
      });
      return;
    }

    // Cas 2 : texte court (< 3 car.) ou catégorie seule → filtre local rapide
    if ((!hasText || text.length < 3) && _allVaccines.isNotEmpty) {
      setState(() {
        _filteredVaccines =
            _allVaccines.where((v) {
              final matchesSearch =
                  !hasText ||
                  (v.name?.toLowerCase().contains(text) ?? false) ||
                  (v.description?.toLowerCase().contains(text) ?? false) ||
                  (v.shortName?.toLowerCase().contains(text) ?? false);
              final matchesCategory =
                  !hasCategory ||
                  (v.categories?.any((c) => c.slug == categorySlug) ?? false);
              return matchesSearch && matchesCategory;
            }).toList();
        _isSearching = false;
      });
      return;
    }

    // Cas 3 : texte long (≥ 3 car.) → appel API
    setState(() => _isSearching = true);
    try {
      final results = await _apiSearch(text, categorySlug);
      if (mounted) {
        setState(() {
          _filteredVaccines = results;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F1),
      body: FutureBuilder<void>(
        future: _futureInit,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }
          return _buildBody();
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchCard(),
          SizedBox(height: 16),
          _buildLegendCard(),
          SizedBox(height: 16),

          // Compteur de résultats (quand un filtre est actif)
          if (_selectedCategory != null || _searchController.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                "${_filteredVaccines.length} vaccin(s) trouvé(s)",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Corps : chargement / vide / liste
          if (_isSearching)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (!_hasInteracted)
            _buildInitialHint()
          else if (_filteredVaccines.isEmpty)
            _buildEmptyState()
          else
            ..._filteredVaccines.map(
              (v) => Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: _VaccineCard(
                  vaccine: v,
                  onReserve: () => _showReservationModal(context, v),
                ),
              ),
            ),

          Gap(1.h),
          _buildImportantNote(),
          Gap(2.h),
        ],
      ),
    );
  }

  // ── Carte de recherche & filtres ──────────────────────────────────────────

  Widget _buildSearchCard() {
    final hasActiveFilter = _selectedCategory != null;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            children: [
              Icon(Icons.attach_money, color: appColor2, size: 28),
              SizedBox(width: 8),
              Text(
                "Prix des Vaccins",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: appColor2,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            "Comparaison des prix entre centres publics et pharmacies privees",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          SizedBox(height: 16),

          // Barre de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Rechercher un vaccin...",
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              // Bouton X pour effacer la recherche
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(Icons.close, color: Colors.grey, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilter(searchText: '');
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: appColor2, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          SizedBox(height: 12),

          // Filtre actif OU liste de catégories
          AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child:
                hasActiveFilter
                    ? _buildActiveFilterChip()
                    : _buildCategoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip() {
    return GestureDetector(
      key: ValueKey('chip'),
      onTap: () => _selectCategory(null),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFF67B04F),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.check, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              _selectedCategory!.name ?? '',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Icon(Icons.close, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      key: ValueKey('list'),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Entrée "Tous les vaccins" (toujours en premier)
          _categoryTile(
            label: "Tous les vaccins",
            isLast: _categories.isEmpty,
            onTap: () => _selectCategory(null),
          ),
          // Catégories dynamiques venant de l'API
          ..._categories.asMap().entries.map((entry) {
            final i = entry.key;
            final cat = entry.value;
            final isLast = i == _categories.length - 1;
            return _categoryTile(
              label: cat.name ?? '',
              isLast: isLast,
              onTap: () => _selectCategory(cat),
            );
          }),
        ],
      ),
    );
  }

  Widget _categoryTile({
    required String label,
    required bool isLast,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          title: Text(label, style: TextStyle(fontSize: 14)),
          trailing: Icon(Icons.add, size: 18, color: Colors.grey),
          onTap: onTap,
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }

  // ── Légende ───────────────────────────────────────────────────────────────

  Widget _buildLegendCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFeff6ff),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: Color(0xFFC6F6D5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Legende des prix",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: appColor2,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 8),
          _legendItem(Colors.green, "Centre public - Tarif reduit"),
          SizedBox(height: 4),
          _legendItem(Colors.blue, "Pharmacie privee - Prix commercial"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  // ── État initial (avant toute interaction) ───────────────────────────────

  Widget _buildInitialHint() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.vaccines_outlined, size: 52, color: Colors.grey.shade300),
          SizedBox(height: 16),
          Text(
            'Recherchez un vaccin',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Choisissez une catégorie ou saisissez le nom d'un vaccin pour voir les prix",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── État vide ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    final isFiltered =
        _selectedCategory != null || _searchController.text.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.search, size: 48, color: Colors.grey.shade300),
          SizedBox(height: 12),
          Text(
            isFiltered ? "Aucun résultat" : "Aucun vaccin disponible",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            isFiltered
                ? "Essayez un autre terme ou une autre catégorie"
                : "Les données seront disponibles prochainement",
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          if (isFiltered) ...[
            SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                _selectCategory(null);
              },
              icon: Icon(Icons.refresh, size: 16),
              label: Text("Réinitialiser les filtres"),
              style: TextButton.styleFrom(foregroundColor: appColor2),
            ),
          ],
        ],
      ),
    );
  }

  // ── État d'erreur ─────────────────────────────────────────────────────────

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, size: 56, color: Colors.grey.shade400),
            SizedBox(height: 12),
            Text(
              "Impossible de charger les données",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed:
                  () => setState(() => _futureInit = _fetchInitialData()),
              icon: Icon(Icons.refresh),
              label: Text("Réessayer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: appColor2,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Note importante ───────────────────────────────────────────────────────

  Widget _buildImportantNote() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(3.w),
        border: Border(left: BorderSide(color: Color(0xFFFA8C16), width: 4)),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 13, color: Colors.black87),
          children: [
            TextSpan(
              text: "Note importante: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: appColorOrangeText,
              ),
            ),
            TextSpan(
              text:
                  "Les prix peuvent varier selon les pharmacies et la disponibilite. "
                  "Contactez directement les centres de sante ou pharmacies pour confirmation.",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: appColorOrangeText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Modal de réservation ──────────────────────────────────────────────────

  void _showReservationModal(BuildContext context, VaccineModel vaccine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReservationModal(vaccine: vaccine),
    );
  }
}

// ─── Carte de vaccin ──────────────────────────────────────────────────────────

class _VaccineCard extends StatelessWidget {
  final VaccineModel vaccine;
  final VoidCallback onReserve;

  _VaccineCard({required this.vaccine, required this.onReserve});

  String formatPrice(dynamic value) {
    if (value == null) return '0';

    final number = double.tryParse(value.toString()) ?? 0;

    return NumberFormat('#,##0', 'fr_FR').format(number);
  }

  String get _publicPriceFormatted {
    final price = vaccine.publicPrice;

    if (price == null || price == '0' || price == '0.00') {
      return 'GRATUIT';
    }

    return '${formatPrice(price)} ${vaccine.currency ?? 'FCFA'}';
  }

  String get _privatePriceFormatted {
    final min = vaccine.privatePriceMin;
    final max = vaccine.privatePriceMax;
    final cur = vaccine.currency ?? 'FCFA';

    if (min == null && max == null) {
      return 'N/A';
    }

    if (min == null) {
      return '${formatPrice(max)} $cur';
    }

    if (max == null) {
      return '${formatPrice(min)} $cur';
    }

    return '${formatPrice(min)} - ${formatPrice(max)} $cur';
  }

  String get _savingsNote {
    final max = vaccine.privatePriceMax;

    if (max != null && max != '0' && max != '0.00') {
      return "Economisez jusqu'a ${formatPrice(max)} ${vaccine.currency ?? 'FCFA'} en allant dans un centre public";
    }

    return "Tarif réduit disponible dans les centres de santé publics";
  }

  String get _importantInfoText {
    final info = vaccine.importantInfo;
    if (info != null && info.isNotEmpty) return info;
    return _publicPriceFormatted == 'GRATUIT'
        ? "Gratuit dans tous les centres de sante publics"
        : "Tarif reduit dans les centres de sante publics";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        border: Border(left: BorderSide(color: appColor2, width: 5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
        ],
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(side: BorderSide.none),
        tilePadding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        childrenPadding: EdgeInsets.zero,
        minTileHeight: 0,
        title: Text(
          vaccine.name ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: appColor2,
            fontSize: 16.sp,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vaccine.description?.isNotEmpty == true)
              Text(
                vaccine.description!,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
            SizedBox(height: 8),

            // Tags catégories
            if (vaccine.categories?.isNotEmpty == true)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children:
                    vaccine.categories!
                        .map((c) => _buildTag(c.name ?? ''))
                        .toList(),
              ),

            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _priceBox(
                    "Centre Public",
                    _publicPriceFormatted,
                    Color(0xFFE6FFFA),
                    Colors.green,
                  ),
                ),
                Gap(2.w),
                Expanded(
                  child: _priceBox(
                    "Centre Prive",
                    _privatePriceFormatted,
                    Color(0xFFEBF4FF),
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                _infoNote(
                  Color(0xFFFFFBE6),
                  Color(0xFFD48806),
                  "Comparaison Public vs Prive",
                  _savingsNote,
                ),
                SizedBox(height: 8),
                _infoNote(
                  Color(0xFFE6F7FF),
                  Color(0xFF1890FF),
                  "Informations importantes",
                  _importantInfoText,
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onReserve,
                    icon: Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text("Reserver pour visite physique"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.black87),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    if (label.isEmpty) return SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFE6F7FF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: Colors.blue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _priceBox(String label, String price, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 2),
          Text(
            price,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoNote(
    Color bgColor,
    Color accentColor,
    String title,
    String text,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(1.w),
        border: Border(left: BorderSide(color: accentColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          SizedBox(height: 2),
          Text(text, style: TextStyle(fontSize: 12.sp, color: Colors.black87)),
        ],
      ),
    );
  }
}

// ─── Modal de réservation ─────────────────────────────────────────────────────

class _ReservationModal extends StatefulWidget {
  final VaccineModel vaccine;

  _ReservationModal({required this.vaccine});

  @override
  State<_ReservationModal> createState() => _ReservationModalState();
}

class _ReservationModalState extends State<_ReservationModal> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  List<CommunesModels> _communes = [];
  List<PharmaciesModels> _pharmacies = [];

  CommunesModels? _selectedCommune;
  PharmaciesModels? _selectedPharmacy;

  bool _loadingPharmacies = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCommunes();
  }

  Future<void> _loadCommunes() async {
    try {
      final data = await fetchCagnotte();

      setState(() {
        _communes = data;
      });
    } catch (_) {}
  }

  Future<List<CommunesModels>> fetchCagnotte() async {
    final http.Response response = await http.get(
      Uri.parse(ApiUrls.getListCommune),
      headers: {'Content-Type': 'application/json'},
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

  Future<void> _loadPharmacies(int communeId) async {
    setState(() => _loadingPharmacies = true);

    try {
      final response = await http.get(
        Uri.parse(ApiUrls.getListPharmaByCity(communeId)),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List body = json.decode(utf8.decode(response.bodyBytes));

        setState(() {
          _pharmacies = body.map((e) => PharmaciesModels.fromJson(e)).toList();
        });
      }
    } catch (_) {}

    setState(() => _loadingPharmacies = false);
  }

  @override
  void dispose() {
    _dateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      locale: Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  String get _publicPriceDisplay {
    final p = widget.vaccine.publicPrice;

    if (p == null || p == '0' || p == '0.00') {
      return 'GRATUIT';
    }

    return '${formatPrice(p)} ${widget.vaccine.currency ?? 'FCFA'}';
  }

  String get _privatePriceDisplay {
    final min = widget.vaccine.privatePriceMin;
    final max = widget.vaccine.privatePriceMax;
    final cur = widget.vaccine.currency ?? 'FCFA';

    if (min == null && max == null) {
      return 'N/A';
    }

    if (min == null) {
      return '${formatPrice(max)} $cur';
    }

    if (max == null) {
      return '${formatPrice(min)} $cur';
    }

    return '${formatPrice(min)} - ${formatPrice(max)} $cur';
  }

  String formatPrice(dynamic value) {
    if (value == null) return '0';

    final number = double.tryParse(value.toString()) ?? 0;

    return NumberFormat('#,##0', 'fr_FR').format(number);
  }

  bool get _isFormValid =>
      _dateController.text.isNotEmpty &&
      _phoneController.text.trim().length >= 8;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // FIX: padding bas dynamique pour éviter le débordement quand le clavier est ouvert
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Barre de drag
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              "Reserver une visite",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E5A27),
              ),
            ),
            SizedBox(height: 16),

            // Vaccin sélectionné
            Text(
              "Vaccin selectionne",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 4),
            Text(
              widget.vaccine.name ?? '',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E5A27),
              ),
            ),
            SizedBox(height: 12),

            // Prix estimatifs
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFEBF4FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Prix estimatifs",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Public: $_publicPriceDisplay",
                    style: TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                  Text(
                    "Prive: $_privatePriceDisplay",
                    style: TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Date
            Text(
              "Date souhaitee",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    hintText: "jj/mm/aaaa",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    suffixIcon: Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Type de centre
            Text(
              "Type de centre",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Commune",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),

                  SizedBox(height: 6),

                  DropdownButtonFormField<CommunesModels>(
                    isExpanded: true,
                    initialValue: _selectedCommune,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    hint: Text(
                      "Choisir une commune",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    items:
                        _communes.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(
                              c.name ?? '',
                              maxLines: 1,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) async {
                      setState(() {
                        _selectedCommune = value;
                        _selectedPharmacy = null;
                        _pharmacies.clear();
                      });

                      if (value != null) {
                        await _loadPharmacies(value.id!);
                      }
                    },
                  ),

                  SizedBox(height: 16),

                  Text(
                    "Pharmacie",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),

                  SizedBox(height: 6),

                  _loadingPharmacies
                      ? Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<PharmaciesModels>(
                        initialValue: _selectedPharmacy,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        hint: Text(
                          "Choisir une pharmacie",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        items:
                            _pharmacies.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p.name ?? '',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPharmacy = value;
                          });
                        },
                      ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Téléphone
            Text(
              "Numero de telephone",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 6),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (_) => setState(() {}),
              // Pour mettre à jour _isFormValid
              decoration: InputDecoration(
                hintText: "+225 XX XX XX XX XX",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.phone, size: 18, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            SizedBox(height: 24),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text("Annuler"),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveAppointment,
                    style: ElevatedButton.styleFrom(
                      // FIX: bouton grisé si formulaire incomplet
                      backgroundColor:
                          _isFormValid
                              ? Color(0xFF2E5A27)
                              : Colors.grey.shade300,
                      foregroundColor:
                          _isFormValid ? Colors.white : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child:
                        _saving
                            ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text("Confirmer"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAppointment() async {
    if (_selectedPharmacy == null ||
        _dateController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final response = await http.post(
        Uri.parse(ApiUrls.postAppointments),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "vaccine_id": widget.vaccine.idVaccine,
          "pharmacy_id": _selectedPharmacy!.id,
          "patient_name": SharedPreferencesHelper().getString('nom'),
          "patient_email": SharedPreferencesHelper().getString('email'),
          "patient_phone": _phoneController.text,
          "appointment_date": _dateController.text,
          "id_user": SharedPreferencesHelper().getString('identifiant'),
          "notes": "",
        }),
      );

      print(response.statusCode);
      debugPrint(response.body, wrapWidth: 1024);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Réservation créée avec succès")),
        );

        Navigator.pop(context);
      }
    } catch (_) {}

    setState(() => _saving = false);
  }
}
