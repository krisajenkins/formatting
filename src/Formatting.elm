module Formatting
    exposing
        ( Format
        , s
        , string
        , int
        , float
        , (<>)
        , print
        , html
        )

{-| A type-safe string formatting library. It fulfils the need for
string-interpolation or a `printf` function, without sacrificing Elm's
runtime guarantees or requiring any language-level changes. It also
composes well, to make building up complex formatters easy.

Example:

    import Formatting exposing (..)

    greeting =
        s "Hello " <> string <> s "!"

    print greeting "Kris"

    --> "Hello Kris!"

@docs Format, (<>), print, html, s, string, int, float
-}

import Html exposing (Html)


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

Given this format:


    orderFormat =
        s "FREE: " <> int <> s " x " <> string  <> s "!"


...we can either use it immediately:


    order : String
    order = print orderFormat 2 "Ice Cream"

    --> "FREE: 2 x Ice Cream!"


...or turn it into an ordinary function to be used later:


    orderFormatter : Int -> String -> String
    orderFormatter =
        print orderFormat


    ...elsewhere...


    order : String
    order = orderFormatter 2 "Ice Cream"

    --> "FREE: 2 x Ice Cream!"
-}
print : Format String a -> a
print (Format format) =
    format identity


{-| Convenience function. Like `print`, but returns an `Html.text`
node as its final result, instead of a `String`.
-}
html : Format (Html msg) a -> a
html (Format format) =
    format Html.text



------------------------------------------------------------
-- The standard formatters.
------------------------------------------------------------


{-| A boilerplate string.
-}
s : String -> Format r r
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


{-| A placeholder for a `Float` argument.
-}
float : Format r (Float -> r)
float =
    Format (\c -> (\n -> c (toString n)))
