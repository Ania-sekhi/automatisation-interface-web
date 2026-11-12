*** Settings ***
Documentation     Régression automatisée de VéloCité (bibliothèque Browser, basée sur Playwright).
...               Chaque test reprend un cas du cahier de tests manuel (projet « VéloCité : campagne de test ») :
...               mêmes données, même résultat attendu. Les identifiants JD-xx renvoient au jeu de données.
Resource          ../resources/borne_velocite.resource
Suite Setup       Run Keywords    Démarrer VéloCité    AND    Ouvrir le navigateur Playwright
Suite Teardown    Run Keywords    Close Browser    AND    Arrêter les applications
Test Setup        Ouvrir une borne réinitialisée
Test Tags         velocite    playwright


*** Test Cases ***
CT-25 ex1 : 45 min, classique, 30 ans          [Template]    Le prix calculé est
    45      30    Classique     ${False}    2,00 €       # JD-P08
CT-25 ex2 : abonné                             [Template]    Le prix calculé est
    45      30    Classique     ${True}     1,00 €       # JD-P09
CT-25 ex3 : vélo électrique                    [Template]    Le prix calculé est
    45      30    Électrique    ${False}    4,00 €       # JD-P43
CT-25 ex4 : plafond                            [Template]    Le prix calculé est
    600     30    Classique     ${False}    15,00 €      # JD-P33 (12,00 € avant CR-01)
CT-25 ex5 : jeune                              [Template]    Le prix calculé est
    60      15    Classique     ${False}    1,00 €       # JD-P11
CT-25 ex6 : pénalité                           [Template]    Le prix calculé est
    1500    30    Classique     ${False}    165,00 €     # JD-P41 (162,00 € avant CR-01)

CT-14 Pas de pénalité à 1 440 min              [Template]    Le prix calculé est
    1440    30    Classique     ${False}    15,00 €      # JD-P38
CT-14 Pénalité à 1 441 min                     [Template]    Le prix calculé est
    1441    30    Classique     ${False}    165,00 €     # JD-P39

CT-10 Plafond électrique à 270 min             [Template]    Le prix calculé est
    270     30    Électrique    ${False}    18,00 €      # JD-P44
CT-10 Plafond électrique à 300 min             [Template]    Le prix calculé est
    300     30    Électrique    ${False}    20,00 €      # JD-P45
CT-10 Plafond électrique à 301 min             [Template]    Le prix calculé est
    301     30    Électrique    ${False}    20,00 €      # JD-P46

CT-19 Déverrouillage possible à 15:00
    Inscrire le client    a    30
    Réserver un vélo    a
    Avancer l'horloge de    15:00
    ${message}=    Déverrouiller le vélo    a
    Should Contain    ${message}    Vélo déverrouillé

CT-19 Réservation expirée à 15:01
    Inscrire le client    a    30
    Réserver un vélo    a
    Avancer l'horloge de    15:01
    ${message}=    Déverrouiller le vélo    a
    Should Contain    ${message}    Réservation expirée

CT-22 Un paiement refusé laisse la location à payer
    Louer un vélo pendant 10 minutes
    Régler la banque sur    Refuser les paiements
    ${message}=    Payer la location    alice
    Should Be Equal    ${message}    Paiement refusé
    ${etat}=    Voir l'état    alice
    Should Be Equal    ${etat}    État : TERMINEE

CT-23 Payer deux fois ne débite qu'une fois
    [Documentation]    Non-régression de DEF-11 (client débité deux fois).
    Louer un vélo pendant 10 minutes
    Payer la location    alice
    Payer la location    alice
    ${debits}=    Voir les débits
    Should Be Equal    ${debits}    Débits : alice 1,00 €


*** Keywords ***
Le prix calculé est
    [Arguments]    ${duree}    ${age}    ${velo}    ${abonne}    ${attendu}
    ${prix}=    Calculer le prix    ${duree}    ${age}    ${velo}    ${abonne}
    Should Be Equal    ${prix}    Prix : ${attendu}
