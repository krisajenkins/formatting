module FormattingTests exposing (tests)

import ElmTest exposing (..)
import Formatting exposing (..)
import String exposing (reverse, toUpper)


tests : Test
tests =
    ElmTest.suite "State"
        [ basicTests
        , mapTests
        , contramapTests
        ]


basicTests : Test
basicTests =
    [ assertEqual "Hello Kris!" (print (s "Hello " <> string <> s "!") "Kris")
    , assertEqual "We need 5 cats." (print (s "We need " <> int <> s " cats.") 5)
    , assertEqual "Height: 1.72" (print (s "Height: " <> float) 1.72)
    ]
        |> List.map defaultTest
        |> ElmTest.suite "Basics"


mapTests : Test
mapTests =
    let
        format =
            string <> s "!"

        check ( f, expected ) =
            defaultTest
                (assertEqual expected
                    (print (map f format) "Hello")
                )
    in
        [ ( identity, "Hello!" )
        , ( toUpper, "HELLO!" )
        , ( reverse, "!olleH" )
        ]
            |> List.map check
            |> ElmTest.suite "map"


contramapTests : Test
contramapTests =
    let
        record =
            { name = "Kris"
            , height = 1.72
            }
    in
        [ assertEqual "Name: Kris" (print (s "Name: " <> contramap .name string) record)
        , assertEqual "Height: 1.72" (print (s "Height: " <> contramap .height float) record)
        ]
            |> List.map defaultTest
            |> ElmTest.suite "contramap"
