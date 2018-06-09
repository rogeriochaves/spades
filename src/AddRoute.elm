module AddRoute exposing (..)

import Elm.Parser as Parser
import Elm.Processing as Processing
import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.Range exposing (..)
import Elm.Syntax.Type exposing (..)
import Elm.Writer as Writer


transform : String -> Result String String
transform code =
    case Parser.parse code of
        Ok rawFile ->
            let
                file =
                    Processing.process Processing.init rawFile

                updateDeclarations ( range, declaration ) =
                    case declaration of
                        TypeDecl type_ ->
                            let
                                newRoute =
                                    [ ValueConstructor "NewRoute" [] emptyRange ]
                            in
                            if type_.name == "Page" then
                                ( range, TypeDecl { type_ | constructors = type_.constructors ++ newRoute } )
                            else
                                ( range, declaration )

                        _ ->
                            ( range, declaration )

                newFile =
                    { file | declarations = List.map updateDeclarations file.declarations }
            in
            newFile
                |> Writer.writeFile
                |> Writer.write
                |> Ok

        Err errors ->
            Err
                ("Error parsing file:\n"
                    ++ String.join "\n" errors
                )
