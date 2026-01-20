module Main exposing (main)

import Browser
import Html exposing (Html, div, text)

type alias Model =
    { message : String }


type Msg
    = NoOp


init : () -> ( Model, Cmd Msg )
init _ =
    ( { message = "GuessIt démarre !" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


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