module Elm.Writer exposing (write, writeDeclaration, writeExpression, writeFile, writePattern, writeTypeAnnotation)

{-|


# Elm.Writer

Write a file to a string.

@docs write, writeFile, writePattern, writeExpression, writeTypeAnnotation, writeDeclaration

-}

import Elm.Syntax.Base exposing (..)
import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.Documentation exposing (..)
import Elm.Syntax.Exposing as Exposing exposing (..)
import Elm.Syntax.Expression exposing (..)
import Elm.Syntax.File exposing (..)
import Elm.Syntax.Infix exposing (..)
import Elm.Syntax.Module exposing (..)
import Elm.Syntax.Pattern exposing (..)
import Elm.Syntax.Range exposing (Range)
import Elm.Syntax.Ranged exposing (Ranged)
import Elm.Syntax.Type exposing (..)
import Elm.Syntax.TypeAlias exposing (..)
import Elm.Syntax.TypeAnnotation exposing (..)
import List.Extra as List
import StructuredWriter as Writer exposing (..)


{-| Transform a writer to a string
-}
write : Writer -> String
write =
    Writer.write


{-| Write a file
-}
writeFile : File -> Writer
writeFile file =
    breaked
        [ writeModule file.moduleDefinition
        , breaked (List.map writeImport file.imports)
        , breaked (List.map writeDeclaration file.declarations)
        ]


writeModule : Module -> Writer
writeModule m =
    case m of
        NormalModule defaultModuleData ->
            writeDefaultModuleData defaultModuleData

        PortModule defaultModuleData ->
            spaced
                [ string "port"
                , writeDefaultModuleData defaultModuleData
                ]

        EffectModule effectModuleData ->
            writeEffectModuleData effectModuleData


writeDefaultModuleData : DefaultModuleData -> Writer
writeDefaultModuleData { moduleName, exposingList } =
    spaced
        [ string "module"
        , writeModuleName moduleName
        , writeExposureExpose exposingList
        ]


writeEffectModuleData : EffectModuleData -> Writer
writeEffectModuleData { moduleName, exposingList, command, subscription } =
    spaced
        [ string "effect"
        , string "module"
        , writeModuleName moduleName
        , writeWhere ( command, subscription )
        , writeExposureExpose exposingList
        ]


writeWhere : ( Maybe String, Maybe String ) -> Writer
writeWhere input =
    case input of
        ( Nothing, Nothing ) ->
            epsilon

        ( Just x, Nothing ) ->
            spaced
                [ string "where { command ="
                , string x
                , string "}"
                ]

        ( Nothing, Just x ) ->
            spaced
                [ string "where { subscription ="
                , string x
                , string "}"
                ]

        ( Just x, Just y ) ->
            spaced
                [ string "where { command ="
                , string x
                , string ", subscription ="
                , string y
                , string "}"
                ]


writeModuleName : ModuleName -> Writer
writeModuleName moduleName =
    string (String.join "." moduleName)


writeExposureExpose : Exposing (Ranged TopLevelExpose) -> Writer
writeExposureExpose x =
    case x of
        All _ ->
            string "exposing (..)"

        Explicit exposeList ->
            let
                diffLines =
                    List.map Exposing.topLevelExposeRange exposeList
                        |> startOnDifferentLines
            in
            spaced
                [ string "exposing"
                , parensComma diffLines (List.map writeExpose exposeList)
                ]


writeExpose : Ranged TopLevelExpose -> Writer
writeExpose ( _, exp ) =
    case exp of
        InfixExpose x ->
            string ("(" ++ x ++ ")")

        FunctionExpose f ->
            string f

        TypeOrAliasExpose t ->
            string t

        TypeExpose { name, constructors } ->
            case constructors of
                Just c ->
                    spaced
                        [ string name
                        , writeExposureValueConstructor c
                        ]

                Nothing ->
                    string name


writeExposureValueConstructor : Exposing ValueConstructorExpose -> Writer
writeExposureValueConstructor x =
    case x of
        All _ ->
            string "(..)"

        Explicit exposeList ->
            let
                diffLines =
                    List.map Tuple.first exposeList
                        |> startOnDifferentLines
            in
            parensComma diffLines (List.map (Tuple.second >> string) exposeList)


startOnDifferentLines : List Range -> Bool
startOnDifferentLines xs =
    List.length (List.unique (List.map (.start >> .row) xs)) > 1


writeImport : Import -> Writer
writeImport { moduleName, moduleAlias, exposingList } =
    spaced
        [ string "import"
        , writeModuleName moduleName
        , maybe (Maybe.map (writeModuleName >> (\x -> spaced [ string "as", x ])) moduleAlias)
        , maybe (Maybe.map writeExposureExpose exposingList)
        ]


writeLetDeclaration : Ranged LetDeclaration -> Writer
writeLetDeclaration ( _, letDeclaration ) =
    case letDeclaration of
        LetFunction function ->
            writeFunction function

        LetDestructuring pattern expression ->
            writeDestructuring pattern expression


