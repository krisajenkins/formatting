# Elm Extensions

[![Build Status](https://travis-ci.org/krisajenkins/formatting.svg?branch=master)](https://travis-ci.org/krisajenkins/formatting)

A type-safe string formatting library. Fulfils the need for
string-interpolation or a `printf` function, without sacrificing Elm's
runtime guarantees.

## Installation

From your top-level directory - the one with `elm-package.json` in - call:

```
$ elm package install krisajenkins/formatting
```
## Documentation

[See the Elm package for full usage docs](http://package.elm-lang.org/packages/krisajenkins/formatting/latest/Formatting).


## Usage

We want to display something like `"Hello <name>!"`. It consist of:

- A boilerplate string, `"Hello "`
- A "hole" for a `String`
- Another boilerplate string, `"!"`

To create that, we'll build up a formatter using `s` for boilerplate
strings, `string` for the hole, and `<>` to join them together:

``` elm
import Formatting exposing (..)

greeting =
    s "Hello " <> string <> s "!"
```

Now we print with that formatter, and its arguments:

``` elm
print greeting "Kris"

--> "Hello Kris!"
```

Now let's try to call that formatter with bad arguments:

``` elm
print greeting 5

-- TYPE MISMATCH ---------------------------------------------
The 2nd argument to function `print` is causing a mismatch.

4|   print greeting 5
                    ^
Function `print` is expecting the 2nd argument to be:

    String

But it is:

    number
```

Woo - it's like `printf`, but it can't blow up at runtime.


## Examples

If you want to compose CSS3 transforms, it's a bit of a pain of string
interpolation. For example, to translate and rotate a div, we'd need
something like:


``` css
translate(50px, 100px) rotate3d(0, 0, 1, 60deg)
```

Filling in all those holes gets messy:


``` elm
"translate(" ++ toString x ++ "px, " ++ toString y ++ "px) rotate3d(0, 0, 1, " ++ toString r "deg)"
```

This is exactly the mess that make me want a `printf` function. Now
with `Formatting` we easily break it down into more readable,
composable pieces:

``` elm
transform =
    let
        px =
            int <> s "px"

        deg =
            float <> s "deg"

        translate =
            s "translate(" <> px <> s ", " <> px <> s ")"

        rotate =
            s "rotate3d(0, 0, 1, " <> deg <> ")"

     in
        translate <> s " " <> rotate
```

## FAQ

### Q. Can't I do something like `Hello %s!`?

A. I don't believe you can, in a type-safe way, without core language
changes. You'd need to parse the formatting string at compile time to
generate a function with the right type.

This library gives you the same utility as `printf`, but it doesn't
need any changes to the language, and it's entirely extensible - you
can make your own formatters on-the-fly.

## Building & Testing

```
make
```

...will run the whole build and test suite.

## Status

In active development. The hard part is done, but we need more utility functions.

API subject to change.

## Credits

This package is a port of [Chris Done's Formatting][formatting] library for
Haskell. When I saw Evan & Noah's [url-parser][url-parser] library, I
realised it could be ported across.

[formatting]: http://chrisdone.com/posts/formatting
[url-parser]: http://package.elm-lang.org/packages/evancz/url-parser/latest

## License

Copyright © 2016 Kris Jenkins

Distributed under the MIT license.
