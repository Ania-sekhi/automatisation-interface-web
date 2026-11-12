*** Settings ***
Documentation     Ouverture du navigateur pour la bibliothèque Browser (basée sur Playwright).
Library           Browser    timeout=5s
Resource          commun.resource


*** Keywords ***
Ouvrir le navigateur Playwright
    IF    $CHROMIUM
        New Browser    chromium    headless=${HEADLESS}    executablePath=${CHROMIUM}
    ELSE
        New Browser    chromium    headless=${HEADLESS}
    END
    New Context    viewport={'width': 1280, 'height': 900}    locale=fr-FR
