module Formatting
    exposing
        ( Format
        , (<>)
        , map
        , contramap
        , print
        , html
        , s
        , string
        , int
        , float
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

@docs Format, (<>), map, contramap, print, html, s, string, int, float
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


{-| Create a new function by applying a function to the results of this formatter.

For example:

    import String exposing (toUpper)

    format = s "Name: " <> map toUpper string

...produces a formatter that uppercases the name:

    print format "Kris"

    --> "Name: KRIS"

-}
map : (String -> String) -> Format r a -> Format r a
map f (Format format) =
    Format (\c -> format (f >> c))


{-| Create a new function by applying a function to the input of this formatter.

For example:

    format = s "Height: " <> contramap .height float

...produces a formatter that accesses a `.height` record field:

    print format { height: 1.72 }

    --> "Height: 1.72"

-}
contramap : (a -> b) -> Format r (b -> v) -> Format r (a -> v)
contramap f (Format format) =
    Format (\c -> (f >> format c))


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
