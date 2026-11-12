# 🎬 TP1 · Selenium IDE : Guru99

[← Retour au projet](../../README.md)

> Découvrir Selenium IDE (enregistrement, commandes, vérifications) sur le site de démonstration Guru99. **J'ai revu la solution proposée, puis j'ai produit une version corrigée.**

![Selenium IDE](https://img.shields.io/badge/Selenium-IDE-43B02A?logo=selenium&logoColor=white)

## 📝 Énoncé

Sur https://demo.guru99.com :

| Ex. | Page | Test | Vérification |
|---|---|---|---|
| 1 | Login | Se connecter | « Successfully logged in... » s'affiche |
| 2 | Accessing Link | Cliquer sur les liens de redirection | Le premier mène à Google, le second à Facebook |
| 3 | Selenium DatePicker Demo | Saisir une date et une heure, valider | L'élément qui affiche la date apparaît |
| 4 | Drag and Drop Action | Déplacer un élément | L'élément apparaît à l'endroit du dépôt |

## ✍️ Ma réalisation

### 1️⃣ Revue de la proposition

📄 [`proposition-formation.side`](proposition-formation.side) (à ouvrir dans Selenium IDE)

| # | Constat | Conséquence |
|---|---|---|
| R1 | **L'exercice 1 (Login) n'est pas automatisé** | Exigence de l'énoncé non couverte |
| R2 | « 02-checkbox check » ouvre **`link.html`** au lieu de `ajax.html` | Le test échoue (les boutons radio n'existent pas sur cette page) |
| R3 | « Reset » : rien ne vérifie que « Yes » était sélectionné avant le reset | Si le clic échoue, `assertNotChecked` passe quand même (**faux positif**) |
| R4 | Le lien Google est **suivi** (navigation vers un site tiers), et le lien Facebook n'est pas testé | Test dépendant de Google (bandeau cookies, titre localisé) ; exigence non couverte |
| R5 | La commande `close` ferme la fenêtre en fin de test | Les tests suivants de la suite n'ont plus de fenêtre |
| R6 | Date : `assertElementPresent` avec un sélecteur **positionnel** (`css=div:nth-child(8)`), et une valeur attendue que la commande ignore | Fragile, et la valeur donne l'illusion d'une vérification du contenu |
| R7 | Test « popup » hors énoncé, **sans aucune assertion** | Il ne vérifie rien |
| R8 | Numérotation 01, 02, 03, 06, 07, 05 ; coquille « ling » ; tailles de fenêtre différentes | Lisibilité, maintenance |

### 2️⃣ Solution corrigée

📄 [`solution-corrigee.side`](solution-corrigee.side) : 6 tests regroupés dans une suite « Suite complète ».

| Test | Correction apportée |
|---|---|
| 01 - Connexion réussie | **Ajouté** (R1) |
| 02 - Reset désélectionne tout | Précondition `assertChecked id=yes` avant le reset (R3) |
| 03 - Check affiche la valeur | URL corrigée : `ajax.html` (R2) |
| 04 - Liens de redirection | Vérifie la **cible des liens** (`@href` contenant google / facebook) sans quitter le site (R4, R5) |
| 05 - Sélection d'une date | Vérification par le texte « Your Birth Date is » au lieu d'une position dans la page (R6) |
| 06 - Glisser-déposer | Inchangé |

> 💡 **Tester un lien externe :** on vérifie que **notre** page pointe au bon endroit (attribut `href`), pas que le site de Google fonctionne. Le test devient rapide, stable et centré sur l'application testée.

> ⚠️ Le fichier corrigé n'a pas pu être rejoué depuis mon environnement de rédaction (site externe inaccessible). Il est à ouvrir et exécuter dans l'extension Selenium IDE.

## ✅ Compétences

Selenium IDE (enregistrement, `assert*`, suites) · choix de localisateurs robustes · revue de scripts de test · détection de faux positifs.
