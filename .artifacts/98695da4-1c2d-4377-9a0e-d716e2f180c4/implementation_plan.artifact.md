# Restriction des abonnements sur iOS (MoneyPage)

Ce plan vise à masquer toutes les références aux abonnements et souscriptions dans la page des transactions (`MoneyPage`) pour les utilisateurs d'iPhone, afin de respecter les politiques de l'App Store.

## User Review Required

> [!IMPORTANT]
> Sur iOS, l'onglet "Souscriptions" sera supprimé et les transactions de type "ABONNEMENT" seront filtrées de la liste principale ("Tout"). Est-ce que ce comportement global est celui attendu ?

## Proposed Changes

### Feature Money

#### [MODIFY] [money_page.dart](file:///C:/Users/theod/OneDrive/Documents/mobiles/pharmaconsult-mobile/lib/features/money/pages/money_page.dart)

- Ajout de l'import `dart:io`.
- Mise à jour de `initState` pour initialiser le `TabController` avec une longueur de 3 sur iOS (au lieu de 4).
- Modification de la méthode `build` :
    - Détection de la plateforme via `Platform.isIOS`.
    - Filtrage des transactions de type `ABONNEMENT` dans l'onglet "Tout" si on est sur iOS.
    - Affichage conditionnel de l'onglet "Souscriptions" dans la `TabBar`.
    - Affichage conditionnel de la vue associée dans la `TabBarView`.

## Verification Plan

### Automated Tests
- N/A

### Manual Verification
1. Lancer l'application sur iOS.
2. Naviguer vers la page "Money" (ou transactions).
3. Vérifier qu'il n'y a que 3 onglets : Tout, Rechargements, Transactions.
4. Vérifier que la liste "Tout" ne contient aucune transaction d'abonnement.
5. Lancer l'application sur Android et vérifier que les 4 onglets sont présents et que les abonnements sont visibles.
