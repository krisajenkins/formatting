module Formatting
    exposing
        ( Format
        , s
        , string
        , int
        , float
        , (<>)
        , print
        )

{-| A type-safe string formatting library. Fulfils the need for
string-interpolation or a `printf` function, without sacrificing Elm's
runtime guarantees.

@docs Format, (<>), print, s, string, int, float
-}

------------------------------------------------------------
-- The core.
------------------------------------------------------------


{-| A string formatter. This type holds all the information we need to
create a formatting function, wrapped up in a way that makes it easy
to compose.

Build one of these up with primitives like `s`, `string` and `int`,
join them together with `<>`, and when you're done, generate the final
printing function with `print`.
-}
type Format r a
    = Format ((String -> r) -> a)


compose : Format b a -> Format c b -> Format c a
compose (Format f) (Format g) =
    Format
        (\c ->
            f
                (\strF ->
                    g (\strG -> c (strF ++ strG))
                )
        )


{-| Compose two formatters together.
-}
(<>) : Format b a -> Format c b -> Format c a
(<>) =
    compose
infixr 8 <>


{-| Turn your formatter into a function that's just waiting for its arguments.

For example:

    order =
        let
            format = s "FREE: " <> int <> s " x " <> string  <> s "!"
        in
            print format 2 "Ice Cream"

    --> "FREE: 2 x Ice Cream!"
-}
print : Format String a -> a
print (Format format) =
    format identity



------------------------------------------------------------
-- The standard formatters.
------------------------------------------------------------


{-| A boilerplate string.
-}
s : String -> Format a a
s str =
    Format (\c -> c str)


{-| A placeholder for a `String` argument.
-}
string : Format r (String -> r)
string =
    Format (\c -> (\str -> c str))


{-| A placeholder for an `Int` argument.
-}
int : Format r (Int -> r)
int =
    Format (\c -> (\n -> c (toString n)))


{-| A placeholder for an `Float` argument.
-}
float : Format r (Float -> r)
float =
    Format (\c -> (\n -> c (toString n)))
