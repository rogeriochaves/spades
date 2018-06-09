module AddRoute exposing (..)

import Elm.Parser as Parser
import Elm.Processing as Processing
import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.Expression exposing (..)
import Elm.Syntax.File exposing (..)
import Elm.Syntax.Pattern exposing (..)
import Elm.Syntax.Range exposing (..)
import Elm.Syntax.Ranged exposing (..)
import Elm.Syntax.Type exposing (..)
import Elm.Writer as Writer


transform : String -> Result String String
transform code =
    case Parser.parse code of
        Ok rawFile ->
            Processing.process Processing.init rawFile
                |> addPageType
                |> addRouteToPath
                |> Writer.writeFile
                |> Writer.write
                |> Ok

        Err errors ->
            Err
                ("Error parsing file:\n"
                    ++ String.join "\n" errors
                )


addPageType : File -> File
addPageType file =
    let
        updateDeclarations ( range, declaration ) =
            case declaration of
                TypeDecl type_ ->
                    let
                        newRoute =
                            [ ValueConstructor "NewRoute" [] emptyRange ]
                    in
                    if type_.name == "Page" then
                        ( range, TypeDecl { type_ | constructors = type_.constructors ++ newRoute } )
                    else
                        ( range, declaration )

                _ ->
                    ( range, declaration )
    in
    { file | declarations = List.map updateDeclarations file.declarations }


addRouteToPath : File -> File
addRouteToPath file =
    let
        updateDeclarations ( range, declaration ) =
            case declaration of
                FuncDecl function ->
                    let
                        body : FunctionDeclaration
                        body =
                            function.declaration

                        newCase : Case
                        newCase =
                            ( ( emptyRange, NamedPattern (QualifiedNameRef [] "NewRoute") [] )
                            , ( emptyRange, Literal "/new-route" )
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
    in
    { file | declarations = List.map updateDeclarations file.declarations }
