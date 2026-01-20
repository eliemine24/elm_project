module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import Http
import Random


type alias Model =
    { message : String
    , words : List String
    , targetWord : Maybe String
    }


type Msg
    = GotWords (Result Http.Error String)
    | PickRandomWord
    | WordPicked Int

-- fonction pour sélectionner un mot au hasard dans words.txt
pickWordCmd : List String -> Cmd Msg
pickWordCmd words =
    Random.generate WordPicked (Random.int 0 (List.length words - 1))


init : () -> ( Model, Cmd Msg )
init _ =
    ( { message = "Chargement..."
      , words = []
      , targetWord = Nothing
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
            ( { model
                | words = wordList
                , message = "Mots chargés"
              }
            , pickWordCmd wordList
            )

        WordPicked index ->
            case List.drop index model.words |> List.head of
                Just w ->
                    ( { model
                        | targetWord = Just w
                        , message = "Mot choisi"
                      }
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ text model.message ]

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }