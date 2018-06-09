module Transformers.AddView exposing (..)

import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.Expression exposing (..)
import Elm.Syntax.Pattern exposing (..)
import Elm.Syntax.Ranged exposing (..)
import Transformers.Helpers exposing (..)


transform : String -> String -> Result String String
transform name code =
    case stringToFile code of
        Ok file ->
            file
                |> updateFileDeclarations (addRenderRoute name)
                |> fileToString
                |> Ok

        Err errors ->
            Err
                ("Error parsing file:\n"
                    ++ String.join "\n" errors
                )


addRenderRoute : String -> Ranged Declaration -> Ranged Declaration
addRenderRoute name ( range, declaration ) =
    case declaration of
        FuncDecl function ->
            let
                body : FunctionDeclaration
                body =
                    function.declaration

                newCase : Case
                newCase =
                    ( ranged <| NamedPattern (QualifiedNameRef [] (name ++ "Page")) []
                    , ranged <|
                        Application
                            [ ranged <| QualifiedExpr [ "Element" ] "map"
                            , ranged <| FunctionOrValue ("MsgFor" ++ name)
                            , ranged <|
                                ParenthesizedExpression
                                    (ranged <|
                                        Application
                                            [ ranged <| QualifiedExpr [ name, "View" ] "view"
                                            , ranged <| RecordAccess (ranged <| FunctionOrValue "model") (String.toLower name)
                                            ]
                                    )
                            ]
                    )

                newExpression : Ranged Expression
                newExpression =
                    case body.expression of
                        ( range, CaseExpression caseExpression ) ->
                            ( range, CaseExpression { caseExpression | cases = caseExpression.cases ++ [ newCase ] } )

                        _ ->
                            body.expression
            in
            if function.declaration.name.value == "renderRoute" then
                ( range, FuncDecl { function | declaration = { body | expression = newExpression } } )
            else
                ( range, declaration )

        _ ->
            ( range, declaration )
