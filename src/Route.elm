module Route exposing (Route(..), parse, toHref)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, map, s, string, top)


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
        , map Profile <| s "profile" </> string
        ]


parse : Url -> Maybe Route
parse url =
    Parser.parse parser
        { url
            | path = Maybe.withDefault "" url.fragment
            , fragment = Nothing
        }
