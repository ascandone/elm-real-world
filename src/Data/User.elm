module Data.User exposing (User, decoder)

import Json.Decode as Dec exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Misc exposing (optionalMaybe)


type alias User =
    { email : String
    , token : String
    , username : String
    , bio : String
    , image : Maybe String
    }


decoder : Decoder User
decoder =
    Dec.field "user"
        (Dec.succeed User
            |> required "email" string
            |> required "token" string
            |> required "username" string
            |> required "bio" string
            |> optionalMaybe "image" string
        )