{-| Write a declaration
-}
writeDeclaration : Ranged Declaration -> Writer
writeDeclaration ( _, decl ) =
    case decl of
        FuncDecl function ->
            writeFunction function

        AliasDecl typeAlias ->
            writeTypeAlias typeAlias

        TypeDecl type_ ->
            writeType type_

        PortDeclaration p ->
            writePortDeclaration p

        InfixDeclaration i ->
            writeInfix i

        Destructuring pattern expression ->
            writeDestructuring pattern expression


writeFunction : Function -> Writer
writeFunction { documentation, signature, declaration } =
    breaked
        [ maybe (Maybe.map writeDocumentation documentation)
        , maybe (Maybe.map (Tuple.second >> writeSignature) signature)
        , writeFunctionDeclaration declaration
        ]


writeFunctionDeclaration : FunctionDeclaration -> Writer
writeFunctionDeclaration declaration =
    breaked
        [ spaced
            [ if declaration.operatorDefinition then
                string ("(" ++ declaration.name.value ++ ")")
              else
                string declaration.name.value
            , spaced (List.map writePattern declaration.arguments)
            , string "="
            ]
        , indent 4 (writeExpression declaration.expression)
        ]


writeSignature : FunctionSignature -> Writer
writeSignature signature =
    spaced
        [ if signature.operatorDefinition then
            string ("(" ++ signature.name ++ ")")
          else
            string signature.name
        , string ":"
        , writeTypeAnnotation signature.typeAnnotation
        ]


writeDocumentation : Documentation -> Writer
writeDocumentation =
    .text >> string


writeTypeAlias : TypeAlias -> Writer
writeTypeAlias typeAlias =
    breaked
        [ spaced
            [ string "type alias"
            , string typeAlias.name
            , spaced (List.map string typeAlias.generics)
            , string "="
            ]
        , indent 4 (writeTypeAnnotation typeAlias.typeAnnotation)
        ]


writeType : Type -> Writer
writeType type_ =
    breaked
        [ spaced
            [ string "type"
            , string type_.name
            , spaced (List.map string type_.generics)
            ]
        , let
            diffLines =
                List.map .range type_.constructors
                    |> startOnDifferentLines
          in
          sepBy ( "=", "|", "" )
            diffLines
            (List.map writeValueConstructor type_.constructors)
        ]


writeValueConstructor : ValueConstructor -> Writer
writeValueConstructor { name, arguments } =
    spaced
        [ string name
        , spaced (List.map writeTypeAnnotation arguments)
        ]


writePortDeclaration : FunctionSignature -> Writer
writePortDeclaration signature =
    spaced [ string "port", writeSignature signature ]


writeInfix : Infix -> Writer
writeInfix { direction, precedence, operator } =
    spaced
        [ case direction of
            Left ->
                string "infixl"

            Right ->
                string "infixr"
        , string (toString precedence)
        , string operator
        ]


writeDestructuring : Ranged Pattern -> Ranged Expression -> Writer
writeDestructuring pattern expression =
    breaked
        [ spaced [ writePattern pattern, string "=" ]
        , indent 4 (writeExpression expression)
        ]


{-| Write a type annotation
-}
writeTypeAnnotation : Ranged TypeAnnotation -> Writer
writeTypeAnnotation ( _, typeAnnotation ) =
    case typeAnnotation of
        GenericType s ->
            string s

        Typed moduleName k args ->
            spaced
                ((string <| String.join "." (moduleName ++ [ k ]))
                    :: List.map (writeTypeAnnotation >> parensIfContainsSpaces) args
                )

        Unit ->
            string "()"

        Tupled xs ->
            parensComma False (List.map writeTypeAnnotation xs)

        Record xs ->
            bracesComma False (List.map writeRecordField xs)

        GenericRecord name fields ->
            spaced
                [ string "{"
                , string name
                , string "|"
                , sepByComma False (List.map writeRecordField fields)
                , string "}"
                ]

        FunctionTypeAnnotation left right ->
            let
                addParensForSubTypeAnnotation type_ =
                    case type_ of
                        ( _, FunctionTypeAnnotation _ _ ) ->
                            join [ string "(", writeTypeAnnotation type_, string ")" ]

                        _ ->
                            writeTypeAnnotation type_
            in
            spaced
                [ addParensForSubTypeAnnotation left
                , string "->"
                , addParensForSubTypeAnnotation right
                ]


writeRecordField : RecordField -> Writer
writeRecordField ( name, ref ) =
    spaced
        [ string name
        , string ":"
        , writeTypeAnnotation ref
        ]


