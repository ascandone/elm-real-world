module Effect exposing (Effect(..), run)

import Browser.Navigation


type Effect msg
    = S


run : Browser.Navigation.Key -> Effect msg -> Cmd msg
run _ _ =
    Cmd.none
