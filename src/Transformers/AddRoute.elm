module Transformers.AddRoute exposing (..)

import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.Expression exposing (..)
import Elm.Syntax.Pattern exposing (..)
import Elm.Syntax.Range exposing (..)
import Elm.Syntax.Ranged exposing (..)
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
            Err
                ("Error parsing file:\n"
                    ++ String.join "\n" errors
                )


addPageType : String -> Ranged Declaration -> Ranged Declaration
addPageType name =
    addNewUnionType "Page"
        (ValueConstructor (name ++ "Page") [] emptyRange)


addRouteToPath : String -> Ranged Declaration -> Ranged Declaration
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


addRouteParser : String -> Ranged Declaration -> Ranged Declaration
addRouteParser name =
    let
        newRoute : Ranged Expression
        newRoute =
            ranged <|
                Application
                    [ ranged <| FunctionOrValue "map"
                    , ranged <| FunctionOrValue (name ++ "Page")
                    , ranged <|
                        ParenthesizedExpression
                            (ranged <|
                                Application
                                    [ ranged <| FunctionOrValue "s"
                                    , ranged <| Literal (String.toLower name)
                                    ]
                            )
                    ]
    in
    updateFunctionBody "routes"
        (\expression ->
            case expression of
                ( range, Application applicationExpressions ) ->
                    let
                        routesList : Ranged Expression
                        routesList =
                            List.tail applicationExpressions
                                |> Maybe.andThen List.head
                                |> Maybe.withDefault ( emptyRange, ListExpr [] )

                        newRoutesList : Ranged Expression
                        newRoutesList =
                            case routesList of
                                ( range, ListExpr list ) ->
                                    ( range, ListExpr (list ++ [ newRoute ]) )

                                _ ->
                                    routesList
                    in
                    ( range
                    , Application
                        [ ranged <| FunctionOrValue "oneOf"
                        , newRoutesList
                        ]
                    )

                _ ->
                    expression
        )
