module Route exposing (Route(..), parse, toHref)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, map, s, string, top)


type Route
    = Home
    | Profile String
    | Article String
    | Login
    | Register
    | NewPost
    | Editor String
    | Settings


toHref : Route -> String
toHref route =
    case route of
        Home ->
            "#/"

        Login ->
            "#/login"

        Register ->
            "#/register"

        Profile username ->
            "#/profile/" ++ username

        Article slug ->
            "#/article/" ++ slug

        NewPost ->
            "#/editor"

        Editor slug ->
            "#/editor/" ++ slug

        Settings ->
            "#/settings"


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ map Home top
        , map Profile <| s "profile" </> string
        , map Login <| s "login"
        , map Register <| s "register"
        , map Article <| s "article" </> string
        , map Profile <| s "profile" </> string
        , map NewPost <| s "editor"
        , map Editor <| s "editor" </> string
        , map Settings <| s "settings"
        ]


parse : Url -> Maybe Route
parse url =
    Parser.parse parser
        { url
            | path = Maybe.withDefault "" url.fragment
            , fragment = Nothing
        }
