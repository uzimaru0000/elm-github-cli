module Prompts exposing (..)

import Json.Encode as JE


type PromptType
    = Text
    | Password
    | Invisible
    | Number
    | Confirm
    | List
    | Toggle
    | Select
    | MultiSelect
    | AutoComplete
    | Date


toString : PromptType -> String
toString type_ =
    case type_ of
        Text ->
            "text"

        Password ->
            "password"

        Invisible ->
            "invisible"

        Number ->
            "number"

        Confirm ->
            "confirm"

        List ->
            "list"

        Toggle ->
            "toggle"

        Select ->
            "select"

        MultiSelect ->
            "multiselect"

        AutoComplete ->
            "autocomplete"

        Date ->
            "date"


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
