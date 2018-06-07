module Update exposing (..)

import Cats.Update
import Counter.Update
import Helpers.Return as Return exposing (Return, andMap, mapCmd, singleton)
import Types exposing (..)


init : () -> Return Msg Model
init _ =
    singleton Model
        |> andMapCmd MsgForCats Cats.Update.init
        |> andMapCmd MsgForCounter Counter.Update.init


update : Msg -> Model -> Return Msg Model
update msg model =
    singleton Model
        |> andMapCmd MsgForCats (Cats.Update.update msg model.cats)
        |> andMapCmd MsgForCounter (Counter.Update.update msg model.counter)


andMapCmd : (msg1 -> msg2) -> Return msg1 model1 -> Return msg2 (model1 -> model2) -> Return msg2 model2
andMapCmd msg =
    andMap << mapCmd msg
