port module Ports exposing (..)


port logError : String -> Cmd msg


port serializeUser : String -> Cmd msg


port deleteUser : () -> Cmd msg


port storageEvent : (Maybe String -> msg) -> Sub msg
