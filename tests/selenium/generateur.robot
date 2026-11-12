*** Settings ***
Documentation     Tests du générateur de mot de passe (SeleniumLibrary / WebDriver), US 1 à 3.
...               Les identifiants CT-xx renvoient au plan de test corrigé (docs/plan-de-test-generateur.md).
...               Les tests tagués « bug-connu » décrivent le comportement attendu que l'application
...               ne respecte pas : lancés avec ``--skiponfailure bug-connu``, ils apparaissent en SKIP
...               (bug toujours présent) et passeront en PASS dès que le bug sera corrigé.
Resource          ../resources/generateur.resource
Suite Setup       Run Keywords    Démarrer le Générateur    AND    Ouvrir le navigateur Selenium
Suite Teardown    Run Keywords    Close All Browsers    AND    Arrêter les applications
Test Setup        Ouvrir le générateur
Test Tags         generateur    selenium


*** Test Cases ***
# ======================= US 1 : options du mot de passe =======================

CT-01 Longueur limite basse : 1
    [Tags]    us1
    [Template]    Le mot de passe a la longueur demandée
    1
CT-02 Longueur nominale : 12
    [Tags]    us1
    [Template]    Le mot de passe a la longueur demandée
    12
CT-03 Longueur limite haute : 50
    [Tags]    us1
    [Template]    Le mot de passe a la longueur demandée
    50

CT-04 Minuscules seules
    [Tags]    us1
    [Template]    Seuls les caractères du type coché sont utilisés
    minuscules
CT-05 Majuscules seules
    [Tags]    us1
    [Template]    Seuls les caractères du type coché sont utilisés
    majuscules
CT-06 Chiffres seuls
    [Tags]    us1
    [Template]    Seuls les caractères du type coché sont utilisés
    chiffres
CT-07 Caractères spéciaux seuls
    [Tags]    us1
    [Template]    Seuls les caractères du type coché sont utilisés
    caractères spéciaux

CT-08 Tous les critères : seuls les caractères autorisés
    [Tags]    us1
    ${mdp}=    Générer un mot de passe    30    @{TOUS}
    Length Should Be    ${mdp}    30
    Le mot de passe ne contient que    ${mdp}    @{TOUS}

CT-09 Aucun critère coché
    [Tags]    us1
    ${mdp}=    Générer un mot de passe    12
    Should Be Equal    ${mdp}    ${MESSAGE_SANS_CRITERE}

CT-10 Le champ longueur refuse les lettres
    [Tags]    us1
    Saisir la longueur    un_Mot
    ${valeur}=    Valeur du champ longueur
    Should Be Empty    ${valeur}

CT-11 Longueur négative : message d'erreur
    [Tags]    us1    bug-connu
    [Template]    Une longueur invalide affiche un message d'erreur
    -1
CT-12 Longueur zéro : message d'erreur
    [Tags]    us1    bug-connu
    [Template]    Une longueur invalide affiche un message d'erreur
    0
CT-13 Longueur vide : message d'erreur
    [Tags]    us1    bug-connu
    [Template]    Une longueur invalide affiche un message d'erreur
    ${EMPTY}

CT-14 Longueur supérieure à 50 refusée
    [Documentation]    BUG : la limite de 50 n'est pas contrôlée, 51 caractères sont générés.
    [Tags]    us1    bug-connu
    ${mdp}=    Générer un mot de passe    51    minuscules
    ${longueur}=    Get Length    ${mdp}
    Should Be True    ${longueur} <= 50    ${longueur} caractères générés

CT-15 Chaque type coché est présent
    [Documentation]    BUG : la présence de chaque type coché n'est pas garantie (20 essais à 4 caractères).
    [Tags]    us1    bug-connu
    Saisir la longueur    4
    Cocher exactement    @{TOUS}
    FOR    ${essai}    IN RANGE    20
        ${mdp}=    Générer
        Le mot de passe contient chaque type    ${mdp}    @{TOUS}
    END

CT-16 Moins de caractères que de critères
    [Documentation]    BUG : aucun contrôle quand la longueur est inférieure au nombre de critères.
    [Tags]    us1    bug-connu
    ${mdp}=    Générer un mot de passe    3    @{TOUS}
    Should Contain    ${mdp}    Impossible

