module Data.Profile exposing (Profile, decoder)

import Json.Decode exposing (Decoder, bool, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Misc exposing (optionalMaybe)


type alias Profile =
    { username : String
    , bio : String
    , image : Maybe String
    , following : Bool
    }


decoder : Decoder Profile
decoder =
    succeed Profile
        |> required "username" string
        |> required "bio" string
        |> optionalMaybe "image" string
        |> required "following" bool
