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

## Usage

We want to display something like `"Hello <name>!"`. That consists of
a boilerplate string, `"Hello "`, a "hole" for a `String`,
and another boilerplate string, `"!"`.

To create that, we'll build up a formatter using `s` for boilerplate
strings, and `string` for the hole:

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

## Documentation

[See the Elm package for full usage docs](http://package.elm-lang.org/packages/krisajenkins/formatting/latest/Formatting).

## Status

In active development. API subject to change.

## Building & Testing

```
make
```

...will run the whole build and test suite.

## License

Copyright © 2016 Kris Jenkins

Distributed under the MIT license.
