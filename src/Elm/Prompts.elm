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
    | Autocomplete
    | Date


type alias Option =
    { type_ : PromptType
    , message : String
    , initial : String
    }


promptType2Str : PromptType -> String
promptType2Str type_ =
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

        Autocomplete ->
            "autocomplete"

        Date ->
            "date"


optionEncoder : Option -> JE.Value
optionEncoder { type_, message, initial } =
    JE.object
        [ ( "type", JE.string <| promptType2Str type_ )
        , ( "name", JE.string "value" )
        , ( "message", JE.string message )
        , ( "initial", JE.string initial )
        ]


option : PromptType -> String -> String -> JE.Value
option type_ message initial =
    { type_ = type_
    , message = message
    , initial = initial
    }
        |> optionEncoder
