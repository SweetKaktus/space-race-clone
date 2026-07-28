# Notes de travail pour la feature Select Ship

Ce qu'on veut:

Sur le menu:
- le joueur 1 doit pouvoir sélectionner son vaisseau avec les touches Q et D (ou A et D pour les QWERTY).
- Le joueur 2 doit pouvoir sélectionner son vaisseau avec les flèches de droite et gauche.

Les joueurs doivent voir de leur côté le sprite de leur vaisseau, ce dernier se met à jour à mesure qu'ils sélectionnent un autre vaisseau.

Par défaut on initialise le vaisseau avec un sprite de base, en cas de changement, on en sélectionne un autre.

Lors de l'init du jeu, on charge tous les sprites et on les transforme en texture, comme ça on les a à disposition.

On voudra donc une liste d'Image, puis une liste de Texture

Quand le joueur appuie sur une touche directionnelle, ça fait monter un compteur qui s'incrémente ou se décrémente, ou se set à 0 ou à la valeur de la longueur de la liste de texture -1 lorsque le compteur atteint le max ou le min possible.

Donc il nous faut des variables qui contiennent la valeur min et max du compteur.
