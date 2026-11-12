# 🔐 TP3 · Selenium IDE : revue du script du générateur de mot de passe

[← Retour au projet](../../README.md)

> Avant d'automatiser le générateur avec SeleniumLibrary, j'ai relu le plan de test (Excel) et le script Selenium IDE proposés en formation. Cette revue explique **pourquoi** j'ai réécrit le plan.

📄 Script proposé : [`proposition-formation.side`](proposition-formation.side) · Plan corrigé : [`docs/plan-de-test-generateur.md`](../../docs/plan-de-test-generateur.md)

## 1️⃣ Revue du plan de test proposé (Excel)

| # | Constat | Type |
|---|---|---|
| P1 | Le test « caractères spéciaux » coche **Caractères numériques** | Erreur de copier-coller |
| P2 | Le résultat attendu de « saisir un mot » est celui de « tous les critères » | Erreur de copier-coller |
| P3 | Le test « Moyen » attend « le champ **Mauvais** se colore en rouge » | Erreur de copier-coller |
| P4 | Les 5 tests de niveau de sécurité sont nommés « cas **KO** » alors que ce sont des cas passants | Nommage trompeur |
| P5 | Le sommaire annonce « supérieur à 50 » et « rien n'est sélectionné », mais **aucun test n'est écrit** | Trou de couverture |
| P6 | La longueur n'est testée qu'avec 12 : les **valeurs limites** 1 et 50 manquent | Trou de couverture |
| P7 | « Un message d'erreur s'affiche » : quel message ? | Résultat attendu non vérifiable |

## 2️⃣ Revue du script Selenium IDE proposé

| # | Constat | Conséquence |
|---|---|---|
| S1 | Les tests « nombres », « caractères spéciaux » et « tous les critères » cochent tous **minuscules** et vérifient `^[A-Z]+$` (majuscules) | Le test vérifie autre chose que son titre, et il échoue à tort |
| S2 | Les tests 03, 04 et 05 utilisent **`storeText`** (mémoriser) au lieu de **`assertText`** (vérifier) | **Aucune vérification** : ils passent toujours, même si l'application est cassée (faux positif) |
| S3 | « Saisir un mot » ne saisit rien, et les tests 03 et 05 sont identiques | Doublon, cas non testé |
| S4 | La suite « Default Suite » contient **0 test** | Lancer la suite n'exécute rien |
| S5 | Aucun test de l'indicateur de sécurité (US 3) | US non couverte |

> 💡 **S2 est le défaut le plus dangereux** : un test qui ne peut pas échouer donne une fausse impression de qualité. Ici, 3 tests sur 10 étaient « verts » sans rien vérifier.

## ➡️ Suite

Selenium IDE ne sait pas lire les couleurs d'un `<canvas>` (l'indicateur de sécurité) ni répéter une génération 20 fois proprement. J'ai donc automatisé le plan corrigé avec **Robot Framework + SeleniumLibrary** : [`tests/selenium/generateur.robot`](../../tests/selenium/generateur.robot).
