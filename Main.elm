module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import Http
import Html exposing (input, button)
import Html.Events exposing (onInput, onClick)
import Html exposing (h1, h2, ul, li, label)
import Html.Attributes exposing (type_, checked, value)
import Random
import Json.Decode as Decode


-- Model holds the entire app state.
type alias Model =
    { message : String                -- status message shown to the user
    , words : List String             -- list of candidate words loaded from /words.txt
    , targetWord : Maybe String       -- the current word to guess (Nothing until picked)
    , definitions : List String       -- definitions fetched from the dictionary API
    , guess : String                  -- current user input for the guess
    , success : Bool                  -- whether the user guessed correctly
    , reveal : Bool                   -- whether to reveal the answer checkbox
    , errorMessage : Maybe String     -- optional error message for network / file errors
    , feedback : Maybe String         -- short feedback ("Correct"/"Incorrect") for the user
    }


-- Messages for the Elm update loop.
type Msg
    = GotWords (Result Http.Error String)      -- result of loading /words.txt
    | WordPicked String                         -- directly pass the selected word
    | GotDefinitions (Result Http.Error (List String)) -- result of dictionary API call
    | UpdateGuess String                        -- user typed into the input
    | CheckGuess                                -- user clicked the "Check" button
    | ToggleReveal Bool                         -- user toggled reveal checkbox


-- Generate a random word directly from the list.
pickWordCmd : List String -> Cmd Msg
pickWordCmd words =
    if List.isEmpty words then
        Cmd.none
    else
        Random.generate 
            (\index -> WordPicked (Maybe.withDefault "" (List.drop index words |> List.head)))
            (Random.int 0 (List.length words - 1))


-- Decoder for a single definition string from the dictionary API JSON.
definitionDecoder : Decode.Decoder String
definitionDecoder =
    Decode.field "definition" Decode.string


-- Decoder that navigates into the API response structure to collect all definitions.
-- API structure: Array -> [0] -> meanings -> Array -> definitions -> Array -> {definition: "..."}
definitionsDecoder : Decode.Decoder (List String)
definitionsDecoder =
    Decode.index 0
        (Decode.field "meanings"
            (Decode.list
                (Decode.field "definitions"
                    (Decode.list definitionDecoder)
                )
            )
        )
        |> Decode.map List.concat  -- flatten nested lists of definitions into one list


-- Perform an HTTP GET to fetch definitions for the given word.
fetchDefinitions : String -> Cmd Msg
fetchDefinitions word =
    Http.get
        { url = "https://api.dictionaryapi.dev/api/v2/entries/en/" ++ word
        , expect = Http.expectJson GotDefinitions definitionsDecoder
        }


-- Initialize model and start loading words.txt
init : () -> ( Model, Cmd Msg )
init _ =
    ( { message = "Chargement..."
      , words = []
      , targetWord = Nothing
      , definitions = []
      , guess = ""
      , success = False
      , reveal = False
      , errorMessage = Nothing
      , feedback = Nothing
      }
    , Http.get
        { url = "/words.txt"
        , expect = Http.expectString GotWords
        }
    )


-- Update handles all messages and returns a new model and optional command.
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- Successfully loaded words.txt: trim, remove empty lines, store list and pick a random word.
        GotWords (Ok content) ->
            let
                wordList =
                    String.split " " content
                        |> List.map String.trim
                        |> List.filter (not << String.isEmpty)
            in
            ( { model | words = wordList, message = "Mot sélectionné, chargement des définitions..." }
            , pickWordCmd wordList
            )

        -- Failed to load words.txt: record an error message.
        GotWords (Err err) ->
            ( { model | errorMessage = Just ("Erreur: impossible de charger les mots. " ++ httpErrorToString err) }, Cmd.none )

        -- Random word was selected: use it directly.
        WordPicked w ->
            if String.isEmpty w then
                ( { model | errorMessage = Just "Erreur: impossible de sélectionner un mot" }, Cmd.none )
            else
                ( { model
                    | targetWord = Just w
                    , message = "Devine le mot"
                    , guess = ""
                    , feedback = Nothing
                    , definitions = []
                  }
                , fetchDefinitions w
                )
                
        -- Definitions loaded successfully: store them.
        GotDefinitions (Ok defs) ->
            if List.isEmpty defs then
                ( { model | errorMessage = Just "Aucune définition trouvée pour ce mot" }, Cmd.none )
            else
                ( { model | definitions = defs, errorMessage = Nothing }, Cmd.none )

        -- Definitions load failed: set an error message.
        GotDefinitions (Err err) ->
            ( { model | errorMessage = Just ("Erreur lors du chargement des définitions: " ++ httpErrorToString err) }, Cmd.none )

        -- User typed: update the guess field.
        UpdateGuess str ->
            ( { model | guess = str }, Cmd.none )

        -- User clicked Check: compare (case-insensitive, trimmed) guess to target word.
        CheckGuess ->
            case model.targetWord of
                Just w ->
                    if String.toLower (String.trim model.guess) == String.toLower w then
                        -- Correct guess: mark success and give positive feedback.
                        ( { model | success = True, feedback = Just "✅ Correct!" }, Cmd.none )
                    else
                        -- Incorrect guess: provide feedback but keep the game running.
                        ( { model | feedback = Just "❌ Incorrect, réessayez!" }, Cmd.none )

                Nothing ->
                    -- No target word selected yet: no-op.
                    ( model, Cmd.none )
        
        -- Toggle whether the answer is revealed.
        ToggleReveal b ->
            ( { model | reveal = b }, Cmd.none )


-- Helper function to convert HTTP errors to readable strings.
httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.BadUrl url ->
            "URL invalide: " ++ url
        Http.Timeout ->
            "Délai d'attente dépassé"
        Http.NetworkError ->
            "Erreur réseau"
        Http.BadStatus status ->
            "Erreur HTTP " ++ String.fromInt status
        Http.BadBody body ->
            "Erreur de décodage: " ++ body


-- View renders the current model to HTML.
view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Guess it!" ]

        -- Show error message if any.
        , case model.errorMessage of
            Just err ->
                div [ Html.Attributes.style "color" "red" ] [ text err ]
            Nothing ->
                text ""

        , h2 [] [ text "Définitions" ]

        -- Show loading hint or the list of definitions.
        , if List.isEmpty model.definitions then
            text "Chargement des définitions..."
          else
            ul []
                (List.map
                    (\def -> li [] [ text def ])
                    model.definitions
                )

        -- Input area: text field + Check button.
        , div []
            [ label [] [ text "Votre réponse: " ]
            , input
                [ value model.guess
                , onInput UpdateGuess
                ]
                []
            , button [ onClick CheckGuess ] [ text "Vérifier" ]
            ]

        -- Show brief feedback (correct / incorrect).
        , case model.feedback of
            Just fb ->
                div [] [ text fb ]
            Nothing ->
                text ""

        -- Reveal toggle: show/hide the answer.
        , div []
            [ label []
                [ input
                    [ type_ "checkbox"
                    , checked model.reveal
                    , onClick (ToggleReveal (not model.reveal))
                    ]
                    []
                , text " Afficher la réponse"
                ]
            ]

        -- If reveal is on, display the target word.
        , if model.reveal then
            case model.targetWord of
                Just w ->
                    div [] [ text ("👉 " ++ w) ]

                Nothing ->
                    text ""
          else
            text ""

        -- Congratulate on success.
        , if model.success then
            div [] [ text "Bravo 🎉" ]
          else
            text ""
        ]


-- Program entry point.
main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }