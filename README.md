# Projet GuessIt en Elm
## Objectif
Réaliser le mini-jeu web GuessIt en Elm dont le but est de deviner un mot à partir de ses définitions. 

## Principe du jeu
- un mot est sélectionné aléatoirement dans words.txt
- les définitions du mot sont récupérées via une API et affichées
- le joueur tente de deviner le mot et entre sa proposition dans une zone de texte
- le jeu affiche si la proposition est correcte ou non
- le joueur peut tenter autant de réponse qu'il souhaite et le temps n'est pas limité
- le joueur peut afficher la bonne réponse grâce à une checkbox

## Technologies utilisées
- Elm : langage fonctionnel compilé en Javascript utilisé pour coder notre mini-jeu web
- [Free Dictionary API](https://dictionaryapi.dev/) : API regroupant des définitions, appelée via une requête HTTP

## Structure
Le projet est composé du fichier `Main.elm` dans lequel est implémenté le mini-jeu et du fichier `words.txt` qui contient la liste des mots utilisés par le mini-jeu. Dans le répertoire, on trouve aussi le fichier `main.js` qui contient le code JavaScript généré par Elm et le fichier de configuration `elm.json`.

## Fonctionnalités implémentées
- sélection aléatoire d’un mot
- chargement des définitions depuis une API externe
- saisie utilisateur et vérification de la réponse
- retour sur la validité de la réponse
- option pour révéler la réponse
- gestion des erreurs (réseau, chargement des données)

## Utilisation
Dans un terminal, récupérer le dossier contenant le projet.
```bash
~$ git clone https://github.com/eliemine24/elm_project.git
```   
Depuis le projet, initialiser le répertoire elm et installer les bibliothèques nécessaires en exécutant le script d'installation (répondre `Y` pour chaque demande du terminal).
```bash
~/elm_project$ ./install.sh
```
Lancer le programme principal.
```bash
~/elm_project$ elm reactor
```    
Copier l'adresse locale proposée (`http://localhost:8000`) dans un navigateur et aller dans le dossier `src` pour ouvrir le fichier `Main.elm`
