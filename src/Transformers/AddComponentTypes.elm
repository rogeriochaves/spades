module Transformers.AddComponentTypes exposing (..)

import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.File exposing (..)
import Elm.Syntax.Range exposing (..)
import Elm.Syntax.Ranged exposing (..)
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
            Err
                ("Error parsing file:\n"
                    ++ String.join "\n" errors
                )


addImportTypes : String -> File -> File
addImportTypes name =
    addImport
        { moduleName = [ name, "Types" ]
        , moduleAlias = Nothing
        , exposingList = Nothing
        , range = emptyRange
        }


addNewModel : String -> Ranged Declaration -> Ranged Declaration
addNewModel name =
    let
        newField : RecordField
        newField =
            ( String.toLower name
            , ranged <| Typed [ name, "Types" ] "Model" []
            )
    in
    updateTypeAliasDefinition "Model"
        (addFieldToRecordDefinition newField)


addMsgType : String -> Ranged Declaration -> Ranged Declaration
addMsgType name =
    addNewUnionType "Msg"
        (ValueConstructor ("MsgFor" ++ name)
            [ ranged <| Typed [ name, "Types" ] "Msg" [] ]
            emptyRange
        )
