module Transformers.AddComponentUpdateSpec exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import TestHelpers exposing (..)
import Transformers.AddComponentUpdate as AddComponentUpdate
import Transformers.Helpers exposing (..)


suite : Test
suite =
    describe "AddComponentUpdate"
        [ test "adds the new model to the init map" <|
            \_ ->
                (fixtureFileHeaderBefore ++ fixtureInitBefore)
                    |> applyTransformer (AddComponentUpdate.addInitMap "Example")
                    |> Expect.equal (Ok <| clearWhitespace <| fixtureFileHeaderBefore ++ fixtureInitAfter)
        ]


fixtureFileHeaderBefore : String
fixtureFileHeaderBefore =
    """
module Update exposing (..)

import Browser
import Cats.Update
import Counter.Update
import Helpers.Return as Return exposing (Return, andMap, mapCmd, singleton)
import Router.Update
import Types exposing (..)
"""


fixtureFileHeaderAfter : String
fixtureFileHeaderAfter =
    """
module Update exposing (..)

import Browser
import Cats.Update
import Counter.Update
import Helpers.Return as Return exposing (Return, andMap, mapCmd, singleton)
import Router.Update
import Types exposing (..)
import Example.Update
"""


fixtureInitBefore : String
fixtureInitBefore =
    """
init _ =
    singleton Model
        |> andMapCmd MsgForRouter Router.Update.init
        |> andMapCmd MsgForCounter Counter.Update.init
"""


fixtureInitAfter : String
fixtureInitAfter =
    """
init _ =
    singleton Model
        |> andMapCmd MsgForRouter Router.Update.init
        |> andMapCmd MsgForCounter Counter.Update.init
        |> andMapCmd MsgForExample Example.Update.init
"""
