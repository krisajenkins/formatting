module Formatting
    exposing
        ( Format(..)
        , (<>)
        , map
        , premap
        , print
        , html
        , s
        , string
        , int
        , float
        , any
        , wrap
        , pad
        , padLeft
        , padRight
        , dp
        , roundTo
        , uriFragment
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

@docs Format
@docs (<>)
@docs map
@docs premap
@docs print
@docs html
@docs s
@docs string
@docs int
@docs float
@docs any
@docs wrap
@docs pad
@docs padLeft
@docs padRight
@docs dp
@docs roundTo
@docs uriFragment
-}

import Html exposing (Html)
import Http
import String


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
    Format (\c -> f <| \strF -> g <| \strG -> c <| strF ++ strG)


{-| Compose two formatters together.
-}
(<>) : Format b a -> Format c b -> Format c a
(<>) =
    compose
infixr 8 <>


{-| Create a new formatter by applying a function to the output of this formatter.

For example:

    import String exposing (toUpper)

    format = s "Name: " <> map toUpper string

...produces a formatter that uppercases the name:

    print format "Kris"

    --> "Name: KRIS"

-}
map : (String -> String) -> Format r a -> Format r a
map f (Format format) =
    Format (\c -> format <| f >> c)


{-| Create a new formatter by applying a function to the input of this
formatter. The dual of `map`.

For example:

    format = s "Height: " <> premap .height float

...produces a formatter that accesses a `.height` record field:

    print format { height: 1.72 }

    --> "Height: 1.72"

-}
premap : (a -> b) -> Format r (b -> v) -> Format r (a -> v)
premap f (Format format) =
    Format (\c -> f >> format c)


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

Hint: If you're using any formatters where whitespace is sigificant,
you might well need one or both of these CSS rules:

    font-family: monospace;
    white-space: pre;
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
    Format identity


{-| A placeholder for any value that we can call `toString` on.


Eagle-eyed readers of the source will notice that we use this same
function to define `int` and `float`, since `toString` gives us the
right result for both of those types.

The sole difference is, `int` and `float` have more restrictive type
signatures.
-}
any : Format r (a -> r)
any =
    Format (\c -> c << toString)


{-| A placeholder for an `Int` argument.
-}
int : Format r (Int -> r)
int =
    any


{-| A placeholder for a `Float` argument.
-}
float : Format r (Float -> r)
float =
    any



------------------------------------------------------------
-- Convenience functions.
------------------------------------------------------------


{-| `wrap` one string with another. It's convenient for building strings
like `"Invalid key '<keyname>'."  For example:

    print (wrap "'" string) "tester"

    --> "'tester'"
-}
wrap : String -> Format r a -> Format r a
wrap wrapping =
    (s wrapping <> string <> s wrapping)
        |> print
        |> map


{-| `String.pad` lifted into the world of Formatters.

For example:

    print (pad 10 '-' string) "KRIS"

    --> "---KRIS---"

-}
pad : Int -> Char -> Format r a -> Format r a
pad n char =
    map <| String.pad n char


{-| `String.padLeft` lifted into the world of Formatters.

For example:

    print (padLeft 10 '_' float) 1.72

    --> "______1.72"

-}
padLeft : Int -> Char -> Format r a -> Format r a
padLeft n char =
    map <| String.padLeft n char


{-| `String.padRight` lifted into the world of Formatters.

For example:

    print (padRight 10 '.' int) 789

    --> "789......."

-}
padRight : Int -> Char -> Format r a -> Format r a
padRight n char =
    map <| String.padRight n char


{-| *DEPRECATED*: Use `roundTo` instead.
-}
dp : number -> Format a (Float -> a)
dp =
    roundTo


{-| A float rounded to `n` decimal places.
-}
roundTo : number -> Format a (Float -> a)
roundTo n =
    Format
        (\c v ->
            c
                (if n == 0 then
                    toString (round v)
                 else
                    let
                        exp =
                            10 ^ n

                        intPart =
                            truncate v

                        fractionalPart =
                            abs (round (v * exp)) - abs (intPart * exp)

                        finalFormat =
                            int <> s "." <> padRight n '0' int
                    in
                        print finalFormat intPart fractionalPart
                )
        )


{-| Format a URI fragment.

For example:

    print uriFragment "this string"

    --> "this%20string"
-}
uriFragment : Format r (String -> r)
uriFragment =
    premap Http.uriEncode string
