module Transformers.AddRoute exposing (addPageType, addRouteParser, addRouteToPath, transform)

import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.Expression exposing (..)
import Elm.Syntax.Node exposing (..)
import Elm.Syntax.Pattern exposing (..)
import Elm.Syntax.Range exposing (..)
import Elm.Syntax.Type exposing (..)
import Transformers.Helpers exposing (..)


transform : String -> String -> Result String String
transform name code =
    case stringToFile code of
        Ok file ->
            file
                |> updateFileDeclarations (addPageType name)
                |> updateFileDeclarations (addRouteToPath name)
                |> updateFileDeclarations (addRouteParser name)
                |> fileToString
                |> Ok

        Err errors ->
            Err ("Error parsing file:\n" ++ errors)


addPageType : String -> Node Declaration -> Node Declaration
addPageType name =
    addNewUnionType "Page"
        (ValueConstructor (ranged <| name ++ "Page") [])


addRouteToPath : String -> Node Declaration -> Node Declaration
addRouteToPath name =
    let
        newCase : Case
        newCase =
            ( ranged <| NamedPattern (QualifiedNameRef [] (name ++ "Page")) []
            , ranged <| Literal ("/" ++ String.toLower name)
            )
    in
    updateFunctionBody "toPath"
        (addCaseBranch newCase)


addRouteParser : String -> Node Declaration -> Node Declaration
addRouteParser name =
    let
        newRoute : Node Expression
        newRoute =
            ranged <|
                Application
                    [ ranged <| FunctionOrValue [] "map"
                    , ranged <| FunctionOrValue [] (name ++ "Page")
                    , ranged <|
                        ParenthesizedExpression
                            (ranged <|
                                Application
                                    [ ranged <| FunctionOrValue [] "s"
                                    , ranged <| Literal (String.toLower name)
                                    ]
                            )
                    ]
    in
    updateFunctionBody "routes"
        (\expression ->
            case expression of
                Node range (Application applicationExpressions) ->
                    let
                        routesList : Node Expression
                        routesList =
                            List.tail applicationExpressions
                                |> Maybe.andThen List.head
                                |> Maybe.withDefault ( ranged <| ListExpr [] )

                        newRoutesList : Node Expression
                        newRoutesList =
                            case routesList of
                                Node range_ (ListExpr list) ->
                                    Node range_ (ListExpr (list ++ [ newRoute ]))

                                _ ->
                                    routesList
                    in
                    Node range
                        (Application
                            [ ranged <| FunctionOrValue [] "oneOf"
                            , newRoutesList
                            ]
                        )

                _ ->
                    expression
        )
