-- Temporary while Fresheyeball/elm-return is not migrated to 0.19


module Helpers.Respond exposing (..)

{-|

@docs Respond, append, sum, zero, comap

-}


{-| A function from a model to a Cmd.
Basically there are times where you want to
have a side effect on the world if the model
has a certain shape. `Respond` facilitates
this use case.
-}
type alias Respond msg a =
    a -> Cmd msg


{-| -}
append : Respond msg a -> Respond msg a -> Respond msg a
append f g a =
    Cmd.batch [ f a, g a ]


{-| -}
sum : List (Respond msg a) -> Respond msg a
sum rs a =
    List.map (\r -> r a) rs
        |> Cmd.batch


{-| -}
zero : Respond msg a
zero =
    always Cmd.none


{-| Add a function to the front
`b -> a >> a -> Cmd msg`
-}
comap : (b -> a) -> Respond msg a -> Respond msg b
comap =
    (>>)
