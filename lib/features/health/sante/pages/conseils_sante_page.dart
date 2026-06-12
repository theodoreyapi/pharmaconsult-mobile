import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmaconsult/core/constants/api_urls.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:pharmaconsult/core/utils/utils.dart';
import 'package:pharmaconsult/models/suivisante/conseil_model.dart';
import 'package:sizer/sizer.dart';

class ConseilsSantePage extends StatefulWidget {
  const ConseilsSantePage({super.key});

  @override
  State<ConseilsSantePage> createState() => _ConseilsSantePageState();
}

class _ConseilsSantePageState extends State<ConseilsSantePage> {
  String _selectedCategory = 'Tous';
  late Future<List<ConseilModel>> _futureConseils;

  final List<String> _categories = [
    'Tous',
    'Hypertension',
    'Diabète',
    'Bien-être',
    'Observance'
  ];

  @override
  void initState() {
    super.initState();
    _futureConseils = fetchConseils();
  }

  Future<List<ConseilModel>> fetchConseils() async {
    final response = await http.get(
      Uri.parse(ApiUrls.getConseil),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = json.decode(utf8.decode(response.bodyBytes));
      return decoded.map((json) => ConseilModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des conseils');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appDegradOne,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF27AE60)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conseils santé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F3E32),
              ),
            ),
            Text(
              'Pour mieux vivre avec votre pathologie',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Categories
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF27AE60) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.grey.shade200,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // List of advice
          Expanded(
            child: FutureBuilder<List<ConseilModel>>(
              future: _futureConseils,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucun conseil disponible'));
                }

                final allConseils = snapshot.data!;
                final filteredConseils = _selectedCategory == 'Tous'
                    ? allConseils
                    : allConseils.where((c) => c.categorie == _selectedCategory).toList();

                if (filteredConseils.isEmpty) {
                  return const Center(child: Text('Aucun conseil dans cette catégorie'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredConseils.length + 1,
                  itemBuilder: (context, index) {
                    if (index == filteredConseils.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Ces conseils sont fournis à titre informatif. Consultez toujours votre pharmacien ou médecin pour un avis personnalisé.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      );
                    }

                    final conseil = filteredConseils[index];
                    return _buildAdviceCard(conseil);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(ConseilModel conseil) {
    Color topColor;
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (conseil.categorie?.toLowerCase()) {
      case 'hypertension':
        topColor = Colors.green;
        icon = Icons.favorite_border;
        iconColor = Colors.green;
        iconBg = const Color(0xFFE8F5E9);
        break;
      case 'diabète':
      case 'diabete':
        topColor = Colors.blue;
        icon = Icons.water_drop_outlined;
        iconColor = Colors.blue;
        iconBg = const Color(0xFFE3F2FD);
        break;
      case 'bien-être':
      case 'bien-etre':
      case 'bien etre':
        topColor = Colors.purple;
        icon = Icons.fitness_center_outlined;
        iconColor = Colors.purple;
        iconBg = const Color(0xFFF3E5F5);
        break;
      case 'observance':
        topColor = Colors.pink;
        icon = Icons.medication_outlined;
        iconColor = Colors.pink;
        iconBg = const Color(0xFFFCE4EC);
        break;
      default:
        topColor = Colors.orange;
        icon = Icons.info_outline;
        iconColor = Colors.orange;
        iconBg = const Color(0xFFFFF3E0);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border(top: BorderSide(color: topColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          conseil.categorie ?? '',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        conseil.type ?? '',
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    conseil.titre ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    conseil.description ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
