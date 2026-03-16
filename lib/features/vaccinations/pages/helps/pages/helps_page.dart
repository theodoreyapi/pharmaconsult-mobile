import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pharmaconsult/core/themes/themes.dart';
import 'package:sizer/sizer.dart';

class HelpsPage extends StatefulWidget {
  const HelpsPage({super.key});

  @override
  State<HelpsPage> createState() => _HelpsPageState();
}

class _HelpsPageState extends State<HelpsPage> {
  // 1. État pour la recherche et les catégories
  String _searchQuery = "";
  String _selectedCategory = "Toutes";

  final List<String> _categories = [
    "Toutes",
    "General",
    "Profils",
    "Rappels",
    "Facturation",
  ];

  final List<Map<String, String>> _allFaqs = [
    {
      "question": "Comment creer un profil sante?",
      "answer":
          "Cliquez sur le bouton Profils en haut de l'ecran, puis sur Creer un nouveau profil sante. Remplissez les informations demandees (nom, prenom, date de naissance, categorie). Chaque profil cree sera facture annuellement a hauteur de 2000 FCFA.",
      "category": "Profils",
    },
    {
      "question": "Comment fonctionnent les rappels SMS?",
      "answer":
          "Lors de la creation d'un rappel, cochez l'option Rappel par SMS et entrez le numero de telephone. Vous recevrez un SMS automatique 3 jours avant la date du rappel, puis le jour meme.",
      "category": "Rappels",
    },
    {
      "question": "Puis-je gerer plusieurs membres de ma famille?",
      "answer":
          "Oui, vous pouvez creer autant de profils sante que necessaire. Chaque profil est facture separement et permet un suivi personnalise du calendrier vaccinal.",
      "category": "Profils",
    },
    {
      "question": "Comment ajouter un certificat de vaccination?",
      "answer":
          "Dans l'onglet Historique, selectionnez un profil et cliquez sur Ajouter une vaccination. Vous pourrez prendre une photo du certificat qui sera sauvegardee dans votre galerie photos.",
      "category": "General",
    },
    {
      "question": "Les prix affiches sont-ils a jour?",
      "answer":
          "Oui, les prix sont mis a jour quotidiennement aupres des pharmacies partenaires. Nous vous recommandons toutefois de contacter directement la pharmacie pour confirmer le prix et la disponibilite.",
      "category": "General",
    },
    {
      "question": "Comment sont factures les profils sante?",
      "answer":
          "Chaque profil sante est facture annuellement a hauteur de 2000 FCFA. Le paiement se fait via Mobile Money ou carte bancaire. Vous pouvez annuler un profil a tout moment depuis les parametres.",
      "category": "Facturation",
    },
    {
      "question": "Puis-je recevoir des rappels pour plusieurs profils?",
      "answer":
          "Oui, vous pouvez configurer des rappels individuels pour chaque profil. Chaque rappel peut etre envoye par notification dans l'application et/ou par SMS..",
      "category": "Rappels",
    },
    {
      "question": "Que faire si j'ai manque un rappel?",
      "answer":
          "Les rappels en retard apparaissent en rouge dans l'onglet Rappels. Consultez votre medecin ou centre de sante pour reprogrammer la vaccination des que possible.",
      "category": "Rappels",
    },
    {
      "question": "Les donnees sont-elles securisees?",
      "answer":
          "Oui, toutes vos donnees de sante sont stockees de maniere securisee et chiffree. Nous respectons strictement les normes de confidentialite et ne partageons jamais vos informations avec des tiers.",
      "category": "General",
    },
    {
      "question": "Puis-je exporter mon historique de vaccination?",
      "answer":
          "Oui, vous pouvez exporter l'historique complet de chaque profil au format PDF depuis l'onglet Historique. Ceci est utile pour les voyages ou consultations medicales.",
      "category": "General",
    },
    {
      "question": "Comment modifier ou supprimer un profil?",
      "answer":
          "Dans l'ecran Profils, cliquez sur l'icone d'edition ou de suppression a cote du profil concerne. Attention, la suppression d'un profil efface definitivement toutes ses donnees.",
      "category": "Profils",
    },
    {
      "question": "Quel est le cout d'un profil sante?",
      "answer":
          "Le cout d'un profil sante est de 2000 FCFA par an. Ce tarif inclut toutes les fonctionnalites: calendrier personnalise, rappels SMS, stockage des certificats et support client.",
      "category": "Facturation",
    },
  ];

  // 3. Logique de filtrage combinée (Tags + Recherche)
  List<Map<String, String>> get _filteredFaqs {
    return _allFaqs.where((faq) {
      final matchesCategory =
          _selectedCategory == "Toutes" || faq['category'] == _selectedCategory;
      final matchesSearch = faq['question']!.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F1),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Aide & FAQ
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline, color: appColor2, size: 30),
                      Gap(2.w),
                      Text(
                        "Aide & FAQ",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: appColor2,
                        ),
                      ),
                    ],
                  ),
                  Gap(2.h),
                  Text(
                    "Trouvez des reponses rapides a vos questions",
                    style: TextStyle(color: Colors.grey[600], fontSize: 15.sp),
                  ),
                ],
              ),
            ),
            Gap(2.h),

            // Barre de recherche
            TextField(
              decoration: InputDecoration(
                hintText: "Rechercher une question...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.w),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Gap(2.h),

            // Filtres (Horizontal Chips)
            _buildCategoryFilters(),
            Gap(2.5.h),

            // Liste des FAQ filtrées
            ..._filteredFaqs.map((faq) => _buildFAQItem(
              faq['question']!,
              faq['answer']!,
              tag: faq['category'],
            )).toList(),

            if (_filteredFaqs.isEmpty)
              Center(child: Text("Aucun résultat trouvé.")),

            Gap(2.h),

            // Section Besoin d'aide supplémentaire
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Besoin d'aide supplementaire?",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: appColor2,
                    ),
                  ),
                  Gap(1.5.h),

                  _buildContactCard(
                    Icons.phone_outlined,
                    "Appelez-nous",
                    "+221 33 823 45 67",
                    infoBlue,
                  ),
                  _buildContactCard(
                    Icons.email_outlined,
                    "Email",
                    "support@vaccination.sn",
                    appColor,
                  ),
                  _buildContactCard(
                    Icons.chat_bubble_outline,
                    "Chat en direct",
                    "Lun-Ven: 8h-18h",
                    appColorPurple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const Gap(10),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF38662B) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade200),
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAQItem(
    String question,
    String answer, {
    String? tag
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(Icons.help_outline, color: appColor2),
          title: Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 15.sp,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    answer,
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.5,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (tag != null) ...[
                    Gap(1.h),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F1),
                        borderRadius: BorderRadius.circular(20.w),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(color: appColor2, fontSize: 14.sp),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          Gap(1.5.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
