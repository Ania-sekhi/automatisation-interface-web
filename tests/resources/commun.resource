*** Settings ***
Documentation     Démarrage et arrêt des trois applications testées.
...               Chaque suite démarre l'application dont elle a besoin : ``robot tests`` suffit.
Library           Process
Library           RequestsLibrary


*** Variables ***
${DOSSIER_APPLICATIONS}    ${CURDIR}/../../applications
${HEADLESS}                True
# Chemin d'un Chromium déjà installé (facultatif) pour la bibliothèque Browser.
# Vide = navigateur installé par « rfbrowser init ».
${CHROMIUM}                ${EMPTY}

${URL_MEDIATHEQUE}         http://127.0.0.1:5000
${URL_GENERATEUR}          http://127.0.0.1:5001/index.html
${URL_VELOCITE}            http://127.0.0.1:8000/


*** Keywords ***
Démarrer la Médiathèque
    ${python}=    Evaluate    sys.executable    modules=sys
    Start Process    ${python}    ${DOSSIER_APPLICATIONS}/mediatheque/app.py    alias=mediatheque
    ...    stdout=${OUTPUT DIR}/mediatheque.log    stderr=STDOUT
    Wait Until Keyword Succeeds    30x    0.5s    GET    ${URL_MEDIATHEQUE}/api/livres    expected_status=200

Démarrer le Générateur
    [Documentation]    Le générateur est une page statique : un simple serveur web suffit.
    ${python}=    Evaluate    sys.executable    modules=sys
    Start Process    ${python}    -m    http.server    5001    --bind    127.0.0.1
    ...    cwd=${DOSSIER_APPLICATIONS}/generateur    alias=generateur
    ...    stdout=${OUTPUT DIR}/generateur.log    stderr=STDOUT
    Wait Until Keyword Succeeds    30x    0.5s    GET    ${URL_GENERATEUR}    expected_status=200

Démarrer VéloCité
    [Documentation]    La livraison à tester doit être installée avant :
    ...                ``pip install applications/velocite/velocite-5.0-py3-none-any.whl``
    ${python}=    Evaluate    sys.executable    modules=sys
    Start Process    ${python}    -m    velocite    --port    8000    alias=velocite
    ...    stdout=${OUTPUT DIR}/velocite.log    stderr=STDOUT
    Wait Until Keyword Succeeds    30x    0.5s    GET    ${URL_VELOCITE}    expected_status=200

Arrêter les applications
    Terminate All Processes
