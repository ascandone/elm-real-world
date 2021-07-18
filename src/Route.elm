module Route exposing (Route(..), parse, toHref)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, map, s, string, top)


type Route
    = Home
    | Profile String
    | Login
    | ViewArticle String
    | ViewProfile String


toHref : Route -> String
toHref route =
    case route of
        Home ->
            "#/"

        Login ->
            "#/login"

        Profile username ->
            "#/profile/" ++ username

        ViewArticle slug ->
            "#/article/" ++ slug

        ViewProfile username ->
            "#/profile/" ++ username


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ map Home top
        , map Profile <| s "profile" </> string
        , map Login <| s "login"
        ]


parse : Url -> Maybe Route
parse url =
    Parser.parse parser
        { url
            | path = Maybe.withDefault "" url.fragment
            , fragment = Nothing
        }
