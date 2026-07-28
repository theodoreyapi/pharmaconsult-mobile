# Walkthrough - Masquage des abonnements iOS (MoneyPage)

J'ai mis à jour la page des transactions (`MoneyPage`) pour masquer toute référence aux abonnements sur iOS.

## Changements effectués

### Money Feature
- **[money_page.dart](file:///C:/Users/theod/OneDrive/Documents/mobiles/pharmaconsult-mobile/lib/features/money/pages/money_page.dart)** :
    - Importation de `dart:io`.
    - Initialisation dynamique du `TabController` : 3 onglets sur iOS, 4 onglets sur les autres plateformes.
    - Mise à jour de la `TabBar` pour masquer l'onglet "Souscriptions" sur iOS.
    - Mise à jour de la `TabBarView` :
        - Sur iOS, les transactions de type `ABONNEMENT` sont filtrées et exclues de la liste "Tout".
        - L'onglet de détail des souscriptions est supprimé de la vue sur iOS.

## Détails techniques

### Filtrage des données
```dart
buildTransactionsList(
  Platform.isIOS
      ? allTransactions
          .where((t) => t.category != "ABONNEMENT")
          .toList()
      : allTransactions,
),
```
Cette logique garantit que même dans la vue globale, les traces d'achats d'abonnements ne sont pas visibles sur iPhone.

## Vérification effectuée
- [x] Validation de la gestion des index du `TabController` (évite les erreurs de décalage).
- [x] Vérification de l'intégrité des données sur Android (non impacté).
- [x] Utilisation correcte des types de catégories (`ABONNEMENT`, `RECHARGEMENT`, `TRANSFERT`).
