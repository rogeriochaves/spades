module Elm.Parser.TypeAnnotation exposing (typeAnnotation)

import Combine exposing (..)
import Elm.Parser.Layout as Layout
import Elm.Parser.Ranges exposing (ranged)
import Elm.Parser.State exposing (State)
import Elm.Parser.Tokens exposing (functionName, typeName)
import Elm.Parser.Whitespace exposing (realNewLine)
import Elm.Syntax.Ranged exposing (Ranged)
import Elm.Syntax.TypeAnnotation exposing (..)


typeAnnotationNoFn : Parser State (Ranged TypeAnnotation)
typeAnnotationNoFn =
    lazy
        (\() ->
            ranged <|
                choice
                    [ parensTypeAnnotation
                    , typedTypeAnnotation
                    , recordTypeAnnotation
                    , genericRecordTypeAnnotation
                    , genericTypeAnnotation
                    ]
        )


typeAnnotation : Parser State (Ranged TypeAnnotation)
typeAnnotation =
    lazy
        (\() ->
            ranged <|
                typeAnnotationNoFn
                    >>= (\typeRef ->
                            or (FunctionTypeAnnotation typeRef <$> (Layout.maybeAroundBothSides (string "->") *> typeAnnotation))
                                (succeed (Tuple.second typeRef))
                        )
        )


parensTypeAnnotation : Parser State TypeAnnotation
parensTypeAnnotation =
    lazy
        (\() ->
            parens (maybe Layout.layout *> sepBy (string ",") (Layout.maybeAroundBothSides typeAnnotation))
                |> map asTypeAnnotation
        )


asTypeAnnotation : List (Ranged TypeAnnotation) -> TypeAnnotation
asTypeAnnotation x =
    case x of
        [] ->
            Unit

        [ ( _, item ) ] ->
            item

        xs ->
            Tupled xs


genericTypeAnnotation : Parser State TypeAnnotation
genericTypeAnnotation =
    lazy (\() -> GenericType <$> functionName)


recordFieldsTypeAnnotation : Parser State RecordDefinition
recordFieldsTypeAnnotation =
    lazy (\() -> sepBy (string ",") (Layout.maybeAroundBothSides recordFieldDefinition))


genericRecordTypeAnnotation : Parser State TypeAnnotation
genericRecordTypeAnnotation =
    lazy
        (\() ->
            between
                (string "{")
                (maybe realNewLine *> string "}")
                (succeed GenericRecord
                    <*> (maybe whitespace *> functionName)
                    <*> (maybe whitespace *> string "|" *> maybe whitespace *> recordFieldsTypeAnnotation)
                )
        )


recordTypeAnnotation : Parser State TypeAnnotation
recordTypeAnnotation =
    lazy
        (\() ->
            between
                (string "{")
                (maybe realNewLine *> string "}")
                (Record <$> recordFieldsTypeAnnotation)
        )


recordFieldDefinition : Parser State RecordField
recordFieldDefinition =
    lazy
        (\() ->
            succeed (,)
                <*> (maybe Layout.layout *> functionName)
                <*> (maybe Layout.layout *> string ":" *> maybe Layout.layout *> typeAnnotation)
        )


typedTypeAnnotation : Parser State TypeAnnotation
typedTypeAnnotation =
    lazy
        (\() ->
            succeed Typed
                <*> many (typeName <* string ".")
                <*> typeName
                <*> (Maybe.withDefault []
                        <$> maybe (maybe Layout.layout *> sepBy Layout.layout typeAnnotationNoFn2)
                    )
        )


typeAnnotationNoFn2 : Parser State (Ranged TypeAnnotation)
typeAnnotationNoFn2 =
    lazy
        (\() ->
            ranged <|
                choice
                    [ parensTypeAnnotation
                    , typedTypeAnnotation2
                    , recordTypeAnnotation
                    , genericRecordTypeAnnotation
                    , genericTypeAnnotation
                    ]
        )


typedTypeAnnotation2 : Parser State TypeAnnotation
typedTypeAnnotation2 =
    lazy
        (\() ->
            succeed Typed
                <*> many (typeName <* string ".")
                <*> typeName
                <*> succeed []
        )
