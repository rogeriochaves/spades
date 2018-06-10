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
    Ok code


addMsgType : String -> Ranged Declaration -> Ranged Declaration
addMsgType name =
    addNewUnionType "Msg"
        (ValueConstructor ("MsgFor" ++ name)
            [ ranged <| Typed [ name, "Types" ] "Msg" [] ]
            emptyRange
        )


addImportTypes : String -> File -> File
addImportTypes name =
    addImport
        { moduleName = [ name, "Types" ]
        , moduleAlias = Nothing
        , exposingList = Nothing
        , range = emptyRange
        }
