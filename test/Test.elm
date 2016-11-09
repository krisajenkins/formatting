module Test exposing (main)

{-| The main entry point for the tests.

@docs main
-}

import FormattingTests
import Legacy.ElmTest exposing (..)


tests : Test
tests =
    suite "All"
        [ FormattingTests.tests ]


{-| Run the test suite under node.
-}
main : Program Never () msg
main =
    runSuite tests
