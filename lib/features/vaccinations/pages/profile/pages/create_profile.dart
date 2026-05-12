import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaconsult/core/constants/constants.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class NewProfileSheet extends StatefulWidget {
  const NewProfileSheet({super.key});

  @override
  State<NewProfileSheet> createState() => _NewProfileSheetState();
}

class _NewProfileSheetState extends State<NewProfileSheet>
    with WidgetsBindingObserver {
  // ── Contrôleurs ────────────────────────────────────────────────────────────
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();

  // ── État du formulaire ────────────────────────────────────────────────────
  String _profileType = 'human'; // 'human' | 'animal'
  String _selectedGender = 'masculin';
  bool _frequentTraveler = false;
  bool _isSubmitting = false;

  String? _selectedRelation;
  String _relationSearch = '';

  String? _selectedAnimalType;

  // ── Données statiques ─────────────────────────────────────────────────────
  static const _animalTypes = ['Chien', 'Chat', 'Cheval', 'Lapin', 'Oiseau'];
  static const _allRelations = [
    'Moi-même',
    'Parent',
    'Enfant',
    'Frère',
    'Sœur',
    'Conjoint',
    'Ami',
  ];

  List<String> get _filteredRelations =>
      _allRelations
          .where((r) => r.toLowerCase().contains(_relationSearch.toLowerCase()))
          .toList();

  bool _waitingForReturn = false;
  StreamSubscription<Uri>? _linkSubscription;
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    _nameController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  void _initDeepLinks() {
    // Écouter les deep links entrants
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      if (!mounted) return;

      // pharmaconsults://payment/successvacci
      if (uri.scheme == 'pharmaconsults' &&
          uri.host == 'payment' &&
          uri.pathSegments.contains('successvacci')) {
        _waitingForReturn = false;

        Navigator.pop(context, true);

        SnackbarHelper.showSuccess(context, "Paiement approuvé. Profil activé");
      }

      // pharmaconsults://payment/errorvacci (optionnel)
      if (uri.scheme == 'pharmaconsults' &&
          uri.host == 'payment' &&
          uri.pathSegments.contains('errorvacci')) {
        _waitingForReturn = false;

        Navigator.pop(context, true);

        SnackbarHelper.showError(
          context,
          "Paiement échoué. Votre profil reste inactif. Cliquez pour réessayer!!",
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && _waitingForReturn) {
      _waitingForReturn = false;

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  // ── Validation ────────────────────────────────────────────────────────────

  String? _validate() {
    if (_nameController.text.trim().isEmpty) {
      return 'Le nom du profil est requis.';
    }
    if (_profileType == 'human' && _selectedRelation == null) {
      return 'Veuillez choisir une relation.';
    }
    if (_profileType == 'animal' && _selectedAnimalType == null) {
      return "Veuillez choisir le type d'animal.";
    }
    return null;
  }

  // ── API ───────────────────────────────────────────────────────────────────

  Future<void> _createProfile() async {
    final error = _validate();
    if (error != null) {
      _showSnack(error, isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final id = SharedPreferencesHelper().getString("identifiant")!;
      final body = {
        'id_user': id,
        'name': _nameController.text.trim(),
        'profile_type': _profileType,
        'relation': _profileType == 'human' ? _selectedRelation : null,
        'animal_type': _profileType == 'animal' ? _selectedAnimalType : null,
        'gender': _selectedGender,
        'birth_date':
            _birthController.text.isNotEmpty
                ? _parseBirthDate(_birthController.text)
                : null,
        'is_frequent_traveler': _frequentTraveler,
      };

      final response = await http.post(
        Uri.parse(ApiUrls.postCreateProfile),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        Navigator.pop(context, true); // true = succès → déclenche refresh
        _showSnack(
          'Profil "${_nameController.text.trim()}" créé avec succès !',
        );
      } else if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _showSnack('Profil créé. Paiement requis pour activation.');

        final url = data['rechargement_url'];

        // ✅ Flag activé AVANT launchUrl
        setState(() => _waitingForReturn = true);

        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        final msg = _parseError(response.body);
        _showSnack(msg, isError: true);
      }
    } catch (_) {
      if (mounted) {
        _showSnack('Erreur réseau. Vérifiez votre connexion.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// "15/03/1995" → "1995-03-15"
  String? _parseBirthDate(String input) {
    try {
      final parts = input.split('/');
      if (parts.length == 3) return '${parts[2]}-${parts[1]}-${parts[0]}';
    } catch (_) {}
    return null;
  }

  String _parseError(String body) {
    try {
      final json_body = json.decode(body);
      if (json_body is Map && json_body['message'] != null) {
        return json_body['message'];
      }
    } catch (_) {}
    return 'Une erreur est survenue.';
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Date picker ───────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
    );
    if (dt != null) {
      setState(() {
        _birthController.text =
            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Nom ────────────────────────────────────────────────────
            _label('Nom du profil'),
            _textField(
              controller: _nameController,
              hint: 'Ex: Yapi, Rex, Grand-père…',
              icon: Icons.person_outline,
            ),
            Gap(2.h),

            // ── Type ───────────────────────────────────────────────────
            _label('Type de profil'),
            _buildTypeToggle(),
            Gap(2.h),

            // ── Conditionnel humain / animal ───────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child:
                  _profileType == 'human'
                      ? _buildRelationSection()
                      : _buildAnimalSection(),
            ),
            Gap(2.h),

            // ── Date de naissance ──────────────────────────────────────
            _label(
              _profileType == 'human'
                  ? 'Date de naissance'
                  : 'Date de naissance ou âge estimé',
            ),
            _buildDateField(),
            Gap(2.h),

            // ── Genre ──────────────────────────────────────────────────
            _label('Genre'),
            _buildGenderSelector(),
            Gap(2.h),

            // ── Voyage fréquent ────────────────────────────────────────
            _buildTravelSection(),
            Gap(2.h),

            // ── Facturation ────────────────────────────────────────────
            _buildBillingSection(),
            Gap(3.h),

            // ── Boutons ────────────────────────────────────────────────
            _buildActions(),
            Gap(2.h),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nouveau profil santé',
            style: TextStyle(
              color: appBlack,
              fontWeight: FontWeight.bold,
              fontSize: 17.sp,
            ),
          ),
          Text(
            'Remplissez les informations du profil',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11.sp),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.black, size: 18),
          ),
        ),
        Gap(1.w),
      ],
    );
  }

  // ── Toggle Humain / Animal ────────────────────────────────────────────────

  Widget _buildTypeToggle() {
    return Row(
      children: [
        _toggleBtn(
          label: 'Humain',
          icon: Icons.person_outline,
          isSelected: _profileType == 'human',
          onTap:
              () => setState(() {
                _profileType = 'human';
                _selectedAnimalType = null;
              }),
        ),
        Gap(2.w),
        _toggleBtn(
          label: 'Animal',
          icon: Icons.pets,
          isSelected: _profileType == 'animal',
          onTap:
              () => setState(() {
                _profileType = 'animal';
                _selectedRelation = null;
              }),
        ),
      ],
    );
  }

  Widget _toggleBtn({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? appColor.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(
              color: isSelected ? appColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? appColor : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? appColor : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section Relation (Humain) ─────────────────────────────────────────────

  Widget _buildRelationSection() {
    return Column(
      key: const ValueKey('human'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Relation'),
        if (_selectedRelation != null)
          _selectedBadge(
            _selectedRelation!,
            onClear: () => setState(() => _selectedRelation = null),
          )
        else ...[
          TextField(
            onChanged: (v) => setState(() => _relationSearch = v),
            decoration: InputDecoration(
              hintText: 'Rechercher une relation…',
              prefixIcon: Icon(Icons.search, color: appColor, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.w),
                borderSide: const BorderSide(color: Color(0xFFE8F5E9)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3.w),
                borderSide: BorderSide(color: appColor),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(color: const Color(0xFFE8F5E9)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredRelations.length,
              separatorBuilder:
                  (_, __) => const Divider(
                    height: 1,
                    color: Color(0xFFE8F5E9),
                    indent: 15,
                    endIndent: 15,
                  ),
              itemBuilder: (_, i) {
                final rel = _filteredRelations[i];
                return ListTile(
                  dense: true,
                  title: Text(
                    rel,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trailing: Icon(
                    Icons.add,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                  onTap: () => setState(() => _selectedRelation = rel),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // ── Section Animal ────────────────────────────────────────────────────────

  Widget _buildAnimalSection() {
    return Column(
      key: const ValueKey('animal'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Type d'animal"),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAF8),
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(color: const Color(0xFFE8F5E9)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedAnimalType,
              hint: Text(
                "Sélectionnez un type d'animal",
                style: TextStyle(color: Colors.grey.shade400),
              ),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items:
                  _animalTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
              onChanged: (v) => setState(() => _selectedAnimalType = v),
            ),
          ),
        ),
      ],
    );
  }

  // ── Champ date ────────────────────────────────────────────────────────────

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickDate,
          child: AbsorbPointer(
            child: TextField(
              controller: _birthController,
              decoration: InputDecoration(
                hintText: 'jj/mm/aaaa',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                suffixIcon: const Icon(
                  Icons.edit_calendar_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.w),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.w),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.w),
                  borderSide: BorderSide(color: appColor, width: 1.5),
                ),
              ),
            ),
          ),
        ),
        if (_profileType == 'animal') ...[
          const SizedBox(height: 4),
          Text(
            "Si la date exacte est inconnue, entrez une date approximative",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
          ),
        ],
      ],
    );
  }

  // ── Sélection genre ───────────────────────────────────────────────────────

  Widget _buildGenderSelector() {
    return Row(
      children: [
        _genderOption('masculin', '♂ Masculin'),
        Gap(2.w),
        _genderOption('feminin', '♀ Féminin'),
      ],
    );
  }

  Widget _genderOption(String value, String label) {
    final selected = _selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? appColor.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(
              color: selected ? appColor : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? appColor : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section voyage ────────────────────────────────────────────────────────

  Widget _buildTravelSection() {
    return GestureDetector(
      onTap: () => setState(() => _frequentTraveler = !_frequentTraveler),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color:
              _frequentTraveler
                  ? const Color(0xFFFFFBEB)
                  : const Color(0xFFF8FAF8),
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color:
                _frequentTraveler
                    ? const Color(0xFFD97706)
                    : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.flight_outlined,
              color:
                  _frequentTraveler
                      ? const Color(0xFFD97706)
                      : Colors.grey.shade400,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voyage fréquemment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color:
                          _frequentTraveler
                              ? const Color(0xFFD97706)
                              : Colors.black87,
                    ),
                  ),
                  Text(
                    'Activer pour recevoir des recommandations de vaccins voyageurs',
                    style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: _frequentTraveler,
              onChanged: (v) => setState(() => _frequentTraveler = v),
              activeColor: const Color(0xFFD97706),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section facturation ───────────────────────────────────────────────────

  Widget _buildBillingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1E4FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.credit_card_outlined,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Facturation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A237E),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tarif par profil :',
                style: TextStyle(
                  color: const Color(0xFF1A237E),
                  fontSize: 13.sp,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '1 000 FCFA / an',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A237E),
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Chaque profil créé sera facturé annuellement à hauteur de 1 000 FCFA '
            'dans le cadre de votre abonnement.',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blue.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Boutons d'action ──────────────────────────────────────────────────────

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 3.w),
              foregroundColor: appColor,
              side: BorderSide(color: appColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.w),
              ),
            ),
            child: Text(
              'Annuler',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
        ),
        Gap(3.w),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _createProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: appColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 3.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.w),
              ),
            ),
            child:
                _isSubmitting
                    ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : Text(
                      'Créer le profil',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  // ── Petits widgets utilitaires ────────────────────────────────────────────

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.w)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: BorderSide(color: appColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _selectedBadge(String label, {required VoidCallback onClear}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: appColor,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
