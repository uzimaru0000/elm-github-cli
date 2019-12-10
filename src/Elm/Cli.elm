module Cli exposing
    ( Color(..)
    , backGroundColor
    , clear
    , foreGroundColor
    , text
    )


type Color
    = Black
    | Red
    | Green
    | Yellow
    | Blue
    | Magenta
    | Cyan
    | White


type Ground
    = Fore
    | Back


type Style
    = Style
        { color : Color
        , ground : Ground
        }


foreGroundColor : Color -> Style
foreGroundColor color =
    Style
        { color = color
        , ground = Fore
        }


backGroundColor : Color -> Style
backGroundColor color =
    Style
        { color = color
        , ground = Back
        }


text : List Style -> String -> String
text style str =
    styleString style ++ str ++ "\u{001B}[m"


clear : String
clear =
    "\u{001B}[2J\u{001B}[H"


styleString : List Style -> String
styleString style =
    "\u{001B}["
        ++ (style
                |> List.map (\(Style x) -> colorToCode x.ground x.color)
                |> String.join ";"
           )
        ++ "m"


colorToCode : Ground -> Color -> String
colorToCode ground color =
    case ground of
        Fore ->
            colorToForeGround color

        Back ->
            colorToBackGround color


colorToForeGround : Color -> String
colorToForeGround color =
    case color of
        Black ->
            "30"

        Red ->
            "31"

        Green ->
            "32"

        Yellow ->
            "33"

        Blue ->
            "34"

        Magenta ->
            "35"

        Cyan ->
            "36"

        White ->
            "37"


colorToBackGround : Color -> String
colorToBackGround color =
    case color of
        Black ->
            "40"

        Red ->
            "41"

        Green ->
            "42"

        Yellow ->
            "43"

        Blue ->
            "45"

        Magenta ->
            "46"

        Cyan ->
            "47"

        White ->
            "48"
