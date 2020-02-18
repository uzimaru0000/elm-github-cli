module Prompts.Select exposing (option)

import Json.Encode as JE
import Prompts


option : String -> List Prompts.Item -> JE.Value
option message choices =
    JE.object
        [ ( "type", Prompts.toString Prompts.Select |> JE.string )
        , ( "name", JE.string "value" )
        , ( "message", JE.string message )
        , ( "choices", JE.list Prompts.itemEncoder choices )
        ]
