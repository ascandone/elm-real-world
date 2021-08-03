module View.Posix exposing (posixToString, view)

import Html exposing (Html, text)
import Time exposing (Month(..), Posix)


monthToString : Month -> String
monthToString month =
    case month of
        Jan ->
            "January"

        Feb ->
            "February"

        Mar ->
            "March"

        Apr ->
            "April"

        May ->
            "May"

        Jun ->
            "June"

        Jul ->
            "July"

        Aug ->
            "August"

        Sep ->
            "September"

        Oct ->
            "October"

        Nov ->
            "November"

        Dec ->
            "December"


posixToString : Time.Zone -> Posix -> String
posixToString timeZone posix =
    let
        day =
            String.fromInt (Time.toDay timeZone posix)

        month =
            monthToString (Time.toMonth timeZone posix)

        year =
            String.fromInt (Time.toYear timeZone posix)
    in
    month ++ " " ++ day ++ ", " ++ year


view : Maybe Time.Zone -> Posix -> Html msg
view mTimeZone posix =
    case mTimeZone of
        Nothing ->
            text ""

        Just timeZone ->
            text (posixToString timeZone posix)
