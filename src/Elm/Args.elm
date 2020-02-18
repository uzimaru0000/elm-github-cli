module Args exposing (Args, fromString)


type alias Args =
    { userName : String
    , repoName : String
    }


fromString : String -> Maybe Args
fromString str =
    case String.split "/" str of
        fst :: scd :: [] ->
            Just
                { userName = fst
                , repoName = scd
                }

        _ ->
            Nothing
