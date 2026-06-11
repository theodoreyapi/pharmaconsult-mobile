import 'package:flutter/material.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:sizer/sizer.dart';

class ConseilsSantePage extends StatefulWidget {
  const ConseilsSantePage({super.key});

  @override
  State<ConseilsSantePage> createState() => _ConseilsSantePageState();
}

class _ConseilsSantePageState extends State<ConseilsSantePage> {
  String _selectedCategory = 'Tous';

  final List<String> _categories = [
    'Tous',
    'Hypertension',
    'Diabète',
    'Bien-être',
    'Observance'
  ];

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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAdviceCard(
                  category: 'Hypertension',
                  type: 'Conseil',
                  title: '5 gestes simples pour contrôler sa tension',
                  description: 'Réduire le sel, marcher 30 min/jour, bien dormir, éviter le stress et prendre son traitement à l\'heure.',
                  icon: Icons.favorite_border,
                  topColor: Colors.green,
                  iconColor: Colors.green,
                  iconBg: const Color(0xFFE8F5E9),
                ),
                _buildAdviceCard(
                  category: 'Diabète',
                  type: 'Article',
                  title: 'Alimentation et diabète : que manger ?',
                  description: 'Privilégier les fibres, limiter les sucres rapides, fractionner les repas en 3 repas + 2 collations.',
                  icon: Icons.water_drop_outlined,
                  topColor: Colors.blue,
                  iconColor: Colors.blue,
                  iconBg: const Color(0xFFE3F2FD),
                ),
                _buildAdviceCard(
                  category: 'Diabète',
                  type: 'Article',
                  title: 'L\'importance du contrôle glycémique régulier',
                  description: 'Un suivi régulier de la glycémie permet de prévenir les complications et d\'adapter le traitement.',
                  icon: Icons.water_drop_outlined,
                  topColor: Colors.orange,
                  iconColor: Colors.orange,
                  iconBg: const Color(0xFFFFF3E0),
                ),
                _buildAdviceCard(
                  category: 'Bien-être',
                  type: 'Conseil',
                  title: 'Activité physique et maladies chroniques',
                  description: '30 minutes de marche par jour réduisent de 30% le risque cardiovasculaire. Commencez doucement !',
                  icon: Icons.fitness_center_outlined,
                  topColor: Colors.purple,
                  iconColor: Colors.purple,
                  iconBg: const Color(0xFFF3E5F5),
                ),
                _buildAdviceCard(
                  category: 'Observance',
                  type: 'Conseil',
                  title: 'Bien prendre ses médicaments chaque jour',
                  description: 'Utilisez un pilulier, associez la prise à un geste quotidien, ne doublez jamais une dose oubliée.',
                  icon: Icons.medication_outlined,
                  topColor: Colors.pink,
                  iconColor: Colors.pink,
                  iconBg: const Color(0xFFFCE4EC),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ces conseils sont fournis à titre informatif. Consultez toujours votre pharmacien ou médecin pour un avis personnalisé.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard({
    required String category,
    required String type,
    required String title,
    required String description,
    required IconData icon,
    required Color topColor,
    required Color iconColor,
    required Color iconBg,
  }) {
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
                          category,
                          style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        type,
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
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
