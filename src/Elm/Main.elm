module Main exposing (..)

import Html exposing (Html, div, text)
import Browser


type alias Model =
  {}


type Msg
  = NoOp


init : () -> (Model, Cmd Msg)
init _ =
  ({}, Cmd.none)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  (model, Cmd.none)


view : Model -> Html Msg
view model =
  div [] [ text "Hello, Elm app" ]


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


main : Program () Model Msg
main =
    Browser.element
    { init = init
    , update = update
    , view = view
    , subscriptions = subscriptions
    }