# ======================= US 2 : génération ====================================

CT-17 Le mot de passe s'affiche après le clic
    [Tags]    us2
    ${avant}=    Résultat affiché
    Should Be Equal    ${avant}    ${TEXTE_INITIAL}
    ${mdp}=    Générer un mot de passe    12    minuscules
    Should Not Be Equal    ${mdp}    ${TEXTE_INITIAL}
    Length Should Be    ${mdp}    12

CT-18 Chaque clic génère un nouveau mot de passe
    [Tags]    us2
    Saisir la longueur    20
    Cocher exactement    @{TOUS}
    @{mots}=    Create List
    FOR    ${i}    IN RANGE    5
        ${mdp}=    Générer
        Should Not Contain    ${mots}    ${mdp}    Mot de passe déjà généré : ${mdp}
        Append To List    ${mots}    ${mdp}
    END

# ======================= US 3 : indicateur de sécurité ========================

CT-19 Indicateur gris avant génération
    [Tags]    us3
    ${couleurs}=    Couleurs de l'indicateur
    FOR    ${niveau}    ${couleur}    IN    &{couleurs}
        Should Be Equal    ${couleur}    gris    msg=Zone ${niveau} : ${couleur}
    END

CT-20 Niveau Mauvais (1 minuscule)
    [Tags]    us3
    [Template]    Le niveau de sécurité avec des minuscules est
    1     Mauvais     rouge
CT-21 Niveau Moyen (5 minuscules)
    [Tags]    us3
    [Template]    Le niveau de sécurité avec des minuscules est
    5     Moyen       orange
CT-22 Niveau Correct (8 minuscules)
    [Tags]    us3
    [Template]    Le niveau de sécurité avec des minuscules est
    8     Correct     jaune
CT-23 Niveau Bon (12 minuscules)
    [Tags]    us3
    [Template]    Le niveau de sécurité avec des minuscules est
    12    Bon         vert
CT-24 Niveau Très bon (20 minuscules)
    [Tags]    us3
    [Template]    Le niveau de sécurité avec des minuscules est
    20    Très bon    bleu

CT-25 La diversité des caractères augmente le niveau
    [Documentation]    Même longueur (6), plus de types : 26^6 combinaisons (Moyen) puis 77^6 (Correct).
    [Tags]    us3
    Générer un mot de passe    6    minuscules
    Seul le niveau est allumé    Moyen    orange
    Cocher exactement    @{TOUS}
    Générer
    Seul le niveau est allumé    Correct    jaune

CT-26 Indicateur réinitialisé si la génération est impossible
    [Documentation]    BUG : l'indicateur garde le niveau précédent quand la génération est impossible.
    [Tags]    us3    bug-connu
    ${image_initiale}=    Image de l'indicateur
    Générer un mot de passe    20    @{TOUS}
    Cocher exactement
    Générer
    ${image}=    Image de l'indicateur
    Should Be Equal    ${image}    ${image_initiale}    msg=L'indicateur n'est pas revenu au gris    values=False


*** Keywords ***
Le mot de passe a la longueur demandée
    [Arguments]    ${longueur}
    ${mdp}=    Générer un mot de passe    ${longueur}    minuscules
    Length Should Be    ${mdp}    ${longueur}

Seuls les caractères du type coché sont utilisés
    [Arguments]    ${critere}
    ${mdp}=    Générer un mot de passe    30    ${critere}
    Le mot de passe ne contient que    ${mdp}    ${critere}

Une longueur invalide affiche un message d'erreur
    [Documentation]    BUG : aucun message d'erreur, un mot de passe vide est affiché.
    [Arguments]    ${longueur}
    ${mdp}=    Générer un mot de passe    ${longueur}    minuscules
    Should Contain    ${mdp}    Impossible

Le niveau de sécurité avec des minuscules est
    [Arguments]    ${longueur}    ${niveau}    ${couleur}
    Générer un mot de passe    ${longueur}    minuscules
    Seul le niveau est allumé    ${niveau}    ${couleur}
