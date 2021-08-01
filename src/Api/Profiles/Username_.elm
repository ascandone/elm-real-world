module Api.Profiles.Username_ exposing (get)

import Api.Internal
import Data.Profile as Profile exposing (Profile)


get : String -> Api.Internal.Request Profile
get username =
    Api.Internal.get Profile.decoderSingle [ "profiles", username ]
