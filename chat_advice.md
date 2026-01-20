# Intructions

## Vue d’ensemble du mini-projet

Fonctionnellement, ton application fait ceci :

1. Charger une liste de mots (`words.txt`)
2. Choisir **un mot au hasard**
3. Récupérer ses **définitions via une requête HTTP**
4. Afficher les définitions
5. L’utilisateur tape une proposition
6. Si la proposition est correcte → message de succès

Techniquement, tu vas utiliser :

* `Browser.element`
* `Http`
* `Json.Decode`
* `Random`
* The Elm Architecture (`Model`, `Msg`, `init`, `update`, `view`)

---

## Étape 0 — Structure minimale du projet

Commence avec **un seul module** (`Main.elm`).
Ensuite, tu pourras découper (par ex. `Dictionary.elm`, `Words.elm`).

```elm
module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
```

---

## Étape 1 — Modèle minimal et affichage statique

👉 Objectif : vérifier que l’architecture fonctionne.

### Model

```elm
type alias Model =
    { message : String }
```

### Msg

```elm
type Msg
    = NoOp
```

### init

```elm
init : () -> ( Model, Cmd Msg )
init _ =
    ( { message = "GuessIt démarre !" }, Cmd.none )
```

### update

```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )
```

### view

```elm
view : Model -> Html Msg
view model =
    div [] [ text model.message ]
```

### main

```elm
main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
```

✅ À ce stade : **la page s’affiche**, rien de plus.

---

## Étape 2 — Charger la liste de mots (`words.txt`)

Tu ne peux pas lire directement un fichier local en Elm.
➡️ Solution classique : exposer `words.txt` via HTTP.

Par exemple :

```
/public/words.txt
```

### Ajout dans le Model

```elm
type alias Model =
    { words : List String
    , message : String
    }
```

### Msg

```elm
type Msg
    = GotWords (Result Http.Error String)
```

### init → requête HTTP

```elm
init _ =
    ( { words = [], message = "Chargement..." }
    , Http.get
        { url = "/words.txt"
        , expect = Http.expectString GotWords
        }
    )
```

### update

```elm
update msg model =
    case msg of
        GotWords (Ok content) ->
            let
                wordList =
                    String.lines content
            in
            ( { model | words = wordList, message = "Mots chargés" }
            , Cmd.none
            )

        GotWords (Err _) ->
            ( { model | message = "Erreur de chargement" }
            , Cmd.none
            )
```

👉 **Objectif intermédiaire** : afficher le nombre de mots chargés.

---

## Étape 3 — Choisir un mot au hasard

### Model

```elm
type alias Model =
    { words : List String
    , targetWord : Maybe String
    }
```

### Msg

```elm
type Msg
    = GotWords (Result Http.Error String)
    | PickRandomWord
    | WordPicked Int
```

### Random

```elm
pickWordCmd : List String -> Cmd Msg
pickWordCmd words =
    Random.generate WordPicked (Random.int 0 (List.length words - 1))
```

### update

```elm
update msg model =
    case msg of
        GotWords (Ok content) ->
            let
                wordList =
                    String.lines content
            in
            ( { model | words = wordList }
            , pickWordCmd wordList
            )

        WordPicked index ->
            case List.drop index model.words |> List.head of
                Just w ->
                    ( { model | targetWord = Just w }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )
```

---

## Étape 4 — Récupérer les définitions (HTTP + JSON)

### Exemple de réponse API (simplifiée)

```json
[
  {
    "meanings": [
      {
        "definitions": [
          { "definition": "A thing you use to..." }
        ]
      }
    ]
  }
]
```

### Model

```elm
type alias Model =
    { targetWord : Maybe String
    , definitions : List String
    }
```

### Msg

```elm
type Msg
    = FetchDefinitions String
    | GotDefinitions (Result Http.Error (List String))
```

### Decoder JSON

```elm
import Json.Decode as Decode

definitionDecoder : Decode.Decoder String
definitionDecoder =
    Decode.field "definition" Decode.string

definitionsDecoder : Decode.Decoder (List String)
definitionsDecoder =
    Decode.at
        [ "meanings" ]
        (Decode.list
            (Decode.at
                [ "definitions" ]
                (Decode.list definitionDecoder)
            )
        )
        |> Decode.map List.concat
```

### Requête HTTP

```elm
fetchDefinitions : String -> Cmd Msg
fetchDefinitions word =
    Http.get
        { url = "https://api.dictionaryapi.dev/api/v2/entries/en/" ++ word
        , expect = Http.expectJson GotDefinitions definitionsDecoder
        }
```

---

## Étape 5 — Interaction utilisateur (input)

### Model

```elm
type alias Model =
    { guess : String
    , success : Bool
    }
```

### Msg

```elm
type Msg
    = UpdateGuess String
    | CheckGuess
```

### view

```elm
import Html exposing (input, button)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (value)

view model =
    div []
        [ input
            [ value model.guess
            , onInput UpdateGuess
            ]
            []
        , button [ onClick CheckGuess ] [ text "Valider" ]
        ]
```

### update

```elm
CheckGuess ->
    case model.targetWord of
        Just w ->
            ( { model | success = model.guess == w }, Cmd.none )

        Nothing ->
            ( model, Cmd.none )
```

---

## Étape 6 — Affichage conditionnel

```elm
if model.success then
    text "Bravo 🎉"
else
    text ""
```

---

## Conseils importants pour la notation

✅ Code **commenté**
✅ Fonctions **courtes**
✅ Découpage possible en modules :

* `Words.elm`
* `Dictionary.elm`
* `Main.elm`

---

## Prochaine étape ?

Si tu veux, je peux :

* t’aider à **factoriser en modules**
* t’aider à **déboguer une erreur Elm**
* te fournir une **structure complète prête à compiler**
* ou vérifier ton code une fois que tu as commencé

👉 Dis-moi où tu en es maintenant (zéro, milieu, ou code déjà écrit).

