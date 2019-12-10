port module Main exposing (..)

import Cli
import GitHub
import Http
import Json.Decode as JD


type alias Model =
    { args : List String
    , repos : List GitHub.Repository
    , cursor : Int
    }


type Msg
    = Input InputData
    | GetRepositories (Result Http.Error (List GitHub.Repository))
    | KeyDown String
    | NoOp


type OuterMsg
    = InputUserName


type alias InputData =
    { msg : OuterMsg
    , input : String
    }


type alias Flag =
    List String


outerMsgDecoder : JD.Decoder OuterMsg
outerMsgDecoder =
    JD.string
        |> JD.andThen
            (\str ->
                case str of
                    "INPUT_USER_NAME" ->
                        JD.succeed InputUserName

                    _ ->
                        JD.fail "undefined msg"
            )


inputDataDecoder : JD.Decoder InputData
inputDataDecoder =
    JD.map2 InputData
        (JD.field "msg" outerMsgDecoder)
        (JD.field "input" JD.string)


init : Flag -> ( Model, Cmd Msg )
init flags =
    ( { args = flags
      , repos = []
      , cursor = 0
      }
    , requestInput ( "INPUT_USER_NAME", "Input username : " )
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input data ->
            case data.msg of
                InputUserName ->
                    ( model, GitHub.getRepositories data.input GetRepositories )

        GetRepositories (Ok repos) ->
            ( { model | repos = repos }
            , [ outputRepos model.cursor repos
              , requestKeyDown ()
              ]
                |> Cmd.batch
            )

        KeyDown "q" ->
            ( model, stdout Cli.clear )

        KeyDown " " ->
            ( model
            , model.repos
                |> List.take (model.cursor + 1)
                |> List.reverse
                |> List.head
                |> Maybe.map .htmlUrl
                |> Maybe.withDefault "Error"
                |> stdout
            )

        KeyDown str ->
            let
                newCursor =
                    model.cursor
                        + moveCursor str
                        |> modBy (List.length model.repos)
            in
            ( { model
                | cursor = newCursor
              }
            , [ outputRepos newCursor model.repos
              , requestKeyDown ()
              ]
                |> Cmd.batch
            )

        _ ->
            ( model, exit 1 )


outputRepos : Int -> List GitHub.Repository -> Cmd msg
outputRepos cursor repos =
    repos
        |> List.indexedMap Tuple.pair
        |> List.map (\( i, x ) -> repoView (i == cursor) (calcPadding repos) x)
        |> String.join "\n"
        |> (++) Cli.clear
        |> stdout


moveCursor : String -> Int
moveCursor str =
    case str of
        "j" ->
            1

        "k" ->
            -1

        _ ->
            0


calcPadding : List GitHub.Repository -> Int
calcPadding repos =
    repos
        |> List.map .name
        |> List.map String.length
        |> List.maximum
        |> Maybe.map ((+) 1)
        |> Maybe.withDefault 1


repoView : Bool -> Int -> GitHub.Repository -> String
repoView isCursor pad repo =
    (String.padRight pad ' ' repo.name
        |> Cli.text
            [ Cli.foreGroundColor Cli.Green
            , if isCursor then
                Cli.backGroundColor Cli.Black

              else
                Cli.backGroundColor Cli.White
            ]
    )
        ++ (repo.description |> Maybe.withDefault "-----")


subscriptions : Model -> Sub Msg
subscriptions _ =
    [ input <|
        (JD.decodeValue (JD.map Input inputDataDecoder)
            >> Result.withDefault NoOp
        )
    , keyDown KeyDown
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


port stdout : String -> Cmd msg


port stderr : String -> Cmd msg


port exit : Int -> Cmd msg


port requestInput : ( String, String ) -> Cmd msg


port requestKeyDown : () -> Cmd msg


port input : (JD.Value -> msg) -> Sub msg


port keyDown : (String -> msg) -> Sub msg
