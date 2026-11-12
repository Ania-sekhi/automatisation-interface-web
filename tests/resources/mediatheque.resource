*** Settings ***
Documentation     « Page Object » de l'interface web de la Médiathèque (bibliothèque Browser / Playwright).
...               Les sélecteurs utilisent les attributs ``data-testid`` : ils ne dépendent ni du style
...               ni des textes affichés, et restent stables si le design change.
Resource          navigateur.resource


*** Variables ***
# Livres présents au démarrage (jeu de données de référence)
${ISBN_PETIT_PRINCE}        9782070408504
${ISBN_ETRANGER}            9782070360024
${ISBN_MISERABLES}          9782253096344
${CATALOGUE}                css=[data-testid="catalogue"]


*** Keywords ***
# --- Préparation -------------------------------------------------------------

Ouvrir une session sur l'API
    Create Session    mediatheque    ${URL_MEDIATHEQUE}

Repartir d'un catalogue de référence
    [Documentation]    Remet le jeu de données de référence par l'API : chaque test démarre dans le même état.
    POST On Session    mediatheque    /api/test/reset    expected_status=200
    New Page    ${URL_MEDIATHEQUE}
    Wait For Elements State    ${CATALOGUE} tr >> nth=0    visible
    Get Title    ==    Médiathèque

Ajouter un livre par l'API
    [Arguments]    ${titre}    ${auteur}    ${isbn}
    &{livre}=    Create Dictionary    titre=${titre}    auteur=${auteur}    isbn=${isbn}
    POST On Session    mediatheque    /api/livres    json=${livre}    expected_status=201

Recharger la page
    Reload
    Wait For Elements State    ${CATALOGUE} tr >> nth=0    visible

# --- Actions -----------------------------------------------------------------

Ajouter un livre
    [Arguments]    ${titre}    ${auteur}    ${isbn}
    Fill Text    css=[data-testid="champ-titre"]     ${titre}
    Fill Text    css=[data-testid="champ-auteur"]    ${auteur}
    Fill Text    css=[data-testid="champ-isbn"]      ${isbn}
    Click    css=[data-testid="bouton-ajouter"]

Emprunter le livre
    [Documentation]    Sans nom d'emprunteur, on clique sur « Emprunter » sans rien saisir.
    [Arguments]    ${isbn}    ${emprunteur}=${EMPTY}
    IF    $emprunteur
        Fill Text    css=[data-testid="livre-${isbn}"] >> css=[data-testid="champ-emprunteur"]    ${emprunteur}
    END
    Click    css=[data-testid="livre-${isbn}"] >> css=[data-testid="bouton-emprunter"]

Rendre le livre
    [Arguments]    ${isbn}
    Click    css=[data-testid="livre-${isbn}"] >> css=[data-testid="bouton-rendre"]

Supprimer le livre
    [Arguments]    ${isbn}
    Click    css=[data-testid="livre-${isbn}"] >> css=[data-testid="bouton-supprimer"]

# --- Vérifications -----------------------------------------------------------

Vérifier le nombre de livres affichés
    [Arguments]    ${nombre}
    Get Text    css=[data-testid="nombre-livres"]    ==    ${nombre}
    Get Element Count    ${CATALOGUE} tr    ==    ${nombre}

Vérifier le statut du livre
    [Arguments]    ${isbn}    ${statut}
    Get Text    css=[data-testid="livre-${isbn}"] >> css=[data-testid="statut"]    ==    ${statut}

Vérifier que le livre n'est plus affiché
    [Arguments]    ${isbn}
    Get Element Count    css=[data-testid="livre-${isbn}"]    ==    0

Vérifier que le bouton Supprimer est désactivé
    [Arguments]    ${isbn}
    Get Element States    css=[data-testid="livre-${isbn}"] >> css=[data-testid="bouton-supprimer"]    contains    disabled

Vérifier le message
    [Arguments]    ${texte}
    Get Text    css=[data-testid="message"]    ==    ${texte}

Vérifier que le formulaire est vidé
    Get Text    css=[data-testid="champ-titre"]    ==    ${EMPTY}
