*** Settings ***
Documentation     « Page Object » de la borne VéloCité (bibliothèque Browser / Playwright).
...               Tous les sélecteurs de l'écran sont ici, et nulle part ailleurs :
...               quand l'interface change, on ne modifie que ce fichier.
Resource          navigateur.resource


*** Variables ***
# Libellé du bouton de paiement : « Payer » jusqu'à la livraison 3, « Régler » depuis la livraison 4
${BOUTON_PAYER}          Régler
${SIMULATEUR}            css=section[aria-labelledby="t-simu"]
${BORNE}                 css=section[aria-labelledby="t-borne"]
${MESSAGE}               id=message
${PRIX}                  id=prix-resultat


*** Keywords ***
# --- Outils -------------------------------------------------------------

Ouvrir une borne réinitialisée
    New Page    ${URL_VELOCITE}
    Click    id=reset
    Wait For Function    () => Number(document.body.dataset.reponses) >= 1

Cliquer et attendre la réponse
    [Documentation]    Clique, puis attend que la borne ait affiché sa réponse
    ...                (le compteur ``data-reponses`` de la page augmente à chaque réponse).
    [Arguments]    ${selecteur}
    ${avant}=    Get Attribute    css=body    data-reponses
    Click    ${selecteur}
    Wait For Function    () => Number(document.body.dataset.reponses) > ${avant}

Cliquer sur le bouton de la borne
    [Arguments]    ${libelle}
    Cliquer et attendre la réponse    ${BORNE} >> role=button[name="${libelle}"]
    ${texte}=    Get Text    ${MESSAGE}
    RETURN    ${texte}

# --- Simulateur de tarif ----------------------------------------------------

Calculer le prix
    [Arguments]    ${duree}    ${age}    ${velo}=Classique    ${abonne}=${False}
    Fill Text    id=duree    ${duree}
    Select Options By    id=type    label    ${velo}
    Fill Text    id=age    ${age}
    IF    ${abonne}    Check Checkbox    id=abonne    ELSE    Uncheck Checkbox    id=abonne
    Cliquer et attendre la réponse    id=calculer
    ${prix}=    Get Text    ${PRIX}
    RETURN    ${prix}

# --- Borne ------------------------------------------------------------------

Inscrire le client
    [Arguments]    ${nom}    ${age}
    Fill Text    id=nom    ${nom}
    Fill Text    id=age-client    ${age}
    Uncheck Checkbox    id=abonne-client
    ${message}=    Cliquer sur le bouton de la borne    Inscrire
    RETURN    ${message}

Faire une action pour le client
    [Arguments]    ${bouton}    ${client}    ${velo}=${None}
    Fill Text    id=client    ${client}
    IF    $velo    Select Options By    id=velo    label    ${velo}
    ${message}=    Cliquer sur le bouton de la borne    ${bouton}
    RETURN    ${message}

Réserver un vélo
    [Arguments]    ${client}    ${velo}=Classique
    ${message}=    Faire une action pour le client    Réserver    ${client}    ${velo}
    RETURN    ${message}

Déverrouiller le vélo
    [Arguments]    ${client}
    ${message}=    Faire une action pour le client    Déverrouiller    ${client}
    RETURN    ${message}

Rendre le vélo
    [Arguments]    ${client}
    ${message}=    Faire une action pour le client    Rendre le vélo    ${client}
    RETURN    ${message}

Payer la location
    [Arguments]    ${client}
    ${message}=    Faire une action pour le client    ${BOUTON_PAYER}    ${client}
    RETURN    ${message}

Voir l'état
    [Arguments]    ${client}
    ${message}=    Faire une action pour le client    Voir l'état    ${client}
    RETURN    ${message}

Avancer l'horloge de
    [Arguments]    ${duree}
    Fill Text    id=attente    ${duree}
    ${message}=    Cliquer sur le bouton de la borne    Avancer l'horloge
    RETURN    ${message}

Régler la banque sur
    [Arguments]    ${choix}
    ${avant}=    Get Attribute    css=body    data-reponses
    Select Options By    id=banque    label    ${choix}
    Wait For Function    () => Number(document.body.dataset.reponses) > ${avant}

Voir les débits
    Cliquer et attendre la réponse    id=debits
    ${texte}=    Get Text    ${MESSAGE}
    RETURN    ${texte}

Louer un vélo pendant 10 minutes
    [Arguments]    ${client}=alice
    Inscrire le client    ${client}    30
    Réserver un vélo    ${client}
    Déverrouiller le vélo    ${client}
    Avancer l'horloge de    10
    Rendre le vélo    ${client}
