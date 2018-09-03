module Transformers.AddComponentView exposing (addImportView, addRenderRoute, transform)

import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.Expression exposing (..)
import Elm.Syntax.File exposing (..)
import Elm.Syntax.Node exposing (..)
import Elm.Syntax.Pattern exposing (..)
import Elm.Syntax.Range exposing (..)
import Transformers.Helpers exposing (..)


transform : String -> String -> Result String String
transform name code =
    case stringToFile code of
        Ok file ->
            file
                |> updateFileDeclarations (addRenderRoute name)
                |> addImportView name
                |> fileToString
                |> Ok

        Err errors ->
            Err ("Error parsing file:\n" ++ errors)


addRenderRoute : String -> Node Declaration -> Node Declaration
addRenderRoute name =
    let
        newCase : Case
        newCase =
            ( ranged <| NamedPattern (QualifiedNameRef [] (name ++ "Page")) []
            , ranged <|
                Application
                    [ ranged <| FunctionOrValue [ "Element" ] "map"
                    , ranged <| FunctionOrValue [] ("MsgFor" ++ name)
                    , ranged <|
                        ParenthesizedExpression
                            (ranged <|
                                Application
                                    [ ranged <| FunctionOrValue [ name, "View" ] "view"
                                    , ranged <|
                                        RecordAccess
                                            (ranged <| FunctionOrValue [] "model")
                                            (ranged <| String.toLower name)
                                    ]
                            )
                    ]
            )
    in
    updateFunctionBody "renderRoute"
        (addCaseBranch newCase)


addImportView : String -> File -> File
addImportView name =
    addImport
        { moduleName = ranged [ name, "View" ]
        , moduleAlias = Nothing
        , exposingList = Nothing
        }
