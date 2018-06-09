module TestHelpers exposing (..)

import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.Ranged exposing (..)
import Helpers exposing (..)
import Regex exposing (..)


applyTransformer : (Ranged Declaration -> Ranged Declaration) -> String -> Result (List String) String
applyTransformer transformer string =
    stringToFile string
        |> Result.map (updateFileDeclarations transformer >> fileToString >> clearWhitespace)


clearWhitespace : String -> String
clearWhitespace =
    replace All (regex "\\s+module") (\_ -> "module")
        >> replace All (regex "\\s+") (\_ -> " ")
        >> replace All (regex "= ") (\_ -> "=")
        >> replace All (regex "\\[ ") (\_ -> "[")
        >> replace All (regex " \\]") (\_ -> "]")
        >> replace All (regex "\\| ") (\_ -> "|")
        >> replace All (regex " \\(\\.\\.\\)") (\_ -> "(..)")
        >> replace All (regex " $") (\_ -> "")
