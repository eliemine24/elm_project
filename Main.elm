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


type alias Model =
    { message : String
    , words : List String
    , targetWord : Maybe String
    , definitions : List String
    , guess : String
    , success : Bool
    , reveal : Bool
    , errorMessage : Maybe String
    , feedback : Maybe String
    }


type Msg
    = GotWords (Result Http.Error String)
    | WordPicked Int
    | GotDefinitions (Result Http.Error (List String))
    | UpdateGuess String
    | CheckGuess
    | ToggleReveal Bool


pickWordCmd : List String -> Cmd Msg
pickWordCmd words =
    Random.generate WordPicked (Random.int 0 (List.length words - 1))


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


fetchDefinitions : String -> Cmd Msg
fetchDefinitions word =
    Http.get
        { url = "https://api.dictionaryapi.dev/api/v2/entries/en/" ++ word
        , expect = Http.expectJson GotDefinitions definitionsDecoder
        }


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotWords (Ok content) ->
            let
                wordList =
                    String.lines content
                        |> List.map String.trim
                        |> List.filter (not << String.isEmpty)
            in
            ( { model | words = wordList }
            , pickWordCmd wordList
            )

        GotWords (Err _) ->
            ( { model | errorMessage = Just "Erreur: impossible de charger les mots" }, Cmd.none )

        WordPicked index ->
            case List.drop index model.words |> List.head of
                Just w ->
                    ( { model
                        | targetWord = Just w
                        , message = "Devine le mot"
                        , guess = ""
                        , feedback = Nothing
                      }
                    , fetchDefinitions w
                    )

                Nothing ->
                    ( model, Cmd.none )

        GotDefinitions (Ok defs) ->
            ( { model | definitions = defs }, Cmd.none )

        GotDefinitions (Err _) ->
            ( { model | errorMessage = Just "Erreur: impossible de charger les définitions" }, Cmd.none )

        UpdateGuess str ->
            ( { model | guess = str }, Cmd.none )

        CheckGuess ->
            case model.targetWord of
                Just w ->
                    if String.toLower (String.trim model.guess) == String.toLower w then
                        ( { model | success = True, feedback = Just "✅ Correct!" }, Cmd.none )
                    else
                        ( { model | feedback = Just "❌ Incorrect, réessayez!" }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )
        
        ToggleReveal b ->
            ( { model | reveal = b }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Guess it!" ]

        , case model.errorMessage of
            Just err ->
                div [ Html.Attributes.style "color" "red" ] [ text err ]
            Nothing ->
                text ""

        , h2 [] [ text "meanings" ]

        , if List.isEmpty model.definitions then
            text "Chargement des définitions..."
          else
            ul []
                (List.map
                    (\def -> li [] [ text def ])
                    model.definitions
                )

        , div []
            [ label [] [ text "Type in to guess: " ]
            , input
                [ value model.guess
                , onInput UpdateGuess
                ]
                []
            , button [ onClick CheckGuess ] [ text "Check" ]
            ]

        , case model.feedback of
            Just fb ->
                div [] [ text fb ]
            Nothing ->
                text ""

        , div []
            [ label []
                [ input
                    [ type_ "checkbox"
                    , checked model.reveal
                    , onClick (ToggleReveal (not model.reveal))
                    ]
                    []
                , text " Show answer"
                ]
            ]

        , if model.reveal then
            case model.targetWord of
                Just w ->
                    div [] [ text ("👉 " ++ w) ]

                Nothing ->
                    text ""
          else
            text ""

        , if model.success then
            div [] [ text "Bravo 🎉" ]
          else
            text ""
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }