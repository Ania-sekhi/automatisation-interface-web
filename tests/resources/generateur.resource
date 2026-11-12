*** Settings ***
Documentation     « Page Object » du générateur de mot de passe (SeleniumLibrary / WebDriver).
...               Les tests appellent des actions métier (« Saisir la longueur », « Cocher exactement »…) :
...               si l'interface change, seul ce fichier change.
Library           SeleniumLibrary    timeout=5s
Library           String
Library           Collections
Resource          commun.resource


*** Variables ***
${TEXTE_INITIAL}           Le mot de passe généré apparaitra ici...
${MESSAGE_SANS_CRITERE}    Impossible de générer le mot de passe sans critères
&{CASES}                   minuscules=id:min    majuscules=id:maj    chiffres=id:num    caractères spéciaux=id:car
&{PLAGES}                  minuscules=a-z    majuscules=A-Z    chiffres=0-9    caractères spéciaux=!-/
@{TOUS}                    minuscules    majuscules    chiffres    caractères spéciaux

# Lecture de l'indicateur de sécurité : couleur d'un pixel de fond de chaque zone du <canvas>
${JS_COULEURS}             SEPARATOR=
...    const zones = [["Mauvais",20,45],["Moyen",75,45],["Correct",155,45],["Bon",260,45],["Très bon",390,45]];
...    const noms = {"255,0,0":"rouge","255,165,0":"orange","255,255,0":"jaune","0,128,0":"vert","0,0,255":"bleu","128,128,128":"gris"};
...    const ctx = document.getElementById("canvas").getContext("2d");
...    const resultat = {};
...    for (const [niveau, x, y] of zones) {
...      const rgb = Array.from(ctx.getImageData(x, y, 1, 1).data.slice(0, 3)).join(",");
...      resultat[niveau] = noms[rgb] || "inconnue " + rgb;
...    }
...    return resultat;


*** Keywords ***
# --- Ouverture ---------------------------------------------------------------

Ouvrir le navigateur Selenium
    ${options}=    Set Variable    add_argument("--window-size=1280,900")
    IF    ${HEADLESS}
        ${options}=    Set Variable    ${options};add_argument("--headless=new")
    END
    IF    $CHROMIUM
        ${options}=    Set Variable    ${options};binary_location="${CHROMIUM}"
    END
    Open Browser    ${URL_GENERATEUR}    chrome    options=${options}

Ouvrir le générateur
    Go To    ${URL_GENERATEUR}
    Wait Until Element Is Visible    id:generation

# --- Actions -----------------------------------------------------------------

Saisir la longueur
    [Arguments]    ${valeur}
    Clear Element Text    id:nb
    IF    $valeur != ""    Input Text    id:nb    ${valeur}    clear=False

Cocher exactement
    [Documentation]    Coche les critères donnés et décoche tous les autres.
    [Arguments]    @{criteres}
    FOR    ${nom}    ${case}    IN    &{CASES}
        IF    $nom in $criteres
            Select Checkbox    ${case}
        ELSE
            Unselect Checkbox    ${case}
        END
    END

Générer
    Click Button    id:generation
    ${mdp}=    Résultat affiché
    RETURN    ${mdp}

Générer un mot de passe
    [Arguments]    ${longueur}    @{criteres}
    Saisir la longueur    ${longueur}
    Cocher exactement    @{criteres}
    ${mdp}=    Générer
    RETURN    ${mdp}

# --- Lectures ----------------------------------------------------------------

Résultat affiché
    ${texte}=    Get Text    id:mdp
    ${texte}=    Strip String    ${texte}
    RETURN    ${texte}

Valeur du champ longueur
    ${valeur}=    Get Value    id:nb
    RETURN    ${valeur}

Couleurs de l'indicateur
    ${couleurs}=    Execute Javascript    ${JS_COULEURS}
    RETURN    ${couleurs}

Image de l'indicateur
    ${image}=    Execute Javascript    return document.getElementById("canvas").toDataURL();
    RETURN    ${image}

# --- Vérifications -----------------------------------------------------------

Le mot de passe ne contient que
    [Arguments]    ${mdp}    @{criteres}
    ${autorises}=    Set Variable    ${EMPTY}
    FOR    ${critere}    IN    @{criteres}
        ${autorises}=    Set Variable    ${autorises}${PLAGES}[${critere}]
    END
    Should Match Regexp    ${mdp}    ^[${autorises}]+$

Le mot de passe contient chaque type
    [Arguments]    ${mdp}    @{criteres}
    FOR    ${critere}    IN    @{criteres}
        ${plage}=    Set Variable    ${PLAGES}[${critere}]
        Should Match Regexp    ${mdp}    [${plage}]    msg=« ${mdp} » ne contient aucun caractère de type ${critere}
    END

Seul le niveau est allumé
    [Arguments]    ${niveau}    ${couleur}
    ${couleurs}=    Couleurs de l'indicateur
    Should Be Equal    ${couleurs}[${niveau}]    ${couleur}
    FOR    ${autre}    ${c}    IN    &{couleurs}
        IF    $autre != $niveau    Should Be Equal    ${c}    gris    msg=Zone ${autre} allumée : ${couleurs}
    END
