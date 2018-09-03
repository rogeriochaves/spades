module Transformers.AddComponentTypesSpec exposing (fixtureFileHeaderAfter, fixtureFileHeaderBefore, fixtureModelAfter, fixtureModelBefore, fixtureMsgsAfter, fixtureMsgsBefore, suite)

import Expect exposing (Expectation)
import Test exposing (..)
import TestHelpers exposing (..)
import Transformers.AddComponentTypes as AddComponentTypes
import Transformers.Helpers exposing (..)


suite : Test
suite =
    describe "AddComponentTypes"
        [ test "adds a new type to the Msg type" <|
            \_ ->
                (fixtureFileHeaderBefore ++ fixtureMsgsBefore)
                    |> applyTransformer (AddComponentTypes.addMsgType "Example")
                    |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeaderBefore ++ fixtureMsgsAfter)
        , test "adds an import to the new types" <|
            \_ ->
                fixtureFileHeaderBefore
                    |> stringToFile
                    |> Result.map (AddComponentTypes.addImportTypes "Example" >> fileToString >> clearWhitespace)
                    |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeaderAfter)
        , test "adds a new attribute to the model" <|
            \_ ->
                (fixtureFileHeaderBefore ++ fixtureModelBefore)
                    |> applyTransformer (AddComponentTypes.addNewModel "Example")
                    |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeaderBefore ++ fixtureModelAfter)
        , test "transforms the whole file" <|
            \() ->
                let
                    fullFileBefore =
                        fixtureFileHeaderBefore ++ fixtureMsgsBefore ++ fixtureModelBefore

                    fullFileAfter =
                        fixtureFileHeaderAfter ++ fixtureMsgsAfter ++ fixtureModelAfter
                in
                fullFileBefore
                    |> AddComponentTypes.transform "Example"
                    |> Result.map clearWhitespace
                    |> Expect.equal (Ok <| clearWhitespace fullFileAfter)
        ]


fixtureFileHeaderBefore : String
fixtureFileHeaderBefore =
    """
module Types exposing (..)

import Cats.Types
import Counter.Types
import Router.Types
"""


fixtureFileHeaderAfter : String
fixtureFileHeaderAfter =
    """
module Types exposing (..)

import Cats.Types
import Counter.Types
import Router.Types
import Example.Types
"""


fixtureMsgsBefore : String
fixtureMsgsBefore =
    """
type Msg
    = MsgForRouter Router.Types.Msg
    | MsgForCats Cats.Types.Msg
    | MsgForCounter Counter.Types.Msg
"""


fixtureMsgsAfter : String
fixtureMsgsAfter =
    """
type Msg
    = MsgForRouter Router.Types.Msg
    | MsgForCats Cats.Types.Msg
    | MsgForCounter Counter.Types.Msg
    | MsgForExample Example.Types.Msg
"""


fixtureModelBefore : String
fixtureModelBefore =
    """
type alias Model =
    { router : Router.Types.Model
    , cats : Cats.Types.Model
    , counter : Counter.Types.Model
    }
"""


fixtureModelAfter : String
fixtureModelAfter =
    """
type alias Model =
    { router : Router.Types.Model
    , cats : Cats.Types.Model
    , counter : Counter.Types.Model
    , example : Example.Types.Model
    }
"""
