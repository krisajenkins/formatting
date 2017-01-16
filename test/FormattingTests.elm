module FormattingTests exposing (tests)

import Formatting exposing (..)
import Legacy.ElmTest as ElmTest exposing (..)
import String exposing (reverse, toUpper)


tests : Test
tests =
    ElmTest.suite "Formatting"
        [ basicTests
        , mapTests
        , premapTests
        , wrapTests
        , paddingTests
        , roundToTests
        , instanceTests
        ]


basicTests : Test
basicTests =
    ElmTest.suite "Basics" <|
        List.map defaultTest
            [ assertEqual "Hello Kris!"
                (print (s "Hello " <> string <> s "!") "Kris")
            , assertEqual "We need 5 cats."
                (print (s "We need " <> int <> s " cats.") 5)
            , assertEqual "Height: 1.72"
                (print (s "Height: " <> float) 1.72)
            , assertEqual "Person: { name = \"Kris\", height = 1.72 }"
                (print (s "Person: " <> any) { name = "Kris", height = 1.72 })
            ]


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
        ElmTest.suite "map" <|
            List.map check
                [ ( identity, "Hello!" )
                , ( toUpper, "HELLO!" )
                , ( reverse, "!olleH" )
                ]


premapTests : Test
premapTests =
    let
        record =
            { name = "Kris"
            , height = 1.72
            }
    in
        ElmTest.suite "premap" <|
            List.map defaultTest
                [ assertEqual "Name: Kris" (print (s "Name: " <> premap .name string) record)
                , assertEqual "Height: 1.72" (print (s "Height: " <> premap .height float) record)
                ]


wrapTests : Test
wrapTests =
    ElmTest.suite "wrap" <|
        List.map defaultTest
            [ assertEqual "This is *great*!" (print (s "This is " <> wrap "*" string <> s "!") "great")
            , assertEqual "Received '50'" (print (s "Received " <> wrap "'" int) 50)
            ]


paddingTests : Test
paddingTests =
    ElmTest.suite "padding" <|
        List.map defaultTest
            [ assertEqual "___1.72___" (print (pad 10 '_' float) 1.72)
            , assertEqual "______1.72" (print (padLeft 10 '_' float) 1.72)
            , assertEqual "1.72______" (print (padRight 10 '_' float) 1.72)
            , assertEqual "1.7234567891" (print (pad 10 '.' float) 1.7234567891)
            , assertEqual "1.7234567891" (print (padLeft 10 '.' float) 1.7234567891)
            , assertEqual "1.7234567891" (print (padRight 10 '.' float) 1.7234567891)
            ]


roundToTests : Test
roundToTests =
    let
        check ( expected, formatter, value ) =
            defaultTest <|
                assertEqual expected
                    (print formatter value)
    in
        ElmTest.suite "roundTo" <|
            List.map check
                [ ( "1235", roundTo 0, 1234.56 )
                , ( "1234.0", roundTo 1, 1234 )
                , ( "1234.00", roundTo 2, 1234.0 )
                , ( "0.00", roundTo 2, 0 )
                , ( "0", roundTo 0, 0 )
                , ( "1234.57", roundTo 2, 1234.567 )
                , ( "1234.567000", roundTo 6, 1234.567 )
                , ( "-1235", roundTo 0, -1234.56 )
                , ( "-1234.0", roundTo 1, -1234 )
                , ( "-1234.57", roundTo 2, -1234.567 )
                , ( "-1234.567000", roundTo 6, -1234.567 )
                , ( "100.0", roundTo 1, 99.99 )
                , ( "2.0", roundTo 1, 1.95 )
                , ( "5.18", roundTo 2, 5.175 )
                , ( "0.014", roundTo 3, 0.0135 )
                , ( "7.1316", roundTo 4, 7.13155 )
                , ( "0.12", roundTo 2, 0.123 )
                , ( "-0.12", roundTo 2, -0.123 )
                , ( "0.00", roundTo 2, 0 )
                , ( "0.00", roundTo 2, 0 )
                , ( "-0.46", roundTo 2, -0.46 )
                , ( "-0.99", roundTo 2, -0.99 )
                , ( "-1.46", roundTo 2, -1.46 )
                , ( "-1.00", roundTo 2, -0.999 )
                , ( "-2.46", roundTo 2, -2.46 )
                , ( "-3.00", roundTo 2, -2.999 )
                ]


instanceTests : Test
instanceTests =
    ElmTest.suite "Tests for specific uses."
        [ defaultTest <|
            assertEqual "Price:  12345.43" <|
                print (s "Price:" <> (padLeft 10 ' ' <| roundTo 2))
                    12345.4321
        ]
