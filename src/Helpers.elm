module Helpers exposing (..)

import Elm.Parser as Parser
import Elm.Processing as Processing
import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.File exposing (..)
import Elm.Syntax.Range exposing (..)
import Elm.Syntax.Ranged exposing (..)
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
