module Effect exposing (Effect(..), HttpRequest_, map, run)

import Browser.Navigation
import Http exposing (Body, Header)


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


run : Browser.Navigation.Key -> Effect msg -> Cmd msg
run key eff =
    case eff of
        Cmd cmd ->
            cmd

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

        _ ->
            Debug.todo "effect run"


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
