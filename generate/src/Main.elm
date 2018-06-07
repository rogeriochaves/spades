port module Main exposing (..)

import Elm.Parser as Parser
import Elm.Processing as Processing
import Elm.Syntax.Declaration exposing (..)
import Elm.Syntax.Range exposing (..)
import Elm.Syntax.Type exposing (..)
import Elm.Writer as Writer
import Html exposing (..)


type alias Flags =
    { code : String }


init : Flags -> ( (), Cmd msg )
init { code } =
    case addRoute code of
        Ok content ->
            ( (), writeFile content )

        Err err ->
            ( (), onError err )


addRoute : String -> Result String String
addRoute code =
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


main : Program Flags () msg
main =
    Html.programWithFlags
        { init = init
        , update = always <| always ( (), Cmd.none )
        , view = always <| text ""
        , subscriptions = always Sub.none
        }


port writeFile : String -> Cmd msg


port onError : String -> Cmd msg
