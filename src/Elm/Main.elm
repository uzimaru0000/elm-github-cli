port module Main exposing (main)

import Cli
import GitHub
import Http
import Json.Decode as JD
import Json.Encode as JE
import Prompts.Select as Select
import Prompts.Text as Text


type State
    = InputUserName
    | SelectRepository


type alias Model =
    { args : List String
    , state : State
    }


type Msg
    = GetRepositories (Result Http.Error (List GitHub.Repository))
    | InputUser String
    | SelectedRepository String
    | NoOp


type alias Flag =
    List String


init : Flag -> ( Model, Cmd Msg )
init flags =
    ( { args = flags
      , state = InputUserName
      }
    , output ( "", Text.option "Input user name : " )
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputUser userName ->
            ( model, GitHub.getRepositories userName GetRepositories )

        GetRepositories (Ok repos) ->
            ( { model | state = SelectRepository }
            , output
                ( ""
                , repos
                    |> List.map repo2Item
                    |> Select.option "Select Repositories"
                )
            )

        SelectedRepository url ->
            ( model
            , exitWithMsg
                ( 0
                , Cli.text [ Cli.foreGroundColor Cli.Green ] url ++ "\n"
                )
            )

        _ ->
            ( model, exitWithMsg ( 1, "Error\n" ) )


repo2Item : GitHub.Repository -> Select.Item
repo2Item repo =
    { title = repo.name
    , value = repo.htmlUrl
    , description = repo.description |> Maybe.withDefault ""
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    [ JD.decodeValue
        (JD.string
            |> JD.map
                (case model.state of
                    InputUserName ->
                        InputUser

                    SelectRepository ->
                        SelectedRepository
                )
        )
        >> Result.withDefault NoOp
        |> input
    ]
        |> Sub.batch


main : Program Flag Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



-- PORTS


port output : ( String, JE.Value ) -> Cmd msg


port exitWithMsg : ( Int, String ) -> Cmd msg


port input : (JD.Value -> msg) -> Sub msg
