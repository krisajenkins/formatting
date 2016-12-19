# Formatting

[![Build Status](https://travis-ci.org/krisajenkins/formatting.svg?branch=master)](https://travis-ci.org/krisajenkins/formatting)

A type-safe string formatting library. It fulfils the need for
string-interpolation or a `printf` function, without sacrificing Elm's
runtime guarantees or requiring any language-level changes. It also
composes well, to make building up complex formatters easy.

## Installation

From your top-level directory - the one with `elm-package.json` in - call:

```
$ elm package install krisajenkins/formatting
```
## Documentation

[See the Elm package for full documentation](http://package.elm-lang.org/packages/krisajenkins/formatting/latest/Formatting).


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

This is exactly the mess that makes me want a `printf` function.  With
`Formatting` we can break it down into more readable,
easily-composable pieces:

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

Actually, this is better than `printf` - you can just compose small
pieces together freely. Elm will keep track of which arguments you
need in which order, and infer the final type of `transform` automatically.

## FAQ

### Q. Can't I do something like `"Hello %s!"`?

A. I don't believe you can, in a type-safe way, without core language
changes. You'd need to parse the formatting string at compile time to
generate a function with the right type. That either needs built-in
language support, or a macro system.

And even when you've done all that work - or waited for the Elm team
to do it - you end up with something that's hard to compose and hard
to extend.

This library gives you the same utility as `printf`, but it doesn't
need any changes to the language, it's freely composable, and it's
entirely extensible - you can make your own formatters on-the-fly.

## Building & Testing

```
make
```

...will run the whole build and test suite.

## Status

In active development. The hard part is done, but we need more utility
functions like string width and alignment helpers.

API subject to change.

## Credits

This package is a port of [Chris Done's Formatting][formatting] library for
Haskell. When I saw Evan & Noah's [url-parser][url-parser] library, I
realised it could be ported across.

Thanks to [Glen Mailer][glenjamin] for suggesting the function
name `premap`.

Thanks to [Folkert de Vries][folkertdev] for splitting the tests out of the main
published package.

Thanks to [Ian Mackenzie][ianmackenzie] for `roundTo` bugfixes.

[formatting]: http://chrisdone.com/posts/formatting
[url-parser]: http://package.elm-lang.org/packages/evancz/url-parser/latest
[glenjamin]: https://github.com/glenjamin
[folkertdev]: https://github.com/folkertdev
[ianmackenzie]: https://github.com/ianmackenzie

## License

Copyright © 2016 Kris Jenkins

Distributed under the MIT license.
