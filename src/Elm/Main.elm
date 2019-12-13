port module Main exposing (main)

import Cli
import GitHub
import Http
import Json.Decode as JD


type State
    = InputUser String
    | ShowRepos (List GitHub.Repository) Int String
    | ShowResult String


type alias Model =
    { args : List String
    , state : State
    }


type Msg
    = GetRepositories (Result Http.Error (List GitHub.Repository))
    | KeyDown KeyEvent
    | NoOp


type alias Flag =
    List String


type alias KeyEvent =
    { sequence : String
    , ctrl : Bool
    , meta : Bool
    , shift : Bool
    }


keyEvent : JD.Decoder KeyEvent
keyEvent =
    JD.map4 KeyEvent
        (JD.field "sequence" JD.string)
        (JD.field "ctrl" JD.bool)
        (JD.field "meta" JD.bool)
        (JD.field "shift" JD.bool)


init : Flag -> ( Model, Cmd Msg )
init flags =
    { args = flags
    , state = InputUser ""
    }
        |> wrapper (view >> output)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model.state, msg ) of
        ( InputUser input, KeyDown ev ) ->
            case ev.sequence of
                "\u{000D}" ->
                    ( model
                    , GitHub.getRepositories input GetRepositories
                    )

                "\u{007F}" ->
                    { model | state = InputUser <| String.slice 0 -1 input }
                        |> wrapper (view >> output)

                "\u{001B}" ->
                    ( model, exitWithMsg ( 0, "" ) )

                _ ->
                    { model | state = InputUser <| input ++ ev.sequence }
                        |> wrapper (view >> output)

        ( InputUser _, GetRepositories (Ok repos) ) ->
            { model | state = ShowRepos repos 0 "" }
                |> wrapper (view >> output)

        ( ShowRepos repos cursor input, KeyDown ev ) ->
            case ev.sequence of
                "J" ->
                    { model
                        | state =
                            ShowRepos repos
                                (cursor
                                    + 1
                                    |> modBy (List.length repos)
                                )
                                input
                    }
                        |> wrapper (view >> output)

                "K" ->
                    { model
                        | state =
                            ShowRepos repos
                                (cursor
                                    - 1
                                    |> modBy (List.length repos)
                                )
                                input
                    }
                        |> wrapper (view >> output)

                "\u{000D}" ->
                    { model
                        | state =
                            repos
                                |> List.take (cursor + 1)
                                |> List.reverse
                                |> List.head
                                |> Maybe.map .htmlUrl
                                |> Maybe.withDefault "Error"
                                |> ShowResult
                    }
                        |> wrapper (view >> Tuple.pair 0 >> exitWithMsg)

                "\u{007F}" ->
                    { model
                        | state =
                            ShowRepos repos cursor (String.slice 0 -1 input)
                    }
                        |> wrapper (view >> output)

                "\u{001B}" ->
                    ( model, exitWithMsg ( 0, "" ) )

                str ->
                    { model | state = ShowRepos repos cursor (input ++ str) }
                        |> wrapper (view >> output)

        _ ->
            ( model, exitWithMsg ( 1, "Error\n" ) )


view : Model -> String
view model =
    case model.state of
        InputUser input ->
            Cli.clear ++ "InputUser : " ++ input

        ShowRepos repos cursor input ->
            Cli.clear
                ++ (repos
                        |> List.filter (.name >> String.startsWith input)
                        |> outputRepos cursor
                   )
                ++ "\n"
                ++ ">> "
                ++ input

        ShowResult result ->
            Cli.clear ++ result ++ "\n"


wrapper : (Model -> Cmd msg) -> Model -> ( Model, Cmd msg )
wrapper outputFunc model =
    ( model, outputFunc model )


outputRepos : Int -> List GitHub.Repository -> String
outputRepos cursor repos =
    repos
        |> List.indexedMap Tuple.pair
        |> List.map (\( i, x ) -> repoView (i == cursor) (calcPadding repos) x)
        |> String.join "\n"


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
    [ keyDown <|
        (JD.decodeValue (JD.map KeyDown keyEvent)
            >> Result.withDefault NoOp
        )
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


port output : String -> Cmd msg


port exitWithMsg : ( Int, String ) -> Cmd msg


port keyDown : (JD.Value -> msg) -> Sub msg
