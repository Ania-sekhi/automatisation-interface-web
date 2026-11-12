# 🧠 TP2 · Selenium IDE : jeu Memory

[← Retour au projet](../../README.md)

> Partir d'un plan de test existant, l'analyser, puis automatiser les tests avec Selenium IDE sur l'application https://enijdenis.github.io/memory/.

![Selenium IDE](https://img.shields.io/badge/Selenium-IDE-43B02A?logo=selenium&logoColor=white)

## 📝 Énoncé

> Tester l'application Memory : repartir des spécifications (`plan_de_test.xlsx`), puis créer les tests avec Selenium IDE.

### Plan de test fourni (synthèse)

| Page | Test | Résultat attendu |
|---|---|---|
| Accueil | Afficher la page d'accueil | « Bienvenue sur le site du Memory de l'ENI. » |
| S'inscrire | Création de profil OK (test / test@test.com / 12Mdp@) | La page de connexion s'affiche |
| S'inscrire | KO : nom d'utilisateur < 3 caractères | « Choisissez un pseudo contenant au moins 3 caractères. », la page tremble |
| S'inscrire | KO : email mal formaté | « Rentrez un email valide. », la page tremble |
| Connexion | Connexion OK | La page de profil s'affiche |
| Connexion | KO : mauvais mot de passe / mauvais utilisateur | Alerte « Erreur, veuillez saisir les informations correctement » |
| Profil | Affichage du profil | Nom, email, choix « Animaux animés », taille 4×4 |
| Profil | Modifier la taille / le choix du Memory | Alerte « Choix des options enregistré ! », modification conservée |
| Jouer | Correspondance des cartes | Essais incrémentés, paires retournées |
| Jouer | Gagner une partie (4×3) | « Bravo ! Vous avez gagné ! … Votre score final : 6 » |

## ✍️ Ma réalisation

### 1️⃣ Revue du plan de test

| # | Constat | Type |
|---|---|---|
| P1 | Inscription avec le mot de passe **12Mdp@**, mais connexion avec **12Mot@** en précondition | Jeu de données incohérent |
| P2 | « Connexion KO : mauvais mot de passe » indique « Entrer un mot de passe **correct** : 12M » | Libellé contradictoire |
| P3 | Aucune règle de mot de passe n'est précisée, et aucun test sur la confirmation différente, l'email ou le pseudo déjà utilisé | Trous de couverture |
| P4 | « La page tremble » : vérification visuelle, précisée ensuite (classe `shake`) | Critère à rendre vérifiable : bonne pratique déjà amorcée |
| P5 | Les préconditions (« un compte existe ») ne disent pas **comment** créer le compte | Tests non autonomes |

### 2️⃣ Revue de la proposition Selenium IDE

📄 [`proposition-formation.side`](proposition-formation.side)

| # | Constat | Conséquence |
|---|---|---|
| S1 | Seulement **2 tests** (inscription, annuler) sur les 12 du plan | Couverture faible |
| S2 | Données différentes du plan (toto / 1234m- au lieu de test / 12Mdp@) | Écart avec la spécification |
| S3 | « Annuler » vérifie les champs avec **`assertText`** | **Faux positif** : `assertText` lit le texte *contenu* dans l'élément. Un champ `<input>` n'en a pas, il a une *valeur*. Le test passe donc même si le formulaire n'est pas vidé |

J'ai vérifié S3 avec Selenium WebDriver : après avoir saisi « toto » dans un champ, `text` vaut `''` et `value` vaut `'toto'`. La bonne commande est **`assertValue`**.

### 3️⃣ Solution corrigée

📄 [`solution-corrigee.side`](solution-corrigee.side)

| Test | Contenu |
|---|---|
| INS-01 | Création de profil OK, avec les données du plan |
| INS-02 | **Ajouté** : pseudo de 2 caractères, message attendu, on reste sur la page |
| INS-03 | **Ajouté** : email mal formaté, message attendu, on reste sur la page |
| INS-04 | « Annuler » corrigé avec `assertValue` (S3) |

Les messages d'erreur sont localisés par leur **texte** (`//*[contains(text(), '…')]`), ce qui reste valable même si leur emplacement dans la page change.

**Couverture :** 4 tests d'inscription automatisés. Les tests de connexion, de profil et de jeu sont à compléter en enregistrant leurs sélecteurs dans Selenium IDE sur l'application.

> ⚠️ **À savoir pour rejouer :** INS-01 crée un compte. Si l'application mémorise les comptes (stockage du navigateur), un deuxième passage peut échouer. Il faut alors utiliser un pseudo unique, par exemple généré avec `executeScript`.
> Le fichier corrigé n'a pas pu être rejoué depuis mon environnement de rédaction (site externe inaccessible) : il est à exécuter dans l'extension Selenium IDE.

## ✅ Compétences

Analyse d'un plan de test existant · Selenium IDE · `assertText` ou `assertValue` · localisation par le texte · détection de faux positifs · gestion des données de test.
