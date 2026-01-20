module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import Http
import Html exposing (input, button)
import Html.Events exposing (onInput, onClick)
import Html.Attributes exposing (value)
import Random
import Json.Decode as Decode


type alias Model =
    { message : String
    , words : List String
    , targetWord : Maybe String
    , definitions : List String
    , guess : String
    , success : Bool
    }


type Msg
    = GotWords (Result Http.Error String)
    | WordPicked Int
    | GotDefinitions (Result Http.Error (List String))
    | UpdateGuess String
    | CheckGuess

-- fonction pour sélectionner un mot au hasard dans words.txt
pickWordCmd : List String -> Cmd Msg
pickWordCmd words =
    Random.generate WordPicked (Random.int 0 (List.length words - 1))

-- décodeur json pour les définitions
definitionDecoder : Decode.Decoder String
definitionDecoder =
    Decode.field "definition" Decode.string

-- décodeur des définitions 
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

-- récup les définitions 
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
            in
            ( { model | words = wordList }
            , pickWordCmd wordList
            )

        WordPicked index ->
            case List.drop index model.words |> List.head of
                Just w ->
                    ( { model
                        | targetWord = Just w
                        , message = "Devine le mot"
                      }
                    , fetchDefinitions w
                    )

                Nothing ->
                    ( model, Cmd.none )

        GotDefinitions (Ok defs) ->
            ( { model | definitions = defs }, Cmd.none )

        UpdateGuess str ->
            ( { model | guess = str }, Cmd.none )

        CheckGuess ->
            case model.targetWord of
                Just w ->
                    ( { model | success = model.guess == w }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        ([ div [] (List.map text model.definitions)
         , input
            [ value model.guess
            , onInput UpdateGuess
            ]
            []
         , button [ onClick CheckGuess ] [ text "Valider" ]
         ]
            ++ (if model.success then
                    [ div [] [ text "Bravo 🎉" ] ]
                else
                    []
               )
        )

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }