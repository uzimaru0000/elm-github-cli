module Prompts.Text exposing (..)

import Json.Encode as JE
import Prompts


option : String -> JE.Value
option message =
    JE.object
        [ ( "type", Prompts.promptType2Str Prompts.Text |> JE.string )
        , ( "name", JE.string "value" )
        , ( "message", JE.string message )
        ]
