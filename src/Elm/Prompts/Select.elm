module Prompts.Select exposing (Item, option)

import Json.Encode as JE
import Prompts


type alias Item =
    { title : String
    , value : String
    , description : String
    }


itemEncoder : Item -> JE.Value
itemEncoder { title, value, description } =
    JE.object
        [ ( "title", JE.string title )
        , ( "value", JE.string value )
        , ( "description", JE.string description )
        ]


option : String -> List Item -> JE.Value
option message choices =
    JE.object
        [ ( "type", Prompts.toString Prompts.Select |> JE.string )
        , ( "name", JE.string "value" )
        , ( "message", JE.string message )
        , ( "choices", JE.list itemEncoder choices )
        ]
