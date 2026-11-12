*** Settings ***
Documentation     Tests de bout en bout de l'interface web de la Médiathèque (bibliothèque Browser / Playwright).
...               Un test = un parcours utilisateur de la matrice de traçabilité (US-01 à US-05).
Resource          ../resources/mediatheque.resource
Suite Setup       Run Keywords    Démarrer la Médiathèque    AND    Ouvrir le navigateur Playwright
...               AND    Ouvrir une session sur l'API
Suite Teardown    Run Keywords    Close Browser    AND    Arrêter les applications
Test Setup        Repartir d'un catalogue de référence
Test Tags         mediatheque    playwright


*** Test Cases ***
UI-01 Le catalogue affiche les livres et leur statut
    [Tags]    US-01    smoke
    Vérifier le nombre de livres affichés    3
    Vérifier le statut du livre    ${ISBN_PETIT_PRINCE}    disponible
    Vérifier le statut du livre    ${ISBN_MISERABLES}      emprunté par Alice

UI-02 Ajouter un livre depuis le formulaire
    [Tags]    US-02    smoke
    Ajouter un livre    Germinal    Émile Zola    9782253004226
    Vérifier le message    « Germinal » ajouté au catalogue
    Vérifier le nombre de livres affichés    4
    Vérifier le statut du livre    9782253004226    disponible
    Vérifier que le formulaire est vidé

UI-03 Un ISBN invalide est refusé avec un message clair
    [Tags]    US-02    négatif
    Ajouter un livre    Germinal    Émile Zola    12345
    Vérifier le message    L'ISBN doit contenir exactement 13 chiffres
    Vérifier le nombre de livres affichés    3

UI-04 Emprunter puis rendre un livre
    [Tags]    US-03    US-04    smoke
    Emprunter le livre    ${ISBN_PETIT_PRINCE}    Bob
    Vérifier le message    « Le Petit Prince » emprunté
    Vérifier le statut du livre    ${ISBN_PETIT_PRINCE}    emprunté par Bob
    Rendre le livre    ${ISBN_PETIT_PRINCE}
    Vérifier le message    « Le Petit Prince » rendu
    Vérifier le statut du livre    ${ISBN_PETIT_PRINCE}    disponible

UI-05 Emprunter sans nom affiche une erreur
    [Tags]    US-03    négatif
    Emprunter le livre    ${ISBN_PETIT_PRINCE}
    Vérifier le message    Le nom de l'emprunteur est obligatoire
    Vérifier le statut du livre    ${ISBN_PETIT_PRINCE}    disponible

UI-06 Un livre emprunté ne peut pas être supprimé
    [Tags]    US-05    négatif
    Vérifier que le bouton Supprimer est désactivé    ${ISBN_MISERABLES}

UI-07 Supprimer un livre disponible
    [Tags]    US-05
    Supprimer le livre    ${ISBN_ETRANGER}
    Vérifier le message    « L'Étranger » supprimé
    Vérifier le nombre de livres affichés    2
    Vérifier que le livre n'est plus affiché    ${ISBN_ETRANGER}

UI-08 Un livre ajouté par l'API apparaît dans l'interface
    [Documentation]    Test multicouche : les données sont préparées par l'API (rapide et fiable),
    ...                seul le résultat est vérifié dans l'interface.
    [Tags]    US-01    US-02    multicouche
    Ajouter un livre par l'API    Candide    Voltaire    9782070466771
    Recharger la page
    Vérifier le nombre de livres affichés    4
    Vérifier le statut du livre    9782070466771    disponible

UI-09 Les modifications sont conservées après rechargement
    [Tags]    US-03
    Emprunter le livre    ${ISBN_ETRANGER}    Chloé
    Recharger la page
    Vérifier le statut du livre    ${ISBN_ETRANGER}    emprunté par Chloé
