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

        Autocomplete ->
            "autocomplete"

        Date ->
            "date"
