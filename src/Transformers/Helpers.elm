module Transformers.Helpers exposing (..)

import Elm.Parser as Parser
import Elm.Processing as Processing
import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.Expression exposing (..)
import Elm.Syntax.File exposing (..)
import Elm.Syntax.Module exposing (..)
import Elm.Syntax.Range exposing (..)
import Elm.Syntax.Ranged exposing (..)
import Elm.Syntax.Type exposing (..)
import Elm.Writer as Writer


stringToFile : String -> Result (List String) File
stringToFile string =
    Parser.parse string
        |> Result.map (Processing.process Processing.init)


fileToString : File -> String
fileToString file =
    Writer.writeFile file
        |> Writer.write


updateFileDeclarations : (Ranged Declaration -> Ranged Declaration) -> File -> File
updateFileDeclarations fn file =
    { file | declarations = List.map fn file.declarations }


ranged : a -> Ranged a
ranged thing =
    ( emptyRange, thing )


addNewUnionType : String -> ValueConstructor -> Ranged Declaration -> Ranged Declaration
addNewUnionType typeName newType ( range, declaration ) =
    case declaration of
        TypeDecl type_ ->
            if type_.name == typeName then
                ( range, TypeDecl { type_ | constructors = type_.constructors ++ [ newType ] } )
            else
                ( range, declaration )

        _ ->
            ( range, declaration )


addCaseBranch : Case -> Ranged Expression -> Ranged Expression
addCaseBranch newCase expression =
    case expression of
        ( range, CaseExpression caseExpression ) ->
            ( range, CaseExpression { caseExpression | cases = caseExpression.cases ++ [ newCase ] } )

        _ ->
            expression


updateFunctionBody : String -> (Ranged Expression -> Ranged Expression) -> Ranged Declaration -> Ranged Declaration
updateFunctionBody functionName fn ( range, declaration ) =
    case declaration of
        FuncDecl function ->
            let
                body : FunctionDeclaration
                body =
                    function.declaration

                newExpression : Ranged Expression
                newExpression =
                    fn body.expression
            in
            if function.declaration.name.value == functionName then
                ( range, FuncDecl { function | declaration = { body | expression = newExpression } } )
            else
                ( range, declaration )

        _ ->
            ( range, declaration )


addImport : Import -> File -> File
addImport newImport file =
    { file | imports = file.imports ++ [ newImport ] }
