module Data.Profile exposing (Profile, decoder)

import Json.Decode exposing (Decoder, bool, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Misc exposing (optionalMaybe)


type alias Profile =
    { username : String
    , bio : Maybe String
    , image : Maybe String
    , following : Bool
    }


decoder : Decoder Profile
decoder =
    succeed Profile
        |> required "username" string
        |> optionalMaybe "bio" string
        |> optionalMaybe "image" string
        |> required "following" bool
