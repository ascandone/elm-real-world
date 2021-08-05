module Effect exposing (Effect(..), HttpRequest_, map, run)

import Browser.Dom
import Browser.Navigation
import Http exposing (Body, Header)
import Ports
import Task


type alias HttpRequest_ msg =
    { method : String
    , headers : List Header
    , url : String
    , body : Body
    , onResult : Result Http.Error String -> msg
    }


type Effect msg
    = Cmd (Cmd msg)
    | NavReplaceUrl String
    | NavPushUrl String
    | NavLoad String
    | HttpRequest (HttpRequest_ msg)
    | PortLogError String
    | PortSerializeUser String
    | Noop
    | BrowserSetViewport Float Float msg


run : Browser.Navigation.Key -> Effect msg -> Cmd msg
run key eff =
    case eff of
        NavPushUrl str ->
            Browser.Navigation.pushUrl key str

        NavLoad str ->
            Browser.Navigation.load str

        PortLogError str ->
            Ports.logError str

        PortSerializeUser str ->
            Ports.serializeUser str

        Noop ->
            Cmd.none

        Cmd cmd ->
            cmd

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
map f effect =
    case effect of
        Cmd cmd ->
            Cmd (Cmd.map f cmd)

        NavReplaceUrl s ->
            NavReplaceUrl s

        HttpRequest args ->
            HttpRequest
                { method = args.method
                , headers = args.headers
                , url = args.url
                , body = args.body
                , onResult = args.onResult >> f
                }

        _ ->
            Debug.todo "effect map"
