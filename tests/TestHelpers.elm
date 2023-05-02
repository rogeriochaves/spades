module TestHelpers exposing (applyTransformer, clearWhitespace, replaceAll)

import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.Node exposing (..)
import Regex exposing (..)
import Transformers.Helpers exposing (..)


applyTransformer : (Node Declaration -> Node Declaration) -> String -> Result String String
applyTransformer transformer string =
    stringToFile string
        |> Result.map (updateFileDeclarations transformer >> fileToString >> clearWhitespace)


clearWhitespace : String -> String
clearWhitespace =
    replaceAll "\\s+module" (\_ -> "module")
        >> replaceAll "\\s+" (\_ -> " ")
        >> replaceAll "= " (\_ -> "=")
        >> replaceAll "\\[ " (\_ -> "[")
        >> replaceAll " \\]" (\_ -> "]")
        >> replaceAll "\\{ " (\_ -> "{")
        >> replaceAll " \\}" (\_ -> "}")
        >> replaceAll " ," (\_ -> ",")
        >> replaceAll "\\| " (\_ -> "|")
        >> replaceAll " \\(\\.\\.\\)" (\_ -> "(..)")
        >> replaceAll " $" (\_ -> "")


replaceAll : String -> (Regex.Match -> String) -> String -> String
replaceAll userRegex replacer string =
    case Regex.fromString userRegex of
        Nothing ->
            string

        Just regex ->
            Regex.replace regex replacer string
