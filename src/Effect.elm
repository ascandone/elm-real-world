module Effect exposing (Effect(..), HttpRequest_, map, run)

import Browser.Dom
import Browser.Navigation
import Http exposing (Body, Header)
import Ports
import Task
import Time


type alias HttpRequest_ msg =
    { method : String
    , headers : List Header
    , url : String
    , body : Body
    , onResult : Result Http.Error String -> msg
    }


type Effect msg
    = NavReplaceUrl String
    | NavPushUrl String
    | NavLoad String
    | HttpRequest (HttpRequest_ msg)
    | PortLogError String
    | PortSerializeUser String
    | PortDeleteUser
    | Noop
    | BrowserSetViewport Float Float msg
    | TimeHere (Time.Zone -> msg)


run : Browser.Navigation.Key -> Effect msg -> Cmd msg
run key eff =
    case eff of
        TimeHere getMsg ->
            Task.perform getMsg Time.here

        NavPushUrl str ->
            Browser.Navigation.pushUrl key str

        NavLoad str ->
            Browser.Navigation.load str

        PortLogError str ->
            Ports.logError str

        PortSerializeUser str ->
            Ports.serializeUser str

        PortDeleteUser ->
            Ports.deleteUser ()

        Noop ->
            Cmd.none

        BrowserSetViewport x y msg ->
            Browser.Dom.setViewport x y
                |> Task.perform (\() -> msg)

        NavReplaceUrl s ->
            Browser.Navigation.replaceUrl key s

        HttpRequest args ->
            Http.request
                { method = args.method
                , headers = args.headers
                , url = args.url
                , body = args.body
                , expect = Http.expectString args.onResult
                , timeout = Nothing
                , tracker = Nothing
                }


map : (a -> b) -> Effect a -> Effect b
map mapper effect =
    case effect of
        TimeHere toMsg ->
            TimeHere (toMsg >> mapper)

        NavReplaceUrl s ->
            NavReplaceUrl s

        HttpRequest args ->
            HttpRequest
                { method = args.method
                , headers = args.headers
                , url = args.url
                , body = args.body
                , onResult = args.onResult >> mapper
                }

        NavPushUrl x ->
            NavPushUrl x

        NavLoad x ->
            NavLoad x

        PortLogError x ->
            PortLogError x

        PortSerializeUser x ->
            PortSerializeUser x

        PortDeleteUser ->
            PortDeleteUser

        Noop ->
            Noop

        BrowserSetViewport x y msg ->
            BrowserSetViewport x y (mapper msg)
