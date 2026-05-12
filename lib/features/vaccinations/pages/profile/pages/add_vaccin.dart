import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pharmaconsult/core/constants/constants.dart';
import 'package:pharmaconsult/core/themes/app_colors.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/models/vaccines/profile_model.dart';
import 'package:sizer/sizer.dart';

class AddVaccin extends StatefulWidget {
  final ProfileModel profile;

  const AddVaccin({super.key, required this.profile});

  @override
  State<AddVaccin> createState() => _AddVaccinState();
}

class _AddVaccinState extends State<AddVaccin> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _vaccinDateController = TextEditingController();
  final TextEditingController _reminderDateController = TextEditingController();
  final TextEditingController _centerNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  String _centerType = "public";

  List<dynamic> _vaccines = [];

  List<dynamic> get _filteredVaccines {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      return _vaccines;
    }

    return _vaccines.where((v) {
      return (v['name'] ?? '').toString().toLowerCase().contains(query);
    }).toList();
  }

  dynamic _selectedVaccin;

  File? _certificateImage;

  bool get _isCustomVaccin {
    if (_searchController.text.trim().isEmpty) return false;

    return !_vaccines.any(
      (v) =>
          (v['name'] ?? '').toString().toLowerCase().trim() ==
          _searchController.text.toLowerCase().trim(),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchVaccines();
  }

  Future<void> _fetchVaccines() async {
    try {
      final type = widget.profile.profileType ?? "human";

      final response = await http.get(
        Uri.parse(ApiUrls.getListVaccinByTypesUrl(type)),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _vaccines = data;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 70);

    if (image != null) {
      setState(() {
        _certificateImage = File(image.path);
      });
    }
  }

  String? _formatDateForApi(String text) {
    if (text.isEmpty) return null;
    try {
      // Si ton controller contient déjà une date au format "dd/MM/yyyy" (format humain)
      // Il faut d'abord la parser en DateTime pour que DateFormat puisse la reformater
      DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(text);
      return DateFormat('yyyy/MM/dd').format(parsedDate);
    } catch (e) {
      return null; // Ou gère l'erreur si le format saisi est invalide
    }
  }

  Future<void> _submitVaccination() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(
        ApiUrls.postCreateVaccinationByProfile(widget.profile.idProfile!),
      );

      final request = http.MultipartRequest("POST", uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      });

      /// -------------------------
      /// TOUS LES CHAMPS MÊME VIDES
      /// -------------------------

      request.fields['vaccine_id'] =
          _selectedVaccin?['id_vaccine']?.toString() ?? "";

      request.fields['vaccine_name_free'] =
          _searchController.text.trim();

      request.fields['id_user'] =
          SharedPreferencesHelper().getString('identifiant') ?? "";

      request.fields['vaccination_date'] =
          _formatDateForApi(_vaccinDateController.text) ?? "";

      request.fields['next_reminder_date'] =
          _formatDateForApi(_reminderDateController.text) ?? "";

      request.fields['center_type'] = _centerType;

      request.fields['center_name'] =
          _centerNameController.text.trim();

      request.fields['notes'] =
          _notesController.text.trim();

      /// -------------------------
      /// IMAGE (OPTIONNEL)
      /// -------------------------
      if (_certificateImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'certificate_image',
            _certificateImage!.path,
          ),
        );
      }

      /// -------------------------
      /// DEBUG
      /// -------------------------
      debugPrint("===== REQUEST FIELDS =====");
      request.fields.forEach((k, v) => debugPrint("$k => $v"));

      debugPrint("===== FILES =====");
      for (final f in request.files) {
        debugPrint(f.field);
      }

      /// -------------------------
      /// SEND
      /// -------------------------
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final data = json.decode(response.body);

      debugPrint("STATUS: ${response.statusCode}");
      debugPrint(response.body);

      if (response.statusCode == 201) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: appColor,
            content: Text(data['message'] ?? "Ajout réussi"),
          ),
        );

        Navigator.pop(context, true);
      } else {
        throw Exception(data['message'] ?? "Erreur serveur");
      }
    } catch (e) {
      debugPrint("ERROR: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool get _isHuman => (widget.profile.profileType ?? 'human') == 'human';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAF7),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            Gap(2.w),
            CircleAvatar(
              radius: 18,
              backgroundColor: appColor.withValues(alpha: 0.12),
              child: Icon(
                _isHuman ? Icons.person : Icons.pets,
                color: appColor,
              ),
            ),
            Gap(3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nouvelle vaccination",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 17.sp,
                    ),
                  ),

                  Text(
                    "Pour : ${widget.profile.name ?? 'Profil'}",
                    style: TextStyle(
                      color: appColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: Colors.black),
          ),
        ],
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(5.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ───────────────── HEADER INFO ─────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF8EF),
                  borderRadius: BorderRadius.circular(4.w),
                  border: Border.all(color: appColor.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.health_and_safety_outlined,
                      color: appColor,
                      size: 18,
                    ),

                    Gap(3.w),

                    Expanded(
                      child: Text(
                        "Ajoutez les informations de vaccination afin "
                        "de suivre les rappels et conserver "
                        "l’historique médical.",
                        style: TextStyle(
                          color: Colors.black87,
                          height: 1.5,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Gap(3.h),

              _buildSection(
                title: "Vaccin",
                icon: Icons.vaccines_outlined,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),

                      decoration: InputDecoration(
                        hintText: "Rechercher un vaccin ou saisir manuellement",

                        prefixIcon: Icon(Icons.search, color: appColor),

                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    Gap(1.5.h),

                    if (_selectedVaccin != null)
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: appColor,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),

                            Gap(2.w),

                            Expanded(
                              child: Text(
                                _selectedVaccin['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedVaccin = null;
                                });
                              },

                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_selectedVaccin == null)
                      Container(
                        height: 250,

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),

                        child:
                            _filteredVaccines.isEmpty
                                ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(4.w),
                                    child: Text(
                                      "Aucun vaccin trouvé.\nVotre saisie sera enregistrée comme vaccin personnalisé.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                )
                                : ListView.separated(
                                  padding: EdgeInsets.zero,

                                  itemCount: _filteredVaccines.length,

                                  separatorBuilder:
                                      (_, __) => Divider(
                                        height: 1,
                                        color: Colors.grey.shade100,
                                      ),

                                  itemBuilder: (_, index) {
                                    final vaccin = _filteredVaccines[index];

                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: appColor.withValues(
                                          alpha: 0.1,
                                        ),

                                        child: Icon(
                                          Icons.vaccines,
                                          color: appColor,
                                        ),
                                      ),

                                      title: Text(
                                        vaccin['name'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      trailing: Icon(
                                        Icons.add_circle_outline,
                                        color: appColor,
                                      ),

                                      onTap: () {
                                        setState(() {
                                          _selectedVaccin = vaccin;
                                          _searchController.text =
                                              vaccin['name'];
                                        });
                                      },
                                    );
                                  },
                                ),
                      ),
                  ],
                ),
              ),

              Gap(3.h),

              // ───────────────── DATES ─────────────────
              _sectionTitle(
                icon: Icons.calendar_month_outlined,
                title: "Dates",
              ),

              Gap(1.5.h),

              _buildDateField(
                controller: _vaccinDateController,
                hint: "Date de vaccination",
                icon: Icons.event_outlined,
              ),

              Gap(2.h),

              _buildDateField(
                controller: _reminderDateController,
                hint: "Date du prochain rappel",
                icon: Icons.notifications_active_outlined,
                isGreen: true,
              ),

              Gap(3.h),

              // ───────────────── CENTRE ─────────────────
              _sectionTitle(
                icon: Icons.local_hospital_outlined,
                title: "Centre de vaccination",
              ),

              Gap(1.5.h),

              Row(
                children: [
                  Expanded(
                    child: _centerTypeCard(
                      label: "Public",
                      icon: Icons.account_balance_outlined,
                      value: "public",
                    ),
                  ),

                  Gap(3.w),

                  Expanded(
                    child: _centerTypeCard(
                      label: "Privé",
                      icon: Icons.local_hospital_outlined,
                      value: "private",
                    ),
                  ),
                ],
              ),

              Gap(2.h),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.5.w),
                decoration: BoxDecoration(
                  color:
                      _centerType == "public"
                          ? Color(0xFFE8F5E9)
                          : Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color:
                          _centerType == "public"
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF2563EB),
                    ),

                    Gap(3.w),

                    Expanded(
                      child: Text(
                        _centerType == "public"
                            ? "Centre public : CHU, hôpital ou centre de santé public."
                            : "Centre privé : clinique, pharmacie ou cabinet privé.",
                        style: TextStyle(
                          color:
                              _centerType == "public"
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF2563EB),
                          fontSize: 12.sp,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Gap(2.h),

              _buildTextField(
                controller: _centerNameController,
                hint: "Ex : CHU de Cocody",
                icon: Icons.place_outlined,
              ),

              Gap(3.h),

              // ───────────────── IMAGE ─────────────────
              _buildSection(
                title: "Certificat de vaccination",
                icon: Icons.image_outlined,

                child: Column(
                  children: [
                    if (_certificateImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),

                        child: Image.file(
                          _certificateImage!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                    if (_certificateImage == null)
                      Container(
                        height: 180,
                        width: double.infinity,

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 60,
                              color: appColor.withValues(alpha: 0.5),
                            ),

                            Gap(1.h),

                            Text(
                              "Ajouter une photo du certificat",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),

                    Gap(2.h),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _pickImage(ImageSource.camera);
                            },

                            icon: Icon(Icons.camera_alt),

                            label: Text("Caméra"),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),

                        Gap(3.w),

                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _pickImage(ImageSource.gallery);
                            },

                            icon: Icon(Icons.image_outlined, color: appColor),

                            label: Text(
                              "Galerie",
                              style: TextStyle(color: appColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Gap(1.5.h),

              Center(
                child: Text(
                  "Ajoutez une photo du carnet ou certificat "
                  "de vaccination.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12.sp,
                    height: 1.5,
                  ),
                ),
              ),

              Gap(3.h),

              // ───────────────── NOTES ─────────────────
              _sectionTitle(
                icon: Icons.notes_outlined,
                title: "Notes complémentaires",
              ),

              Gap(1.5.h),

              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Observations, réactions, remarques médicales...",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(4.w),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.w),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.w),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),

              Gap(4.h),

              // ───────────────── BOUTONS ─────────────────
              SizedBox(
                width: double.infinity,
                height: 6.5.h,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitVaccination,

                  icon:
                      _isLoading
                          ? SizedBox(
                            width: 18,
                            height: 18,

                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.check_circle_outline),

                  label: Text(
                    _isLoading ? "Enregistrement..." : "Ajouter la vaccination",
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColor,
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              Gap(1.5.h),

              SizedBox(
                width: double.infinity,
                height: 6.2.h,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),

                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                  ),

                  child: const Text(
                    "Annuler",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Gap(3.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8F4),
        borderRadius: BorderRadius.circular(3.w),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: appColor),

              Gap(2.w),

              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
              ),
            ],
          ),

          Gap(2.h),

          child,
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: appColor),

        Gap(2.w),

        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────

  Widget _centerTypeCard({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final selected = _centerType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _centerType = value;
        });
      },

      borderRadius: BorderRadius.circular(4.w),

      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),

        decoration: BoxDecoration(
          color: selected ? appColor.withValues(alpha: 0.08) : Colors.white,

          borderRadius: BorderRadius.circular(4.w),

          border: Border.all(
            color: selected ? appColor : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),

        child: Column(
          children: [
            Icon(icon, color: selected ? appColor : Colors.grey.shade600),

            Gap(0.8.h),

            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? appColor : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,

      decoration: InputDecoration(
        hintText: hint,

        prefixIcon: Icon(icon),

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.w),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.w),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────

  Widget _buildDateField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isGreen = false,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,

      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          controller.text =
              "${picked.day.toString().padLeft(2, '0')}/"
              "${picked.month.toString().padLeft(2, '0')}/"
              "${picked.year}";
        }
      },

      decoration: InputDecoration(
        hintText: hint,

        prefixIcon: Icon(icon),

        suffixIcon: const Icon(Icons.calendar_month_outlined),

        filled: true,
        fillColor: isGreen ? const Color(0xFFF0FDF4) : Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.w),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.w),
          borderSide: BorderSide(
            color: isGreen ? const Color(0xFFC8E6C9) : Colors.grey.shade200,
          ),
        ),
      ),
    );
  }
}
