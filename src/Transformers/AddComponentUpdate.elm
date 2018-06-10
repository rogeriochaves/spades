module Transformers.AddComponentUpdate exposing (..)

import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.Expression exposing (..)
import Elm.Syntax.File exposing (..)
import Elm.Syntax.Infix exposing (..)
import Elm.Syntax.Pattern exposing (..)
import Elm.Syntax.Range exposing (..)
import Elm.Syntax.Ranged exposing (..)
import Transformers.Helpers exposing (..)


transform : String -> String -> Result String String
transform name code =
    case stringToFile code of
        Ok file ->
            file
                |> fileToString
                |> Ok

        Err errors ->
            Err
                ("Error parsing file:\n"
                    ++ String.join "\n" errors
                )


addInitMap : String -> Ranged Declaration -> Ranged Declaration
addInitMap name =
    let
        newInitMap =
            ranged <|
                Application
                    [ ranged <| FunctionOrValue "andMapCmd"
                    , ranged <| FunctionOrValue ("MsgFor" ++ name)
                    , ranged <| QualifiedExpr [ name, "Update" ] "init"
                    ]
    in
    updateFunctionBody "init"
        (addToLastRightPipe newInitMap)


addUpdateMap : String -> Ranged Declaration -> Ranged Declaration
addUpdateMap name =
    let
        newUpdateMap =
            ranged <|
                Application
                    [ ranged <| FunctionOrValue "andMapCmd"
                    , ranged <| FunctionOrValue ("MsgFor" ++ name)
                    , ranged <|
                        ParenthesizedExpression
                            (ranged <|
                                Application
                                    [ ranged <| QualifiedExpr [ name, "Update" ] "update"
                                    , ranged <| FunctionOrValue "msg"
                                    , ranged <|
                                        RecordAccess
                                            (ranged <| FunctionOrValue "model")
                                            (String.toLower name)
                                    ]
                            )
                    ]
    in
    updateFunctionBody "update"
        (addToLastRightPipe newUpdateMap)
