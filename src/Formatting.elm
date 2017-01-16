module Formatting
    exposing
        ( Format(..)
        , (<>)
        , map
        , premap
        , toFormatter
        , apply
        , print
        , html
        , s
        , string
        , int
        , bool
        , float
        , number
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

@docs Format
@docs (<>)
@docs map
@docs premap
@docs toFormatter
@docs apply
@docs print
@docs html
@docs s
@docs string
@docs int
@docs bool
@docs float
@docs number
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


{-| A formatter. This type holds all the information we need to
create a formatting function, wrapped up in a way that makes it easy
to compose.

Build one of these up with primitives like `s`, `string` and `int`,
join them together with `<>`, and when you're done, generate the final
printing function with `print`.

## Example

    import Formatting exposing (..)

    greeting =
        s "Hello " <> string <> s "!"

    print greeting "Kris"

    --> "Hello Kris!"


## Creating Custom Formatters

Imagine you have an existing formatting rule you'd like to turn into a formatter:

``` elm
tweetSummary : Int -> String -> String
tweetSummary starCount body =
    "(" ++ toString starCount ++ ") " ++ body
```

First, wrap the type signature in brackets:

``` elm
tweetSummary : (Int -> String -> String)
```

Then change the result type to a variable. (That's where the magic
begins - the Formatting library gets control of the final result
type.):


``` elm
tweetSummary : (Int -> String -> r)
```

Now add `Format r` to the start.

``` elm
tweetSummary : Format r (Int -> String -> r)
```

All very mechanical. Now for the function body. Let's recall what it
looked like at the start:

``` elm
tweetSummary starCount body =
    "(" ++ toString starCount ++ ") " ++ body
```

Change that into an anonymous function:


``` elm
tweetSummary =
    (\starCount body ->
        "(" ++ toString starCount ++ ") " ++ body
    )
```

Now add in a `callback` function as the first argument:

``` elm
tweetSummary =
    (\callback starCount body ->
        "(" ++ toString starCount ++ ") " ++ body
    )
```

Pass your function's result to that callback (using `<|` is the easy way):

``` elm
tweetSummary =
    (\callback starCount body ->
        callback <| "(" ++ toString starCount ++ ") " ++ body
    )
```

Finally, wrap that all up in a `Format` constructor:

``` elm
tweetSummary =
    Format
        (\callback starCount body ->
            callback <| "(" ++ toString starCount ++ ") " ++ body
        )
```

And you're done. You have a composable formatting function. It's a
mechanical process that's probably a bit weird at first, but easy to
get used to.

-}
type Format r a
    = Format ((String -> r) -> a)


compose : Format b a -> Format c b -> Format c a
compose (Format f) (Format g) =
    Format (\callback -> f <| \strF -> g <| \strG -> callback <| strF ++ strG)


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
    Format (\callback -> format <| f >> callback)


{-| Create a new formatter by applying a function to the input of this
formatter. The dual of `map`.

For example:

``` elm
format = s "Height: " <> premap .height float
```

...produces a formatter that accesses a `.height` record field:

```elm
print format { height: 1.72 }

--> "Height: 1.72"
```

-}
premap : (a -> b) -> Format r (b -> v) -> Format r (a -> v)
premap f (Format format) =
    Format (\callback -> f >> format callback)


{-| Convert an ordinary 'stringifying' function into a Formatter.
-}
toFormatter : (a -> String) -> Format r (a -> r)
toFormatter f =
    Format (\callback -> f >> callback)


{-| Apply an argument to a Formatter. Useful when you want to supply
an argument, but don't yet want to convert your formatter to a plain
ol' function (with `print`).
-}
apply : Format r (a -> b -> r) -> a -> Format r (b -> r)
apply (Format f) value =
    Format (\callback -> f callback value)


{-| Turn your formatter into a function that's just waiting for its arguments.

Given this format:


``` elm
orderFormat =
    s "FREE: " <> int <> s " x " <> string  <> s "!"
```


...we can either use it immediately:


``` elm
order : String
order = print orderFormat 2 "Ice Cream"

--> "FREE: 2 x Ice Cream!"
```


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

``` css
font-family: monospace;
white-space: pre;
```
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
    toFormatter toString


{-| A placeholder for an `Int` argument.
-}
int : Format r (Int -> r)
int =
    any


{-| A placeholder for an `Bool` argument.
-}
bool : Format r (Bool -> r)
bool =
    any


{-| A placeholder for a `Float` argument.
-}
float : Format r (Float -> r)
float =
    any


{-| A placeholder for a `Number` argument.
-}
number : Format r (number -> r)
number =
    any



------------------------------------------------------------
-- Convenience functions.
------------------------------------------------------------


{-| `wrap` one string with another. It's convenient for building strings
like `"Invalid key '<keyname>'."  For example:

``` elm
print (wrap "'" string) "tester"

--> "'tester'"
```
-}
wrap : String -> Format r a -> Format r a
wrap wrapping format =
    s wrapping <> format <> s wrapping


{-| `String.pad` lifted into the world of Formatters.

For example:

``` elm
print (pad 10 '-' string) "KRIS"

--> "---KRIS---"
```
-}
pad : Int -> Char -> Format r a -> Format r a
pad n char =
    map <| String.pad n char


{-| `String.padLeft` lifted into the world of Formatters.

For example:

``` elm
print (padLeft 10 '_' float) 1.72

--> "______1.72"
```

-}
padLeft : Int -> Char -> Format r a -> Format r a
padLeft n char =
    map <| String.padLeft n char


{-| `String.padRight` lifted into the world of Formatters.

For example:

``` elm
print (padRight 10 '.' int) 789

--> "789......."
```
-}
padRight : Int -> Char -> Format r a -> Format r a
padRight n char =
    map <| String.padRight n char


{-| *DEPRECATED*: Use `roundTo` instead.
-}
dp : Int -> Format r (Float -> r)
dp =
    roundTo


{-| A float rounded to `n` decimal places.
-}
roundTo : Int -> Format r (Float -> r)
roundTo n =
    Format
        (\callback value ->
            callback <|
                if n == 0 then
                    toString (round value)
                else
                    let
                        exp =
                            10 ^ n

                        raised =
                            abs (round (value * toFloat exp))

                        sign =
                            if value < 0.0 then
                                "-"
                            else
                                ""

                        finalFormat =
                            string <> int <> s "." <> padLeft n '0' int
                    in
                        print finalFormat
                            sign
                            (raised // exp)
                            (rem raised exp)
        )


{-| Format a URI fragment.

For example:

``` elm
print uriFragment "this string"

--> "this%20string"
```
-}
uriFragment : Format r (String -> r)
uriFragment =
    premap Http.encodeUri string
