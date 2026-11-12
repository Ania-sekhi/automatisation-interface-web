# L'application testée

Ces fichiers sont les **5 livraisons** de VéloCité reçues de l'équipe de développement, sous forme de paquets installables. Je ne les ai pas développées : je les ai **testées**.

| Paquet | Livraison | Contenu | Testée en |
|---|:---:|---|:---:|
| `velocite-1.0-py3-none-any.whl` | 1 | Première version (10 défauts injectés volontairement) | Campagne 1 |
| `velocite-2.0-py3-none-any.whl` | 2 | Corrections de D-01 à D-10 | Campagne 2 |
| `velocite-3.0-py3-none-any.whl` | 3 | Correction de DEF-11, **mise en production** | Campagne 3 |
| `velocite-4.0-py3-none-any.whl` | 4 | Évolution CR-01 (plafond 15 €) + nouveau libellé « Régler » | Campagne 4 |
| `velocite-5.0-py3-none-any.whl` | 5 | Correction de DEF-14 | Campagne 5 |

## Lancer une livraison

```bash
pip install application/velocite-5.0-py3-none-any.whl   # ou une autre livraison
velocite                                                # puis ouvrir http://127.0.0.1:8000
```

Pour changer de livraison : `pip install --force-reinstall application/velocite-3.0-py3-none-any.whl`.
