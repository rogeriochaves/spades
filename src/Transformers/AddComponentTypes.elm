module Transformers.AddComponentTypes exposing (addImportTypes, addMsgType, addNewModel, transform)

import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.File exposing (..)
import Elm.Syntax.Node exposing (..)
import Elm.Syntax.Range exposing (..)
import Elm.Syntax.Type exposing (..)
import Elm.Syntax.TypeAnnotation exposing (..)
import Transformers.Helpers exposing (..)


transform : String -> String -> Result String String
transform name code =
    case stringToFile code of
        Ok file ->
            file
                |> addImportTypes name
                |> updateFileDeclarations (addNewModel name)
                |> updateFileDeclarations (addMsgType name)
                |> fileToString
                |> Ok

        Err errors ->
            Err ("Error parsing file:\n" ++ errors)


addImportTypes : String -> File -> File
addImportTypes name =
    addImport
        { moduleName = ranged [ name, "Types" ]
        , moduleAlias = Nothing
        , exposingList = Nothing
        }


addNewModel : String -> Node Declaration -> Node Declaration
addNewModel name =
    let
        newField : RecordField
        newField =
            ( ranged <| String.toLower name
            , namespaced [ name, "Types" ] "Model" []
            )
    in
    updateTypeAliasDefinition "Model"
        (addFieldToRecordDefinition newField)


addMsgType : String -> Node Declaration -> Node Declaration
addMsgType name =
    addNewUnionType "Msg"
        (ValueConstructor
            (ranged <| "MsgFor" ++ name)
            [ namespaced [ name, "Types" ] "Msg" [] ]
        )
