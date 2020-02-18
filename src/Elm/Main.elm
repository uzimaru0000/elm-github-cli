port module Main exposing (main)

import Args exposing (Args)
import Cli
import GitHub
import Http
import Json.Decode as JD
import Json.Encode as JE
import Prompts
import Prompts.AutoComplete as AutoComplete
import Prompts.Text as Text


type State
    = InputUserName
    | SelectRepository


type alias Model =
    { args : Maybe Args
    , state : State
    }


type Msg
    = GetRepositories (Result Http.Error (List GitHub.Repository))
    | InputUser String
    | SelectedRepository String
    | NoOp


type alias Flag =
    String


init : Flag -> ( Model, Cmd Msg )
init flags =
    let
        maybeArgs =
            Args.fromString flags
    in
    ( { args = maybeArgs
      , state = InputUserName
      }
    , case maybeArgs of
        Just args ->
            GitHub.getRepositories args.userName GetRepositories

        Nothing ->
            output <| Text.option "Input User Name : "
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputUser userName ->
            ( model, GitHub.getRepositories userName GetRepositories )

        GetRepositories (Ok repos) ->
            ( { model | state = SelectRepository }
            , model.args
                |> Maybe.andThen (.repoName >> findRepository repos)
                |> Maybe.map
                    (.htmlUrl
                        >> Cli.text [ Cli.foreGroundColor Cli.Green ]
                        >> Tuple.pair 0
                        >> exitWithMsg
                    )
                |> Maybe.withDefault
                    (repos
                        |> List.map repo2Item
                        |> AutoComplete.option "Select Repository : "
                        |> output
                    )
            )

        SelectedRepository url ->
            ( model
            , exitWithMsg
                ( 0
                , Cli.text [ Cli.foreGroundColor Cli.Green ] url
                )
            )

        _ ->
            ( model
            , exitWithMsg ( 1, "Error" )
            )


repo2Item : GitHub.Repository -> Prompts.Item
repo2Item repo =
    { title = repo.name
    , value = repo.htmlUrl
    , description = repo.description |> Maybe.withDefault ""
    }


findRepository : List GitHub.Repository -> String -> Maybe GitHub.Repository
findRepository list name =
    list
        |> List.filter (.name >> (==) name)
        |> List.head


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        decoder =
            case model.state of
                InputUserName ->
                    JD.map InputUser JD.string

                SelectRepository ->
                    JD.map SelectedRepository JD.string
    in
    [ JD.decodeValue decoder
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


port output : JE.Value -> Cmd msg


port exitWithMsg : ( Int, String ) -> Cmd msg


port input : (JD.Value -> msg) -> Sub msg
