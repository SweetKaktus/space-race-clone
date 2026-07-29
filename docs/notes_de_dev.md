# Notes de dev

Éléments dans le jeu:
- Étoiles
- 2 joueurs
- Timer
- Score

Règles:
- Il y a un certain nombre d'étoiles à l'écran, elles défilent toutes de gauche à droite, chaque étoile va dans une seule direction. Quand une étoile arrive au bout de l'écran, elle passe de l'autre côté mais reste dans la même direction.
- Les joueurs doivent traverser l'écran. Une fois arrivés au dela de l'écran en haut, ils basculent en bas de l'écran, alors le joueur gagne 1 point.
- A la fin du chrono la partie s'arrête et les scores s'affichent
- Si le joueur touche une étoile il est ramené au début de sa course.

Caractéristiques de chaque élément:
- Étoile:
	- position_x (aléatoire)
	- position_y (aléatoire)
	- width
	- height
	- speed (aléatoire)
	- direction (1 fois sur 2 : 1 ou -1)
	- color

- Joueurs:
	- player_number
	- position_x
	- position_y
	- width
	- height
	- speed
	- score
	- state
	- color

- Timer:
	- position_x
	- position_y
	- width
	- height
	- time
	- color
	
TO DO:
[X] Rectangle

	[X] Système de collision
	
[X] Joueur

	[X] Déplacements

	[X] State Machine

	[X] Marquer un point

	[X] Mourir

	[X] Resets de position


[X] Etoiles

	[X] Déplacements

	[X] Création d'un lots d'étoiles

	[X] Position de départ aléatoire

	[X] Vitesse aléatoire

	[X] Collision avec Joueur



## 260724 - Mon erreur sur la state machine

En fait j'avais créé 2 états de reset : ResetPosition et ResetToStartPosition.
L'idée c'était que certains events déclenchaient ces états pour que j'ai juste à trigger ces états pour ramener le joueur à certaines positions.

Le truc c'est que le switch en Zig ne fonctionne pas comme ça: Une fois qu'on a conclu une branche => On sort du switch, donc par exemple, quand je finissais de traverser le niveau, mon joueur se mettait en CROSS_FINISH_LINE puis au sein de la branche il basculait en RESET_POSITION, ensuite il sortait du switch, poursuivait l'algo et s'apercevait qu'il était toujours à la coordonnée qui déclenche le CROSS_FINISH_LINE, donc il rebasculait en CROSS_FINISH_LINE, et refaisait la même chose en boucle.

Du coup dans les états qui déclenchent un reset de position (CROSS_FINISH_LINE et DEAD), je réinitialise la position au sein de mon état, j'applique le code dont j'ai besoin, puis je bascule en état IDLE, qui est ajusté ensuite en fonction des touches sur lesquelles on appuie.

---

## Reste à faire à ce jour:

[X] Mettre un timer en place (et l'afficher).

[X] Ajouter des sons

[X] Ajouter des graphismes

	[X] Utiliser la method `void ImageResizeNN` pour scale ma texture

	[X] Ajouter des vaisseaux

[X] Faire tester

---

## Notes techniques

Pipeline de manipulation des images:
1. LoadImage
2. ImageResizeNN
3. LoadTextureFromImage
4. DrawTexture


---

Licences:
- https://mattflat.itch.io/ (SFX)
- https://gooseninja.itch.io (Music)
- https://gvituri.itch.io (Graphics)


---

Proto terminé et en ligne !
Participation à la [Garbage Jam #6](https://itch.io/jam/garbage-jam-6/rate/4825847)


---

Améliorations hors first release:

[X] Ajouter une trainée derrière le vaisseau

[X] Sélection de vaisseau sur le menu

[] Ajouter un fond qui scroll à l'infini de haut en bas
