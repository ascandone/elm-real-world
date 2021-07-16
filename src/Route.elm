module Route exposing (Route(..), parse, toHref)

import Url exposing (Url)
import Url.Parser as Parser exposing (Parser, map, string, top)


type Route
    = Home
    | Profile String


toHref : Route -> String
toHref route =
    case route of
        Home ->
            "/"

        Profile username ->
            "/profile/" ++ username


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ map Home top
        , map Profile string
        ]


parse : Url -> Maybe Route
parse url =
    Parser.parse parser
        { url
            | path = Maybe.withDefault "" url.fragment
            , fragment = Nothing
        }
