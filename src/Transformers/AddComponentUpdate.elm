module Transformers.AddComponentUpdate exposing (addImportUpdate, addInitMap, addUpdateMap, transform)

import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.Expression exposing (..)
import Elm.Syntax.File exposing (..)
import Elm.Syntax.Node exposing (..)
import Elm.Syntax.Range exposing (..)
import Transformers.Helpers exposing (..)


transform : String -> String -> Result String String
transform name code =
    case stringToFile code of
        Ok file ->
            file
                |> addImportUpdate name
                |> updateFileDeclarations (addInitMap name)
                |> updateFileDeclarations (addUpdateMap name)
                |> fileToString
                |> Ok

        Err errors ->
            Err ("Error parsing file:\n" ++ errors)


addInitMap : String -> Node Declaration -> Node Declaration
addInitMap name =
    let
        newInitMap =
            ranged <|
                Application
                    [ ranged <| FunctionOrValue [] "andMapCmd"
                    , ranged <| FunctionOrValue [] ("MsgFor" ++ name)
                    , ranged <| FunctionOrValue [ name, "Update" ] "init"
                    ]
    in
    updateFunctionBody "init"
        (addToLastRightPipe newInitMap)


addUpdateMap : String -> Node Declaration -> Node Declaration
addUpdateMap name =
    let
        newUpdateMap =
            ranged <|
                Application
                    [ ranged <| FunctionOrValue [] "andMapCmd"
                    , ranged <| FunctionOrValue [] ("MsgFor" ++ name)
                    , ranged <|
                        ParenthesizedExpression
                            (ranged <|
                                Application
                                    [ ranged <| FunctionOrValue [ name, "Update" ] "update"
                                    , ranged <| FunctionOrValue [] "msg"
                                    , ranged <|
                                        RecordAccess
                                            (ranged <| FunctionOrValue [] "model")
                                            (ranged <| String.toLower name)
                                    ]
                            )
                    ]
    in
    updateFunctionBody "update"
        (addToLastRightPipe newUpdateMap)


addImportUpdate : String -> File -> File
addImportUpdate name =
    addImport
        { moduleName = ranged [ name, "Update" ]
        , moduleAlias = Nothing
        , exposingList = Nothing
        }
