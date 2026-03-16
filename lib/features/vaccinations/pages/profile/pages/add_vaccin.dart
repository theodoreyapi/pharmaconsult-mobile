import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pharmaconsult/core/widgets/widgets.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/themes/app_colors.dart';

class AddVaccin extends StatefulWidget {
  const AddVaccin({super.key});

  @override
  State<AddVaccin> createState() => _AddVaccinState();
}

class _AddVaccinState extends State<AddVaccin> {
  String? _selectedVaccin;
  String _vaccinSearchQuery = "";
  String _centerType = "public"; // public ou prive

  bool _hasSelectedImage = false;

  final List<String> _availableVaccins = [
    "Hexavalent",
    "Pneumocoques",
    "Rotavirus",
    "RRO (Rougeole-Rubeole-Oreillons)",
    "Meningocoques ACWY",
  ];

  List<String> get _filteredVaccins =>
      _availableVaccins
          .where(
            (v) => v.toLowerCase().contains(_vaccinSearchQuery.toLowerCase()),
          )
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ajouter une vaccination",
              style: TextStyle(
                color: appBlack,
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            Text(
              "Pour: Yapi",
              style: TextStyle(
                color: appColor2,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ],
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
            _buildLabel("Nom du vaccin"),
            _selectedVaccin == null
                ? _buildVaccinSearchList()
                : _buildSelectedVaccinBadge(),

            Gap(2.h),
            _buildLabel("Date du vaccin"),
            _buildDateField("jj/mm/aaaa"),

            Gap(2.h),
            _buildLabel("Prochain rappel"),
            _buildDateField("jj/mm/aaaa", isGreen: true, hasIcon: true),

            Gap(2.h),
            _buildLabel("Type de centre"),
            Row(
              children: [
                Radio(
                  value: "public",
                  groupValue: _centerType,
                  onChanged:
                      (val) => setState(() => _centerType = val.toString()),
                ),
                const Text("Centre public"),
                const Gap(10),
                Radio(
                  value: "prive",
                  groupValue: _centerType,
                  onChanged:
                      (val) => setState(() => _centerType = val.toString()),
                ),
                const Text("Centre prive"),
              ],
            ),

            // Message d'information dynamique sur le centre
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color:
                    _centerType == "public"
                        ? Color(0xFFE8F5E9)
                        : Color(0xFFE8EEF5),
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: Text(
                _centerType == "public"
                    ? "Centre public: Saisissez le nom du centre de sante public."
                    : "Centre privé: Saisissez le nom de la clinique ou du cabinet.",
                style: TextStyle(
                  color: _centerType == "public" ? Color(0xFF2E7D32) : infoBlue,
                  fontSize: 15.sp,
                ),
              ),
            ),

            Gap(2.h),
            _buildLabel("Centre de vaccination"),
            _buildDateField("Ex: CHU de Cocody"),

            Gap(2.h),
            // --- LOGIQUE IMAGE ---
            _hasSelectedImage
                ? _buildImagePreviewSection()
                : _buildImageSelectorSection(),

            Gap(1.h),
            Text(
              "Prenez une photo du certificat de vaccination ou "
              "selectionnez une image depuis votre galerie",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),

            Gap(3.h),
            // --- BOUTONS D'ACTION FINAUX ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Ajouter cette vaccination",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
              ),
            ),

            if (_hasSelectedImage) ...[
              const Gap(8),
              const Center(
                child: Text(
                  "Apres l'ajout, vous pourrez ajouter d'autres vaccins",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],

            Gap(1.2.h),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
                child: Text(
                  _hasSelectedImage ? "Annuler" : "Terminer et fermer",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildVaccinSearchList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (v) => setState(() => _vaccinSearchQuery = v),
          decoration: InputDecoration(
            hintText: "Rechercher ou parcourir les vaccins...",
            prefixIcon: Icon(Icons.search, color: appColor),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8F5E9)),
            ),
          ),
        ),
        const Gap(10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8F5E9)),
          ),
          child: Column(
            children:
                _filteredVaccins
                    .map(
                      (v) => ListTile(
                        title: Text(
                          v,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(Icons.add, color: Colors.grey),
                        onTap: () => setState(() => _selectedVaccin = v),
                      ),
                    )
                    .toList(),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8.0, left: 4),
          child: Text(
            "Vaccins humains disponibles",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    String hint, {
    bool isGreen = false,
    bool hasIcon = false,
  }) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: isGreen,
        fillColor: isGreen ? const Color(0xFFF1F8F1) : Colors.transparent,
        suffixIcon:
            hasIcon
                ? const Icon(Icons.calendar_month_outlined, color: Colors.grey)
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isGreen ? const Color(0xFFE8F5E9) : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedVaccinBadge() {
    return Container(
      padding: EdgeInsets.all(3.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: appColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, color: Colors.white, size: 18.sp),
          Gap(3.w),
          Text(
            _selectedVaccin!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () => setState(() => _selectedVaccin = null),
            child: const Icon(Icons.close, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSelectorSection() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _hasSelectedImage = true),
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
            label: const Text("Camera", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: appColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.w),
              ),
            ),
          ),
        ),
        Gap(1.2.h),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _hasSelectedImage = true),
            icon: Icon(Icons.image_outlined, color: appColor),
            label: Text("Galerie", style: TextStyle(color: appColor)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: appColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.w),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreviewSection() {
    return Column(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8F1),
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(color: const Color(0xFFE8F5E9)),
          ),
          child: Center(
            child: Icon(
              Icons.favorite,
              size: 80,
              color: appColor.withValues(alpha: 0.4),
            ),
          ),
        ),
        Gap(1.2.h),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _hasSelectedImage = false),
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                label: const Text(
                  "Supprimer",
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
              ),
            ),
            Gap(1.2.h),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.refresh, color: appColor),
                label: Text("Remplacer", style: TextStyle(color: appColor)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: appColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
