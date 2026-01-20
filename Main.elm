module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import Http

type alias Model =
    { words : List String
    , message : String
    }


type Msg
    = GotWords (Result Http.Error String)


init _ =
    ( { words = [], message = "Chargement..." }
    , Http.get
        { url = "/words.txt"
        , expect = Http.expectString GotWords
        }
    )


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


view : Model -> Html Msg
view model =
    div [] [ text model.message ]

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }