module Transformers.AddComponentTypesSpec exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import TestHelpers exposing (..)
import Transformers.AddComponentTypes as AddComponentTypes
import Transformers.Helpers exposing (..)


suite : Test
suite =
    describe "AddComponentTypes"
        [ test "adds a page to the Page type" <|
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
