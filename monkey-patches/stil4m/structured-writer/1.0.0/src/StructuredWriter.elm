module StructuredWriter exposing (Writer, append, bracesComma, bracketsComma, breaked, epsilon, indent, join, maybe, parensComma, sepBy, sepByComma, sepBySpace, spaced, string, write)

{-| Write structured strings


# Types

@docs Writer


# Write

@docs write


# Utils

@docs append, bracesComma, bracketsComma, breaked, epsilon, indent,join, maybe, parensComma, sepBy, sepByComma, sepBySpace, spaced, string

-}


{-| Opaque type which holds the data to be writter
-}
type Writer
    = Sep ( String, String, String ) Bool (List Writer)
    | Breaked (List Writer)
    | Str String
    | Append Writer Writer
    | Indent Int Writer
    | Spaced (List Writer)
    | Joined (List Writer)


asIndent : Int -> String
asIndent =
    flip String.repeat " "


{-| Transform a writer to a string
-}
write : Writer -> String
write =
    writeIndented 0


writeIndented : Int -> Writer -> String
writeIndented indent w =
    case w of
        Sep ( pre, sep, post ) differentLines items ->
            let
                seperator =
                    if differentLines then
                        "\n" ++ asIndent indent ++ sep
                    else
                        sep
            in
            String.concat
                [ pre
                , String.join seperator
                    (List.map (identity >> writeIndented indent) items)
                , post
                ]

        Breaked items ->
            items
                |> List.concatMap (writeIndented 0 >> String.split "\n")
                |> String.join ("\n" ++ asIndent indent)

        Str s ->
            s

        Indent n next ->
            asIndent (n + indent) ++ writeIndented (n + indent) next

        Spaced items ->
            String.join " " (List.map (writeIndented indent) items)

        Joined items ->
            String.concat (List.map (writeIndented indent) items)

        Append x y ->
            writeIndented indent x ++ writeIndented indent y


{-| Add indentation of `n` spaces

    write (indent 2 (string "foo")) == "  foo"

-}
indent : Int -> Writer -> Writer
indent =
    Indent


{-| Break a few writers over different lines
-}
breaked : List Writer -> Writer
breaked =
    Breaked


{-| Write nothing
-}
epsilon : Writer
epsilon =
    Str ""


{-| Join a few writers with spaces
-}
spaced : List Writer -> Writer
spaced =
    Spaced


{-| Write a literal string
-}
string : String -> Writer
string =
    Str


{-| Write something if it is present
-}
maybe : Maybe Writer -> Writer
maybe =
    Maybe.withDefault epsilon


{-| Join writers with commans, enclosed with parens. Puts all things on a new line if the first argument is `True`.
-}
parensComma : Bool -> List Writer -> Writer
parensComma =
    Sep ( "(", ", ", ")" )


{-| Join writers with commans, enclosed with braces. Puts all things on a new line if the first argument is `True`.
-}
bracesComma : Bool -> List Writer -> Writer
bracesComma =
    Sep ( "{", ", ", "}" )


{-| Join writers with commans, enclosed with brackets. Puts all things on a new line if the first argument is `True`.
-}
bracketsComma : Bool -> List Writer -> Writer
bracketsComma =
    Sep ( "[", ", ", "]" )


{-| Join writers with commas. Puts all things on a new line if the first argument is `True`.
-}
sepByComma : Bool -> List Writer -> Writer
sepByComma =
    Sep ( "", ", ", "" )


{-| Join writers with spaces. Puts all things on a new line if the first argument is `True`.
-}
sepBySpace : Bool -> List Writer -> Writer
sepBySpace =
    Sep ( "", " ", "" )


{-| Join writers with the second value in the tuple and enclose with the first and last. Puts all things on a new line if the second argument is `True`.

    write (sepBy ("<","-",">") False [string "a", string "b"]) == "<a,b>"

-}
sepBy : ( String, String, String ) -> Bool -> List Writer -> Writer
sepBy =
    Sep


{-| Join two writers into one.
-}
append : Writer -> Writer -> Writer
append =
    Append


{-| Join a bunch of writers into one.
-}
join : List Writer -> Writer
join =
    Joined
