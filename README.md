# Projet GuessIt en ELM
## Objectif
Réaliser le mini-jeu web GuessIt en ELM dont le but est de deviner un mot à partir de ses définitions. 

## Principe du jeu
- un mot est sélectionné aléatoirement parmi les mots de words.txt
- les définitions du mot sont récupérées via une API et affichées
- le joueur tente de deviner le mot et entre sa proposition dans une zone de texte
- le jeu affiche si la proposition est correcte ou non
- le joueur peut tenter autant de réponse qu'il souhaite et le temps n'est pas limité
- le joueur peut afficher la bonne réponse en cochant une checkbox

## Technologies utilisées
- ELM : langage fonctionnel compilé en Javascript utilisé pour les applications web
- [Free Dictionary API](https://dictionaryapi.dev/) : API regroupant des définitions, appelée via une requête HTTP

## Structure
Le projet est composé du fichier `Main.elm` dans lequel est implémenté le mini-jeu, du fichier `words.txt` qui contient la liste des mots utilisés par le mini-jeu, et des fichiers et dossiers relatifs au language ELM.

## Fonctionnalités implémentées
- sélection aléatoire d’un mot
- chargement des définitions depuis une API externe
- saisie utilisateur et vérification de la réponse
- retour sur la validité de la réponse
- option pour révéler la réponse
- gestion des erreurs (réseau, chargement des données)

## Utilisation
Récupérer le dépôt du projet:   
```
git clone https://github.com/eliemine24/elm_project.git
```   
Dans un terminal, lancer le serveur ELM :   
```
elm reactor
```    
Copier l'adresse locale proposée (`http://localhost:8000`) dans un navigateur et ouvrir le fichier `Main.elm`
