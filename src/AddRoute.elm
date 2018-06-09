module AddRoute exposing (..)

import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.Expression exposing (..)
import Elm.Syntax.Pattern exposing (..)
import Elm.Syntax.Range exposing (..)
import Elm.Syntax.Ranged exposing (..)
import Elm.Syntax.Type exposing (..)
import Helpers exposing (..)


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
addPageType name ( range, declaration ) =
    case declaration of
        TypeDecl type_ ->
            let
                newRoute =
                    [ ValueConstructor (name ++ "Page") [] emptyRange ]
            in
            if type_.name == "Page" then
                ( range, TypeDecl { type_ | constructors = type_.constructors ++ newRoute } )
            else
                ( range, declaration )

        _ ->
            ( range, declaration )


addRouteToPath : String -> Ranged Declaration -> Ranged Declaration
addRouteToPath name ( range, declaration ) =
    case declaration of
        FuncDecl function ->
            let
                body : FunctionDeclaration
                body =
                    function.declaration

                newCase : Case
                newCase =
                    ( ranged <| NamedPattern (QualifiedNameRef [] (name ++ "Page")) []
                    , ranged <| Literal ("/" ++ String.toLower name)
                    )

                newExpression : Ranged Expression
                newExpression =
                    case body.expression of
                        ( range, CaseExpression caseExpression ) ->
                            ( range, CaseExpression { caseExpression | cases = caseExpression.cases ++ [ newCase ] } )

                        _ ->
                            body.expression
            in
            if function.declaration.name.value == "toPath" then
                ( range, FuncDecl { function | declaration = { body | expression = newExpression } } )
            else
                ( range, declaration )

        _ ->
            ( range, declaration )


addRouteParser : String -> Ranged Declaration -> Ranged Declaration
addRouteParser name ( range, declaration ) =
    case declaration of
        FuncDecl function ->
            let
                body : FunctionDeclaration
                body =
                    function.declaration

                newExpression : Ranged Expression
                newExpression =
                    case body.expression of
                        ( range, Application applicationExpressions ) ->
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
                            body.expression
            in
            if function.declaration.name.value == "routes" then
                ( range, FuncDecl { function | declaration = { body | expression = newExpression } } )
            else
                ( range, declaration )

        _ ->
            ( range, declaration )
