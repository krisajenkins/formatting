module Utils exposing (..)


roundTo : Int -> Float -> Float
roundTo places value =
    let
        factor =
            10 ^ places
    in
        (value
            * factor
            |> round
            |> toFloat
        )
            / factor
