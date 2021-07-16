module Data.Profile exposing (Profile, decoder)

import Json.Decode exposing (Decoder, bool, string, succeed)
import Json.Decode.Pipeline exposing (required)


type alias Profile =
    { username : String
    , bio : String
    , image : String
    , following : Bool
    }


decoder : Decoder Profile
decoder =
    succeed Profile
        |> required "username" string
        |> required "bio" string
        |> required "image" string
        |> required "following" bool
