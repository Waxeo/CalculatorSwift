# CalculatorSwift

Première approche du langage Swift dans le cadre des projets proposés par l'école 42, il s'agit d'une calculatrice fonctionelle. 
J'ai fais le choix de me baser sur la calculatrice Apple, notamment dans l'affichage des gestions d'erreurs liées aux overflows, une mauvaise expression ou encore une division par 0. 

Bien que le rendu et la structure sont améliorables je suis content de cette première approche avec le langage, il se prend en main facilement (2 jours pour recherches + code fonctionnel) et est très agréable a manipuler !

## Utilisation

Il y'a quelques spécificitéés liées a des problèmes rencontrés lors du développement :

- Pour passer un nombre en négatif, il ne faut pas appuyer sur "-" puis rentrer le nombre voulu mais d'abord rentrer le nombre puis appuyer sur "(-x)" qui passera l'expression donnée en négatif.
- L'overflow arrive dans la limite du double max / min a environ 1*10^308 donc vous pouvez y aller sur les gros calculs.
- Appuyer sur deux opérateurs a la suite remplaçera le premier par le deuxième.
- Finir un nombre par "." est considéré comme .0.
- La calculatrice éxecute bien les règles de prioritées sur la multiplication et la division.
- Pour le reste de son utilisation globale, elle s'utilise comme celle développée par Apple.

## Affichage
