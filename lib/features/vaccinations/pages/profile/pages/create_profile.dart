import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/widgets/widgets.dart';
import 'package:sizer/sizer.dart';

import 'add_vaccin.dart';

class NewProfileSheet extends StatefulWidget {
  const NewProfileSheet({super.key});

  @override
  State<NewProfileSheet> createState() => _NewProfileSheetState();
}

class _NewProfileSheetState extends State<NewProfileSheet> {
  String? _selectedAnimalType;
  final List<String> _animalTypes = [
    "Chien",
    "Chat",
    "Cheval",
    "Lapin",
    "Oiseau",
  ];

  String? _selectedRelation;
  String _searchQuery = "";
  final List<String> _allRelations = [
    "Moi-meme",
    "Parent",
    "Enfant",
    "Frere",
    "Soeur",
    "Conjoint",
    "Ami",
  ];

  // Simulation d'un vaccin ajouté
  List<Map<String, dynamic>> get _addedVaccins => [
    {
      "name": "Pneumocoques",
      "date": "14/03/2026",
      "place": "Centre public",
      "rappel": "14/03/2031",
    },
  ];

  // Liste filtrée selon la recherche
  List<String> get _filteredRelations =>
      _allRelations
          .where((r) => r.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

  // Variables d'état pour le formulaire
  int _profileTypeIndex = 0; // 0 pour Humain, 1 pour Animal
  String _selectedGender = 'Masculin';
  bool _frequentTraveler = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Nouveau profil',
          style: TextStyle(color: appBlack, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Nom du profil"),
            TextField(
              decoration: InputDecoration(
                hintText: 'Yapi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            Gap(2.h),

            _buildLabel("Type de profil"),
            Row(
              children: [
                _buildToggleButton("Humain", _profileTypeIndex == 0, () {
                  setState(() => _profileTypeIndex = 0);
                }),
                const Gap(10),
                _buildToggleButton("Animal", _profileTypeIndex == 1, () {
                  setState(() => _profileTypeIndex = 1);
                }),
              ],
            ),
            Gap(2.h),

            // --- DÉBUT DE LA LOGIQUE CONDITIONNELLE ---
            if (_profileTypeIndex == 0) ...[
              // Champs pour l'Humain (Relation)
              _buildLabel("Relation"),
              _selectedRelation == null
                  ? Column(
                    children: [
                      // Barre de recherche
                      TextField(
                        onChanged:
                            (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Rechercher une relation...',
                          prefixIcon: Icon(Icons.search, color: appColor),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3.w),
                            borderSide: BorderSide(color: Color(0xFFE8F5E9)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3.w),
                            borderSide: BorderSide(color: appColor),
                          ),
                        ),
                      ),
                      const Gap(10),
                      // Liste des relations
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3.w),
                          border: Border.all(color: const Color(0xFFE8F5E9)),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          // Important pour le mettre dans une Column
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredRelations.length,
                          separatorBuilder:
                              (context, index) => const Divider(
                                height: 1,
                                color: Color(0xFFE8F5E9),
                                indent: 15,
                                endIndent: 15,
                              ),
                          itemBuilder: (context, index) {
                            final relation = _filteredRelations[index];
                            return ListTile(
                              title: Text(
                                relation,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Icon(
                                Icons.add,
                                color: Colors.grey.shade300,
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedRelation = relation;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  )
                  : // Affichage du badge une fois sélectionné (le code reste le même que précédemment)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: appColor,
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 18),
                        Gap(2.w),
                        Text(
                          _selectedRelation!,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _selectedRelation = null),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
            ] else ...[
              // Champs pour l'Animal
              _buildLabel("Type d'animal"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8F5E9)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    hint: const Text("Selectionnez un type d'animal"),
                    value: _selectedAnimalType,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                    items:
                        _animalTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                    onChanged:
                        (val) => setState(() => _selectedAnimalType = val),
                  ),
                ),
              ),
            ],

            // --- FIN DE LA LOGIQUE CONDITIONNELLE ---
            Gap(2.h),

            // Label Date de naissance adapté
            _buildLabel(
              _profileTypeIndex == 0
                  ? "Date de naissance"
                  : "Date de naissance ou age estime",
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'jj/mm/aaaa',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.w),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.w),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                // Petit texte d'aide sous le champ pour l'animal
                helperText:
                    _profileTypeIndex == 1
                        ? "Si la date exacte est inconnue, "
                            "entrez une date approximative"
                        : null,
              ),
            ),

            Gap(2.h),

            _buildLabel("Genre"),
            Row(
              children: [
                Radio<String>(
                  value: 'Masculin',
                  groupValue: _selectedGender,
                  onChanged: (val) => setState(() => _selectedGender = val!),
                ),
                Text("Masculin"),
                Gap(1.h),
                Radio<String>(
                  value: 'Feminin',
                  groupValue: _selectedGender,
                  onChanged: (val) => setState(() => _selectedGender = val!),
                ),
                Text("Feminin"),
              ],
            ),
            Gap(2.h),

            // Section Voyage
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF8),
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _frequentTraveler,
                    onChanged:
                        (val) => setState(() => _frequentTraveler = val!),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Voyage frequemment",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Activer pour recevoir des recommandations de vaccins pour voyageurs",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap(20),

            // Section Vaccination
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E9).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Vaccinations (0)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(
                        height: 8.w,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showBarModalBottomSheet(
                              isDismissible: false,
                              enableDrag: false,
                              expand: true,

                              context: context,
                              builder: (context) => AddVaccin(),
                            );
                          },
                          icon: Icon(
                            Icons.add,
                            size: 15.sp,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Ajouter un vaccin",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.sp,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.w),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(2.h),
                  // Note d'information
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(3.w),
                      border: const Border(
                        left: BorderSide(color: Colors.blue, width: 4),
                      ),
                    ),
                    child: Text(
                      "Note: Vous pouvez ajouter autant de vaccins que "
                      "nécessaire. Si vous n'avez pas encore fait de vaccin, "
                      "vous pouvez ignorer cette section et continuer. "
                      "Vous pourrez ajouter vos vaccins plus tard.",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    "Aucune vaccination enregistrée. "
                    "Cliquez sur \"Ajouter un vaccin\" pour commencer.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 14.sp),
                  ),

                  // Liste des cartes de vaccins
                  ..._addedVaccins
                      .map((vaccin) => _buildVaccinCard(vaccin))
                      .toList(),
                ],
              ),
            ),
            const Gap(20),
            // Section Facturation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD1E4FF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.blue, size: 20),
                      Gap(10),
                      Text(
                        "Facturation",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tarif par profil:",
                        style: TextStyle(color: Color(0xFF1A237E)),
                      ),
                      Text(
                        "2000 FCFA/an",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    ],
                  ),
                  const Gap(10),
                  Text(
                    "Chaque profil crée sera facture annuellement a "
                    "hauteur de 2000 FCFA dans le cadre de "
                    "votre abonnement.",
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),

            Gap(2.5.h),
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: SubmitButton(
                    onPressed: () {},
                    "Creer le profil",
                    height: 12.w,
                    fontSize: 15.sp,
                  ),
                ),
                Expanded(
                  child: CancelButton(
                    onPressed: () => Navigator.pop(context),
                    "Annuler",
                    height: 12.w,
                    fontSize: 15.sp,
                    textcouleur: appColor,
                  ),
                ),
              ],
            ),
            Gap(2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinCard(Map<String, dynamic> vaccin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                vaccin['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A8D11),
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.edit_outlined,
                      color: Colors.blue.shade400,
                      size: 20,
                    ),
                  ),
                  Gap(1.h),
                  GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(5),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const Gap(5),
              Text(
                vaccin['date'],
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const Gap(5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              vaccin['place'],
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Gap(5),
          Row(
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                size: 14,
                color: Colors.orange,
              ),
              const Gap(5),
              Text(
                "Rappel: ${vaccin['rappel']}",
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
