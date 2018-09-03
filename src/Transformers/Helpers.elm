module Transformers.Helpers exposing (addCaseBranch, addFieldToRecordDefinition, addImport, addNewUnionType, addToLastRightPipe, fileToString, namespaced, ranged, stringToFile, unranged, updateFileDeclarations, updateFunctionBody, updateTypeAliasDefinition)

import Elm.Parser as Parser
import Elm.Processing as Processing
import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.Expression exposing (..)
import Elm.Syntax.File exposing (..)
import Elm.Syntax.Import exposing (..)
import Elm.Syntax.Infix exposing (..)
import Elm.Syntax.Module exposing (..)
import Elm.Syntax.Node exposing (..)
import Elm.Syntax.Range exposing (..)
import Elm.Syntax.Type exposing (..)
import Elm.Syntax.TypeAnnotation exposing (..)
import Elm.Writer as Writer
import Parser exposing (deadEndsToString)


stringToFile : String -> Result String File
stringToFile string =
    Parser.parse string
        |> Result.map (Processing.process Processing.init)
        |> Result.mapError deadEndsToString


fileToString : File -> String
fileToString file =
    Writer.writeFile file
        |> Writer.write


updateFileDeclarations : (Node Declaration -> Node Declaration) -> File -> File
updateFileDeclarations fn file =
    { file | declarations = List.map fn file.declarations }


ranged : a -> Node a
ranged thing =
    Node emptyRange thing


unranged : Node a -> a
unranged node =
    case node of
        Node _ thing ->
            thing


namespaced path fnName args =
    ranged <| Typed (ranged ( path, fnName )) args


addNewUnionType : String -> ValueConstructor -> Node Declaration -> Node Declaration
addNewUnionType typeName newType (Node range declaration) =
    case declaration of
        CustomTypeDeclaration type_ ->
            if unranged type_.name == typeName then
                Node range (CustomTypeDeclaration { type_ | constructors = type_.constructors ++ [ ranged newType ] })

            else
                Node range declaration

        _ ->
            Node range declaration


addCaseBranch : Case -> Node Expression -> Node Expression
addCaseBranch newCase expression =
    case expression of
        Node range (CaseExpression caseExpression) ->
            Node range (CaseExpression { caseExpression | cases = caseExpression.cases ++ [ newCase ] })

        _ ->
            expression


addFieldToRecordDefinition : RecordField -> Node TypeAnnotation -> Node TypeAnnotation
addFieldToRecordDefinition newField typeAnnotation =
    case typeAnnotation of
        Node range (Record recordFields) ->
            Node range (Record (recordFields ++ [ ranged newField ]))

        _ ->
            typeAnnotation


updateFunctionBody : String -> (Node Expression -> Node Expression) -> Node Declaration -> Node Declaration
updateFunctionBody expectedName fn (Node range declaration) =
    case declaration of
        FunctionDeclaration function ->
            let
                body : FunctionImplementation
                body =
                    unranged function.declaration

                updateDeclaration : Node FunctionImplementation
                updateDeclaration =
                    case function.declaration of
                        Node range_ _ ->
                            Node range_ { body | expression = fn body.expression }

                functionName : String
                functionName =
                    function.declaration
                        |> unranged
                        |> .name
                        |> unranged
            in
            if functionName == expectedName then
                Node range (FunctionDeclaration { function | declaration = updateDeclaration })

            else
                Node range declaration

        _ ->
            Node range declaration


updateTypeAliasDefinition : String -> (Node TypeAnnotation -> Node TypeAnnotation) -> Node Declaration -> Node Declaration
updateTypeAliasDefinition typeAliasName fn (Node range declaration) =
    case declaration of
        AliasDeclaration typeAlias ->
            let
                newTypeAnnotation : Node TypeAnnotation
                newTypeAnnotation =
                    fn typeAlias.typeAnnotation
            in
            if unranged typeAlias.name == typeAliasName then
                Node range (AliasDeclaration { typeAlias | typeAnnotation = newTypeAnnotation })

            else
                Node range declaration

        _ ->
            Node range declaration


addImport : Import -> File -> File
addImport newImport file =
    { file | imports = file.imports ++ [ ranged newImport ] }


addToLastRightPipe : Node Expression -> Node Expression -> Node Expression
addToLastRightPipe extraExpr expr =
    case expr of
        Node range (OperatorApplication "|>" Left rightExpr leftExpr) ->
            Node range
                (OperatorApplication "|>"
                    Left
                    rightExpr
                    (addToLastRightPipe extraExpr leftExpr)
                )

        Node range _ ->
            Node range (OperatorApplication "|>" Left expr extraExpr)