{-| Writer an expression
-}
writeExpression : Ranged Expression -> Writer
writeExpression ( range, inner ) =
    let
        recurRangeHelper =
            \( x, y ) -> ( x, writeExpression ( x, y ) )

        writeRecordSetter ( name, expr ) =
            ( Tuple.first expr
            , spaced [ string name, string "=", writeExpression expr ]
            )

        sepHelper : (Bool -> List Writer -> Writer) -> List ( Range, Writer ) -> Writer
        sepHelper f l =
            let
                diffLines =
                    List.map Tuple.first l
                        |> startOnDifferentLines
            in
            f diffLines (List.map Tuple.second l)
    in
    case inner of
        UnitExpr ->
            string "()"

        Application xs ->
            case xs of
                [] ->
                    epsilon

                [ x ] ->
                    writeExpression x

                x :: rest ->
                    spaced
                        [ writeExpression x
                        , sepHelper sepBySpace (List.map recurRangeHelper rest)
                        ]

        OperatorApplication x dir left right ->
            case dir of
                Left ->
                    sepHelper sepBySpace
                        [ ( Tuple.first left, writeExpression left )
                        , ( range, spaced [ string x, writeExpression right ] )
                        ]

                Right ->
                    sepHelper sepBySpace
                        [ ( Tuple.first left, spaced [ writeExpression left, string x ] )
                        , ( Tuple.first right, writeExpression right )
                        ]

        FunctionOrValue x ->
            string x

        IfBlock condition thenCase elseCase ->
            breaked
                [ spaced [ string "if", writeExpression condition, string "then" ]
                , indent 2 (writeExpression thenCase)
                , string "else"
                , indent 2 (writeExpression elseCase)
                ]

        PrefixOperator x ->
            string ("(" ++ x ++ ")")

        Operator x ->
            string x

        Integer i ->
            string (toString i)

        Floatable f ->
            string (toString f)

        Negation x ->
            append (string "-") (writeExpression x)

        Literal s ->
            string (toString s)

        CharLiteral c ->
            string (toString c)

        TupledExpression t ->
            sepHelper sepByComma (List.map recurRangeHelper t)

        ParenthesizedExpression x ->
            join [ string "(", writeExpression x, string ")" ]

        LetExpression letBlock ->
            breaked
                [ string "let"
                , indent 2 (breaked (List.map writeLetDeclaration letBlock.declarations))
                , string "in"
                , indent 2 (writeExpression letBlock.expression)
                ]

        CaseExpression caseBlock ->
            let
                writeCaseBranch ( pattern, expression ) =
                    indent 2 <|
                        breaked
                            [ spaced [ writePattern pattern, string "->" ]
                            , indent 2 (writeExpression expression)
                            ]
            in
            breaked
                [ spaced [ string "case", writeExpression caseBlock.expression, string "of" ]
                , breaked (List.map writeCaseBranch caseBlock.cases)
                ]

        LambdaExpression lambda ->
            spaced
                [ join
                    [ string "\\"
                    , spaced (List.map writePattern lambda.args)
                    ]
                , string "->"
                , writeExpression lambda.expression
                ]

        RecordExpr setters ->
            sepHelper bracesComma (List.map writeRecordSetter setters)

        ListExpr xs ->
            sepHelper bracketsComma (List.map recurRangeHelper xs)

        QualifiedExpr moduleName name ->
            join [ writeModuleName moduleName, string ".", string name ]

        RecordAccess expression accessor ->
            join [ writeExpression expression, string ".", string accessor ]

        RecordAccessFunction s ->
            join [ string ".", string s ]

        RecordUpdateExpression { name, updates } ->
            spaced
                [ string "{"
                , string name
                , string "|"
                , sepHelper sepByComma (List.map writeRecordSetter updates)
                , string "}"
                ]

        GLSLExpression s ->
            join
                [ string "[glsl|"
                , string s
                , string "|]"
                ]


{-| Write a pattern
-}
writePattern : Ranged Pattern -> Writer
writePattern ( _, p ) =
    case p of
        AllPattern ->
            string "_"

        UnitPattern ->
            string "()"

        CharPattern c ->
            string (toString c)

        StringPattern s ->
            string s

        IntPattern i ->
            string (toString i)

        FloatPattern f ->
            string (toString f)

        TuplePattern inner ->
            parensComma False (List.map writePattern inner)

        RecordPattern inner ->
            bracesComma False (List.map (.value >> string) inner)

        UnConsPattern left right ->
            spaced [ writePattern left, string "::", writePattern right ]

        ListPattern inner ->
            bracketsComma False (List.map writePattern inner)

        VarPattern var ->
            string var

        NamedPattern qnr others ->
            spaced
                [ writeQualifiedNameRef qnr
                , spaced (List.map writePattern others)
                ]

        QualifiedNamePattern qnr ->
            writeQualifiedNameRef qnr

        AsPattern innerPattern asName ->
            spaced [ writePattern innerPattern, string "as", string asName.value ]

        ParenthesizedPattern innerPattern ->
            spaced [ string "(", writePattern innerPattern, string ")" ]


writeQualifiedNameRef : QualifiedNameRef -> Writer
writeQualifiedNameRef { moduleName, name } =
    case moduleName of
        [] ->
            string name

        _ ->
            join
                [ writeModuleName moduleName
                , string "."
                , string name
                ]



-- Helpers


parensIfContainsSpaces : Writer -> Writer
parensIfContainsSpaces w =
    if Writer.write w |> String.contains " " then
        join [ string "(", w, string ")" ]
    else
        w
