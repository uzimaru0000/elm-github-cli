module GitHub exposing
    ( Repository
    , getRepositories
    )

import Http
import Json.Decode as JD exposing (Decoder)


endpoint : String
endpoint =
    "https://api.github.com"


type alias Repository =
    { id : Int
    , name : String
    , htmlUrl : String
    , description : Maybe String
    }


repositoryDecoder : Decoder Repository
repositoryDecoder =
    JD.map4 Repository
        (JD.field "id" JD.int)
        (JD.field "name" JD.string)
        (JD.field "html_url" JD.string)
        (JD.field "description" <| JD.nullable JD.string)


getRepositories : String -> (Result Http.Error (List Repository) -> msg) -> Cmd msg
getRepositories username msg =
    Http.get
        { url =
            [ endpoint, "users", username, "repos" ]
                |> String.join "/"
        , expect = Http.expectJson msg (JD.list repositoryDecoder)
        }
